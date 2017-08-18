defmodule UploadTest do
  use ExUnit.Case

  # NOTE: The code is Auth.Signature is lightly adapted from
  # https://github.com/CargoSense/ex_aws/ (@copyright CargoSense, MIT License)

  # REFERENCES:
  #
  #    http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-authentication-HTTPPOST.html
  #    http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-post-example.html
  #

  @awsSecretAccessKey "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  @region "us-east-1"

  # AWSAccessKeyId	AKIAIOSFODNN7EXAMPLE
  # x-amz-date in the policy (20151229)

  @string_to_sign "eyAiZXhwaXJhdGlvbiI6ICIyMDE1LTEyLTMwVDEyOjAwOjAwLjAwMFoiLA0KICAiY29uZGl0aW9ucyI6IFsNCiAgICB7ImJ1Y2tldCI6ICJzaWd2NGV4YW1wbGVidWNrZXQifSwNCiAgICBbInN0YXJ0cy13aXRoIiwgIiRrZXkiLCAidXNlci91c2VyMS8iXSwNCiAgICB7ImFjbCI6ICJwdWJsaWMtcmVhZCJ9LA0KICAgIHsic3VjY2Vzc19hY3Rpb25fcmVkaXJlY3QiOiAiaHR0cDovL3NpZ3Y0ZXhhbXBsZWJ1Y2tldC5zMy5hbWF6b25hd3MuY29tL3N1Y2Nlc3NmdWxfdXBsb2FkLmh0bWwifSwNCiAgICBbInN0YXJ0cy13aXRoIiwgIiRDb250ZW50LVR5cGUiLCAiaW1hZ2UvIl0sDQogICAgeyJ4LWFtei1tZXRhLXV1aWQiOiAiMTQzNjUxMjM2NTEyNzQifSwNCiAgICB7IngtYW16LXNlcnZlci1zaWRlLWVuY3J5cHRpb24iOiAiQUVTMjU2In0sDQogICAgWyJzdGFydHMtd2l0aCIsICIkeC1hbXotbWV0YS10YWciLCAiIl0sDQoNCiAgICB7IngtYW16LWNyZWRlbnRpYWwiOiAiQUtJQUlPU0ZPRE5ON0VYQU1QTEUvMjAxNTEyMjkvdXMtZWFzdC0xL3MzL2F3czRfcmVxdWVzdCJ9LA0KICAgIHsieC1hbXotYWxnb3JpdGhtIjogIkFXUzQtSE1BQy1TSEEyNTYifSwNCiAgICB7IngtYW16LWRhdGUiOiAiMjAxNTEyMjlUMDAwMDAwWiIgfQ0KICBdDQp9"

  @signature "46503978d3596de22955b4b18d6dfb1d54e8c5958727d5bdcd02cc1119c60fc9"

  def test_params do %{
     service: "s3",
     region: @region,
     datetime: {{2015, 12, 29}, {0, 0, 0}},
     secret_access_key: @awsSecretAccessKey
    }
  end

  # datetime = {{2013, 5, 24}, {0, 0, 0}}
  # 20151229T000000Z"


  test "signing key" do

    signing_key = S3DirectUpload.Signature.signing_key(test_params())

    {:ok, signing_key_from_sigaws} = Sigaws.Util.signing_key(
        {2015, 12, 29} |> Date.from_erl!(),
        @region,
        "s3",
        @awsSecretAccessKey
      )

    assert signing_key == signing_key_from_sigaws

  end

  test "signature" do

    signature = S3DirectUpload.Signature.generate(test_params(), @string_to_sign)

    {:ok, signing_key_from_sigaws} = Sigaws.Util.signing_key(
        {2015, 12, 29} |> Date.from_erl!(),
        @region,
        "s3",
        @awsSecretAccessKey
      )

    signature_from_sigaws = signing_key_from_sigaws
      |>  Sigaws.Util.hmac([@string_to_sign])
      |>  Base.encode16(case: :lower)

    assert signature == signature_from_sigaws
  end

  test "upload" do
    upload = %S3DirectUpload{file_name: "frog.jpg", mimetype: "image/jpeg", path: "jxx", region: "us-east-1"}
    result = S3DirectUpload.presigned upload
    credentials = result.credentials
    IO.inspect(credentials, label: "credentials")

    assert result.url == "https://s3-bucket.s3.amazonaws.com"
    assert credentials.key == "jxx/frog.jpg"

    # Date is long-form:
    assert (String.contains? credentials.date,"Z") == true
    assert (String.contains? credentials.date,"T") == true
    assert (String.contains? credentials.credential,"aws4_request") == true
  end

end
