# MySQL 日常管理 1：账号密码修改、用户授权管理

注意：在本文我将介绍mysql的一些日常使用方法，大由于mysql使用的语言是SQL，所以如 果我前面标注sql，那么表明是登陆mysql后使用SQL命令，不同于在linux命令行使用的bash命令，mysql命令后面一般都带一个分号；代表语句结束。


1. 首先启动mysald，使用命令：systemctl start mysqld，登陆mysql，使用命令：mysql -uroot -p。
2. 修改root密码。当我们想要修改root密码，那我们先登陆mysql，然后使用sql命令：alter user 'root'@'localhost' identified by '新密码';，再重载一下，使用sql命令：flush privileges;，就修改好了。
3. 用户创建与授权。真实的生产环境中，一般都会存在多个用户，每个用户都有不同的权限，比如数据库管理员、开发人员、测试人员等等。那么我们如何创建用户，给用户分配不同的权限呢？
   3.1 创建用户。使用sql命令：create user '用户名'@'localhost' identified by '密码'；，可以退出一下，使用命令：mysql -u用户名 -p，输入密码，就可以登陆了。
   3.2 授权用户。使用sql命令：grant 权限 on 数据库.表 to '用户名'@'localhost';，这里的权限有，all privileges(所有权限)、select（查表内容）、insert（增加表内容）、update（改表内容）、delete（删表内容），create（创建表结构）、drop（删除表结构）、alter（修改表结构）等等。表结构与表内容的区别就在，如果你删了表内容相当于在一个excel中删除了数据，文件本身还在，如果你删除了表结构，相当于在excel中删除了整个文件。比如：grant select on 库名.表名 to '用户名'@'localhost';，表示给用户名授予查找权限，一般的数据库用户最多只能给查找权限。如果是需要有写入等需求的用户，也只能给对于表内容相关修改的权限：select、insert、update、delete，切忌授权DROP、ALTER这类高危权限，避免程序异常误删表。