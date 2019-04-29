#install grid

groupadd –g 1200 asmadmin
groupadd -g 1300 asmdba
groupadd -g 1301 asmoper

 usermod -F -g oinstall -G asmdba,asmoper,asmadmin,dba oracle

su - oracle
cd grid
export DISPLAY=10.101.1.34:0.0
export ORACLE_SID=+ASM
export ORACLE_HOME=/opt/oracle/product/11.2.0/grid
./runInstaller -silent -ignoreSysPrereqs -ignorePrereq -responseFile /home/oracle/grid/crs_install.rsp

create spfile from pfile='/opt/oracle/admin/+ASM/pfile/init.ora';

./asmca -silent -oui_internal -configureASM -diskGroupName DATA -diskList /dev/rdsk/c6t0d1 -redundancy EXTERNAL




/tmp/deinstall2012-04-06_02-12-54-PM/perl/bin/perl -I/tmp/deinstall2012-04-06_02-12-54-PM/perl/lib -I/tmp/deinstall2012-04-06_02-12-54-PM/crs/install /tmp/deinstall2012-04-06_02-12-54-PM/crs/install/roothas.pl -force  -delete -paramfile /tmp/deinstall2012-04-06_02-12-54-PM/response/deinstall_Ora11g_gridinfrahome1.rsp\

perl/bin/perl -I perl/lib -I crs/install crs/install/roothas.pl -force  -delete -paramfile response/deinstall_Ora11g_gridinfrahome1.rsp

$ORACLE_HOME/OPatch/ocm/bin/emocmrsp

opatch auto SRC/PATCH -oh GRID_HOME -ocmrf ocm.rsp

./opatch auto /tmp/13343424 -oh $GRID_HOME -ocmrf $GRID_HOME/ocm.rsp

$GRID_HOME/OPatch/opatch lsinventory -detail -oh $GRID_HOME

$GRID_HOME/OPatch/opatch auto /opt/src -oh $GRID_HOME -ocmrf $GRID_HOME/ocm.rsp;k