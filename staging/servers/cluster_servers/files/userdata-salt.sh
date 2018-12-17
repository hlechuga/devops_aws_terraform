#cloud-boothook
#!/bin/bash
set -euf -o pipefail
exec 1> >(tee user-data.log | logger -s -t $(basename -- $0)) 2>&1
echo '----------START-----------'
sslverify=0
yum -y install git
git config --system credential.helper '!aws codecommit credential-helper $@'
git clone ssh://APKAJKB2IFN7CTXOASFQ@git-codecommit.ap-southeast-1.amazonaws.com/v1/repos/simple_salt /srv/salt
chmod 700 /srv/salt
yum -y install 

echo '----------END-----------'