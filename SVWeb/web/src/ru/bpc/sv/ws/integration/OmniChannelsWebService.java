package ru.bpc.sv.ws.integration;

import org.apache.log4j.Logger;
import ru.bpc.sv.instagentws.ObjectFactory;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.utils.UserException;
import ru.bpc.svxp.omnichannels.Fault;
import ru.bpc.svxp.omnichannels.OmniChannelsException;
import ru.bpc.svxp.omnichannels.OmniChannelsWS;
import ru.bpc.svxp.omnichannels.product.Products;
import ru.bpc.svxp.omnichannels.product.RequestProducts;

import javax.annotation.Resource;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.JAXB;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.WebServiceContext;
import java.io.StringReader;
import java.util.HashMap;
import java.util.Map;

@SuppressWarnings("unused")
@WebService(name = "OmniChannelsWS", portName = "OmniChannelsSOAP", serviceName = "OmniChannelsWS",
        targetNamespace = "http://bpc.ru/SVXP/omnichannels", wsdlLocation = "META-INF/wsdl/omni-channels.wsdl")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso(ObjectFactory.class)
public class OmniChannelsWebService implements OmniChannelsWS {
    private static final Logger logger = Logger.getLogger("ISSUING");

    @Resource
    private WebServiceContext wsContext;

    @Override
    public Products products(RequestProducts requestProducts) throws OmniChannelsException {
        try {
            IntegrationDao integDao = getDao();

            Map<String, Object> map = new HashMap<String, Object>();
            map.put("instId", requestProducts.getInstId());
            map.put("lang", requestProducts.getLang());
            map.put("omniVersion", requestProducts.getOmniVersion());

            String xml = integDao.getOmniProductsXml(map);
            return unmarshal(xml, Products.class);
        } catch(Exception e) {
            throw handleException(e);
        }
    }

    private <T> T unmarshal(String xml, Class<T> type) {
        StringReader reader = new StringReader(xml);
        return JAXB.unmarshal(reader, type);
    }

    private IntegrationDao getDao() {
        return new IntegrationDao();
    }

    private OmniChannelsException handleException(Exception e) {
        logger.error(e.getMessage(), e);
        String message = e.getMessage();
        Fault fault = new Fault();
        if (message != null && message.startsWith("ORA-")) {
            message = message.replaceFirst("ORA-\\d+: ", "");
            message = message.split("ORA-\\d+:")[0];
            message = message.replaceAll("\n", "->");
        }
        fault.setDescription(message);
        if (e instanceof UserException) {
            fault.setCode(((UserException) e).getErrorCodeText());
        } else {
            fault.setCode("UNKNOWN");
        }
        return new OmniChannelsException("ERROR", fault);
    }
}
