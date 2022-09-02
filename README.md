# handbrake-custom-build
Custom Handbrake build container


## Add Repo:
```
apt-get install software-properties-common
apt-add-repository 'deb [arch=amd64] https://smeinecke.github.io/handbrake-deb/repo bullseye main'
wget -O ~/handbrake.key https://smeinecke.github.io/handbrake-deb/public.key
gpg --no-default-keyring --keyring ./handbrake_keyring.gpg --import handbrake.key
gpg --no-default-keyring --keyring ./handbrake_keyring.gpg --export > ./handbrake.gpg
mv ./handbrake.gpg /etc/apt/trusted.gpg.d/
```
