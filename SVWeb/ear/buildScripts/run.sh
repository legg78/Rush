# possible run parameters:
# replace - delete existing sources and checkout new sources (should be used when
#           you want to change branch but do it inside existing directory)
# deploy - deploy application after successful build (deploy settings are in
#          EAR project's pom.xml)
# cluster - build application using settings for cluster (see pom.xmls profiles)

svnUserName=cruisecontrol
svnPassword=cruisecontrol1
svnUrl=http://sv2.bpc.in/scm/repo/trunk/
projectPrefix=ru.bpc.sv.ia

replaceSrc=false
deploy=false
cluster=false

if [ $# -ne 0 ]; then
	for f in "$@"; do
		if [ "$f" = "replace" ]; then
			replaceSrc=true
		elif [ "$f" = "deploy" ]; then
			deploy=true
		elif [ "$f" = "cluster" ]; then
			cluster=true
		fi
	done
fi

projectDir=$projectPrefix.cyberplat
if $replaceSrc ; then
	echo "Removing $projectDir..."
	rm -rf $projectDir/
fi
if [ -d $projectDir ]; 	then
	svn_command=update
	updatePath=$projectDir
	echo "Updating sources for $projectDir"
else
	svn_command=checkout
	updatePath=$svnUrl$projectDir
	echo "Checking out sources from $updatePath"
fi
svn $svn_command $updatePath --username $svnUserName --password $svnPassword

projectDir=$projectPrefix.prototype
if $replaceSrc ; then
	echo "Removing $projectDir..."
	rm -rf $projectDir/
fi
if [ -d $projectDir ]; 	then
	svn_command=update
	updatePath=$projectDir
	echo "Updating sources for $projectDir"
else
	svn_command=checkout
	updatePath=$svnUrl$projectDir
	echo "Checking out sources from $updatePath"
fi
svn $svn_command $updatePath --username $svnUserName --password $svnPassword

projectDir=$projectPrefix.prototype.common
if $replaceSrc ; then
	echo "Removing $projectDir..."
	rm -rf $projectDir/
fi
if [ -d $projectDir ]; 	then
	svn_command=update
	updatePath=$projectDir
	echo "Updating sources for $projectDir"
else
	svn_command=checkout
	updatePath=$svnUrl$projectDir
	echo "Checking out sources from $updatePath"
fi
svn $svn_command $updatePath --username $svnUserName --password $svnPassword

projectDir=$projectPrefix.prototype.dao
if $replaceSrc ; then
	echo "Removing $projectDir..."
	rm -rf $projectDir/
fi
if [ -d $projectDir ]; 	then
	svn_command=update
	updatePath=$projectDir
	echo "Updating sources for $projectDir"
else
	svn_command=checkout
	updatePath=$svnUrl$projectDir
	echo "Checking out sources from $updatePath"
fi
svn $svn_command $updatePath --username $svnUserName --password $svnPassword

projectDir=$projectPrefix.prototype.web
if $replaceSrc ; then
	echo "Removing $projectDir..."
	rm -rf $projectDir/
fi
if [ -d $projectDir ]; 	then
	svn_command=update
	updatePath=$projectDir
	echo "Updating sources for $projectDir"
else
	svn_command=checkout
	updatePath=$svnUrl$projectDir
	echo "Checking out sources from $updatePath"
fi
svn $svn_command $updatePath --username $svnUserName --password $svnPassword

if $replaceSrc ; then
	echo "Removing pom.xml..."
	rm pom.xml
fi
if ! [ -f pom.xml ]; then
	echo "Copying pom.xml from $projectPrefix.prototype/buildScripts/ ..."
	cp $projectPrefix.prototype/buildScripts/pom.xml pom.xml
fi

if [ -f log.txt ]; then 
	rm log.txt 
fi
if $deploy ; then
	# Deploy settings are in EAR project's pom.xml 
	if $cluster ; then
		echo "building and deploying clustered ear..."
		mvn clean install -Pcluster >> log.txt
	else
		echo "building and deploying ear..."
		mvn clean install >> log.txt
	fi
else
	if $cluster ; then
		echo "building clustered ear..."
		mvn clean package -Pcluster >> log.txt
	else
		echo "building ear..."
		mvn clean package >> log.txt
	fi
fi
# --------------- Count errors
ERRORS=$(cat "./log.txt" | grep -e '^\[ERROR\]*');
echo "$ERRORS";
