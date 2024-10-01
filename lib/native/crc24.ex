defmodule Crc24.Native.Crc24 do
  # internal module to talk to the underlying rust nif

  @moduledoc false
  # 'nif' feature is needed to tell rust to initialize the nif
  use Rustler, otp_app: :crc24, crate: "crc24", features: ["nif"]

  @doc false
  # accept any term, but raise argument error if we dont support getting the crc yet
  def crc24(data) when is_binary(data) do
    crc24_binary(data)
  end

  def crc24(_data) do
    raise ArgumentError
  end

  @doc false
  # actually pass our request on the the nif
  # this function is replaced when the nif is loaded
  def crc24_binary(_data) do
    :erlang.nif_error(:nif_not_loaded)
  end
end
