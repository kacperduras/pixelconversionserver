import Config

if Mix.env == :prod do
  config :rollbax, access_token: System.get_env("ROLLBAR_TOKEN") || nil, environment: "production"
else
  config :rollbax, enabled: :log
end

unless Mix.env == :test do
  config :pixelconversionserver, PixelConversionServer.FacebookAPI.Scheduler, jobs: [
    facebook_api: [
      schedule: "* * * * *",
      task: {
        PixelConversionServer.FacebookAPI.Scheduler, :execute, [
          System.get_env("PIXEL_ID") || nil,
          System.get_env("ACCESS_TOKEN") || nil,
          System.get_env("TEST_EVENT_CODE") || nil
        ]
      }
    ]
  ], debug_logging: Mix.env == :dev
end
