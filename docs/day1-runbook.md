## Installation Steps

1. Updated package index  
   ```bash
   sudo apt update
   ```

2. Installed Apache, MySQL, PHP  
   ```bash
   sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql
   ```

3. Enabled and started services  
   ```bash
   sudo systemctl enable apache2
   sudo systemctl start apache2
   sudo systemctl enable mysql
   sudo systemctl start mysql
   ```

4. Enabled Apache modules  
   ```bash
   sudo a2enmod rewrite headers ssl
   sudo systemctl reload apache2
   apache2ctl -M
   ```

5. Created webadmin user and site directory  
   ```bash
   sudo adduser --disabled-password --gecos "" webadmin
   sudo mkdir -p /var/www/html
   sudo chown -R webadmin:webadmin /var/www/html
   ls -ld /var/www/html
   ```

6. Configured Apache virtual host  
   ```bash
   sudo nano /etc/apache2/sites-available/html.conf
   sudo a2dissite 000-default.conf
   sudo a2ensite html.conf
   sudo systemctl reload apache2
   ```

7. Created site pages (`index.php`, `about.php`, `contact.php`, `info.php`) as described.

## Validation

- `http://localhost` loads the Day 1 Home page.
- `http://localhost/info.php` shows PHP info.
