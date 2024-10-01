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
