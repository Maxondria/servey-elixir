defmodule Servey.ServicesSupervisor do
  use Supervisor

  def start_link(_arg) do
    IO.puts("Starting the services supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    # 60 is the arg that will be sent to the sensor server, we can do anything with it.
    children = [Servey.PledgeServer, {Servey.SensorServer, 60}]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
