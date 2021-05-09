defmodule Servey.FourOhFourCounter do
  @process_id :four_oh_four_counter_process_id
  # Client interface
  def start(initial_state \\ %{}) do
    IO.puts("Starting the 404 counter...")

    pid = spawn(__MODULE__, :listen_loop, [initial_state])
    Process.register(pid, @process_id)
    pid
  end

  def bump_count(path) do
    send(@process_id, {self(), :bump_count, path})

    receive do
      {:response, status} -> status
    end
  end

  def get_count(path) do
    send(@process_id, {self(), :get_count, path})

    receive do
      {:response, count} -> count
    end
  end

  def get_counts do
    send(@process_id, {self(), :get_counts})

    receive do
      {:response, counts} -> counts
    end
  end

  # Server
  def listen_loop(state) do
    receive do
      {sender_pid, :bump_count, path} ->
        bumped_state = Map.update(state, path, 1, &(&1 + 1))
        send(sender_pid, {:response, :ok})
        listen_loop(bumped_state)

      {sender_pid, :get_count, path} ->
        send(sender_pid, {:response, Map.get(state, path, 0)})
        listen_loop(state)

      {sender_pid, :get_counts} ->
        send(sender_pid, {:response, state})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message received: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end
end
