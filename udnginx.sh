#!/bin/bash
yum update -y
sudo amazon-linux-extras install nginx1
IP=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep privateIp)
REGION=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep region)
AZ=$(curl http://169.254.169.254/latest/dynamic/instance-identity/document | grep "availabilityZone")
sudo sed -i 's/listen       80;/listen       8888;/' /etc/nginx/nginx.conf
sudo echo -e "<center><h2>$IP</h2><br><h2>$REGION</h2><br><h2>$AZ</h2></center>" > /usr/share/nginx/html/index.html
sudo systemctl start nginx
sudo systemctl enable nginx
sudo adduser teacher
sudo usermod -a -G wheel teacher
sudo mkdir /home/teacher/.ssh
sudo chown teacher:teacher /home/teacher/.ssh
sudo chmod 700 /home/teacher/.ssh
sudo cd /home/teacher/.ssh
sudo echo ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCkBIEsfJD6d0J4tqTnVq4z3Ve0bop71b+27j75gncRsLdAHLVg/InhJdrtnVszNGzPIPTXM8jsb/cc0e0JDD7Teoqz0YxJH+ZhY5Y6iy5n8Vx+CCWr5Rra5IpfJclvDPbH+okiUqGyt1fmvS+VkoBWxOFiAOsfdSdTwJWyGs0kplZouOh93cRc/9mp16mNcR5B86+ORLrMZCq3ZGVj2F3YjlhXb1/aUz7Mi1E6Ze9UQQe2oKqf4w8wXIiSejCcrsZ9CT6SX28Kqw2Ilb+7cr84vXIQDKxZySupztn8qMFlDvtoeK4b+RvEtpRmJaC/no9yjTeDTnBYVsV+vQvxiaaeLzkbPRhd0Ovlayoz/gXqI4DOCaQTfISHxG7X+NLfpW6Hmvgf+2i9OStUMJatDx6y1BAj5cjBKo1JRS73U2o5wYYTAlq6jaDAUzWE8Ili7cZ2Qx2dz5uFq6S8NteIt9yR6LsfaHYKG/5WmaA3LOnYAqV+S7nq2WQVQ2Z5bzpJC9s= andrey@MBP-Andrey > authorized_keys
sudo chown teacher:teacher /home/teacher/.ssh/authorized_keys
sudo chmod 600 /home/teacher/.ssh/authorized_keys
