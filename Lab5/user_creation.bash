sudo adduser AwesamUsername
sudo chfn AwesamUsername
su - AwesamUsername
sudo groupadd DevGroup
sudo usermod -aG DevGroup AwesamUsername
sudo pkill -KILL -u AwesamUsername
sudo deluser --remove-home --force AwesamUsername

echo """
Wooo! More users! More useful in system administration, but still.
Adjusting permissions of users is highly conclusive to them not nuking the
company's infrastructure!
"""