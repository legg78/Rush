package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import com.bpcbt.sv.camel.converters.Config;
import org.apache.log4j.Logger;
import ru.bpc.sv.svxp.reconciliation.AmountType;
import ru.bpc.sv.svxp.reconciliation.OperationType;
import ru.bpc.sv.svxp.reconciliation.Reconciliation;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.operations.constants.OperationsConstants;
import ru.bpc.sv2.reconciliation.RcnConstants;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

public class LoadCbsAMKReconciliationSaver extends LoadCbsReconciliationSaver {

    private static final Logger logger = Logger.getLogger("PROCESSES");

    private static final int CSV_FIELDS_COUNT = 13;
    private static final String US_ON_US = "STTT0010";
    private static final String OPER_TYPE_PROCESSED = "OPST0400";

    @Override
    public void save() throws Exception {

        String line;
        String cvsSplitBy = ",";
        Charset inputCharset = Config.getFrontEndCharset();

        try (BufferedReader br = new BufferedReader(new InputStreamReader(inputStream, inputCharset))) {
            Reconciliation reconciliation = new Reconciliation();
            boolean firstLine = true;
            while ((line = br.readLine()) != null) {
                String[] operation = line.split(cvsSplitBy);
                if (CSV_FIELDS_COUNT == operation.length) {
                    // map of operation
                    ReconciliationAMK reconciliationAMK = new ReconciliationAMK(operation);
                    if (firstLine) {
                        mapHeaderReconciliation(reconciliation, reconciliationAMK);
                        firstLine = false;
                    }
                    mapBodyReconciliation(reconciliation, reconciliationAMK);
                } else {
                    logger.error("Invalid length of line " + operation.length);
                }
            }
            if (! reconciliation.getOperation().isEmpty()) {
                List<OperationType> operations = new ArrayList<OperationType>(RegisterReconciliationJdbc.BATCH_SIZE);
                List<Filter> options = new ArrayList<Filter>(RegisterReconciliationJdbc.PARAMS_SIZE);
                RegisterReconciliationJdbc dao = new RegisterReconciliationJdbc(params, con);
                setUserContext();
                for (OperationType rec : reconciliation.getOperation()) {
                    operations.add(rec);
                    if (operations.size() >= RegisterReconciliationJdbc.BATCH_SIZE) {
                        registerOperations(dao, options, operations);
                        operations.clear();
                    }
                }
                dao.setSessionFileId(sessionId);
                registerOperations(dao, options, operations);
                dao.flush();
            }
        } catch (Exception e) {
            if (e instanceof UserException) {
                throw new UserException(e);
            } else {
                throw new SystemException(e);
            }
        }
    }

    private void mapBodyReconciliation(Reconciliation reconciliation, ReconciliationAMK reconciliationAMK) {
        OperationType operationType = new OperationType();
        operationType.setOperType(reconciliationAMK.getOperationIdentifier().substring(0, 8));
        operationType.setMsgType(mapMessageType(reconciliationAMK.getMessageType()));
        operationType.setSttlType(US_ON_US);
        operationType.setOperDate(parseDateTime(reconciliationAMK.getTransactionDate()));

        long operAmount = Long.parseLong(reconciliationAMK.getAmount());
        long chargeAmount = Long.parseLong(reconciliationAMK.getTotalChargeAmount());

        AmountType amount = new AmountType();
        amount.setAmountValue(operAmount + chargeAmount);
        amount.setCurrency(reconciliationAMK.getCurrency());
        operationType.setOperAmount(amount);

        amount = new AmountType();
        amount.setAmountValue(operAmount);
        amount.setCurrency(reconciliationAMK.getCurrency());
        operationType.setOperRequestAmount(amount);

        amount = new AmountType();
        amount.setAmountValue(chargeAmount);
        amount.setCurrency(reconciliationAMK.getCurrency());
        operationType.setOperSurchargeAmount(amount);

        operationType.setOriginatorRefnum(null);
        operationType.setNetworkRefnum(null);
        operationType.setAcqInstBin(null);
        operationType.setStatus(OPER_TYPE_PROCESSED);
        operationType.setIsReversal( (null == reconciliationAMK.getMessageType()) ? 0 : ("14".equals(reconciliationAMK.getMessageType()) ? 1 : 0));
        operationType.setMcc(null);
        operationType.setMerchantNumber(null);
        operationType.setMerchantName(null);
        operationType.setMerchantStreet(null);
        operationType.setMerchantCity(null);
        operationType.setMerchantRegion(null);
        operationType.setMerchantCountry(null);
        operationType.setMerchantPostcode(null);
        operationType.setTerminalType(null);
        operationType.setTerminalNumber(reconciliationAMK.getTerminalNumber());
        operationType.setCardNumber(null);
        operationType.setCardSeqNumber(null);
        operationType.setCardExpirDate(null);
        operationType.setCardCountry(null);
        operationType.setAcqInstId(null);
        operationType.setIssInstId(null);
        operationType.setAuthCode(null);

        reconciliation.getOperation().add(operationType);

    }

    private void mapHeaderReconciliation(Reconciliation reconciliation, ReconciliationAMK reconciliationAMK) {
        reconciliation.setFileType(ProcessConstants.FILE_TYPE_CBS_AMK_RECONCILIATION);
        reconciliation.setStartDate(parseDateTime(reconciliationAMK.getValueDate() + "000000"));
        reconciliation.setEndDate(parseDateTime(reconciliationAMK.getValueDate() + "235959"));
        reconciliation.setInstId(1001);
        reconciliation.setReconType(RcnConstants.RECONCILIATION_TYPE_COMMON);
    }

    private XMLGregorianCalendar parseDateTime(String dateTime) {
        DateFormat format = new SimpleDateFormat("yyyyMMddHHmmss");
        Date date;
        XMLGregorianCalendar xmlGregCal = null;
        try {
            date = format.parse(dateTime);
            GregorianCalendar cal = new GregorianCalendar();
            cal.setTime(date);

            try {
                xmlGregCal = DatatypeFactory.newInstance().newXMLGregorianCalendar(cal);
            } catch (DatatypeConfigurationException e) {
                logger.error(e.getMessage(), e);
            }
        } catch (ParseException e) {
            logger.error(e.getMessage(), e);
        }
        return xmlGregCal;
    }

    private String mapMessageType(String codeMTI) {
        String result = null;
        if (null != codeMTI) {
            String firstSimbols = codeMTI.substring(0, 2);
            if ("11".equals(firstSimbols))
                result = OperationsConstants.MESSAGE_TYPE_AUTHORIZATION;
            if ("12".equals(firstSimbols))
                result = OperationsConstants.MESSAGE_TYPE_AUTHORIZATION;
            if ("14".equals(firstSimbols))
                result = OperationsConstants.MESSAGE_TYPE_AUTHORIZATION;
        }
        return result;
    }
}
