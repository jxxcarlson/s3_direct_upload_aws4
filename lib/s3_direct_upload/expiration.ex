defmodule S3DirectUpload.Expiration do

  @moduledoc false

  @iso8601 "~.4.0w-~.2.0w-~.2.0wT~.2.0w:~.2.0w:~.2.0wZ"
  @iso8601X "~.4.0w~.2.0w~.2.0wT~.2.0w~.2.0w~.2.0wZ"

  def datetime do
    :calendar.universal_time
    |> :calendar.datetime_to_gregorian_seconds
    |> Kernel.+(60 * 60)
    |> :calendar.gregorian_seconds_to_datetime
    |> expiration_format
  end

  defp expiration_format({ {year, month, day}, {hour, min, sec} }) do
    :io_lib.format(@iso8601, [year, month, day, hour, min, sec])
    |> to_string
  end

  defp iso_format({ {year, month, day}, {hour, min, sec} }) do
    :io_lib.format(@iso8601X, [year, month, day, hour, min, sec])
    |> to_string
  end

  def iso_8601_now do
    :calendar.universal_time
    |> :calendar.datetime_to_gregorian_seconds
    |> :calendar.gregorian_seconds_to_datetime
    |> iso_format
  end
end
