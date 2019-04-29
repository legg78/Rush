package ru.bpc.sv2.scheduler.process.nbc.entity;

import com.bpcbt.sv.nbc.pain001.CreditTransferTransaction6;
import com.bpcbt.sv.nbc.pain001.CustomerCreditTransferInitiationV05;
import com.bpcbt.sv.nbc.pain001.PaymentInstruction9;
import com.bpcbt.sv.nbc.pain002.*;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.ui.session.UserSession;
import util.auxil.ManagedBeanWrapper;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.namespace.QName;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

public class Pain002Handler extends PainHandler {
    public final static String HEADER = "<?xml version=\"1.0\" encoding=\"UTF-8\" standalone=\"yes\"?>\n" +
                                        "<Document xsi:schemaLocation=\"xsd/pain.002.001.06.xsd\" " +
                                        "xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.002.001.06\" " +
                                        "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\">\n";
    public final static String NAMESPACE_1 = " xmlns=\"http://www.w3.org/2001/XMLSchema\" " +
                                             "xmlns=\"urn:iso:std:iso:20022:techd:pain.002.001.06\"";
    public final static String NAMESPACE_2 = "xmlns=\"urn:iso:std:iso:20022:techd:pain.002.001.06\"";
    public final static String NAMESPACE_3 = "xsi:schemaLocation=\"xsd/pain.002.001.06.xsd\" " +
                                             "xmlns=\"urn:iso:std:iso:20022:tech:xsd:pain.002.001.06\" " +
                                             "xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\"";

    private Unmarshaller unmarshaller;
    private Marshaller marshaller;
    private QName qNameLocal;
    private QName qNameDoc;

    public Pain002Handler() throws Exception {
        qNameLocal = new QName("http://www.w3.org/2001/XMLSchema", "CstmrPmtStsRpt");
        qNameDoc = new QName(null, "Document");
        unmarshaller = JAXBContext.newInstance(Document.class).createUnmarshaller();
        marshaller = JAXBContext.newInstance(CustomerPaymentStatusReportV06.class).createMarshaller();
        initTemplate();
    }

    @Override
    public String asString(boolean cutHeader) throws Exception {
        Object root;
        if (cutHeader) {
            CustomerPaymentStatusReportV06 content = ((Document)data).getCstmrPmtStsRpt();
            root = new JAXBElement<CustomerPaymentStatusReportV06>(qNameLocal, CustomerPaymentStatusReportV06.class, content);
        } else {
            root = new JAXBElement<Document>(qNameDoc, Document.class, ((Document)data));
        }
        org.w3c.dom.Document document = builder.newDocument();
        marshaller.marshal(root, document);
        StringWriter writer = new StringWriter();
        transformer.transform(new DOMSource(document), new StreamResult(writer));
        return getCleanWriterContent(cutHeader, writer, NAMESPACE_1, NAMESPACE_2, NAMESPACE_3);
    }
    @Override
    public boolean parse(final String raw) {
        try {
            JAXBElement<Document>tmp = (JAXBElement)unmarshaller.unmarshal(new StringReader(raw));
            data = tmp.getValue();
        } catch (Exception e) {
            logger.trace(e.getMessage());
            return false;
        }
        return true;
    }
    @Override
    public void setData(Object orig) {
        if (orig instanceof com.bpcbt.sv.nbc.pain001.Document) {
            getContent().getGrpHdr().setMsgId(getOriginal(orig).getGrpHdr().getMsgId());
            getContent().getGrpHdr().setCreDtTm(getGregorianCurrentDate());
            getContent().getGrpHdr().getDbtrAgt().getFinInstnId().setBICFI(getOriginalPayment(orig, 0).getDbtrAgt().getFinInstnId().getBICFI());
            getContent().getGrpHdr().getCdtrAgt().getFinInstnId().setBICFI(getOriginalInformation(orig, 0, 0).getCdtrAgt().getFinInstnId().getBICFI());

            getContent().getOrgnlGrpInfAndSts().setOrgnlMsgId(getOriginal(orig).getGrpHdr().getMsgId());
            getContent().getOrgnlGrpInfAndSts().setOrgnlCreDtTm(getOriginal(orig).getGrpHdr().getCreDtTm());

            getContentPayment(0).setOrgnlPmtInfId(getOriginalPayment(orig, 0).getPmtInfId());

            getContentPayment(0).getTxInfAndSts().get(0).setOrgnlEndToEndId(getOriginalInformation(orig, 0, 0).getPmtId().getEndToEndId());
            getContentPayment(0).getTxInfAndSts().get(0).getOrgnlTxRef().getAmt().getInstdAmt().setValue(getOriginalInformation(orig, 0, 0).getAmt().getInstdAmt().getValue());
            getContentPayment(0).getTxInfAndSts().get(0).getOrgnlTxRef().getCdtr().setNm(getOriginalInformation(orig, 0, 0).getCdtr().getNm());
            getContentPayment(0).getTxInfAndSts().get(0).getOrgnlTxRef().getDbtr().setNm(getOriginalPayment(orig, 0).getDbtr().getNm());

            super.setData(template);
        } else {
            super.setData(orig);
        }
    }

