import properties

print 'connecting to admin server....'

connect(properties.login, properties.password, properties.url, adminServerName=properties.serverName)

print 'stopping and undeploying ....'

stopApplication(properties.appName)

undeploy(properties.appName)

print 'disconnecting from admin server....'

disconnect()

exit()
