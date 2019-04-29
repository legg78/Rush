package ru.bpc.sv.ws.integration;

import in.bpc.sv.svxp.dictionary.currencyrate.CurrencyRates;
import in.bpc.sv.svxp.dictionary.currencyrate.RequestCurrencyRates;
import in.bpc.sv.svxp.dictionary.dictionaries.Dictionaries;
import in.bpc.sv.svxp.dictionary.dictionaries.RequestDictionaries;
import in.bpc.sv.svxp.dictionary.mcc.Mcc;
import in.bpc.sv.svxp.dictionary.mcc.RequestMcc;
import org.apache.log4j.Logger;
import ru.bpc.sv.instagentws.ObjectFactory;
import ru.bpc.sv2.logic.IntegrationDao;
import ru.bpc.sv2.utils.UserException;
import ru.bpc.svxp.dictionary.DictionaryException;
import ru.bpc.svxp.dictionary.DictionaryWS;
import ru.bpc.svxp.dictionary.Fault;

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
@WebService(name = "DictionaryWS", portName = "DictionarySOAP", serviceName = "DictionaryWS",
        targetNamespace = "http://bpc.ru/SVXP/dictionary", wsdlLocation = "META-INF/wsdl/dictionary.wsdl")
@SOAPBinding(parameterStyle = SOAPBinding.ParameterStyle.BARE)
@XmlSeeAlso(ObjectFactory.class)
public class DictionaryWebService implements DictionaryWS {
    private static final Logger logger = Logger.getLogger("ISSUING");

    @Resource
    private WebServiceContext wsContext;


    @Override
    public Mcc mcc(RequestMcc requestMcc) throws DictionaryException {
        try {
            IntegrationDao integDao = getDao();

            Map<String, Object> map = new HashMap<String, Object>();
            map.put("lang", requestMcc.getLang());
            map.put("dictVersion", requestMcc.getDictVersion());

            String xml = integDao.getDictMccXml(map);
            return unmarshal(xml, Mcc.class);
        } catch(Exception e) {
            throw handleException(e);
        }
    }

    @Override
    public Dictionaries dictionaries(RequestDictionaries requestDictionaries) throws DictionaryException {
        try {
            IntegrationDao integDao = getDao();

            String xml = null;
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("dictVersion", requestDictionaries.getDictVersion());
            map.put("instId", requestDictionaries.getInstId());
            map.put("lang", requestDictionaries.getLang());
            map.put("arrayDictionaryId", requestDictionaries.getArrayDictionaryId());
            map.put("xml", xml);

            xml = integDao.getDictDictionariesXml(map);
            return unmarshal(xml, Dictionaries.class);
        } catch(Exception e) {
            throw handleException(e);
        }
    }


    public CurrencyRates currencyRates(RequestCurrencyRates requestCurrencyRates) throws DictionaryException {
        try {
            IntegrationDao integDao = getDao();

            Integer baseRateExport = null;
            if (requestCurrencyRates.isBaseRateExport() != null) {
                baseRateExport = requestCurrencyRates.isBaseRateExport() ? 0 : 1;
            }

            String xml = null;
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("instId", requestCurrencyRates.getInstId());
            map.put("baseRateExport",  baseRateExport);
            map.put("rateType", requestCurrencyRates.getRateType());
            map.put("effDate", requestCurrencyRates.getEffDate() == null ? null : requestCurrencyRates.getEffDate().toGregorianCalendar().getTime());
            map.put("dictVersion", requestCurrencyRates.getDictVersion());
            map.put("xml", xml);

            xml = integDao.getDictCurrencyRatesXml(map);
            return unmarshal(xml, CurrencyRates.class);
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

    private DictionaryException handleException(Exception e) {
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
        return new DictionaryException("ERROR", fault);
    }
}
