defmodule RadiosTest do
  use ExUnit.Case
  doctest Radios

  setup do
    radios = start_supervised!(Radios)
    %{radios: radios}
  end

  test "scenario 1", %{radios: radios} do
    assert Radios.store(radios, 100, "Radio100", MapSet.new(["CPH-1", "CPH-2"])) == :ok
    assert Radios.store(radios, 101, "Radio101", MapSet.new(["CPH-1", "CPH-2", "CPH-3"])) == :ok
    assert Radios.set_location(radios, 100, "CPH-1") == :ok
    assert Radios.set_location(radios, 101, "CPH-3") == :ok
    assert Radios.set_location(radios, 100, "CPH-3") == :forbidden
    assert Radios.get_location(radios, 101) == {:ok, "CPH-3"}
    assert Radios.get_location(radios, 100) == {:ok, "CPH-1"}
  end

  test "scenario 2", %{radios: radios} do
    assert Radios.store(radios, 102, "Radio102", MapSet.new(["CPH-1", "CPH-3"])) == :ok
    assert Radios.get_location(radios, 102) == :notfound
  end

end
