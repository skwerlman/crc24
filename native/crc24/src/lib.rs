// see RFC 4880, section 6 for an explanation of these constants
// https://www.ietf.org/rfc/rfc4880.txt
const CRC_24_INIT: u32 = 0xB704CE;
const CRC_24_POLY: u32 = 0x1864CFB;

// based on the C implementation in RFC 4880
pub fn crc24<T>(data: &mut T) -> u32
where
    T: Iterator<Item = u8>,
{
    let mut csum = CRC_24_INIT;

    for octet in data {
        csum ^= (octet as u32) << 16;
        for _ in 0..=7 {
            csum <<= 1;
            if csum & 0x1000000 != 0 {
                csum ^= CRC_24_POLY;
            }
        }
    }

    // truncate to 24 bits
    csum & 0xFFFFFF
}

// the feature flag nif is needed because the init! macro will fail to build in a non-nif setting (such as during testing)
// this feature should be enabled in the corresponding elixir module
#[cfg(feature = "nif")]
pub mod nif {
    // this mod is for type-specific adapters which take BEAM data and convert it into iterators of u8
    // this allows us to accept more types without needing to adapt the actual crc impl

    use rustler::{Binary, Error};

    use crate::crc24;

    #[rustler::nif]
    /// calculate the crc24 of an elixir binary
    fn crc24_binary(bin: Binary) -> Result<u32, Error> {
        // take ownership of the binary so we can convert it to a mutable iterator
        let owned_bin = bin.to_owned().expect("Could not take ownership of binary");
        Ok(crc24(&mut owned_bin.iter().cloned()))
    }

    rustler::init!("Elixir.Crc24.Native.Crc24");
}

#[cfg(test)]
mod tests {
    // this mod tests the crc24 function without involving any of the NIF machinery
    // the elixir suite is more comprehensive, as it includes several property tests as well
    use super::*;

    #[test]
    fn test_crc24() {
        assert_eq!(crc24(&mut "".bytes()), 0xB704CE);
        assert_eq!(crc24(&mut "a".bytes()), 0xF25713);
        assert_eq!(crc24(&mut "abc".bytes()), 0xBA1C7B);
        assert_eq!(crc24(&mut "test".bytes()), 0xF86ED0);
        assert_eq!(crc24(&mut "hello".bytes()), 0x47F58A);
        assert_eq!(crc24(&mut "Hello, world!!!".bytes()), 0xBE7D51);
        assert_eq!(crc24(&mut "message digest".bytes()), 0xDBF0B6);
        assert_eq!(crc24(&mut "abcdefghijklmnopqrstuvwxyz".bytes()), 0xED3665);
        assert_eq!(
            crc24(&mut "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789".bytes()),
            0x4662CD
        );
        assert_eq!(crc24(&mut "123456789".bytes()), 0x21CF02);
        assert_eq!(crc24(&mut "12345678901234567890123456789012345678901234567890123456789012345678901234567890".bytes()), 0x8313BB);
    }
}
