#!/bin/bash
#
#***********************************************#
#Author:                                  xiaxiao
#Date:                      26-07-17
#FileName:                           aliyun_yum_epel.sh
#Description: This simple shell script quickly configures domestic YUM sources by stacking raw commands, suitable for beginner learning.                                   
#CopyRight(c)26All right reserved
#***********************************************#
mkdir -p /etc/yum.repos.d/bak
mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/bak/
curl -o /etc/yum.repos.d/CentOS-Base.repo https://mirrors.aliyun.com/repo/Centos-8.repo
yum install epel-release -y
