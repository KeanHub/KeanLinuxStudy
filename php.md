# php链接nginx和数据库

1. 安装php和相关的软件，yum源问题看千蚊nginx.md中有讲到,直接使用命令：yum install php php-mysql -y，启动nginx，使用命令：systemctl start nginx。启动php-fpm，使用命令：systemctl start php-fpm。启动mysql，使用命令：systemctl start mysqld。
2. 配置一个nginx关于php的转发配置文件。使用命令：vim /etc/nginx/conf.d/demo.php.conf，然后把下面内容粘贴进去
  server {
    listen 80 default_server;
    server_name _;
    root /usr/share/nginx/html;
    index index.html index.htm index.php;

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }
}
然后检测语法，重载nginx，使用命令：nginx -t && nginx -s reload。
打开/etc/php-fpm.d/www.conf，找到;isten = /run/php-fpm/www.sock，在下面加入listen = 127.0.0.1:9000  ，注意后面没有标点符号，：
重启systemctl restart php-fpm
然后检测语法，重载nginx，使用命令：nginx -t && nginx -s reload。

3. 创建一个demo.php文件，使用命令：vim /usr/share/nginx/html/demo.php，然后把下面内容粘贴进去。
<?php
// 数据库信息
$host = '127.0.0.1';   // 本机数据库
$user = 'root';         // mysql登录账号
$pwd = '你的mysql密码'; // 
$dbname = 'user_db';    // 数据库名称

// 创建连接
$conn = mysqli_connect($host, $user, $pwd, $dbname);

// 判断连接是否失败
if (!$conn) {
    die("数据库连接失败：" . mysqli_connect_error());
}
echo "✅ 网站成功连上MySQL数据库！<br>";

// 查询表里所有用户
$sql = "SELECT * FROM user";
$result = mysqli_query($conn, $sql);

// 循环输出账号密码
while ($row = mysqli_fetch_assoc($result)) {
    echo "ID：{$row['id']}，用户名：{$row['username']}，密码：{$row['password']}<br>";
}

// 关闭连接
mysqli_close($conn);
?>
4. 测试访问。写完 demo.php 后，先在终端执行php /usr/share/nginx/html/demo.php，先确认 PHP 代码本身无语法、数据库连接问题，再通过浏览器访问，使用ip/demo.php访问如果出现结果则说明成功。
5. 典型问题：
200 OK（浏览器下载 PHP 源码）
未配置 default_server、php-fpm 未监听 9000、Nginx PHP 转发配置失效
404 Not Found
文件路径 / 名字写错、nginx 根目录配置错误
403 Forbidden
SELinux 拦截、文件权限不足
500 Internal Server Error
Call to undefined function mysqli_connect：缺少 php-mysqlnd
Connection refused：MySQL 没启动
Unknown database：user_db 数据库未创建
502 Bad Gateway
php-fpm 未正常监听 127.0.0.1:9000