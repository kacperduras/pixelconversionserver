defmodule PixelConversionServer.FacebookAPI do
  defmodule Client do
    use HTTPoison.Base

    def process_request_body(body) do
      if is_nil(body) do
        Poison.encode!(%{})
      else
        Poison.encode!(body)
      end
    end

    def process_response_body(body) do
      if is_nil(body) or String.trim(body) == "" do
        %{}
      else
        body
          |> Poison.decode!
          |> Enum.map(fn ({key, value}) -> {String.to_atom(key), value} end)
      end
    end
  end

  defmodule Scheduler do
    use Quantum, otp_app: :pixelconversionserver

    def execute(pixel_id, access_token, test_event_code \\ nil) do
      if is_nil(pixel_id) or String.trim(pixel_id) == "" or is_nil(access_token) or String.trim(access_token) == "" do
        Supervisor.stop(PixelConversionServer, :shutdown)
      else
        size = Cachex.size!(:pixelconversionserver) / 1000
        if size > 0 do
          packets_groups = if size <= 1, do: 1, else: Decimal.to_integer(Decimal.round(size, :up))
          if packets_groups > 0 do
            Enum.each(Enum.uniq(Enum.to_list(1..packets_groups)), fn each_packets_group ->
              start_packet = Decimal.to_integer(Decimal.add(1,
                Decimal.add(-1000, Decimal.mult(each_packets_group, 1000))))
              end_packet = Decimal.to_integer(Decimal.sub(Decimal.add(start_packet, 1000), 1))

              items = Enum.filter(Enum.map(Enum.to_list(start_packet..end_packet), fn target_packet ->
                Cachex.take(:pixelconversionserver, target_packet) |> elem(1)
              end), & !is_nil(&1))

              Task.async(fn ->
                try do
                  PixelConversionServer.FacebookAPI.make_request(items, fn (status, response) ->
                    Rollbax.report_message(:warning, "Status: #{status}, response: #{response}")
                  end, %{piuxel_id: pixel_id, access_token: access_token, test_event_code: test_event_code})
                rescue
                  exception -> Rollbax.report(:error, exception, System.stacktrace())
                end
              end)
            end)
          end
        end
      end
    end
  end

  def make_request(items, fallback, settings) do
    url = build_request_url(settings.pixel_id) <> "?access_token=#{settings.access_token}"

    unless length(items) <= 0 do
      request = %{
        data: items,
        test_event_code: settings.test_event_code
      }

      {status, response} = PixelConversionServer.FacebookAPI.Client.post(
        url, request, [{"Content-Type", "application/json"}])
      if status == :error do
        fallback.(:error, response.reason)
      else
        code = response.status_code
        if is_integer(code) and (code <= 599 and code >= 400) do
          fallback.(:ok, code)
        else
          body = response[:body]
          if is_nil(body) do
            fallback.(:ok, 404)
          else
            received = body[:events_received]
            if length(items) != received do
              fallback.(:invaild, received)
            end
          end
        end
      end
    end
  end

  def build_request_url(pixel_id, version \\ "v9.0") do
    "https://graph.facebook.com/#{version}/#{pixel_id}/events"
  end

  def valid_request_items(items) do
    Enum.filter(items, fn item ->
      if Map.has_key?(item, :event_name) and Map.has_key?(item, :event_time)
         and Map.has_key?(item, :user_data), do: item
    end)
  end
end
