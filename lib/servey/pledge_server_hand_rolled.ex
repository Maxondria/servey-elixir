defmodule Servey.PledgeServerHandRolled.GenericServer do
  def start(callback_module, initial_state \\ [], process_id) do
    # __MODULE__ is a macro that keeps reference to the current module
    pid = spawn(__MODULE__, :listen_loop, [initial_state, callback_module])
    # Register this PID to be used throughout the module
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
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state, callback_module)
    end
  end
end

defmodule Servey.PledgeServerHandRolled do
  @process_id :pledge_server_hand_rolled_process_id

  alias Servey.PledgeServerHandRolled.GenericServer

  # Client Interface functions
  def start() do
    IO.puts("Starting the pledge server...")
    GenericServer.start(__MODULE__, [], @process_id)
  end

  def create_pledge(name, amount) do
    GenericServer.call(@process_id, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenericServer.call(@process_id, :recent_pledges)
  end

  def total_pledged do
    GenericServer.call(@process_id, :total_pledged)
  end

  def clear do
    GenericServer.cast(@process_id, :clear_cache)
  end

  # Server callbacks

  def handle_call(:total_pledged, state) do
    total =
      Enum.reduce(state, 0, fn {_name, pledge}, acc ->
        acc + pledge
      end)

    {total, state}
  end

  def handle_call(:recent_pledges, state), do: {state, state}

  def handle_call({:create_pledge, name, amount}, state) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(state, 2)
    new_state = [{name, amount} | most_recent_pledges]
    {id, new_state}
  end

  def handle_cast(:clear_cache, _state), do: []

  defp send_pledge_to_service(_name, _amount) do
    # CODE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end
