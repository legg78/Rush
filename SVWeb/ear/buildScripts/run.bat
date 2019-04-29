rem possible run parameters:
rem replace - delete existing sources and checkout new sources (should be used when
rem           you want to change branch but do it inside existing directory)
rem deploy - deploy application after successful build (deploy settings are in
rem          EAR project's pom.xml)
rem cluster - build application using settings for cluster (see pom.xmls profiles)

@ECHO OFF

SETLOCAL EnableDelayedExpansion

set svnUserName=cruisecontrol
set svnPassword=cruisecontrol1
set svnUrl=http://sv2.bpc.in/scm/repo/trunk/
set projectPrefix=ru.bpc.sv.ia

set replaceSrc="false"
set deploy="false"
set cluster="false"

if NOT "%1"=="" (
	for %%A in (%*) do (
    	if "%%A"=="replace" (
			set replaceSrc="true"
		)
    	if "%%A"=="deploy" (
			set deploy="true"
		)
    	if "%%A"=="cluster" (
			set cluster="true"
		)
	)
)

set projectDir=%projectPrefix%.cyberplat
if %replaceSrc%=="true" (
	echo Removing %projectDir%...
	rd /s/q %projectDir%
)
if exist %projectDir% (
	set svn_command=update
	set updatePath=%projectDir%
	echo Updating sources for %projectDir%
) else (
	set svn_command=checkout
	set updatePath=%svnUrl%%projectDir%
	echo Checking out sources from !updatePath!
)
svn %svn_command% %updatePath% --username %svnUserName% --password %svnPassword%

set projectDir=%projectPrefix%.prototype
if %replaceSrc%=="true" (
	echo Removing %projectDir%...
	rd /s/q %projectDir%
)
if exist %projectDir% (
	set svn_command=update
	set updatePath=%projectDir%
	echo Updating sources for %projectDir%
) else (
	set svn_command=checkout
	set updatePath=%svnUrl%%projectDir%
	echo Checking out sources from !updatePath!
)

svn %svn_command% %updatePath% --username %svnUserName% --password %svnPassword%

set projectDir=%projectPrefix%.prototype.common
if %replaceSrc%=="true" (
	echo Removing %projectDir%...
	rd /s/q %projectDir%
)
if exist %projectDir% (
	set svn_command=update
	set updatePath=%projectDir%
	echo Updating sources for %projectDir%
) else (
	set svn_command=checkout
	set updatePath=%svnUrl%%projectDir%
	echo Checking out sources from !updatePath!
)
svn %svn_command% %updatePath% --username %svnUserName% --password %svnPassword%

set projectDir=%projectPrefix%.prototype.dao
if %replaceSrc%=="true" (
	echo Removing %projectDir%...
	rd /s/q %projectDir%
)
if exist %projectDir% (
	set svn_command=update
	set updatePath=%projectDir%
	echo Updating sources for %projectDir%
) else (
	set svn_command=checkout
	set updatePath=%svnUrl%%projectDir%
	echo Checking out sources from !updatePath!
)
svn %svn_command% %updatePath% --username %svnUserName% --password %svnPassword%

set projectDir=%projectPrefix%.prototype.web
if %replaceSrc%=="true" (
	echo Removing %projectDir%...
	rd /s/q %projectDir%
)
if exist %projectDir% (
	set svn_command=update
	set updatePath=%projectDir%
	echo Updating sources for %projectDir%
) else (
	set svn_command=checkout
	set updatePath=%svnUrl%%projectDir%
	echo Checking out sources from !updatePath!
)
svn %svn_command% %updatePath% --username %svnUserName% --password %svnPassword%

if %replaceSrc%=="true" (
	echo Removing pom.xml...
	del pom.xml
)
if not exist pom.xml (
	echo Copying pom.xml from %projectPrefix%.prototype\buildScripts\ ...
	copy %projectPrefix%.prototype\buildScripts\pom.xml pom.xml
)

if exist log.txt del log.txt
if %deploy%=="true" (
	rem Deploy settings are in EAR project's pom.xml 
	if %cluster%=="true" (
		echo building and deploying clustered ear...
		mvn clean install -Pcluster >> log.txt
	) else (
		echo building and deploying ear...
		mvn clean install >> log.txt
	)
) else (
	if %cluster%=="true" (
		echo building clustered ear...
		mvn clean package -Pcluster >> log.txt
	) else (
		echo building ear...
		mvn clean package >> log.txt
	)
)
ENDLOCAL
