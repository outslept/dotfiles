use std::{
    fs::File,
    io::BufWriter,
    path::{Path, PathBuf},
};

use anyhow::{Context, Result, bail};
use clap::Args;
use flate2::{Compression, write::GzEncoder};
use tar::Builder;

#[derive(Args)]
pub struct CompressArgs {
    /// Input file or directory to archive
    pub path: PathBuf,

    /// Output archive path (.tar.gz). Defaults to <name>.tar.gz next to input.
    #[arg(short = 'o', long = "out")]
    pub out: Option<PathBuf>,

    /// Compression level (0-9). Default: 6
    #[arg(
        short = 'l',
        long = "level",
        default_value_t = 6,
        value_parser = clap::value_parser!(u32).range(0..=9)
    )]
    pub level: u32,
}

pub fn run(args: CompressArgs) -> Result<()> {
    let input_path = args.path;
    if !input_path.exists() {
        bail!("Input path not found: {}", input_path.display());
    }

    let output_path = match args.out {
        Some(p) => p,
        None => default_output_archive_path(&input_path),
    };

    let output_dir = output_path.parent().unwrap_or_else(|| Path::new("."));
    std::fs::create_dir_all(output_dir)
        .with_context(|| format!("Create directory: {}", output_dir.display()))?;

    let file =
        File::create(&output_path).with_context(|| format!("Create: {}", output_path.display()))?;
    let writer = BufWriter::new(file);
    let compression_level = args.level;
    let encoder = GzEncoder::new(writer, Compression::new(compression_level));
    let mut tar_builder = Builder::new(encoder);

    let archive_root = input_path
        .file_name()
        .map(|s| s.to_string_lossy().to_string())
        .unwrap_or_else(|| "archive".into());

    if input_path.is_dir() {
        tar_builder
            .append_dir_all(&archive_root, &input_path)
            .with_context(|| format!("Append directory: {}", input_path.display()))?;
    } else {
        tar_builder
            .append_path_with_name(&input_path, &archive_root)
            .with_context(|| format!("Append file: {}", input_path.display()))?;
    }

    let encoder = tar_builder.into_inner().context("Finalize tar")?;
    let _file = encoder.finish().context("Finalize gzip")?;

    println!("ok: {}", output_path.display());
    Ok(())
}

fn default_output_archive_path(input: &Path) -> PathBuf {
    let parent_dir = input.parent().unwrap_or_else(|| Path::new("."));
    let base = input
        .file_name()
        .map(|s| s.to_string_lossy().to_string())
        .unwrap_or_else(|| "archive".into());
    parent_dir.join(format!("{}.tar.gz", base))
}
