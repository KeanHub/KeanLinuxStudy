#!/bin/bash
#
#*************************************************************#
#Author:                  xiaxiao
#Date:                 26-07-24
#FileName:              lnmp_install.sh
#Description: 前置要求：系统已提前装好 nginx php php-mysqlnd mariadb-server；仅自动生成配置、启动服务
#CopyRight(c)26All right reserved
#*************************************************************#

# 1. 防火墙放行80网页服务，永久生效重载
firewall-cmd --add-service=http --permanent
firewall-cmd --reload
# 临时关闭SELinux，修复网站目录安全上下文
setenforce 0
restorecon -R /usr/share/nginx/html

# 2. 注释nginx主配置自带默认server，解决站点冲突
sed -i "s/listen       80;/#listen       80;/" /etc/nginx/nginx.conf
sed -i "s/server_name  _;/#server_name  _;/" /etc/nginx/nginx.conf

# 3. 启动mysqld并设置开机自启
systemctl start mysqld
systemctl enable mysqld

# 4. 修改php-fpm配置，追加9000端口监听
sed -i '/;listen = \/run\/php-fpm\/www.sock/a listen = 127.0.0.1:9000;' /etc/php-fpm.d/www.conf
# 启动php-fpm并设置开机自启，重启加载新端口配置
systemctl start php-fpm
systemctl enable php-fpm
systemctl restart php-fpm

# 5. 创建nginx php转发配置文件
cat > /etc/nginx/conf.d/demo.php.conf <<EOF
server {
    listen 80 default_server;
    server_name _;
    root /usr/share/nginx/html;
    index index.html index.htm index.php;

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include fastcgi_params;
    }
}
EOF

# 6. 创建数据库测试demo.php页面（已删除所有<br>）
cat > /usr/share/nginx/html/demo.php <<EOF
<?php
\$host = '127.0.0.1';
\$user = 'root';
\$pwd = '1190750452Xx.';
\$dbname = 'user';
\$conn = mysqli_connect(\$host,\$user,\$pwd,\$dbname);
if(!\$conn){
    die("数据库连接失败：".mysqli_connect_error());
}
echo "网站成功连上MySQL数据库！";
\$sql = "SELECT * FROM user";
\$result = mysqli_query(\$conn,\$sql);
while(\$row = mysqli_fetch_assoc(\$result)){
    echo "ID：{\$row['id']}，用户名：{\$row['username']}，密码：{\$row['password']}";
}
mysqli_close(\$conn);
?>
EOF

# 7. 设置网站目录权限
chmod -R 755 /usr/share/nginx/html

# 8. 校验nginx配置、平滑重载，再设置开机自启
nginx -t && nginx -s reload
systemctl start nginx
systemctl enable nginx

# 9. 部署完成提示
echo "部署完毕，使用 服务器IP/demo.php 访问测试页面"
