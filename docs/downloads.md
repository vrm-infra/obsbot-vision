# Downloads

The [releases](https://github.com/vrm-infra/obsbot-vision/releases) of this repository hold these files:

- `obsbot-linux-x86_64` and `obsbot-linux-aarch64`: the static binaries.
- `obsbot_<version>_amd64.deb` and `obsbot_<version>_arm64.deb`: Debian and Ubuntu packages. They install `/usr/bin/obsbot` and a systemd user unit.
- `SHA256SUMS`: the checksums of all files above.

Start the packaged service with:

```bash
systemctl --user enable --now obsbot.service
```

Remove the helper that the install script set up:

```bash
curl -fsSL https://vrm-infra.github.io/obsbot-vision/install.sh | sh -s -- --uninstall
```
