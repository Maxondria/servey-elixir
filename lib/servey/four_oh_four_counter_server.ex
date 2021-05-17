defmodule Servey.FourOhFourCounter do
  @process_id :four_oh_four_counter_process_id

  use GenServer

  # Client Interface functions
  def start() do
    IO.puts("Starting the FourOhFourCounter server...")
    GenServer.start(__MODULE__, [], name: @process_id)
  end

  def bump_count(path) do
    GenServer.call(@process_id, {:bump_count, path})
  end

  def get_count(path) do
    GenServer.call(@process_id, {:get_count, path})
  end

  def get_counts do
    GenServer.call(@process_id, :get_counts)
  end

  # Server callbacks

  def init(state) do
    {:ok, state}
  end

  def handle_call({:bump_count, path}, state) do
    bumped_state = Map.update(state, path, 1, &(&1 + 1))
    {:reply, :ok, bumped_state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)
    {:reply, count, state}
  end

  def handle_call(:get_counts, state) do
    {:reply, state, state}
  end

  def handle_cast(:clear, _state), do: {:noreply, []}

  # callback to handle unexpected messages + has more uses
  def handle_info(message, state) do
    IO.puts("Can't touch this! #{inspect(message)}")
    {:noreply, state}
  end
end
