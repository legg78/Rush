package ru.bpc.sv.ws.integration;

import org.apache.log4j.Logger;
import org.jdom.Document;
import ru.bpc.sv.merchantportalws.*;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.utils.ExceptionUtils;
import util.conversion.date.ConversionDate;
import util.conversion.installment.InstallmentPlanConversion;
import util.conversion.xml.ConversionXml;

import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;
import java.util.HashMap;
import java.util.Map;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */

@SuppressWarnings("unused")
@WebService(name = "merchantPortalWS", portName = "MerchantPortalSOAP", serviceName = "MerchantPortal",
        targetNamespace = "http://bpc.ru/sv/merchantPortalWS/", wsdlLocation = "META-INF/wsdl/merchantPortalWS.wsdl")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso(ObjectFactory.class)
public class MerchantPortalWebService implements MerchantPortal {

    private static final Logger logger = Logger.getLogger("ISSUING");

    @Override
    public GetInstallmentPlanResponseType getInstallmentPlan(@WebParam(partName = "request", name = "getInstallmentPlanRequest", targetNamespace = "http://bpc.ru/sv/merchantPortalWS/") GetInstallmentPlanRequestType getInstallmentPlanRequestType) throws MerchantPortalException {
        try {
            IntegrationDao local = new IntegrationDao();
            InstallmentPlanTypeReq request = getInstallmentPlanRequestType.getInstallmentPlan();

            Map<String, Object> map = new HashMap<String, Object>();
            map.put("dppAmount", request.getTransactionAmount());
            map.put("installmentCount", request.getNumberInstallments());
            map.put("fixedAmount", request.getFixedPaymentAmount());
            map.put("installmentPeriod", request.getInstallmentPeriod());
            map.put("firstInstalmentDate", request.getFirstInstallmentDate() != null ? new ConversionDate(request.getFirstInstallmentDate()).calendarToDate() : null);
            map.put("interestAmount", request.getInterest());
            map.put("calcAlgorithm", request.getInstallmentAlgorithm().value());
            map.put("merchantNumber", request.getMerchantNumber());
            map.put("instId", request.getInstId());

            String xml = local.getInstallmentPlan(map);

            Document document = new ConversionXml(xml).stringToXmlDocConversion();
            InstallmentPlanTypeResp typeResp = new InstallmentPlanConversion(document).converseXmlToResponseObject();
            GetInstallmentPlanResponseType installmentPlanResponseType = new GetInstallmentPlanResponseType();
            installmentPlanResponseType.setInstallmentPlan(typeResp);
            return installmentPlanResponseType;
        } catch (Exception e) {
            throw createFault(e);
        }
    }

    private MerchantPortalException createFault(Exception e) {
        logger.error("", e);
        FaultType faultType = new FaultType();
        faultType.setText(ExceptionUtils.getExceptionMessage(e));
        return new MerchantPortalException("Error", faultType);
    }
}
