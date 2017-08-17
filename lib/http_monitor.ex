defmodule HttpMonitor do
  @doc """
  Spawns a process that heartbeats the given `endpoint` every `poll_sleep` ms.
  Returns a monitor reference
  """
  @spec monitor(endpoint :: binary, ms :: integer) :: reference
  def monitor(endpoint, poll_sleep) do
    {:ok, pid} = HttpMonitor.EndpointMonitor.start(endpoint, poll_sleep)
    Process.monitor(pid)
  end
end
