
package in.bpc.sv2.utils;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.datatype.XMLGregorianCalendar;
import javax.xml.namespace.QName;

import in.bpc.sv2.utils.KladrRecords;
import in.bpc.sv2.utils.Lov;
import in.bpc.sv2.utils.LovRequest;
import in.bpc.sv2.utils.OtpCheck;
import in.bpc.sv2.utils.OtpSend;
import in.bpc.sv2.utils.Rates;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the in.bpc.sv2.utils package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {
	private final static QName _Lov_QNAME = new QName("http://sv2.bpc.in/Utils", "lov");
    private final static QName _KladrRecords_QNAME = new QName("http://sv2.bpc.in/Utils", "kladr_records");
    private final static QName _EffectiveDate_QNAME = new QName("http://sv2.bpc.in/Utils", "effective_date");
    private final static QName _ParentId_QNAME = new QName("http://sv2.bpc.in/Utils", "parent_id");
    private final static QName _OtpSend_QNAME = new QName("http://sv2.bpc.in/Utils", "otp_send");
    private final static QName _TranslitText_QNAME = new QName("http://sv2.bpc.in/Utils", "translit_text");
    private final static QName _PostalCode_QNAME = new QName("http://sv2.bpc.in/Utils", "postal_code");
    private final static QName _LovRequest_QNAME = new QName("http://sv2.bpc.in/Utils", "lov_request");
    private final static QName _AddressId_QNAME = new QName("http://sv2.bpc.in/Utils", "address_id");
    private final static QName _Rates_QNAME = new QName("http://sv2.bpc.in/Utils", "rates");
    private final static QName _Text_QNAME = new QName("http://sv2.bpc.in/Utils", "text");
    private final static QName _PhoneNumber_QNAME = new QName("http://sv2.bpc.in/Utils", "phone_number");
    private final static QName _OtpCheck_QNAME = new QName("http://sv2.bpc.in/Utils", "otp_check");
    private final static QName _Result_QNAME = new QName("http://sv2.bpc.in/Utils", "result");
    
    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: in.bpc.sv2.utils
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link Document }
     * 
     */
    public Document createDocument() {
        return new Document();
    }

    /**
     * Create an instance of {@link Rate }
     * 
     */
    public Rate createRate() {
        return new Rate();
    }

    /**
     * Create an instance of {@link Lov }
     * 
     */
    public Lov createLov() {
        return new Lov();
    }

    /**
     * Create an instance of {@link Rates }
     * 
     */
    public Rates createRates() {
        return new Rates();
    }

    /**
     * Create an instance of {@link LovParam }
     * 
     */
    public LovParam createLovParam() {
        return new LovParam();
    }

    /**
     * Create an instance of {@link LovRecord }
     * 
     */
    public LovRecord createLovRecord() {
        return new LovRecord();
    }

    /**
     * Create an instance of {@link LovRequest }
     * 
     */
    public LovRequest createLovRequest() {
        return new LovRequest();
    }
    
    public KladrRecords createKladrRecords() {
        return new KladrRecords();
    }

    public KladrRecord createKladrRecord() {
        return new KladrRecord();
    }
    
    public OtpCheck createOtpParamCheck() {
        return new OtpCheck();
    }
   
    public OtpSend createOtpParamSend() {
        return new OtpSend();
    }
    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Lov }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "lov")
    public JAXBElement<Lov> createLov(Lov value) {
        return new JAXBElement<Lov>(_Lov_QNAME, Lov.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link KladrRecords }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "kladr_records")
    public JAXBElement<KladrRecords> createKladrRecords(KladrRecords value) {
        return new JAXBElement<KladrRecords>(_KladrRecords_QNAME, KladrRecords.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link XMLGregorianCalendar }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "effective_date")
    public JAXBElement<XMLGregorianCalendar> createEffectiveDate(XMLGregorianCalendar value) {
        return new JAXBElement<XMLGregorianCalendar>(_EffectiveDate_QNAME, XMLGregorianCalendar.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "parent_id")
    public JAXBElement<String> createParentId(String value) {
        return new JAXBElement<String>(_ParentId_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link OtpSend }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "otp_send")
    public JAXBElement<OtpSend> createOtpSend(OtpSend value) {
        return new JAXBElement<OtpSend>(_OtpSend_QNAME, OtpSend.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "translit_text")
    public JAXBElement<String> createTranslitText(String value) {
        return new JAXBElement<String>(_TranslitText_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "postal_code")
    public JAXBElement<String> createPostalCode(String value) {
        return new JAXBElement<String>(_PostalCode_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link LovRequest }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "lov_request")
    public JAXBElement<LovRequest> createLovRequest(LovRequest value) {
        return new JAXBElement<LovRequest>(_LovRequest_QNAME, LovRequest.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "address_id")
    public JAXBElement<Integer> createAddressId(Integer value) {
        return new JAXBElement<Integer>(_AddressId_QNAME, Integer.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Rates }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "rates")
    public JAXBElement<Rates> createRates(Rates value) {
        return new JAXBElement<Rates>(_Rates_QNAME, Rates.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "text")
    public JAXBElement<String> createText(String value) {
        return new JAXBElement<String>(_Text_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "phone_number")
    public JAXBElement<String> createPhoneNumber(String value) {
        return new JAXBElement<String>(_PhoneNumber_QNAME, String.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link OtpCheck }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "otp_check")
    public JAXBElement<OtpCheck> createOtpCheck(OtpCheck value) {
        return new JAXBElement<OtpCheck>(_OtpCheck_QNAME, OtpCheck.class, null, value);
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link String }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://sv2.bpc.in/Utils", name = "result")
    public JAXBElement<String> createResult(String value) {
        return new JAXBElement<String>(_Result_QNAME, String.class, null, value);
    }

}
