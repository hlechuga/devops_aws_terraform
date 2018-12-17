#cloud-boothook
#!/bin/bash
set -euf -o pipefail
exec 1> >(tee user-data.log | logger -s -t $(basename -- $0)) 2>&1
echo '----------START-----------'
sslverify=0
yum install python-pip
pip install --upgrade pip
pip install ansible
echo '----------END-----------'