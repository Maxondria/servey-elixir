defmodule Servey.PledgeController do
  alias Servey.Conv
  alias Servey.PledgeServer

  def create(%Conv{params: %{"name" => name, "amount" => amount}} = conv) do
    # Sends the pledge to the external service and caches it
    PledgeServer.create_pledge(name, String.to_integer(amount))

    %{conv | status: 201, resp_body: "#{name} pledged #{amount}!"}
  end

  def index(%Conv{} = conv) do
    # Gets the recent pledges from the cache
    pledges = PledgeServer.recent_pledges()

    %{conv | status: 200, resp_body: inspect(pledges)}
  end
end
