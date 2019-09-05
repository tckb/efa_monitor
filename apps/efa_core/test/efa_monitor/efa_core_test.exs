defmodule EfaMonitor.EfaCoreTest do
  use ExUnit.Case
  doctest EfaMonitor.EfaCore

  test "greets the world" do
    assert EfaMonitor.EfaCore.hello() == :world
  end
end
