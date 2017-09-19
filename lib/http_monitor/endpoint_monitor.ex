defmodule HttpMonitor.EndpointMonitor do
  use GenPoller

  def start(endpoint, poll_sleep, opts \\ []) do
    state = %{from: self(), endpoint: endpoint, poll_sleep: poll_sleep}
    GenPoller.start(__MODULE__, state, opts)
  end

  def init(state) do
    ref = Process.monitor(state.from)
    GenPoller.start_loop
    {:ok, put_in(state[:from_ref], ref)}
  end

  def handle_tick(state) do
    if endpoint_up?(state) do
      {:continue, state}
    else
      {:stop, :normal, state}
    end
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, state = %{from_ref: ref}) do
    {:stop, :normal, state}
  end

  defp endpoint_up?(%{endpoint: endpoint}) do
    case retry(1, fn -> HTTPoison.get(endpoint) end) do
      {:ok, res} -> res.status_code in (200..399)
      _ -> false
    end
  end

  defp retry(0, yield) do
    yield.()
  end
  defp retry(n, yield) when n > 0 do
    case yield.() do
      {:error, _} -> retry(n - 1, yield)
      res -> res
    end
  end
end
