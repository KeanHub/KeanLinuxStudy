# nginx静态部署

实验前准备：
1.一个简单的.html文件，桌面创建一个txt文件，里面输入几个文字，然后保存，后缀改为.html，这样一个简单的html文件就创建完成啦
2.一个干净的linux环境，我用的是vmware虚拟机配置的centos8版本
3.为了模拟真实环境，我选择使用xshell连接虚拟机，登录上系统后，直接把文件拖拽进xshell的桌面即可

实验步骤：
1.安装nginx。由于是centos8，所以使用yum安装，但是centos8的yum源已经过时了，直接使用命令：yum install nginx安装会报错，所以需要更换成国内的镜像yum源，操作如下:
    1.1.备份yum源,使用命令：
    mkdir -p /etc/yum.repos.d/bak创建一个备份目录
    mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/备份原始yum源
    1.2.下载阿里云的yum源，使用命令：curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo
    1.3.下载epel扩展源，虽然安装好阿里云的yum源头，但是这个仓库并没有我们需要的nginx等第三方软件，所以需要下载epel扩展源，使用命令：yum install epel-release -y，两者是依赖关系，顺序不能颠倒。现在我们已经成功更换了yum源，可以进行安装nginx了。
    1.4.安装nginx，使用命令：yum install nginx -y

2.移动文件。把准备好的HTML文件移动到nginx的html目录下，使用命令：mv ./demo.html /usr/share/nginx/html/demo.html。
  小技巧：注意.代指当前目录，请先进入存放html文件的文件夹中。
            usr目录存放在根目录，root用户默认在root目录，一般用户进入默认是home目录，所以你前面不加/usr他是识别不出来的是根目录的。
            敲路径有一个小技巧，不要全部手打，打一两个字母，按一下TAB，会自动补全剩下的路径，也防止手误。

3.修改自定义站点配置。使用代码vim /etc/nginx/conf.d/demo.conf，然后粘贴（ctrl+shift+v）最简配置：server {
                listen 80;
                server_name localhost;
                root /usr/share/nginx/html;
                index demo.html;
             }
  然后保存退出，退出方法是冒号wq       :wq

4.校验启动。校验配置语法（必做，防止写错启动失败）使用命令：nginx -t，看到ok，success就是正确的。启动nginx，使用命令systemctl start nginx。此时nginx已经启动成功。
  打开浏览器输入本机ip地址/html文件名，本机IP可以用命令ip a 查看，一般是查看ens160网卡的ip，就可以看到我们创建的html文件了。
5.但是我这里并没有看到任何页面，显示404超时，大概率因为防火墙问题，打开防火墙，使用命令firewall-cmd --add-service=http --permanent
  firewall-cmd --reload
  再重启一下nginx，使用命令systemctl restart nginx。
6.403 Forbidden问题。如果你跟我一样遇到了403 Forbidden问题，首先已经连通，但是没有给你资源，那就要测试setenforce 0，这是临时屏蔽SELinux的命令，如果可以访问，说明  
  SELinux的拦截了你的请求，先再次启动SELinux，这个是很重要的东西，不要自行关闭，然后请修复权限，使用命令：chmod -R 755 /usr/share/nginx/html，再修复SELinux标签使用命令：restorecon -R /usr/share/nginx/html，最后重载nginx，使用命令：nginx -s reload就可以看到你的HTML文件了。
  如果说上面的方案并没有解决，说明有可能是nginx的配置写的有问题，或者其他权限问题。



