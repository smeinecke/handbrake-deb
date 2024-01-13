# handbrake-custom-build
Custom Handbrake build container and debian repository for handbrake.

## Supports:
 * bullseye
 * bookworm
 * focal
 * jammy
 * mantic


## Add Repo:
```
apt-get install software-properties-common wget lsb-release ca-certificates
wget -O /usr/share/keyrings/smeinecke.github.io-handbrake-deb.key https://smeinecke.github.io/handbrake-deb/public.key
apt-add-repository "deb [signed-by=/usr/share/keyrings/smeinecke.github.io-handbrake-deb.key arch=amd64] https://smeinecke.github.io/handbrake-deb/repo $(lsb_release -sc) main"
```
or
```
wget -O- https://smeinecke.github.io/handbrake-deb/add-repository.sh | bash
```
