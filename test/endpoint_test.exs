defmodule EndpointTest do
  use ExUnit.Case
  use Plug.Test

  alias Radios.Endpoint

  @opts Endpoint.init([])

  defp put_radio(id, data) do
    :post
    |> conn("/radios/#{id}", Poison.encode!(data))
    |> put_req_header("content-type", "application/json")
    |> Endpoint.call(@opts)
  end

  defp set_location(id, loc) do
    :post
    |> conn("/radios/#{id}/location", Poison.encode!(%{location: loc}))
    |> put_req_header("content-type", "application/json")
    |> Endpoint.call(@opts)
  end

  defp get_location(id) do
    :get
    |> conn("/radios/#{id}/location")
    |> put_req_header("content-type", "application/json")
    |> Endpoint.call(@opts)
  end

  test "scenario1" do
    conn = put_radio("100", %{alias: "Radio100", allowed_locations: ["CPH-1", "CPH-2"]})
    assert conn.state == :sent
    assert conn.status == 200

    conn = put_radio("101", %{alias: "Radio101", allowed_locations: ["CPH-1", "CPH-2", "CPH-3"]})
    assert conn.state == :sent
    assert conn.status == 200

    conn = set_location("100", "CPH-1")
    assert conn.state == :sent
    assert conn.status == 200

    conn = set_location("101", "CPH-3")
    assert conn.state == :sent
    assert conn.status == 200

    conn = set_location("100", "CPH-3")
    assert conn.state == :sent
    assert conn.status == 403

    conn = get_location("101")
    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body) == %{"location" => "CPH-3"}

    conn = get_location("100")
    assert conn.state == :sent
    assert conn.status == 200
    assert Poison.decode!(conn.resp_body) == %{"location" => "CPH-1"}
    
  end

  test "scenario2" do
    conn = put_radio("102", %{alias: "Radio102", allowed_locations: ["CPH-1", "CPH-3"]})
    assert conn.state == :sent
    assert conn.status == 200

    conn = get_location("102")
    assert conn.state == :sent
    assert conn.status == 404
  end

  test "return 404" do
    conn =
      :get
      |> conn("/missing", "")
      |> Endpoint.call(@opts)

    assert conn.state == :sent
    assert conn.status == 404
  end

  test "validation test" do
    # number for alias
    conn = :post
    |> conn("/radios/100", Poison.encode!(%{alias: 123, allowed_locations: ["CPH-1"]}))
    |> put_req_header("content-type", "application/json")
    |> Endpoint.call(@opts)
    assert conn.state == :sent
    assert conn.status == 400

    # Numbers is list
    conn = :post
    |> conn("/radios/100", Poison.encode!(%{alias: "Radio 1", allowed_locations: ["CPH-1", 123]}))
    |> put_req_header("content-type", "application/json")
    |> Endpoint.call(@opts)
    assert conn.state == :sent
    assert conn.status == 400
    
    # Valid radio
    conn = put_radio("100", %{alias: "Radio100", allowed_locations: ["CPH-1", "CPH-2"]})
    assert conn.state == :sent
    assert conn.status == 200

    # And now invalid location
    conn = set_location("100", 123)
    assert conn.state == :sent
    assert conn.status == 400

    # insert more tests here
  end

end
