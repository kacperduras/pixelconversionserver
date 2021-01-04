# pixelconversionserver [![Build Status](https://travis-ci.com/kacperduras/pixelconversionserver.svg?branch=main)](https://travis-ci.com/kacperduras/pixelconversionserver)

The external server for Facebook Pixel tracking in [Elixir](https://elixir-lang.org/).

## How to run
```shell
$ mix escript.build
$ ./pixelconversionserver
```

or

```shell
$ mix run --no-halt
```

Please, for production use, set `MIX_ENV` to `prod`.

### Available environment settings
* `APP_PORT`: HTTP port (default: `4000`)
* `ROLLBAR_TOKEN`: access token for [Rollbar](https://rollbar.com/)
* `PIXEL_ID`: id of Facebook Pixel
* `ACCESS_TOKEN`: access token for Facebook Pixel
* `TEST_EVENT_CODE`: test code for Facebook Pixel (optional)

## How to use

### Request
```shell
curl -X POST \
  -F 'data=[
       {
         "event_name": "PageView",
         "event_time": 0000000000,
         "user_data": {
           "em": "sample"
         }
       }
     ]' \
  http://localhost:4000/track
```

Documentation for request body is available [here](https://developers.facebook.com/docs/marketing-api/conversions-api/parameters/server-event): only `data` field.

### Good response
```json
{
  "status": "ok",
  "processed": 1
}
```

### Bad response
```json
{
  "error": true,
  "code": 500,
  "body": { /* optional exception content */ }
}
```

### License
[MIT](LICENSE)
