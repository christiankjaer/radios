defmodule Radios.Application do
  use Application

  def start(_type, _args) do
    port = String.to_integer(System.get_env("PORT") || "8080")

    children = [
      {Radios, name: Radios}, # Start the Radios database
      Plug.Cowboy.child_spec( # And the webserver
        scheme: :http,
        plug: Radios.Endpoint,
        options: [port: port]
      )
    ]

    opts = [strategy: :one_for_one, name: Radios.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
