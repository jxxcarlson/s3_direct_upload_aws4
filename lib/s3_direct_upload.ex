defmodule S3DirectUpload do

  alias S3DirectUpload.Utils
  alias S3DirectUpload.Signature
  alias S3DirectUpload.Expiration

  defstruct file_name: nil, mimetype: nil, path: nil,
    acl: "public-read", service: "s3", region: nil,
    access_key: Application.get_env(:s3_direct_upload, :aws_access_key),
    secret_key: Application.get_env(:s3_direct_upload, :aws_secret_key),
    bucket: Application.get_env(:s3_direct_upload, :aws_s3_bucket)

  def presigned_json(%S3DirectUpload{} = upload) do
    presigned(upload)
    |> Poison.encode!
  end

  def presigned(%S3DirectUpload{} = upload) do
    IO.puts "QQQ Presigned QQQ"
    # expiration_date = Expiration.iso_8601_now   # Long date, e.g, "20170815T121502Z"
    now = Utils.utc_now(:tuple)
    # short_date = now |> S3DirectUpload.Utils.short_date
    today = now |> Utils.amz_date # Long date, e.g., "20170815T120227Z"
    policy_ = policy(upload)
    IO.inspect policy_, label: "ENC_POLICY"

    params = %{
        service: upload.service,
        region: upload.region,
        datetime: now, # S3DirectUpload.Utils.utc_now(:tuple) |> S3DirectUpload.Utils.short_date
        secret_access_key: upload.secret_key
      }

     %{
      url: "https://#{upload.bucket}.s3.amazonaws.com",
      credentials: %{
        AWSAccessKeyId: upload.access_key,
        signature: Signature.generate(params, policy_),
        policy: policy_,
        acl: upload.acl,
        key: "#{upload.path}/#{upload.file_name}",
        date: today,
        credential: "#{upload.access_key}/#{today}/#{upload.region}/s3/aws4_request"
      }
    }

  end

  # @expiration Application.get_env(:s3_direct_upload, :expiration_api, S3DirectUpload.Expiration)

  # REFERENCE: http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTCon.html
  #            http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-UsingHTTPPOST.html
  #            http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-HTTPPOSTConstructPolicy.html

  def policy(upload) do
    IO.inspect(upload, label: "upload")
    IO.inspect(Expiration.datetime, label: "Expiration.datetime")
    p = %{
      expiration: Expiration.datetime,
      conditions: conditions(upload)
    }
    IO.inspect(p, label: "policy")
    p
    |> Poison.encode!
    |> Base.encode64
  end

  def conditions(upload) do
    [
      %{"bucket" => upload.bucket},
      %{"acl" => upload.acl},
      ["starts-with", "$Content-Type", upload.mimetype],
      ["starts-with", "$key", upload.path]
    ]
  end
end
