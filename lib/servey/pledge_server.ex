defmodule Servey.PledgeServer do
  @process_id :pledge_server_process_id

  use GenServer

  defmodule State do
    defstruct cache_size: 3, pledges: []
  end

  # Client Interface functions
  def start() do
    IO.puts("Starting the pledge server...")
    GenServer.start(__MODULE__, %State{}, name: @process_id)
  end

  def create_pledge(name, amount) do
    GenServer.call(@process_id, {:create_pledge, name, amount})
  end

  def recent_pledges do
    GenServer.call(@process_id, :recent_pledges)
  end

  def total_pledged do
    GenServer.call(@process_id, :total_pledged)
  end

  def set_cache_size(size) do
    GenServer.cast(@process_id, {:set_cache_size, size})
  end

  def clear do
    GenServer.cast(@process_id, :clear_cache)
  end

  # Server callbacks

  # callback will be called on starting the GenServer
  def init(%State{} = state) do
    # Init will automatically receive the initial state, we can then update it and return what's updated
    # Ideally, in our case, fetch the latest pledges from the external API and
    # fill our initial state
    recent_pledges_on_server = fetch_recent_pledges_from_service()
    {:ok, %{state | pledges: recent_pledges_on_server}}
  end

  # callback to handle send and await messages
  def handle_call(:total_pledged, _from, %State{pledges: pledges} = state) do
    total =
      Enum.reduce(pledges, 0, fn {_name, pledge}, acc ->
        acc + pledge
      end)

    {:reply, total, state}
  end

  def handle_call(:recent_pledges, _from, %State{pledges: pledges} = state) do
    {:reply, pledges, state}
  end

  def handle_call(
        {:create_pledge, name, amount},
        _from,
        %State{pledges: pledges, cache_size: cache_size} = state
      ) do
    {:ok, id} = send_pledge_to_service(name, amount)
    most_recent_pledges = Enum.take(pledges, cache_size - 1)
    new_pledges = [{name, amount} | most_recent_pledges]
    {:reply, id, %{state | pledges: new_pledges}}
  end

  # callback to handle messages that don't need a reply
  def handle_cast({:set_cache_size, size}, %State{pledges: pledges} = state) do
    resized_cache = Enum.take(pledges, size)
    {:noreply, %{state | cache_size: size, pledges: resized_cache}}
  end

  def handle_cast(:clear_cache, %State{} = state) do
    {:noreply, %{state | pledges: []}}
  end

  # callback to handle unexpected messages + has more uses
  def handle_info(message, %State{} = state) do
    IO.puts("Can't touch this! #{inspect(message)}")
    {:noreply, state}
  end

  # External services
  defp send_pledge_to_service(_name, _amount) do
    # CODE TO SEND PLEDGE TO EXTERNAL SERVICE
    {:ok, "pledge-#{:rand.uniform(1000)}"}
  end

  defp fetch_recent_pledges_from_service do
    # CODE GOES HERE TO FETCH RECENT PLEDGES FROM EXTERNAL SERVICE

    # Example response
    [{"wilma", 15}, {"fred", 25}]
  end
end

# alias Servey.PledgeServer

# {:ok, _pid} = PledgeServer.start()
# IO.inspect(PledgeServer.recent_pledges())
# IO.inspect(PledgeServer.create_pledge("larry", 10))
# # IO.inspect(PledgeServer.set_cache_size(5))
# IO.inspect(PledgeServer.create_pledge("moe", 20))
# IO.inspect(PledgeServer.create_pledge("curly", 30))
# IO.inspect(PledgeServer.create_pledge("daisy", 40))
# IO.inspect(PledgeServer.create_pledge("grace", 50))

# IO.inspect(PledgeServer.recent_pledges())

# IO.inspect(PledgeServer.total_pledged())
