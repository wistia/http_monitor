# http_monitor

a [monitor](https://hexdocs.pm/elixir/Process.html#monitor/1) implementation over http

## Why?

[Monitors](https://hexdocs.pm/elixir/Process.html#monitor/1) are an extremely useful Erlang feature that allow you to detect when a process crashes. Erlang provides support for process monitoring as well as node monitoring. We run multi-node clusters however we use HTTP and Kubernetes instead of distributed Erlang. We still wanted a way to react to remote nodes (or more generically, other services) going down however thus we built a small library which periodically pings the remote service to make sure it is still alive. This is a form of heartbeating. `http_monitor` also gives you a nice OTP-like interface for handling when those remote services go down.

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
