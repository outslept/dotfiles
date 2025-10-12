use anyhow::Result;
use clap::Args;
use std::{
    env, fs,
    path::{Path, PathBuf},
    process::Command,
};

#[derive(Args)]
pub struct ClearBrowserCachesArgs {}

pub fn run(_: ClearBrowserCachesArgs) -> Result<()> {
    terminate_browser_processes();

    let mut any_cleared = false;
    any_cleared |= clear_chrome_cache();
    any_cleared |= clear_edge_cache();
    any_cleared |= clear_brave_cache();
    any_cleared |= clear_opera_cache();
    any_cleared |= clear_firefox_cache();

    if !any_cleared {
        println!("no caches found");
    }

    Ok(())
}

fn run_command(program: &str, args: &[&str]) -> bool {
    Command::new(program)
        .args(args)
        .status()
        .map(|s| s.success())
        .unwrap_or(false)
}

fn terminate_browser_processes() {
    #[cfg(windows)]
    {
        for name in ["chrome.exe", "msedge.exe", "firefox.exe", "opera.exe", "brave.exe"] {
            let _ = run_command("taskkill", &["/f", "/im", name]);
        }
    }

    #[cfg(not(windows))]
    {
        let process_names = [
            "chrome",
            "google-chrome",
            "chromium",
            "msedge",
            "firefox",
            "opera",
            "brave",
            "Google Chrome",
            "Microsoft Edge",
            "Brave Browser",
            "Opera",
            "Firefox",
        ];

        for name in process_names {
            let ok = run_command("pkill", &["-9", "-x", name]);
            if !ok {
                let _ = run_command("killall", &["-9", name]);
            }
        }
    }
}

#[cfg(windows)]
fn local_app_data_dir() -> Option<PathBuf> {
    env::var_os("LOCALAPPDATA").map(PathBuf::from)
}

#[cfg(windows)]
fn roaming_app_data_dir() -> Option<PathBuf> {
    env::var_os("APPDATA").map(PathBuf::from)
}

// #[cfg(target_os = "macos")]
// fn caches_root_dir() -> Option<PathBuf> {
//     env::var_os("HOME").map(|h| PathBuf::from(h).join("Library").join("Caches"))
// }

#[cfg(all(unix, not(target_os = "macos")))]
fn caches_root_dir() -> Option<PathBuf> {
    if let Some(xdg) = env::var_os("XDG_CACHE_HOME") {
        Some(PathBuf::from(xdg))
    } else {
        env::var_os("HOME").map(|h| PathBuf::from(h).join(".cache"))
    }
}

fn remove_dir_if_present(dir: &Path) -> bool {
    if dir.is_dir() {
        if let Err(e) = fs::remove_dir_all(dir) {
            eprintln!("failed to remove {}: {}", dir.display(), e);
        }
        return true;
    }
    false
}

fn remove_dirs(paths: impl IntoIterator<Item = PathBuf>) -> bool {
    let mut any = false;
    for p in paths {
        any |= remove_dir_if_present(&p);
    }
    any
}

const CHROMIUM_CACHE_SUBDIRS: [&str; 4] = [
    "Cache",
    "Code Cache",
    "GPUCache",
    "Service Worker/CacheStorage",
];

fn clear_chromium_profile_roots(label: &str, roots: Vec<PathBuf>) -> bool {
    let mut cleared = false;
    for root in roots {
        cleared |= clear_one_chromium_profile_root(&root);
    }
    if cleared {
        println!("Cleared {} cache", label);
    }
    cleared
}

fn clear_one_chromium_profile_root(root: &Path) -> bool {
    if !root.is_dir() {
        return false;
    }
    let mut cleared = false;
    if let Ok(entries) = fs::read_dir(root) {
        for entry in entries.flatten() {
            if let Ok(ft) = entry.file_type() {
                if ft.is_dir() {
                    let base = entry.path();
                    let targets = CHROMIUM_CACHE_SUBDIRS
                        .iter()
                        .map(|s| base.join(s))
                        .collect::<Vec<_>>();
                    cleared |= remove_dirs(targets);
                }
            }
        }
    }
    cleared
}

fn clear_chrome_cache() -> bool {
    #[cfg(windows)]
    let roots = {
        let mut v = Vec::new();
        if let Some(local) = local_app_data_dir() {
            v.push(local.join(["Google", "Chrome", "User Data"].iter().collect::<PathBuf>()));
        }
        v
    };

    // #[cfg(target_os = "macos")]
    // let roots = {
    //     let mut v = Vec::new();
    //     if let Some(base) = caches_root_dir() {
    //         v.push(base.join(["Google", "Chrome"].iter().collect::<PathBuf>()));
    //     }
    //     v
    // };

    #[cfg(all(unix, not(target_os = "macos")))]
    let roots = {
        let mut v = Vec::new();
        if let Some(base) = caches_root_dir() {
            v.push(base.join("google-chrome"));
            v.push(base.join("chromium"));
        }
        v
    };

    clear_chromium_profile_roots("Chrome/Chromium", roots)
}

