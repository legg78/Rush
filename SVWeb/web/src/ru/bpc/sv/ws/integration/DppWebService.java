package ru.bpc.sv.ws.integration;

import org.apache.cxf.staxutils.DelegatingXMLStreamWriter;
import org.apache.log4j.Logger;
import ru.bpc.sv.instagentws.ObjectFactory;
import ru.bpc.sv.svxp.dpps.DppsType;
import ru.bpc.sv.svxp.dpps.ws.DppException;
import ru.bpc.sv.svxp.dpps.ws.DppWS;
import ru.bpc.sv.svxp.dpps.ws.Fault;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.utils.UserException;

import javax.annotation.Resource;
import javax.jws.WebParam;
import javax.jws.WebService;
import javax.jws.soap.SOAPBinding;
import javax.xml.bind.*;
import javax.xml.bind.annotation.XmlSeeAlso;
import javax.xml.namespace.QName;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamException;
import javax.xml.stream.XMLStreamWriter;
import javax.xml.ws.WebServiceContext;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.HashMap;
import java.util.Map;

@SuppressWarnings("unused")
@WebService(name = "DppWS", portName = "DppSOAP", serviceName = "DppWS",
		targetNamespace = "http://bpc.ru/SVXP/dpps", wsdlLocation = "META-INF/wsdl/dpp.wsdl")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso(ObjectFactory.class)
public class DppWebService implements DppWS {
	private static final Logger logger = Logger.getLogger("ISSUING");

	private final static String REGISTER_DPPS_ROOT_ELEMENT = "dpps";

	@Resource
	private WebServiceContext wsContext;

	@Override
	public DppsType registerDpps(@WebParam(partName = "request",name = "dpps",targetNamespace = "http://bpc.ru/sv/SVXP/dpps/ws") DppsType dpps) throws DppException {
		try {
			IntegrationDao integDao = getDao();

			Map<String, Object> map = new HashMap<String, Object>();
			map.put("i_xml", marshalDppsType(dpps));

			String xml = integDao.registerDpps(map);

			DppsType result = unmarshal(xml, DppsType.class);
			return result;
		} catch(Exception e) {
			throw handleException(e);
		}
	}

	private <T> T unmarshal(String xml, Class<T> clazz) {
		StringReader reader = new StringReader(xml);
		return JAXB.unmarshal(reader, clazz);
	}

	private String marshalDppsType(DppsType obj) throws XMLStreamException {
		StringWriter sw = new StringWriter();

		try {
			JAXBContext context = JAXBContext.newInstance(DppsType.class);
			Object rootJaxbObject = new JAXBElement(new QName(REGISTER_DPPS_ROOT_ELEMENT), DppsType.class, obj);

			Marshaller m = context.createMarshaller();
			m.setProperty(Marshaller.JAXB_FORMATTED_OUTPUT,true);

			XMLStreamWriter xmlWriter = XMLOutputFactory.newInstance().createXMLStreamWriter(sw);
			NamespaceStrippingXMLStreamWriter writer = new NamespaceStrippingXMLStreamWriter(xmlWriter);
			m.marshal(rootJaxbObject, writer);
		} catch (JAXBException e) {
			throw new DataBindingException(e);
		}

		return sw.toString();
	}


	private IntegrationDao getDao() {
		return new IntegrationDao();
	}

	private DppException handleException(Exception e) {
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
		return new DppException("ERROR", fault);
	}


	public class NamespaceStrippingXMLStreamWriter extends DelegatingXMLStreamWriter {

		public NamespaceStrippingXMLStreamWriter(XMLStreamWriter xmlWriter) throws XMLStreamException {
			super(xmlWriter);
		}

		@Override
		public void writeNamespace(String prefix, String uri) throws XMLStreamException {
			// intentionally doing nothing
		}

		@Override
		public void writeDefaultNamespace(String uri) throws XMLStreamException {
			// intentionally doing nothing
		}

		@Override
		public void writeStartElement(String prefix, String local, String uri) throws XMLStreamException {
			super.writeStartElement(null, local, null);
		}

		@Override
		public void writeStartElement(String uri, String local) throws XMLStreamException {
			super.writeStartElement(null, local);
		}

		@Override
		public void writeEmptyElement(String uri, String local) throws XMLStreamException {
			super.writeEmptyElement(null, local);
		}

		@Override
		public void writeEmptyElement(String prefix, String local, String uri) throws XMLStreamException {
			super.writeEmptyElement(null, local, null);
		}

		@Override
		public void writeAttribute(String prefix, String uri, String local, String value) throws XMLStreamException {
			super.writeAttribute(null, null, local, value);
		}

		@Override
		public void writeAttribute(String uri, String local, String value) throws XMLStreamException {
			super.writeAttribute(null, local, value);
		}
	}
}