    private void initTemplate() {
        template = new Document();
        ((Document)template).setCstmrPmtStsRpt(createStmrPmtStsRpt());
        UserSession userSession = ManagedBeanWrapper.getManagedBean("usession");
        if (userSession != null && userSession.getUser() != null && userSession.getUser().getPerson() != null) {
            getContent().getGrpHdr().getInitgPty().setNm(userSession.getUser().getPerson().getFullName());
        }
    }

    private CustomerPaymentStatusReportV06 getContent() {
        return ((Document)template).getCstmrPmtStsRpt();
    }
    private OriginalPaymentInstruction12 getContentPayment(int index) {
        return getContent().getOrgnlPmtInfAndSts().get(index);
    }
    private CustomerCreditTransferInitiationV05 getOriginal(Object original) {
        return ((com.bpcbt.sv.nbc.pain001.Document)original).getCstmrCdtTrfInitn();
    }
    private PaymentInstruction9 getOriginalPayment(Object original, int index) {
        return getOriginal(original).getPmtInf().get(index);
    }
    private CreditTransferTransaction6 getOriginalInformation(Object original, int i1, int i2) {
        return getOriginalPayment(original, i1).getCdtTrfTxInf().get(i2);
    }
    private CustomerPaymentStatusReportV06 createStmrPmtStsRpt() {
        CustomerPaymentStatusReportV06 stmrPmtStsRpt = new CustomerPaymentStatusReportV06();
        stmrPmtStsRpt.setGrpHdr(createGrpHdr());
        stmrPmtStsRpt.setOrgnlGrpInfAndSts(createOrgnlGrpInfAndSts());
        stmrPmtStsRpt.getOrgnlPmtInfAndSts().add(createOriginalPaymentInstruction());
        return stmrPmtStsRpt;
    }
    private GroupHeader52 createGrpHdr() {
        GroupHeader52 grpHdr = new GroupHeader52();
        grpHdr.setInitgPty(createInitgPty());
        grpHdr.setDbtrAgt(createAgt());
        grpHdr.setCdtrAgt(createAgt());
        return grpHdr;
    }
    private OriginalGroupHeader1 createOrgnlGrpInfAndSts() {
        OriginalGroupHeader1 orgnlGrpInfAndSts = new OriginalGroupHeader1();
        orgnlGrpInfAndSts.setOrgnlMsgNmId("pain.001.001.05");
        return orgnlGrpInfAndSts;
    }
    private PartyIdentification43 createInitgPty() {
        PartyIdentification43 initgPty = new PartyIdentification43();
        initgPty.setPstlAdr(createPostalAddress());
        return initgPty;
    }
    private BranchAndFinancialInstitutionIdentification5 createAgt() {
        BranchAndFinancialInstitutionIdentification5 agt = new BranchAndFinancialInstitutionIdentification5();
        agt.setFinInstnId(new FinancialInstitutionIdentification8());
        return agt;
    }
    private OriginalPaymentInstruction12 createOriginalPaymentInstruction() {
        OriginalPaymentInstruction12 orgnlPmtInfAndSts = new OriginalPaymentInstruction12();
        orgnlPmtInfAndSts.getTxInfAndSts().add(createPaymentTransaction());
        return orgnlPmtInfAndSts;
    }
    private PaymentTransaction57 createPaymentTransaction() {
        PaymentTransaction57 txInfAndSts = new PaymentTransaction57();
        txInfAndSts.setTxSts(TransactionIndividualStatus3Code.ACSC);
        txInfAndSts.setOrgnlTxRef(createOriginalTrxnReference());
        return txInfAndSts;
    }
    private OriginalTransactionReference20 createOriginalTrxnReference() {
        OriginalTransactionReference20 orgnlTxRef = new OriginalTransactionReference20();
        orgnlTxRef.setAmt(createAmt());
        orgnlTxRef.setCdtr(createInitgPty());
        orgnlTxRef.setDbtr(createInitgPty());
        return orgnlTxRef;
    }
    private AmountType4Choice createAmt() {
        AmountType4Choice amt = new AmountType4Choice();
        amt.setInstdAmt(createCurrencyAndAmount());
        return amt;
    }
    private ActiveOrHistoricCurrencyAndAmount createCurrencyAndAmount() {
        ActiveOrHistoricCurrencyAndAmount instdAmt = new ActiveOrHistoricCurrencyAndAmount();
        instdAmt.setCcy("KHR");
        return instdAmt;
    }
    private PostalAddress6 createPostalAddress() {
        PostalAddress6 pstlAdr = new PostalAddress6();
        pstlAdr.setStrtNm("NA");
        pstlAdr.setBldgNb("NA");
        pstlAdr.setPstCd("NA");
        pstlAdr.setTwnNm("NA");
        pstlAdr.setCtry("NA");
        return pstlAdr;
    }
}
