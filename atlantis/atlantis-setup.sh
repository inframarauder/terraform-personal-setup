#!/bin/bash
set -eux

# install utilities
apt-get update -y
apt-get install curl -y
apt-get install wget -y
apt-get install htop -y
apt-get install unzip -y

# install terraform
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt-get update
sudo apt-get install terraform -y

# download atlantis
wget https://github.com/runatlantis/atlantis/releases/download/v0.23.4/atlantis_linux_386.zip
unzip atlantis_linux_386.zip
mv atlantis /usr/local/bin/

# setup atlantis variables
URL=$(curl -s http://169.254.169.254/latest/meta-data/public-hostname)
ATLANTIS_URL="http://$URL:4141"
GH_USER="${gh_username}"
GH_TOKEN="${gh_pat}"
GH_WEBHOOK_SECRET="${gh_webhook_secret}"
GH_REPO_ALLOWLIST="${gh_repo_allowlist}"

# create atlantis start script
echo "
#!/bin/bash
set -eux

atlantis server \
--gh-user=$GH_USER \
--gh-token=$GH_TOKEN \
--gh-webhook-secret=$GH_WEBHOOK_SECRET \
--repo-allowlist=$GH_REPO_ALLOWLIST \
--atlantis-url=$ATLANTIS_URL 
" >> /usr/local/bin/atlantis-start.sh

# make atlantis start script executable
chmod +x /usr/local/bin/atlantis-start.sh

# create atlantis service
echo "
[Unit]
Description=Atlantis

[Service]
Type=simple
User=root
ExecStart=/bin/bash /usr/local/bin/atlantis-start.sh
Restart=always

[Install]
WantedBy=multi-user.target
" >> /etc/systemd/system/atlantis.service

# start atlantis service
systemctl daemon-reload
systemctl enable atlantis.service
systemctl start atlantis.service


