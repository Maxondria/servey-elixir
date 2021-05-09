defmodule Servey.PledgeServer do
  @process_id :pledge_server_process_id

  # Client Interface functions
  def start(initial_state \\ []) do
    IO.puts("Starting the pledge server...")
    # __MODULE__ is a macro that keeps reference to the current module
    pid = spawn(__MODULE__, :listen_loop, [initial_state])
    # Register this PID to be used throughout the module
    Process.register(pid, @process_id)
    pid
  end

  def create_pledge(name, amount) do
    send(@process_id, {self(), :create_pledge, name, amount})

    receive do
      {:response, id} -> id
    end
  end

  def recent_pledges do
    send(@process_id, {self(), :recent_pledges})

    receive do
      {:response, pledges} -> pledges
    end
  end

  def total_pledged do
    send(@process_id, {self(), :total_pledged})

    receive do
      {:response, total} -> total
    end
  end

  # Server
  def listen_loop(state) do
    receive do
      {sender_pid, :create_pledge, name, amount} ->
        {:ok, id} = send_pledge_to_service(name, amount)
        most_recent_pledges = Enum.take(state, 2)
        new_state = [{name, amount} | most_recent_pledges]

        send(sender_pid, {:response, id})

        listen_loop(new_state)

      {sender_pid, :recent_pledges} ->
        send(sender_pid, {:response, state})
        listen_loop(state)

      {sender_pid, :total_pledged} ->
        total =
          Enum.reduce(state, 0, fn {_name, pledge}, acc ->
            acc + pledge
          end)

        send(sender_pid, {:response, total})
        listen_loop(state)

      unexpected ->
        IO.puts("Unexpected message: #{inspect(unexpected)}")
        listen_loop(state)
    end
  end

  defp send_pledge_to_service(_name, _amount) do
    # CODE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end
end

# alias Servey.PledgeServer

# PledgeServer.start()

# IO.inspect(PledgeServer.create_pledge("larry", 10))
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))
# IO.inspect(PledgeServer.create_pledge("grace", 50))

# IO.inspect(PledgeServer.recent_pledges())

# IO.inspect(PledgeServer.total_pledged())
