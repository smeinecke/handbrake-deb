# handbrake-deb
Custom HandBrake build container and Debian/Ubuntu APT repository.

## Supported distributions
- **APT repository**
  - bullseye
  - bookworm
  - focal
  - jammy
  - noble
- **Build flavors**
  - bullseye
  - bookworm
  - trixie
  - focal
  - jammy
  - noble

## Use the APT repository
- **Manual setup**

```bash
sudo apt-get update
sudo apt-get install -y software-properties-common wget lsb-release ca-certificates
sudo wget -O /usr/share/keyrings/smeinecke.github.io-handbrake-deb.key https://smeinecke.github.io/handbrake-deb/public.key
sudo apt-add-repository "deb [signed-by=/usr/share/keyrings/smeinecke.github.io-handbrake-deb.key arch=amd64] https://smeinecke.github.io/handbrake-deb/repo $(lsb_release -sc) main"
sudo apt-get update
```

- **One-liner**

```bash
wget -O- https://smeinecke.github.io/handbrake-deb/add-repository.sh | bash
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
