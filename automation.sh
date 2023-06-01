#!/bin/bash

sudo apt update -y
if dpkg -s apache2 >/dev/null 2>&1; then
    echo "Apache2 is installed."
else
    sudo apt install -y apache2
fi
sudo systemctl enable apache2
sudo systemctl status apache2

cd /var/log/apache2
ls -la
sudo tar -cvf /tmp/httpd_logs-$(date '+%d%m%Y-%H%M').tar *.log
cp /tmp/httpd_logs-$(date '+%d%m%Y-%H%M').tar /home/ubuntu/logsstoringlogs

sudo apt-get install awscli -y
aws s3 ls
aws s3 cp /tmp/httpd_logs-$(date '+%d%m%Y-%H%M').tar s3://upgrad-anuroopn/
sudo chmod 777 /home/ubuntu/logsstoringlogs/httpd_logs-$(date '+%d%m%Y-%H%M').tar
sudo apt install -y git
git --version

file_name="$1"
path="/var/www/html/$file_name"

if [ -f "$path" ]; then
    echo "$file_name exists in the path."
else
    echo "As $file_name is not there, creating a new file in the path."
    touch "$path"
    echo "File has been created in the path."
fi

if [ -f "$path" ]; then
    sudo chmod a+w "$path"
fi

echo "Content appending to the path $path"

tarfilename="httpd-logs"
filetype="tar"
datecreated=$(date '+%d%m%Y-%H%M%S')
pwd
cd /home/ubuntu/logsstoringlogs
pwd
ls -la
tar_file=$(ls -t httpd_logs-*.tar | head -n 1)
tarsize=$(du -k "$tar_file" | awk '{print $1}')
echo -e "$tarfilename\t$datecreated\t        $filetype\t$tarsize k" >> "$path"

if [ -f "$path" ]; then
    sudo chmod a-w "$path"
fi

cat "$path"

# CRONJOB creation
if [ -d "root/upgradautomation_project" ]; then 
	echo "directory exists in the path"
fi
sudo cp /home/ubuntu/automationfiles/automation.sh /root/upgradautomation_project
cron_content="* * * * * root /root/upgradautomation_project/automation.sh"
echo "$cron_content" | sudo tee /etc/cron.d/automation > /dev/null
sudo chown root:root "/etc/cron.d/automation"
sudo chmod 644 "/etc/cron.d/automation"
echo "Cron job created successfully"

