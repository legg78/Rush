FROM nexus.dmz1.bpc.in:8082/weblogic/svbo_svweb:app_2
LABEL maintainer="Sergey Dorontsov dorontcov@bpcbt.com"
### ARG
ARG SERVER_EAR=ear/target/sv2-ear.ear
### BODY
ADD ${SERVER_EAR} /home/weblogic/
