defmodule Servey.FourOhFourCounter.GenericServer do
  def start(callback_module, initial_state \\ [], process_id) do
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    Process.register(pid, process_id)
    pid
  end

  def call(pid, message) do
    send(pid, {:call, self(), message})

    receive do
      {:response, response} -> response
    end
  end

  def cast(pid, message) do
    send(pid, {:cast, message})
  end

  def listen_loop(state, callback_module) do
    receive do
      {:call, sender_pid, message} when is_pid(sender_pid) ->
        {response, new_state} = callback_module.handle_call(message, state)
        send(sender_pid, {:response, response})
        listen_loop(new_state, callback_module)

      {:cast, message} ->
        new_state = callback_module.handle_cast(message, state)
        listen_loop(new_state, callback_module)

      unexpected ->
        IO.puts("Unexpected message received: #{inspect(unexpected)}")
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servey.FourOhFourCounter do
  @process_id :four_oh_four_counter_process_id

  alias Servey.FourOhFourCounter.GenericServer
  # Client interface
  def start() do
    IO.puts("Starting the 404 counter...")

    GenericServer.start(__MODULE__, [], @process_id)
  end

  def bump_count(path) do
    GenericServer.call(@process_id, {:bump_count, path})
  end

  def get_count(path) do
    GenericServer.call(@process_id, {:get_count, path})
  end

  def get_counts do
    GenericServer.call(@process_id, :get_counts)
  end

  # Server callbacks

  def handle_call({:bump_count, path}, state) do
    bumped_state = Map.update(state, path, 1, &(&1 + 1))
    {:ok, bumped_state}
  end

  def handle_call({:get_count, path}, state) do
    count = Map.get(state, path, 0)
    {count, state}
  end

  def handle_call(:get_counts, state) do
    {state, state}
  end

  def handle_cast(:clear, _state), do: []
end
