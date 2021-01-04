defmodule PixelConversionServer do
  use Application

  def main(_args) do
    start(:normal, _args)
  end

  def start(_type, _args) do
    children = [
      Supervisor.child_spec(
        {
          Cachex, [name: :pixelconversionserver]
        },
        id: Cachex, restart: :transient
      ),
      Plug.Cowboy.child_spec(
        scheme: :http,
        plug: PixelConversionServer.Router,
        options: [port: String.to_integer(System.get_env("APP_PORT") || "4000")]
      ),
      Supervisor.child_spec(
        {
          PixelConversionServer.FacebookAPI.Scheduler, []
        },
        id: PixelConversionServer.FacebookAPI.Scheduler, restart: :transient
      )
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: PixelConversionServer)
  end
end
