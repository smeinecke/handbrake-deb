# handbrake-deb
Custom HandBrake build container and Debian/Ubuntu APT repository.

This build includes support for **fdk-aac**, **numa**, **Intel QSV**, and **NVIDIA NVENC/NVDEC**.
Note: the normal/stock HandBrake build typically does not include **fdk-aac**, **numa** or **Intel QSV** enabled out of the box.

## Supported distributions
- **APT repository**
  - bullseye
  - bookworm
  - trixie
  - focal
  - jammy
  - noble
  - resolute
- **Build flavors**
  - bullseye
  - bookworm
  - trixie
  - focal
  - jammy
  - noble
  - resolute

## Use the APT repository
- **One-liner**

```bash
wget -O- https://smeinecke.github.io/handbrake-deb/add-repository.sh | bash
```

The script automatically detects whether your system uses the legacy one-line `.list` format or the modern DEB822 `.sources` format and writes the matching file.

- **Manual setup (legacy)**

For older releases that still use one-line sources (e.g. Debian bookworm, Ubuntu focal/jammy):

```bash
sudo apt-get update
sudo apt-get install -y lsb-release ca-certificates wget
sudo wget -O /usr/share/keyrings/smeinecke.github.io-handbrake-deb.key https://smeinecke.github.io/handbrake-deb/public.key
sudo tee /etc/apt/sources.list.d/smeinecke-handbrake-deb.list >/dev/null <<EOF
deb [signed-by=/usr/share/keyrings/smeinecke.github.io-handbrake-deb.key arch=amd64] https://smeinecke.github.io/handbrake-deb/repo $(lsb_release -sc) main
EOF
sudo apt-get update
```

- **Manual setup (DEB822)**

For releases that have switched to DEB822 sources (e.g. Debian trixie, Ubuntu noble/resolute):

```bash
sudo apt-get update
sudo apt-get install -y lsb-release ca-certificates wget
sudo wget -O /usr/share/keyrings/smeinecke.github.io-handbrake-deb.key https://smeinecke.github.io/handbrake-deb/public.key
sudo tee /etc/apt/sources.list.d/smeinecke-handbrake-deb.sources >/dev/null <<EOF
Types: deb
URIs: https://smeinecke.github.io/handbrake-deb/repo
Suites: $(lsb_release -sc)
Components: main
Signed-By: /usr/share/keyrings/smeinecke.github.io-handbrake-deb.key
Architectures: amd64
EOF
sudo apt-get update
```

Install packages:

```bash
sudo apt-get install -y handbrake handbrake-cli
```

## Build locally (Docker)
This repository includes a local helper that builds inside a container and copies resulting `*.deb` files into the current directory.

```bash
./build_in_container.sh <deb_flavor> <hb_tag>
```

Example:

```bash
./build_in_container.sh bookworm 1.10.2
```
