defmodule Servey.Fetcher do
  def async(fun) do
    # This is the parent process id, the caller of async, we bind it to parent_id
    parent_pid = self()

    # The self() in spawn will be equal to a different process,
    # since spawn returns a pid, we shall keep it on calling async
    # and we return it in our tuple so we can match it later to know
    # which process the message is returned for
    spawn(fn -> send(parent_pid, {self(), :result, fun.()}) end)
  end

  def get_result(pid) do
    receive do
      # The ^ sign returns the value of the variable but doesn't bind it to a new value,
      # so pid will retain it's value unchanged
      # look at it as readonly just to be sure it matches
      {^pid, :result, value} ->
        value
        # Raise an error is the response doesn't arrive in 2 seconds
    after
      2000 ->
        raise "Timed out!"
    end
  end
end
