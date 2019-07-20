defmodule Radios.Endpoint do
  use Plug.Router

  plug(Plug.Logger)
  plug(:match)
  plug(Plug.Parsers, parsers: [:json], json_decoder: Poison)
  plug(:dispatch)

  @type status() :: :ok | :notfound | :forbidden | :badrequest

  @spec to_response(Plug.Conn.t(), status()) :: Plug.Conn.t()
  defp to_response(conn, :ok) do
    send_resp(conn, 200, "OK")
  end

  defp to_response(conn, :notfound) do
    send_resp(conn, 404, "Not Found")
  end

  defp to_response(conn, :forbidden) do
    send_resp(conn, 403, "Forbidden")
  end

  defp to_response(conn, :badrequest) do
    send_resp(conn, 400, "Bad Request")
  end

  @spec get_location(Plug.Conn.t(), integer()) :: Plug.Conn.t()
  defp get_location(conn, id) do
    case Radios.get_location(Radios, id) do
      {:ok, loc} ->
        send_resp(conn, 200, Poison.encode!(%{location: loc}))

      _ ->
        to_response(conn, :notfound)
    end
  end

  @spec set_location(Plug.Conn.t(), integer(), String.t()) :: Plug.Conn.t()
  defp set_location(conn, id, loc) when is_bitstring(loc) do
    to_response(conn, Radios.set_location(Radios, id, loc))
  end

  defp set_location(conn, _, _) do
    to_response(conn, :badrequest)
  end

  @spec store_radio(Plug.Conn.t(), integer(), String.t(), list(String.t())) :: Plug.Conn.t()
  defp store_radio(conn, id, radio_alias, locs)
       when is_bitstring(radio_alias) and is_list(locs) do
    Radios.store(Radios, id, radio_alias, locs)
    to_response(conn, :ok)
  end

  defp store_radio(conn, _, _, _) do
    to_response(conn, :badrequest)
  end

  @spec with_id_from_string(Plug.Conn.t(), String.t(), function()) :: Plug.Conn.t()
  defp with_id_from_string(conn, id, fun) do
    case Integer.parse(id) do
      {n, ""} -> fun.(n)
      _ -> to_response(conn, :badrequest)
    end
  end

  get "/radios/:id/location" do
    with_id_from_string(conn, id, fn n ->
      get_location(conn, n) end)
  end

  post "/radios/:id" do
    with_id_from_string(conn, id, fn n ->
      case conn.body_params do
        %{"alias" => radio_alias, "allowed_locations" => locs} ->
          store_radio(conn, n, radio_alias, locs)

        _ ->
          to_response(conn, :badrequest)
      end
    end)
  end

  post "/radios/:id/location" do
    with_id_from_string(conn, id, fn n ->
      case conn.body_params do
        %{"location" => loc} -> set_location(conn, n, loc)
        _ -> to_response(conn, :badrequest)
      end
    end)
  end

  match _ do
    to_response(conn, :notfound)
  end
end
