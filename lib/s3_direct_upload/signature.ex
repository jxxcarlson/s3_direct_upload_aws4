defmodule S3DirectUpload.Signature do

  @moduledoc false
  import S3DirectUpload.Utils, only: [hmac_sha256: 2, date: 1, bytes_to_hex: 1]

  def generate(params, string_to_sign) do
    params
    |> signing_key
    |> hmac_sha256(string_to_sign)
    |> bytes_to_hex
  end

  def signing_key(params) do
    IO.puts "SIGNING KEY ..."
    IO.inspect(params.datetime, label: "params.datetime")
    IO.inspect(date(params.datetime), label: "date(params.datetime)")

    ["AWS4", params.secret_access_key]
    |> hmac_sha256(date(params.datetime))
    |> hmac_sha256(params.region)
    |> hmac_sha256(params.service)
    |> hmac_sha256("aws4_request")
  end

  # def test_ params do %{
  #    service: "s3",
  #    region: "us-east-1",
  #    datetime: {{2015, 12, 29}, {0, 0, 0}},
  #    secret_access_key: "yada::123"
  #   }
  # end

end
