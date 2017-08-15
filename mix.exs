defmodule S3DirectUpload.Mixfile do
  use Mix.Project

  def project do
    [app: :s3_direct_upload,
     version: "0.1.2",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     deps: deps()]
  end

  # Configuration for the OTP application
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [extra_applications: [:logger]]
  end

  # Dependencies
  defp deps do
    [{:poison, "~> 3.0"},
     {:ex_doc, "~> 0.14", only: :dev, runtime: false},
     {:sigaws, "~> 0.7"}]
  end

  defp description do
    """
    Pre-signed S3 upload helper for client-side multipart POSTs.
    """
  end


end
