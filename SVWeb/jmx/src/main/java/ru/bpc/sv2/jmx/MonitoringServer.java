package ru.bpc.sv2.jmx;

import org.apache.commons.lang3.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jmx.JmxException;
import org.springframework.jmx.support.MBeanServerFactoryBean;
import org.springframework.stereotype.Component;
import ru.bpc.sv2.jmx.utils.MonitoringSettings;

import javax.management.MBeanServer;
import javax.management.remote.JMXConnectorServer;
import javax.management.remote.JMXConnectorServerFactory;
import javax.management.remote.JMXServiceURL;
import java.io.IOException;
import java.rmi.NoSuchObjectException;
import java.rmi.RemoteException;
import java.rmi.registry.LocateRegistry;
import java.rmi.registry.Registry;
import java.rmi.server.UnicastRemoteObject;
import java.util.HashMap;
import java.util.Map;

@Component
public class MonitoringServer {
    private static final Logger logger = LoggerFactory.getLogger("MONITORING");

    private Registry registry = null;
    private JMXConnectorServer cs = null;

    @Autowired
    MBeanServerFactoryBean mBeanServerFactoryBean;

    @Autowired
    MonitoringSettings settings;

    public boolean start(int port) {
        try {
            logger.info("Starting JMX connector server");

            initRegistry(port);
            startJmxServer(port);

            return true;
        } catch(IOException e) {
            logger.error("Error while starting JMX connector server", e);
            stop();
            return false;
        }

    }

    private void initRegistry(int port) throws RemoteException {
        try {
            registry = LocateRegistry.getRegistry(null, port);
            registry.list();
        } catch (RemoteException ex) {
            logger.debug("RMI registry access threw exception", ex);
            logger.info("Could not detect RMI registry - creating new one");
            registry = LocateRegistry.createRegistry(port);
        }
    }

    private void startJmxServer(int port) throws IOException {
        MBeanServer mbs = mBeanServerFactoryBean.getObject();

        Map<String,Object> env = new HashMap<String,Object>();

        env.put("com.sun.management.jmxremote.ssl", "false");
        env.put("com.sun.management.jmxremote.local.only", "false");
        env.put("com.sun.management.jmxremote.authenticate", "false");

        logger.info("JMX connector server environment params: {}", env);

        final String serviceUrl = "service:jmx:rmi:///jndi/rmi://:" + port + "/jmxrmi";
        JMXServiceURL url = new JMXServiceURL(serviceUrl);

        cs = JMXConnectorServerFactory.newJMXConnectorServer(url, env, mbs);

        Thread connectorThread = new Thread() {
            @Override
            public void run() {
                try {
                    cs.start();
                    logger.info("JMX connector server started by service url: " + serviceUrl);
                } catch (IOException ex) {
                    throw new JmxException("Could not start JMX connector server after delay", ex);
                }
            }
        };

        connectorThread.setName("JMX Connector Thread [" + serviceUrl + "]");
        connectorThread.start();
    }

    public void stop() {
        logger.info("Stopping JMX connector server");
        if (cs != null) {
            try {
                cs.stop();
            } catch (IOException e) {
                logger.error("Error while stopping JMX connector server", e);
            }
        }
        if (registry != null) {
            try {
                UnicastRemoteObject.unexportObject(registry, true);
                registry = null;
            } catch (NoSuchObjectException e) {
                logger.error("Error unexport register", e);
            }
        }
        logger.info("JMX connector server stopped");
    }
}
