defmodule Crc24Test do
  use ExUnit.Case, async: true
  use ExUnitProperties
  doctest Crc24

  describe "CRC-24 Examples" do
    test "hello" do
      csum = Crc24.crc24("hello")
      assert csum == 0x47F58A
    end

    test "hello world" do
      csum = Crc24.crc24("Hello, world!!!")
      assert csum == 0xBE7D51
    end

    test "test" do
      csum = Crc24.crc24("test")
      assert csum == 0xF86ED0
    end

    test "numbers" do
      csum = Crc24.crc24("123456789")
      assert csum == 0x21CF02
    end
  end

  describe "Ironclad tests" do
    test "empty string" do
      csum = Crc24.crc24("")
      assert csum == 0xB704CE
    end

    test "'a'" do
      csum = Crc24.crc24("a")
      assert csum == 0xF25713
    end

    test "'abc'" do
      csum = Crc24.crc24("abc")
      assert csum == 0xBA1C7B
    end

    test "message digest" do
      csum = Crc24.crc24("message digest")
      assert csum == 0xDBF0B6
    end

    test "lowercase alphabet" do
      csum = Crc24.crc24("abcdefghijklmnopqrstuvwxyz")
      assert csum == 0xED3665
    end

    test "alphanumeric" do
      csum = Crc24.crc24("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")

      assert csum == 0x4662CD
    end

    test "numeric" do
      csum =
        Crc24.crc24(
          "12345678901234567890123456789012345678901234567890123456789012345678901234567890"
        )

      assert csum == 0x8313BB
    end
  end

  describe "CRC24" do
    property "accepts all binaries" do
      check all(bin <- binary()) do
        # no assertion on the return type, since we only care that no error is raised
        Crc24.crc24(bin)
      end
    end

    property "always returns an integer" do
      check all(bin <- binary()) do
        csum = Crc24.crc24(bin)
        assert is_integer(csum)
      end
    end

    property "always returns a number between 0 and 0xFFFFFF" do
      check all(bin <- binary()) do
        csum = Crc24.crc24(bin)
        assert is_number(csum) and csum >= 0 and csum <= 0xFFFFFF
      end
    end

    property "return value is deterministic" do
      check all(bin <- binary()) do
        csum1 = Crc24.crc24(bin)
        csum2 = Crc24.crc24(bin)
        assert csum1 == csum2
      end
    end
  end
end
