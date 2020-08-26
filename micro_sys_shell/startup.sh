#! /bin/sh

echo "#########################"
echo "###    STARTUP SHELL  ###"
echo "###                   ###"
echo "###    MICRO SERVICE  ###"
echo "###                   ###"
echo "###    POWERED BY SQ  ###"
echo "#########################"
echo ""
echo ""

#定义操作参数
array_opr=(
    '[no arg]         show opr info'
    '[-l]             list all appNum'
    '[-a]             start all app'
    '[-s]  [appNum]   start a specify app by appNum'
    '[-st] [appNum]   start a specify app by appNum and trace log file'
    'example for start a specify app: sh startup.sh -s 1'
)

#定义应用存放的绝对路径
array_app=(
    '/home/bimuser/bimgis-data-service/services/data_manage/bimgis-ebs-app-1.0.0.jar'
    '/home/bimuser/bimgis-data-service/services/bimgis-data-aggr-app-1.0.0.jar'
)

#app文件名列表
array_name=()

DEPLOY_LOG='startup.log'

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
          #echo "$i|dead   |-----|${array_name[$i]}"
          printf "%d|%-7s|%-10s|%s\n" $i dead ----- ${array_name[$i]}
       else
          #echo "$i|running|$PID|${array_name[$i]}"
          printf "%d|%-7s|%-10s|%s\n" $i running $PID ${array_name[$i]}
       fi
   done
   exit 0

#全部启动
elif [ $1 == "-a" ];then
   echo "startup all app..."
   for((i = 0; i < ${#array_app[*]}; i++));do
       echo "startup appNum=$i,appPath=${array_app[$i]}"
       if [ ! -f "${array_app[$i]}" ];then
          echo "${array_app[$i]} is not exist! start app fail!"
       else
          nohup java -jar ${array_app[$i]} >> ${array_name[$i]}.log 2>&1 &
       fi
   done

#指定启动一个应用
elif [ $# -eq 2 ] && [ $1 == '-s' -o $1 == '-st' ];then
     name_tmp=${array_name[$2]}
     echo "ready startup app $name_tmp..."

     path_tmp=${array_app[$2]}
     if [ ! -f "$path_tmp" ];then
          echo "$path_tmp is not exist! start app fail!"
       else
          nohup java -jar $path_tmp >> ${name_tmp}.log 2>&1 &
          echo "You can use the ${name_tmp}.log file to see how the application is starting"          
          if [ $1 == '-st' ];then
              tail -f ${name_tmp}.log
          fi
     fi

#不支持
else
   echo "no suppors the arg,input sh startup.sh with no args to get args info"
fi

echo "done!"
exit 0
