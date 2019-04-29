package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import com.bpcbt.sv.camel.converters.mapping.BlockAddressingString;
import org.apache.log4j.Logger;
import ru.bpc.sv2.reconciliation.export.atm.ReconciliationATM;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.concurrent.Callable;

public class ReconciliationATMParser implements Callable<ReconciliationATM> {

    private static final Logger logger = Logger.getLogger(ReconciliationATMParser.class);

    private static final String ATM = "ATM";
    private static final String TERMINAL_TYPE = "TRMT0002";
    private static final String BODY_TYPE = "0002";
    private static final String TRANSACTIONAL_STATUS = "-1";

    private BlockAddressingString line;

    @Override
    public ReconciliationATM call() throws Exception {

        if (line != null && !line.isEmpty()) {
            return parseElement(line.getTarget());
        } else {
            return null;
        }

    }

    private ReconciliationATM parseElement(String element) {
        ReconciliationATM reconciliation = null;
        try {
            if (BODY_TYPE.equals(element.substring(0, 4))) {
                String terminalType = element.substring(105, 109).trim();
                String transactionStatus = element.substring(180, 184).trim();

                //Only rows with Terminal type = ‘ATM ’ and Transaction status (response code) = -1 or empty should be loaded
                if (ATM.equals(terminalType)
                        && (TRANSACTIONAL_STATUS.equals(transactionStatus) || transactionStatus.isEmpty())) {
                    reconciliation = new ReconciliationATM();
                    // parse other fields
                    String localTransactionTime = element.substring(87, 93); //HHMMSS
                    String localTransactionDate = element.substring(93, 99); //YYMMDD
                    String transactionAmount = element.substring(29, 41);
                    String transactionCurrencyCode = element.substring(167, 170);
                    String traceNumber = element.substring(81, 87);
                    String acquiringInstitutionIDCode = element.substring(109, 117).trim();
                    String cardNumber = element.substring(4, 23).trim();
                    String authorizationNumber = element.substring(141, 147);
                    String reversalFlag = element.substring(184, 185);
                    String terminalNumber = element.substring(159, 167);
                    String issuerFee = element.substring(197, 209);
                    String fromAccount = element.substring(245, 273).trim();
                    String toAccount = element.substring(273, 301).trim();

                    reconciliation.setOperDate(parseDateTime(localTransactionDate, localTransactionTime));
                    reconciliation.setOperAmount(Long.parseLong(transactionAmount));
                    reconciliation.setOperCurrency(transactionCurrencyCode);
                    reconciliation.setTraceNumber(traceNumber);
                    reconciliation.setAcqInstId(
                            (Integer.parseInt(acquiringInstitutionIDCode) == 0) ? null : Integer.parseInt(acquiringInstitutionIDCode));
                    reconciliation.setCardNumber(cardNumber);
                    reconciliation.setAuthCode(authorizationNumber);
                    reconciliation.setReversal("1".equals(reversalFlag));
                    reconciliation.setTerminalType(TERMINAL_TYPE);
                    reconciliation.setTerminalNum(terminalNumber);
                    reconciliation.setIssFee(Long.parseLong(issuerFee));
                    reconciliation.setAccFrom(fromAccount);
                    reconciliation.setAccTo(toAccount);
                }
            }
        } catch (StringIndexOutOfBoundsException e) {
            logger.error(e.getMessage(), e);
        }
        return reconciliation;
    }

    public void setLine(BlockAddressingString line) {
        this.line = line;
    }

    private Date parseDateTime(String localTransactionDate, String localTransactionTime) {
        try {
            return new SimpleDateFormat("yyMMddHHmmss").parse(localTransactionDate + localTransactionTime);
        } catch (ParseException e) {
            logger.error(e.getMessage(), e);
            return null;
        }

    }
}
