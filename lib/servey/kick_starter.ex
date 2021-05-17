defmodule Servey.KickStarter do
  use GenServer

  def start do
    IO.puts("Starting the kickstarter...")
    GenServer.start(__MODULE__, :ok, name: __MODULE__)
  end

  # Remember all functions running in this process are in the module process
  # which technically runs the init function below too.
  # We shall refer to this as the kick_starter_pid.

  # Calling Servey.KickStarter.start() returns the kick_starter_pid.
  # This way we have access to the server_pid via :http_server_process, and kick_starter_pid

  def init(:ok) do
    # whatever is returned from here is used by the gen server, and doesn't necessarily indicate the return of start() above
    # So, this is a different process [server_pid], which is then held in state of the genserver

    # Exit signals to the 'server pid' won't affect the kick_starter process even though we link them below.
    Process.flag(:trap_exit, true)

    server_pid = start_server()
    {:ok, server_pid}
  end

  # Whenever kick_starter process catches ':trap_exits', it will throw the message which we ignore and
  # start new processes
  def handle_info({:EXIT, _pid, reason}, _state) do
    IO.puts("HTTP Server exited: (#{inspect(reason)})")
    # Restart the server in a new process
    server_pid = start_server()
    {:noreply, server_pid}
  end

  defp start_server do
    IO.puts("Starting the HTTP server...")

    # Spawns the given function, links it to the current process, and returns its PID.
    # The current process in this context is the kick_starter_pid since it is one that starts 'start' function
    # above.

    # The reason we link them is because we want to listen to any exit messages
    # to the child process [server process], and trap it so we can use it in the
    # handle_info function above to restart the server
    server_pid = spawn_link(Servey.HttpServer, :start, [4000])

    # We simply register this pid globally on the module. This now gives us access to the current server_pid
    # anywhere we want.
    Process.register(server_pid, :http_server_process)
    # return the pid so it can be returned as new gen_server state.
    server_pid
  end
end
