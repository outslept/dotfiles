pub mod cli;
pub mod commands;

use anyhow::Result;
use clap::Parser;

pub fn run() -> Result<()> {
    let cli = cli::Cli::parse();

    match cli.cmd {
        cli::Cmd::Compress(args) => commands::compress::run(args)?,
        cli::Cmd::Decompress(args) => commands::decompress::run(args)?,
        cli::Cmd::KillPort(args) => commands::kill_port::run(args)?,
        cli::Cmd::ClearBrowserCaches(args) => commands::clear_browser_caches::run(args)?,
        cli::Cmd::ClearJsCaches(args) => commands::clear_js_caches::run(args)?,
        cli::Cmd::Iso2sd(args) => commands::iso2sd::run(args)?,
    }

    Ok(())
}
