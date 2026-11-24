# Darpan

Darpan is a web page that controls the OBSBOT Meet SE webcam on Linux.
It is an independent, unofficial project.
It is not affiliated with, endorsed by or supported by OBSBOT.
OBSBOT and Meet SE are trademarks of their owners.

Open the page: <https://vrm-infra.github.io/darpan/>

## Two modes

- Browser mode needs nothing to install.
  The page shows the controls the browser offers for your camera: zoom, pan, tilt, focus, exposure, white balance, brightness, contrast, saturation and sharpness.
  It shows only what the browser reports for that camera.
- Helper mode adds auto framing, HDR, gestures, microphone settings, sleep, the LED and saved profiles.
  It needs the Darpan helper, a small program that runs on your computer.
  The page finds it by itself on `http://127.0.0.1:8737`.

The page never sends your video or settings to any server.
It talks only to your browser and to the helper on your own computer.

## Install the helper

Linux on x86_64 or aarch64, with systemd.
No sudo is needed.

```bash
curl -fsSL https://vrm-infra.github.io/darpan/install.sh | sh
```

The script downloads the binary from the latest release in this repository.
It checks the SHA-256 against `SHA256SUMS` from the same release.
It installs `~/.local/bin/obsbot` and starts it at login as a systemd user service.

Remove it again:

```bash
curl -fsSL https://vrm-infra.github.io/darpan/install.sh | sh -s -- --uninstall
```

## Other downloads

The releases of this repository also hold:

- `obsbot-linux-x86_64` and `obsbot-linux-aarch64`: the static binaries.
- `obsbot_<version>_amd64.deb` and `obsbot_<version>_arm64.deb`: Debian and Ubuntu packages.
  They install `/usr/bin/obsbot` and a systemd user unit.
  Start it with `systemctl --user enable --now obsbot.service`.
- `SHA256SUMS`: the checksums of all files above.

## Browser notes

- Chrome and Edge ask once for camera access, and once for permission to move the camera (pan, tilt, zoom).
- A public page that calls your own computer needs a permission in Chrome 142 and newer.
  Allow it when Chrome asks.
- Only Chrome is tested.
  A browser that blocks a public page from calling `127.0.0.1` cannot use helper mode, but browser mode still works.

## License

MIT. See `LICENSE`.
