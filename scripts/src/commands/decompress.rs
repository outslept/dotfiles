use std::{fs::File, io::BufReader, path::PathBuf};

use anyhow::{bail, Context, Result};
use clap::Args;
use flate2::read::GzDecoder;
use tar::Archive;

#[derive(Args)]
pub struct DecompressArgs {
    /// Input .tar.gz archive to extract
    pub archive: PathBuf,

    /// Destination directory (default: current working directory)
    #[arg(short = 'C', long = "dir")]
    pub dest: Option<PathBuf>,
}

pub fn run(args: DecompressArgs) -> Result<()> {
    let input_archive_path = args.archive;
    if !input_archive_path.exists() {
        bail!("Archive not found: {}", input_archive_path.display());
    }

    let destination_dir = args
        .dest
        .unwrap_or(std::env::current_dir().context("Get current working directory")?);
    std::fs::create_dir_all(&destination_dir)
        .with_context(|| format!("Create directory: {}", destination_dir.display()))?;

    let file = File::open(&input_archive_path)
        .with_context(|| format!("Open: {}", input_archive_path.display()))?;
    let gzip_decoder = GzDecoder::new(BufReader::new(file));
    let mut tar_archive = Archive::new(gzip_decoder);

    for entry_result in tar_archive.entries().context("Read archive entries")? {
        let mut entry = entry_result.context("Read entry")?;
        entry
            .unpack_in(&destination_dir)
            .with_context(|| format!("Extract into: {}", destination_dir.display()))?;
    }

    println!("ok: extracted to {}", destination_dir.display());
    Ok(())
}
