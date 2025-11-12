#!/bin/bash -xe

# STEP 1 - Updates
yum -y update

# STEP 2 - Begin Configuration
yum -y install httpd wget cowsay curl python3 pip3
amazon-linux-extras install -y php7.2
amazon-linux-extras install epel -y
yum install stress -y
pip3 install random-cat
systemctl enable httpd
systemctl start httpd

# STEP 2 - Custom Random Web Page
bgcolor=$(printf "%02x%02x%02x\n" $((RANDOM%256)) $((RANDOM%256)) $((RANDOM%256)))
TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")
instanceId=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" http://169.254.169.254/latest/meta-data/instance-id)
# wget -O /var/www/html/cat.gif "http://thecatapi.com/api/images/get?format=src&type=gif&api_key=8f7dc437-0b9b-47b8-a2c0-65925d593acf"
echo "<html><head>" >> /var/www/html/index.php
echo "<meta http-equiv=\"Cache-Control\" content=\"no-cache, no-store, must-revalidate\">" >> /var/www/html/index.php
echo "<meta http-equiv=\"Pragma\" content=\"no-cache\">" >> /var/www/html/index.php
echo "<meta http-equiv=\"Expires\" content=\"0\">" >> /var/www/html/index.php
echo "</head><body style=\"background-color:#$bgcolor;\">" >> /var/www/html/index.php
echo "<center><h1>Instance ID : $instanceId</h1></center><br>" >> /var/www/html/index.php
# echo "<center><img src=\"cat.gif?nocache=<?php echo time(); ?>\">" >> /var/www/html/index.php
echo "</body></html>" >> /var/www/html/index.php

# Step 4 - permissions 
usermod -a -G apache ec2-user   
chown -R ec2-user:apache /var/www
chmod 2775 /var/www
find /var/www -type d -exec chmod 2775 {} \;
find /var/www -type f -exec chmod 0664 {} \;

# STEP 5 COWSAY
echo "#!/bin/sh" > /etc/update-motd.d/40-cow
echo 'cowsay "Amazon Linux 2 AMI - Animals4Life"' > /etc/update-motd.d/40-cow
chmod 755 /etc/update-motd.d/40-cow
rm /etc/update-motd.d/30-banner
update-motd