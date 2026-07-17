#!/bin/bash
#
#***********************************************#
#Author:                                  xiaxiao
#Date:                      26-07-17
#FileName:                           deploy_nginx_static.sh
#Description:                                    
#CopyRight(c)26All right reserved
#***********************************************#
mv $1 /usr/share/nginx/html/
echo "server {
                listen 80;
                server_name localhost;
                root /usr/share/nginx/html;
                index $1;
             }" > /etc/nginx/conf.d/"$1.conf"
firewall-cmd --add-service=http --permanent
firewall-cmd --reload
chmod -R 755 /usr/share/nginx/html
restorecon -R /usr/share/nginx/html
systemctl restart nginx
echo "部署完成，浏览器访问 http://本机IP/$1  即可查看"


