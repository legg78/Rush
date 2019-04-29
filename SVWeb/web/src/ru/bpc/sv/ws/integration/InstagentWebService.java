package ru.bpc.sv.ws.integration;

import org.apache.log4j.Logger;
import ru.bpc.sv.instagentws.*;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.utils.ExceptionUtils;

import javax.annotation.Resource;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.ws.WebServiceContext;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
@SuppressWarnings("unused")
@WebService(name = "instagentWS", portName = "InstagentSOAP", serviceName = "Instagent",
        targetNamespace = "http://bpc.ru/sv/instagentWS/", wsdlLocation = "META-INF/wsdl/instagentWS.wsdl")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso(ObjectFactory.class)
public class InstagentWebService implements Instagent {

    private static final Logger logger = Logger.getLogger("ISSUING");

    @Resource
    protected WebServiceContext wsContext;

    @Override
    public GetInstitutionsResponseType getInstitutions(@WebParam(partName = "request", name = "getInstitutionsRequest", targetNamespace = "http://bpc.ru/sv/instagentWS/") GetInstitutionsRequestType getInstitutionsRequestType) throws InstagentException {
        try {
            IntegrationDao local = new IntegrationDao();
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("lang", getInstitutionsRequestType.getLang());
            List<InstitutionType> list = local.getInstitutions(map);
            GetInstitutionsResponseType responseType = new GetInstitutionsResponseType();
            responseType.getInstitution().addAll(list);
            return responseType;
        } catch (Exception e) {
            throw createFault(e);
        }
    }

    @Override
    public GetAgentsResponseType getAgents(@WebParam(partName = "request", name = "getAgentsRequest", targetNamespace = "http://bpc.ru/sv/instagentWS/") GetAgentsRequestType getAgentsRequestType) throws InstagentException {
        try {
            IntegrationDao local = new IntegrationDao();
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("lang", getAgentsRequestType.getLang());
            List<AgentType> list = local.getAgents(map);
            GetAgentsResponseType responseType = new GetAgentsResponseType();
            responseType.getAgent().addAll(list);
            return responseType;
        } catch (Exception e) {
            throw createFault(e);
        }
    }

    @Override
    public GetCardTypesResponse getCardTypes(@WebParam(partName = "request", name = "getCardTypes", targetNamespace = "http://bpc.ru/sv/instagentWS/") GetCardTypesRequest getCardTypesRequest) throws InstagentException {
        try {
            IntegrationDao local = new IntegrationDao();
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("lang", getCardTypesRequest.getLang());
            List<CardType> list = local.getCardTypes(map);
            GetCardTypesResponse responseType = new GetCardTypesResponse();
            responseType.getCardType().addAll(list);
            return responseType;
        } catch (Exception e) {
            throw createFault(e);
        }
    }

    @Override
    public GetServiceTypesResponse getServiceTypes(@WebParam(partName = "request", name = "getServiceTypes", targetNamespace = "http://bpc.ru/sv/instagentWS/") GetServiceTypesRequest getServiceTypesRequest) throws InstagentException {
        try {
            IntegrationDao local = new IntegrationDao();
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("lang", getServiceTypesRequest.getLang());
            List<ServiceType> list = local.getServiceTypes(map);
            GetServiceTypesResponse responseType = new GetServiceTypesResponse();
            responseType.getServiceType().addAll(list);
            return responseType;
        } catch (Exception e) {
            throw createFault(e);
        }
    }

    private InstagentException createFault(Exception e) {
        logger.error(e.getMessage(), e);
        FaultType type = new FaultType();
        type.setText(ExceptionUtils.getExceptionMessage(e));
        return new InstagentException("Error", type);
    }

}
