import properties

print 'connecting to admin server....'
connect(properties.login, properties.password, properties.url)

print 'deploying....'

deploy(properties.appName, properties.earPath, targets=properties.serverName, upload=properties.upload, timeout=properties.timeout)

startApplication(properties.appName)

print 'disconnecting from admin server....'

disconnect()

exit()
