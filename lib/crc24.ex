defmodule Crc24 do
  @moduledoc """
  A NIF-based OpenPGP CRC-24 implementation.
  """

  @doc """
  Calculate the CRC-24 of the given data.

  Currently, only the `t:binary/0` type is supported.

  ### Example:

      iex> Crc24.crc24("Hello, world!!!")
      0xBE7D51
  """
  @spec crc24(data :: any) :: non_neg_integer
  defdelegate crc24(data), to: Crc24.Native.Crc24
end
