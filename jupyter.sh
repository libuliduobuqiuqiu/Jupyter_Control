#!/usr/bin/bash
#-----------------------------------------------------------------
#	Author: linshukai
#	Filename: jupyter.sh
#	Datetime: 2020-05-08
#	Description: 有关于jupyter服务控制：启动，重启，停止，检查
#-----------------------------------------------------------------

workPath=$(cd $(dirname $0)/; pwd) 
pidFile=$workPath/jupyter.pid
logFile=$workPath/jupyter.log

function check_pid(){
	if [ -f $pidFile ];then
		pid=$(cat $pidFile)
		if [ -n $pid ];then
			tasks=$(ps -p $pid | grep -v "PID TTY" | wc -l)
			return $tasks
		fi
	fi
	return 0
} # 通过PID检查正在运行进程

function start(){
	check_pid
	tasks=$?
	if [ $tasks -gt 0 ];then
		echo -n "The jupyter Service is running already, PID="
		$(cat $pidFile)
		return 1
	fi
	nohup /usr/local/bin/jupyter lab >> $logFile 2>&1 &
	echo $! > $pidFile
	echo "The Jupyter Service start to run, PID=$!"
} # 首先检查是否正常启动，然后在判断是否启动jupyter

function stop(){
	check_pid
	tasks=$?
	pid=$(cat $pidFile)
	if [ $tasks -gt 0 ];then
		kill -9 $pid
		echo "Jupyter Service stoped...."
	else
		echo "Jupyter Service not running....."
	fi
		
} # 检查是否正在运行，关闭指定PID

function restart(){
	stop
	sleep 2
	start
}

function status(){
	check_pid
	tasks=$?
	if [ $tasks -gt 0 ];then
		echo -n "Jupyter Service is running, PID="
		cat $pidFile
		echo "Please check the log for details:"$logFile
	else
		echo "Jupyter Service has stopped"
	fi
} # 输出进程PID

function help(){
	echo "$0 start|stop|restart|status"
}

case $1 in
	start) start;;
	stop) stop;;
	restart) restart;;
	status) status;;
	*) help;;
esac

