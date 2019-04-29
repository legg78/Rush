DEF_ORADB_PORT=1521
while :
do
	EXIST_PORT=`netstat -tuln | grep $DEF_ORADB_PORT | wc -l`
	if [[ $EXIST_PORT -eq 0 ]]; then
		export CI_ORADB_PORT=$DEF_ORADB_PORT
		echo $DEF_ORADB_PORT
		break
	fi
	DEF_ORADB_PORT=$(($DEF_ORADB_PORT + 1))
done