fn clear_edge_cache() -> bool {
    #[cfg(windows)]
    let roots = {
        let mut v = Vec::new();
        if let Some(local) = local_app_data_dir() {
            v.push(local.join(["Microsoft", "Edge", "User Data"].iter().collect::<PathBuf>()));
        }
        v
    };

    // #[cfg(target_os = "macos")]
    // let roots = {
    //     let mut v = Vec::new();
    //     if let Some(base) = caches_root_dir() {
    //         v.push(base.join("Microsoft Edge"));
    //     }
    //     v
    // };

    #[cfg(all(unix, not(target_os = "macos")))]
    let roots = {
        let mut v = Vec::new();
        if let Some(base) = caches_root_dir() {
            v.push(base.join("microsoft-edge"));
        }
        v
    };

    clear_chromium_profile_roots("Edge", roots)
}

fn clear_brave_cache() -> bool {
    #[cfg(windows)]
    let roots = {
        let mut v = Vec::new();
        if let Some(local) = local_app_data_dir() {
            v.push(
                local.join(
                    ["BraveSoftware", "Brave-Browser", "User Data"]
                        .iter()
                        .collect::<PathBuf>(),
                ),
            );
        }
        v
    };

    // #[cfg(target_os = "macos")]
    // let roots = {
    //     let mut v = Vec::new();
    //     if let Some(base) = caches_root_dir() {
    //         v.push(base.join(["BraveSoftware", "Brave-Browser"].iter().collect::<PathBuf>()));
    //     }
    //     v
    // };

    #[cfg(all(unix, not(target_os = "macos")))]
    let roots = {
        let mut v = Vec::new();
        if let Some(base) = caches_root_dir() {
            v.push(base.join(["BraveSoftware", "Brave-Browser"].iter().collect::<PathBuf>()));
        }
        v
    };

    clear_chromium_profile_roots("Brave", roots)
}

fn clear_opera_cache() -> bool {
    let mut cleared = false;

    #[cfg(windows)]
    {
        if let Some(roam) = roaming_app_data_dir() {
            let base = roam.join(["Opera Software", "Opera Stable"].iter().collect::<PathBuf>());
            let paths = CHROMIUM_CACHE_SUBDIRS
                .iter()
                .map(|s| base.join(s))
                .collect::<Vec<_>>();
            cleared |= remove_dirs(paths);
        }
    }

    // #[cfg(target_os = "macos")]
    // {
    //     if let Some(base) = caches_root_dir() {
    //         // Opera on macOS should keep the main cache in this bundle cache
    //         let path = base.join("com.operasoftware.Opera");
    //         cleared |= remove_dir_if_present(&path);
    //     }
    // }

    #[cfg(all(unix, not(target_os = "macos")))]
    {
        if let Some(base) = caches_root_dir() {
            // linux ~/.cache/opera/{Cache,Code Cache,GPUCache}
            let base = base.join("opera");
            let paths = CHROMIUM_CACHE_SUBDIRS
                .iter()
                .map(|s| base.join(s))
                .collect::<Vec<_>>();
            cleared |= remove_dirs(paths);
        }
    }

    if cleared {
        println!("Cleared Opera cache");
    }
    cleared
}

fn clear_firefox_cache() -> bool {
    let mut cleared = false;

    #[cfg(windows)]
    {
        if let Some(local) = local_app_data_dir() {
            let profiles =
                local.join(["Mozilla", "Firefox", "Profiles"].iter().collect::<PathBuf>());
            cleared |= clear_firefox_profiles_at(&profiles);
        }
    }

    // #[cfg(target_os = "macos")]
    // {
    //     if let Some(base) = caches_root_dir() {
    //         let profiles = base.join(["Firefox", "Profiles"].iter().collect::<PathBuf>());
    //         cleared |= clear_firefox_profiles_at(&profiles);
    //     }
    // }

    #[cfg(all(unix, not(target_os = "macos")))]
    {
        if let Some(base) = caches_root_dir() {
            let profiles = base.join(["mozilla", "firefox"].iter().collect::<PathBuf>());
            cleared |= clear_firefox_profiles_at(&profiles);
        }
    }

    if cleared {
        println!("Cleared Firefox cache");
    }
    cleared
}

fn clear_firefox_profiles_at(profiles_root: &Path) -> bool {
    if !profiles_root.is_dir() {
        return false;
    }
    let mut cleared = false;
    if let Ok(entries) = fs::read_dir(profiles_root) {
        for entry in entries.flatten() {
            let cache2 = entry.path().join("cache2");
            cleared |= remove_dir_if_present(&cache2);
        }
    }
    cleared
}
