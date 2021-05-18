defmodule Servey.Supervisor do
  use Supervisor

  def start_link do
    IO.puts("Starting the OTP Supervisor...")
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [Servey.ServicesSupervisor, Servey.KickStarter]
    Supervisor.init(children, strategy: :one_for_one)
  end
end
