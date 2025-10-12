use anyhow::Result;
use clap::Args;
use std::{
    env,
    ffi::OsStr,
    path::{Path, PathBuf},
    process::Command,
};

#[derive(Args)]
pub struct ClearJsCachesArgs {}

pub fn run(_: ClearJsCachesArgs) -> Result<()> {
    for (name, argv) in CACHE_CLEAN_COMMANDS {
        if let Some(exe) = find_executable_on_path(name) {
            let ok = invoke_command(&exe, argv)?;
            if ok {
                println!("Cleared {} cache", name);
            }
        }
    }
    Ok(())
}

const CACHE_CLEAN_COMMANDS: [(&str, &[&str]); 4] = [
    ("npm", &["cache", "clean", "--force"]),
    ("yarn", &["cache", "clean"]),
    ("pnpm", &["store", "prune"]),
    ("bun", &["pm", "cache", "rm"]),
];

fn find_executable_on_path(program: &str) -> Option<PathBuf> {
    let path = env::var_os("PATH")?;
    let mut search_dirs: Vec<PathBuf> = env::split_paths(&path).collect();

    // mimic Windows search order: include current dir first
    if cfg!(windows) {
        if let Ok(cwd) = env::current_dir() {
            search_dirs.insert(0, cwd);
        }
    }

    #[cfg(windows)]
    let pathexts: Vec<String> = env::var("PATHEXT")
        .unwrap_or_else(|_| String::from(".COM;.EXE;.BAT;.CMD"))
        .split(';')
        .map(|s| s.trim().to_string())
        .collect();

    for dir in search_dirs {
        let direct = dir.join(program);
        if direct.is_file() {
            return Some(direct);
        }

        #[cfg(windows)]
        {
            // PATHEXT variants (npm.cmd, yarn.cmd, etc.)
            if Path::new(program).extension().is_none() {
                for ext in &pathexts {
                    let candidate = dir.join(format!("{program}{ext}"));
                    if candidate.is_file() {
                        return Some(candidate);
                    }
                }
            }
        }
    }
    None
}

fn invoke_command(executable: &Path, argv: &[&str]) -> Result<bool> {
    #[cfg(windows)]
    {
        let is_batch = is_batch_script(executable);
        let status = if is_batch {
            Command::new("cmd")
                .arg("/C")
                .arg(executable)
                .args(argv)
                .status()?
        } else {
            Command::new(executable).args(argv).status()?
        };
        return Ok(status.success());
    }

    #[cfg(not(windows))]
    {
        let status = Command::new(executable).args(argv).status()?;
        Ok(status.success())
    }
}

#[cfg(windows)]
fn is_batch_script(path: &Path) -> bool {
    path.extension()
        .and_then(OsStr::to_str)
        .map(|ext| ext.eq_ignore_ascii_case("cmd") || ext.eq_ignore_ascii_case("bat"))
        .unwrap_or(false)
}
