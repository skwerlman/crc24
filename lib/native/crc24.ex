defmodule Crc24.Native.Crc24 do
  @moduledoc false
  use Rustler, otp_app: :crc24, crate: "crc24", features: ["nif"]

  @doc false
  @spec crc24(any()) :: non_neg_integer()
  # accept any term, but raise argument error if we dont support getting the crc yet
  def crc24(data) when is_binary(data) do
    crc24_binary(data)
  end

  def crc24(_data) do
    raise ArgumentError
  end

  @doc false
  @spec crc24_binary(binary()) :: non_neg_integer()
  def crc24_binary(_data) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
