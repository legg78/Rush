package ru.bpc.sv2.scheduler.process.svng.mastercard;

import org.apache.cxf.endpoint.Client;
import org.apache.cxf.frontend.ClientProxy;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;
import org.apache.cxf.transport.http.HTTPConduit;
import org.apache.cxf.transports.http.configuration.HTTPClientPolicy;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

import static ru.bpc.sv2.scheduler.process.AsyncProcessHandler.HandlerState;

/**
 * @author Sergey Rastegaev
 * @version $Id$
 */
public abstract class AsyncSoapHandler {

    protected static final int HTTP_TIMEOUT = 60 * 2 * 1000;

    protected HandlerState state = HandlerState.StandBy;
    private JaxWsProxyFactoryBean factoryBean;
    private Client client;
    private ExecutorService exec;

    protected <T> T createInstance(String address, Class<T> clazz) {
        factoryBean = new JaxWsProxyFactoryBean();
        factoryBean.setServiceClass(clazz);
        factoryBean.setAddress(address);
        exec = Executors.newFixedThreadPool(5);

        return factoryBean.create(clazz);
    }

    protected void configureClient(Object instance) {
        if (instance == null)
            return;

        this.client = ClientProxy.getClient(instance);

        final HTTPConduit conduit = (HTTPConduit) client.getConduit();
        final HTTPClientPolicy policy = new HTTPClientPolicy();
        policy.setConnectionTimeout(HTTP_TIMEOUT);
        policy.setReceiveTimeout(HTTP_TIMEOUT);
        conduit.setClient(policy);
    }

    protected void destroyClient() {
        if (client != null)
            client.destroy();

        factoryBean = null;

        if (exec != null)
            exec.shutdown();
    }

}
