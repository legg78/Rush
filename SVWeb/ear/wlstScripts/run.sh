#! /bin/bash

scriptName=""

if [ "$1" == "deploy" ]; then
	scriptName="deploy.py"
elif [ "$1" == "redeploy" ]; then
	scriptName="redeploy.py"
elif [ "$1" == "undeploy" ]; then
	scriptName="undeploy.py"
else
	echo "Run format: run.sh [deploy|redeploy|undeploy]"
	exit
fi

$WL_HOME/common/bin/wlst.sh $scriptName
