defmodule PixelConversionServer.Router do
  use Plug.Router
  use Plug.ErrorHandler

  if Mix.env == :dev do
    use Plug.Debugger
    plug Plug.Logger
  end

  plug Plug.Parsers, parsers: [:json], pass: ["application/json"], json_decoder: Poison

  plug :match
  plug :dispatch

  post "/track" do
    data = if Map.has_key?(conn.body_params, "data"), do: Map.fetch!(conn.body_params, "data"), else: %{}

    if is_nil(data) or (if is_list(data), do: length(data) <= 0, else: true) do
      build_response(conn, 400, %{message: "Invalid payload"})
    else
      valid_items = PixelConversionServer.FacebookAPI.valid_request_items(data)

      if length(valid_items) > 0 do
        Enum.each(valid_items, fn item ->
          Cachex.put(:pixelconversionserver,
            Decimal.to_integer(Decimal.add(Cachex.size!(:pixelconversionserver), 1)), item)
        end)

        build_response(conn, 200, %{status: :ok, processed: length(valid_items)})
      else
        build_response(conn, 400, %{message: "Invalid payload"})
      end
    end
  end

  match _, do: build_response(conn, 500)

  def handle_errors(conn, %{kind: _kind, reason: _reason, stack: _stack}),
      do: build_response(conn, conn.status, _reason || nil)

  defp build_response(conn, code \\ 500, body \\ nil) do
    # https://tools.ietf.org/html/rfc2616#section-10
    result = if is_integer(code) and (code <= 599 and code >= 400) do
      if is_nil(body), do: %{error: true, code: code, body: body}, else: %{error: true, code: code}
    else
      unless is_nil(body) do
        if is_list(body) or is_tuple(body) or is_map(body), do: body, else: %{error: true, code: 500}
      else
        %{}
      end
    end

    conn
      |> put_status(if is_map(body) and Map.has_key?(body, :error)
          and Map.fetch!(body, :error) == true, do: 500, else: code)
      |> put_resp_content_type("application/json")
      |> send_resp(code, Poison.encode!(result))
      |> halt
  end
end
