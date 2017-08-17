# HttpMonitor

a monitor implementation over http

## Summary

This library creates a simple Elixir process which continually heartbeats some endpoint.
If the endpoint fails to respond then the process crashes. `HttpMonitor.monitor` also
returns an Erlang reference which can be used similar to how you would monitor native Erlang
processes.

Follows Kubernetes liveness probe conventions which treat anything with 200-399 as a successful
heartbeat.

## Usage

```ex
defmodule MyServer do
  use GenServer

  def init(_)
    # Ping google every 5s
    ref = HttpMonitor.monitor("https://google.com", 5_000)
    {:ok, [ref: ref]}
  end

  # Handle the endpoint going down just like you would handle any other monitor
  def handle_info({:DOWN, ref, :process, _pid, _reason}, state = [ref: ref]) do
    IO.puts "Google went down! Warn the press!"
    {:stop, :normal, state}
  end
end
```
