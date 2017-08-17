defmodule HttpMonitorTest do
  use ExUnit.Case
  doctest HttpMonitor

  describe "monitor" do
    test "continually pings the endpoint" do
      parent = self()
      bypass = Bypass.open
      Bypass.expect bypass, fn conn ->
        assert conn.request_path == "/ping"
        send(parent, :pong)
        Plug.Conn.resp(conn, 200, "ok")
      end

      endpoint = "http://localhost:#{bypass.port}/ping"
      HttpMonitor.monitor(endpoint, 1)

      assert_receive :pong
      assert_receive :pong
      assert_receive :pong
    end

    test "sends the parent process a DOWN message if the endpoint goes down" do
      bypass = Bypass.open
      Bypass.expect bypass, fn conn ->
        assert conn.request_path == "/ping"
        Plug.Conn.resp(conn, 500, "ok")
      end

      endpoint = "http://localhost:#{bypass.port}/ping"
      HttpMonitor.monitor(endpoint, 1)

      assert_receive {:DOWN, _, _ ,_, _}
    end
  end
end
