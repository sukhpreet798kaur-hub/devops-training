# Check open ports before
ss -tulpen | grep LISTEN > /root/ports_before.txt

# Install and configure ufw
sudo apt-get update
sudo apt-get install -y ufw
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable

# Show rules and open ports after
sudo ufw status verbose > /root/firewall_rules.txt
ss -tulpen | grep LISTEN > /root/ports_after.txtsudo chown -R www-data:www-data /var/www/html
sudo chmod -R 750 /var/www/html
sudo find /var/www/html -type f -name "*.php" -exec chmod 640 {} \;

script/log_review.sh

Executable an dun it
cd ~/devops
chmod +x scripts/log_review.sh
./scripts/log_review.sh | tee /root/log_review_sample.txt

Fail2ban configuration

sudo apt-get update
sudo apt-get install -y fail2ban

# Create config
sudo mkdir -p /etc/fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local
sudo systemctl restart fail2ban
sudo systemctl status fail2ban
