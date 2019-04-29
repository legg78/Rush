#print 'connecting to admin server....'

#connect('weblogic', 'weblogic', 't3://localhost:7007', adminServerName='AdminServer')

#print 'stopping and undeploying ....'

#stopApplication('ru.bpc.sv.ia.prototype')

#undeploy('ru.bpc.sv.ia.prototype')

#print 'deploying....'

#deploy('ru.bpc.sv.ia.prototype', '/home/weblogic/iofiles/ear/ru.bpc.sv.ia.prototype.ear', targets='AdminServer')

#startApplication('ru.bpc.sv.ia.prototype')

import properties

print 'connecting to admin server....'
connect(properties.login, properties.password, properties.url)

print 'stopping and undeploying ....'

stopApplication(properties.appName)

undeploy(properties.appName)

print 'deploying....'

deploy(properties.appName, properties.earPath, targets=properties.serverName, upload=properties.upload, timeout=properties.timeout)

startApplication(properties.appName)

print 'disconnecting from admin server....'

disconnect()

exit()
