package ru.bpc.sv.ws.integration;

import org.apache.log4j.Logger;
import ru.bpc.sv.svxp.pmo.*;
import ru.bpc.sv.svxp.pmo.ws.Fault;
import ru.bpc.sv.svxp.pmo.ws.PmoException;
import ru.bpc.sv.svxp.pmo.ws.PmoWS;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.utils.UserException;

import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.annotation.XmlSeeAlso;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebService(name = "PmoWS", portName = "PmoSOAP", serviceName = "PmoWS",
		targetNamespace = "http://bpc.ru/SVXP/pmo", wsdlLocation = "META-INF/wsdl/pmo.wsdl")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso(ObjectFactory.class)
public class PmoWebService implements PmoWS {
	private static final Logger logger = Logger.getLogger("ISSUING");

	@Override
	public PaymentOrders exportOrders(ExportOrdersRequest exportOrdersRequest) throws PmoException {
		try {
			IntegrationDao integDao = getDao();
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("instId", exportOrdersRequest.getInstId());
			map.put("purposeId", exportOrdersRequest.getPurposeId());
			map.put("pmoStatusChangeMode", exportOrdersRequest.getPmoStatusChangeMode());
			map.put("maxCount", exportOrdersRequest.getMaxCount());

			List<PaymentOrder> list = integDao.getPaymentOrders(map);
			if (list == null) {
				return null;
			}
			PaymentOrders orders = new PaymentOrders();
			orders.getPaymentOrder().addAll(list);
			return orders;
		} catch(Exception e) {
			throw handleException(e);
		}
	}


	@Override
	public int importOrderResponses(ImportOrderResponses importOrderResponses) throws PmoException {
		try {
			Map<String, Object> map = new HashMap<String, Object>(2);
			map.put("pmoResponses", importOrderResponses.getImportOrderResponse());
			map.put("createOperation", importOrderResponses.isCreateOperation());

			IntegrationDao integDao = getDao();
			integDao.importPaymentOrderResponses(map);
			return 1;
		} catch(Exception e) {
			throw handleException(e);
		}
	}

	private IntegrationDao getDao() {
		return new IntegrationDao();
	}

	private PmoException handleException(Exception e) {
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
		return new PmoException("ERROR", fault);
	}
}
