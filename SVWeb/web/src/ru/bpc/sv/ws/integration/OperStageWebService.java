package ru.bpc.sv.ws.integration;

import org.apache.log4j.Logger;
import ru.bpc.sv.operstagews.*;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.WebServiceConstants;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.OperationPrivConstants;
import ru.bpc.sv2.utils.ExceptionUtils;

import javax.annotation.Resource;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.servlet.ServletContext;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.WebServiceContext;
import javax.xml.ws.handler.MessageContext;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

/**
 * Created by Gasanov on 01.11.2016.
 */
@SuppressWarnings("unused")
@WebService(name = "OperstageWS", portName = "OperstageSOAP", serviceName = "Operstage",
        targetNamespace = "http://bpc.ru/sv/operstageWS/", wsdlLocation = "META-INF/wsdl/operstageWS.wsdl")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
/* TODO: Below doesn't work in Websphere. Have to find a workaround
@com.sun.xml.ws.developer.SchemaValidation
*/
@XmlSeeAlso({ObjectFactory.class})
public class OperStageWebService implements Operstage {
    private static final Logger logger = Logger.getLogger("ISSUING");

    @Resource
    protected WebServiceContext wsContext;

    @Override
    @WebResult(
            name = "value",
            targetNamespace = "http://bpc.ru/sv/operstageWS/",
            partName = "output"
    )
    public int setOperStage(FraudControl fraudControl) throws OperstageException {
        try {
            ServletContext servletContext =
                    (ServletContext) wsContext.getMessageContext().get(MessageContext.SERVLET_CONTEXT);
            String userFile = servletContext.getInitParameter(SystemConstants.EXTERNAL_PROPERTIES_FILE);
            Properties prop = new Properties();
            String wsUserName;
            try {
                prop.load(new FileInputStream(userFile));
                wsUserName = prop.getProperty(WebServiceConstants.WS_USERNAME_PROPERTY);
                wsUserName = (wsUserName == null) ? WebServiceConstants.WS_DEFAULT_CREDENTIALS : wsUserName;
            } catch (FileNotFoundException e) {
                logger.error(e.getMessage());
                logger.trace("Using default credentials...");
                wsUserName = WebServiceConstants.WS_DEFAULT_CREDENTIALS;
            }

            OperationDao operationWs = new OperationDao();
            Long sessionId = operationWs.registerSession(wsUserName, OperationPrivConstants.ADD_PROCESS_STAGE);
            Map<String, Object> params = new HashMap<String, Object>();
            List<Operation> operations = fraudControl.getOperation();
            for(Operation operation : operations) {
                params.clear();
                params.put("operId", operation.getOperId());
                params.put("externalAuthId", operation.getExternalAuthId());
                params.put("isReversal", operation.getIsReversal());
                params.put("command", operation.getCommand());
                operationWs.setOperStage(sessionId, wsUserName, params);
            }
        }catch (Exception e){
            logger.error(e.getMessage(), e);
            FaultType type = new FaultType();
            type.setText(ExceptionUtils.getExceptionMessage(e));
            throw new OperstageException("Error", type);
        }
        return 0;
    }
}
