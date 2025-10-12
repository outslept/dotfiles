use crate::commands;
use clap::{Parser, Subcommand};

#[derive(Parser)]
#[command(
    name = "toolbelt",
    version,
    about = "A small CLI toolbox: archive, extract, free ports, clean caches, flash ISOs."
)]
pub struct Cli {
    #[command(subcommand)]
    pub cmd: Cmd,
}

#[derive(Subcommand)]
pub enum Cmd {
    #[command(name = "archive", visible_alias = "compress", about = "Create a .tar.gz archive from a file or directory")]
    Compress(commands::compress::CompressArgs),

    #[command(name = "extract", visible_aliases = ["decompress", "unpack"], about = "Extract a .tar.gz archive safely into a directory")]
    Decompress(commands::decompress::DecompressArgs),

    #[command(name = "kill-port", visible_aliases = ["free-port", "free"], about = "Kill the process(es) listening on a TCP port")]
    KillPort(commands::kill_port::KillPortArgs),

    #[command(name = "clean-browsers", visible_aliases = ["clear-browser-caches", "clear-browsers"], about = "Clear caches of common browsers (Windows/macOS/Linux)")]
    ClearBrowserCaches(commands::clear_browser_caches::ClearBrowserCachesArgs),

    #[command(name = "clean-node-cache", visible_aliases = ["clear-js-caches", "clear-js-cache", "clean-js-cache", "clean-npm-cache"], about = "Clear package manager caches (npm, yarn, pnpm, bun)")]
    ClearJsCaches(commands::clear_js_caches::ClearJsCachesArgs),

    #[command(name = "flash-iso", visible_aliases = ["iso2sd", "iso-to-sd", "write-iso"], about = "Write an ISO image to a block device (Linux only)")]
    Iso2sd(commands::iso2sd::Iso2sdArgs),
}
