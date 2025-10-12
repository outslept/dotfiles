use anyhow::{Context, Result};
use clap::Args;
use std::collections::HashSet;
use std::process::Command;

#[derive(Args)]
pub struct KillPortArgs {
    /// TCP port to free
    pub port: u16,
}

pub fn run(args: KillPortArgs) -> Result<()> {
    let target_port = args.port;

    if cfg!(windows) {
        // netstat -ano -p tcp
        let netstat_output = Command::new("netstat")
            .args(["-ano", "-p", "tcp"])
            .output()
            .context("Invoke netstat")?;
        let netstat_stdout = String::from_utf8_lossy(&netstat_output.stdout);

        let mut pids: HashSet<u32> = HashSet::new();
        for line in netstat_stdout.lines() {
            let cols: Vec<&str> = line.split_whitespace().collect();
            if cols.len() < 5 {
                continue;
            }
            // Proto | LocalAddress | ForeignAddress | State | PID
            let local_addr = cols[1];
            let state = cols[3].to_ascii_uppercase();
            let pid_str = cols[4];

            if !state.contains("LISTEN") {
                continue;
            }

            // "0.0.0.0:3000", "[::]:3000", "[fe80::1%12]:80"
            let port_match = local_addr
                .rsplit_once(':')
                .and_then(|(_, p)| p.parse::<u16>().ok());
            if port_match == Some(target_port) {
                if let Ok(pid) = pid_str.parse::<u32>() {
                    pids.insert(pid);
                }
            }
        }

        if pids.is_empty() {
            println!("no process is listening on port {}", target_port);
            return Ok(());
        }

        for pid in pids {
            let status = Command::new("taskkill")
                .args(["/F", "/T", "/PID", &pid.to_string()])
                .status()
                .context("Invoke taskkill")?;
            if status.success() {
                println!("killed {}", pid);
            } else {
                println!("failed to kill {}", pid);
            }
        }
    } else {
        // lsof -tiTCP:<port> -sTCP:LISTEN -nP
        let lsof_output = Command::new("lsof")
            .arg(format!("-tiTCP:{}", target_port))
            .args(["-sTCP:LISTEN", "-nP"])
            .output();

        let pids: HashSet<u32> = match lsof_output {
            Ok(o) if o.status.success() => String::from_utf8_lossy(&o.stdout)
                .lines()
                .filter_map(|s| s.trim().parse::<u32>().ok())
                .collect(),
            _ => HashSet::new(),
        };

        if pids.is_empty() {
            println!("no process is listening on port {}", target_port);
            return Ok(());
        }

        for pid in pids {
            let term = Command::new("kill")
                .args(["-TERM", &pid.to_string()])
                .status()
                .context("Invoke kill -TERM")?;

            if term.success() {
                println!("terminated {}", pid);
                continue;
            }
        }
    }

    Ok(())
}
