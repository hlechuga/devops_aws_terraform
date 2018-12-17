#cloud-boothook
#!/bin/bash
set -euf -o pipefail
exec 1> >(tee user-data.log | logger -s -t $(basename -- $0)) 2>&1
echo '----------START-----------'
# subscription-manager remove --all
# subscription-manager unregister
# subscription-manager clean
# subscription-manager register
# subscription-manager refresh
# subscription-manager attach --auto
sslverify=0
# yum -y update
# yum -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum -y install nginx
# mkdir -p /var/www/sample
# touch /var/www/sample/index.html
# cat > /var/www/sample/index.html <<EOF
# <h1>I'm a webserver cluster</h1>
# <p>DB address: ${db_address}</p>
# <p>DB port: ${db_port}</p>
# EOF
sed -i 's/80/${server_port}/g' /etc/nginx/nginx.conf
# sed -i 's/\/usr\/share\/nginx\/html/\/var\/www\/sample/g' /etc/nginx/nginx.conf
chkconfig nginx on
service nginx start
echo '----------END-----------'