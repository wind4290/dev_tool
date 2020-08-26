#! /bin/sh

echo "#########################"
echo "###    SHUTDOWN SHELL ###"
echo "###                   ###"
echo "###    MICRO SERVICE  ###"
echo "###                   ###"
echo "###    POWERED BY SQ  ###"
echo "#########################"
echo ""
echo ""

#定义操作参数
array_opr=(
    '[no arg]        show opr info'
    '[-l]            list all appNum'
    '[-a]            shutdown all app'
    '[-s] [appNum]   shutdown a specify app by appNum'
)

#定义应用绝对路径
array_app=(
    '/home/bimuser/bimgis-data-service/services/data_manage/bimgis-ebs-app-1.0.0.jar'
    '/home/bimuser/bimgis-data-service/services/bimgis-data-aggr-app-1.0.0.jar'
)

#app文件名列表
array_name=()

DEPLOY_LOG='shutdown.log'

#初始化app文件名
if [ ${#array_app[*]} -gt 0 ];then
   for((i = 0; i < ${#array_app[*]}; i++));do
       item_tmp=${array_app[$i]}
       array_tmp=(${item_tmp//// })
       length_tmp=${#array_tmp[*]}
       array_name[$i]=${array_tmp[$length_tmp-1]}
   done
fi



#列出定义的操作参数
if [ $# -lt 1 ];then
   echo "args defined as follows:"
   for((i = 0; i < ${#array_opr[*]}; i++));do
       echo "${array_opr[$i]}"
   done
   exit 0

#列出待处理的应用及编号
elif [ $1 == '-l' ];then
   echo "app list(appNum|state|pid|appName):"
   for((i = 0; i < ${#array_name[*]}; i++));do
       PID=`ps x|grep ${array_name[$i]}|grep -v grep |awk '{print $1}'`
       if [ -z "$PID" ]; then
          printf "%d|%-7s|%-10s|%s\n" $i dead ----- ${array_name[$i]}
       else
          printf "%d|%-7s|%-10s|%s\n" $i running $PID ${array_name[$i]}
       fi
   done
   exit 0

#全部关闭
elif [ $1 == "-a" ];then
   echo "shutdown all app..."

   for((i = 0; i < ${#array_name[*]}; i++));do
       PID=`ps x|grep ${array_name[$i]}|grep -v grep |awk '{print $1}'`
       echo "shutdown appName=${array_name[$i]},appNum=$i"
       if [ -z "$PID" ]; then
          echo "system process is not exist,skip to next app"
       else
          echo "pid=$PID"
          kill -15 $PID
       fi
   done
   sleep 5 #暂停5秒等待最后一个被关闭的进程退出

#指定关闭一个应用
elif [ $# -eq 2 ] && [ $1 == '-s' ];then
     name_tmp=${array_name[$2]}
   
     PID=`ps x|grep $name_tmp|grep -v grep |awk '{print $1}'`
     echo "shutdown appName=$name_tmp,appNum=$2"
     if [ -z "$PID" ]; then
          echo "system process is not exist，shutdown opr is fail"
       else
          echo "pid=$PID"
          kill -15 $PID
     fi
     sleep 5 #暂停5秒等待最后一个被关闭的进程退出

#不支持
else
   echo "no suppors the arg,input sh shutdown.sh with no args to get args info"
fi

echo "done!"
exit 0
