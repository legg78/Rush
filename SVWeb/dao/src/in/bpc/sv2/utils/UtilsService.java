
package in.bpc.sv2.utils;

import java.net.MalformedURLException;
import java.net.URL;
import java.util.logging.Logger;
import javax.xml.namespace.QName;
import javax.xml.ws.Service;
import javax.xml.ws.WebEndpoint;
import javax.xml.ws.WebServiceClient;
import javax.xml.ws.WebServiceFeature;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.1.6 in JDK 6
 * Generated source version: 2.1
 * 
 */
@WebServiceClient(name = "UtilsService", targetNamespace = "http://sv2.bpc.in/Utils", wsdlLocation = "file:/C:/Program%20Files/Java/jdk1.6.0_14/bin/utils.wsdl")
public class UtilsService
    extends Service
{

    private final static URL UTILSSERVICE_WSDL_LOCATION;
    private final static Logger logger = Logger.getLogger(in.bpc.sv2.utils.UtilsService.class.getName());

    static {
        URL url = null;
        try {
            URL baseUrl;
            baseUrl = in.bpc.sv2.utils.UtilsService.class.getResource(".");
            url = new URL(baseUrl, "file:/C:/Program%20Files/Java/jdk1.6.0_14/bin/utils.wsdl");
        } catch (MalformedURLException e) {
            logger.warning("Failed to create URL for the wsdl Location: 'file:/C:/Program%20Files/Java/jdk1.6.0_14/bin/utils.wsdl', retrying as a local file");
            logger.warning(e.getMessage());
        }
        UTILSSERVICE_WSDL_LOCATION = url;
    }

    public UtilsService(URL wsdlLocation, QName serviceName) {
        super(wsdlLocation, serviceName);
    }

    public UtilsService() {
        super(UTILSSERVICE_WSDL_LOCATION, new QName("http://sv2.bpc.in/Utils", "UtilsService"));
    }

    /**
     * 
     * @return
     *     returns Utils
     */
    @WebEndpoint(name = "Utils")
    public Utils getUtils() {
        return super.getPort(new QName("http://sv2.bpc.in/Utils", "Utils"), Utils.class);
    }

    /**
     * 
     * @param features
     *     A list of {@link javax.xml.ws.WebServiceFeature} to configure on the proxy.  Supported features not in the <code>features</code> parameter will have their default values.
     * @return
     *     returns Utils
     */
    @WebEndpoint(name = "Utils")
    public Utils getUtils(WebServiceFeature... features) {
        return super.getPort(new QName("http://sv2.bpc.in/Utils", "Utils"), Utils.class, features);
    }

}