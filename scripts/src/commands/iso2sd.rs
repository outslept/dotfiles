use anyhow::{Result, bail};
use clap::Args;
use std::path::PathBuf;

#[derive(Args)]
pub struct Iso2sdArgs {
    /// Path to ISO image
    pub input: PathBuf,
    /// Output device (e.g. /dev/sda)
    pub device: PathBuf,
}

pub fn run(args: Iso2sdArgs) -> Result<()> {
    #[cfg(not(target_os = "linux"))]
    {
        bail!("iso2sd is only supported on Linux");
    }

    #[cfg(target_os = "linux")]
    {
        let input_image_path = args.input;
        let output_device_path = args.device;

        if !input_image_path.exists() {
            bail!("Input file not found: {}", input_image_path.display());
        }

        // dd bs=4M status=progress oflag=sync if=<iso> of=<dev>
        let dd_status = Command::new("sudo")
            .args([
                "dd",
                "bs=4M",
                "status=progress",
                "oflag=sync",
                &format!("if={}", input_image_path.display()),
                &format!("of={}", output_device_path.display()),
            ])
            .status()
            .context("run dd")?;

        if !dd_status.success() {
            bail!("dd failed");
        }

        let _ = Command::new("sudo")
            .args(["eject", &output_device_path.to_string_lossy()])
            .status();

        println!(
            "ok: wrote {} to {}",
            input_image_path.display(),
            output_device_path.display()
        );
        Ok(())
    }
}
