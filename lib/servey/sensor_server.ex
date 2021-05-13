defmodule Servey.SensorServer do
  @process_id :sensor_server_process_id

  use GenServer

  defmodule State do
    defstruct sensor_data: %{},
              refresh_interval: :timer.minutes(60)
  end

  # Client Interface

  def start do
    GenServer.start(__MODULE__, %State{}, name: @process_id)
  end

  def get_sensor_data do
    GenServer.call(@process_id, :get_sensor_data)
  end

  def set_refresh_interval(interval) do
    GenServer.call(@process_id, {:set_refresh_interval, interval})
  end

  # Server Callbacks

  def init(%State{refresh_interval: refresh_interval} = state) do
    initial_state = run_tasks_to_get_sensor_data()
    # schedule a message to be sent to the gen server process in a specified time
    schedule_refresh(refresh_interval)
    {:ok, %{state | sensor_data: initial_state}}
  end

  def handle_call(:get_sensor_data, _from, %State{sensor_data: sensor_data} = state) do
    {:reply, sensor_data, state}
  end

  def handle_cast({:set_refresh_interval, interval}, %State{} = state) do
    {:noreply, %{state | refresh_interval: interval}}
  end

  def handle_info(:refresh, %State{refresh_interval: refresh_interval} = state) do
    IO.puts("Refreshing the cache...")
    new_state = run_tasks_to_get_sensor_data()
    schedule_refresh(refresh_interval)
    {:noreply, %{state | sensor_data: new_state}}
  end

  def handle_info(unexpected, state) do
    IO.puts("Can't touch this! #{inspect(unexpected)}")
    {:noreply, state}
  end

  defp schedule_refresh(refresh_interval) do
    # schedule a message to be sent to the gen server process in a specified time
    Process.send_after(self(), :refresh, refresh_interval)
  end

  defp run_tasks_to_get_sensor_data do
    IO.puts("Running tasks to get sensor data...")

    task = Task.async(fn -> Servey.Tracker.get_location("bigfoot") end)

    snapshots =
      ["cam-1", "cam-2", "cam-3"]
      |> Enum.map(&Task.async(fn -> Servey.VideoCam.get_snapshot(&1) end))
      |> Enum.map(&Task.await/1)

    where_is_bigfoot = Task.await(task)

    # task = Task.async(Tracker, :get_location, ["bigfoot"])

    # Task.await by default waits for 5000(5s) before timing out.
    # If there is need to wait for the task even more, we can
    # add a different argument as timeout. Task.await(task, 7000).
    # or Task.await(task, :infinity)

    # Another alternative to 'await' is 'yield', we can keep checking on the task,
    #
    #     iex> task = Task.async(fn -> :timer.sleep(8000); "Done!" end)
    #     iex> Task.yield(task, 5000)
    #     nil
    #     iex> Task.yield(task, 5000)
    #     {:ok, "Done!"}

    # In this case, calling yield for the first time, it waits for 5 seconds if the task hasn't finished,
    # 'nil' is returned.
    # Else, it will return the result in a tuple. {:ok, "Done!"}

    # Consider the example below, this can be looked at as a manual implementation of await.
    # But allows for cleaner handling of errors from timeouts.

    #   case Task.yield(task, 5000)
    #       {:ok, result} ->
    #         result
    #       nil ->
    #         Logger.warn "Timed out!"
    #         Task.shutdown(task)
    #   end

    # In the example above, if a message doesn't arrive within the 5 second cut-off then we shut down the task by calling Task.shutdown.
    # If a message arrives while shutting down the task, then Task.shutdown returns {:ok, result}. Otherwise it returns nil.

    %{snapshots: snapshots, location: where_is_bigfoot}
  end
end
