defmodule PixelConversionServer.FacebookAPITest do
  use ExUnit.Case
  doctest PixelConversionServer.FacebookAPI

  test "build request url" do
    assert PixelConversionServer.FacebookAPI.build_request_url("0000000000") == "https://graph.facebook.com/v9.0/0000000000/events"
  end

  test "valid request items" do
    items = [
      %{
        event_name: "Purchase",
        event_time: DateTime.utc_now(),
        user_data: %{
          em: "sample"
        },
        custom_data: %{
          currency: "PLN",
          value: "100"
        }
      },
      %{
        event_name: "Purchase",
        event_time: 978307200,
        user_data: %{
          em: "sample"
        },
        custom_data: %{
          currency: "PLN",
          value: "100"
        }
      },
      %{
        event_name: "Purchase",
        event_time: DateTime.utc_now(),
        user_data: %{
          em: "sample"
        }
      },
      %{
        event_name: "Purchase",
        event_time: DateTime.utc_now(),
        custom_data: %{
          currency: "PLN",
          value: "100"
        }
      }
    ]

    assert length(PixelConversionServer.FacebookAPI.valid_request_items(items)) == 3
  end
end
