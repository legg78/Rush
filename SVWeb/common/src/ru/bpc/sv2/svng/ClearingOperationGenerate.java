package ru.bpc.sv2.svng;

import java.math.BigDecimal;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathException;
import javax.xml.xpath.XPathFactory;
import org.dom4j.Element;
import org.dom4j.Node;

/**
 * Created by Gasanov on 19.08.2016.
 */
public class ClearingOperationGenerate {

    public static boolean generate(Node node, ClearingOperation operation, StringBuilder path) throws ParseException {
        return generate(node, operation, path, "yyyy-MM-dd'T'HH:mm:ss");
    }

    public static boolean generate(Node node, ClearingOperation operation, StringBuilder path, String dateFormat) throws ParseException {
        if (node != null && node.getNodeType() == Node.ELEMENT_NODE) {
            Element element = (Element) node;
            Integer len = path.length();
            path.append("/").append(node.getName());
            match(element, operation, path.toString(), dateFormat);
            List list = element.elements();
            for (Object child : list) {
                generate((Element) child, operation, path, dateFormat);
            }
            path.setLength(len);
            return (list != null && list.size() > 0) ? true : false;
        }
        return false;
    }

    public static ClearingOperation assembleFromNode(Node node, String dateFormat) throws ParseException {
        ClearingOperation co = new ClearingOperation();
        generate(node, co, new StringBuilder(), dateFormat);
        return (co);
    }

    private static void match(Element element, ClearingOperation operation, String path, String dateFormat) throws ParseException {
        SimpleDateFormat df = new SimpleDateFormat(dateFormat);

        if (path.equals("/operation/oper_id")) {
            operation.setId(Long.valueOf(element.getText()));
        } else if (path.equals("/inst_id")) {
            operation.setInstId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/oper_type")) {
            operation.setOperType(element.getText());
        } else if (path.equals("/operation/msg_type")) {
            operation.setMsgType(element.getText());
        } else if (path.equals("/operation/sttl_type")) {
            operation.setSttlType(element.getText());
        } else if (path.equals("/operation/reconciliation_type")) {
            operation.setReconType(element.getText());
        } else if (path.equals("/operation/oper_date")) {
            operation.setOperDate(df.parse(element.getText()));
        } else if (path.equals("/operation/host_date")) {
            operation.setHostDate(df.parse(element.getText()));
        } else if (path.equals("/operation/oper_count")) {
            operation.setOperCount(Long.valueOf(element.getText()));
        } else if (path.equals("/operation/oper_amount/amount_value")) {
            operation.setOperAmount(new BigDecimal(element.getText()));
        } else if (path.equals("/operation/oper_amount/currency")) {
            operation.setOperCurrency(element.getText());
        } else if (path.equals("/operation/oper_request_amount/amount_value")) {
            operation.setOperRequestAmount(new BigDecimal(element.getText()));
        } else if (path.equals("/operation/oper_request_amount/currency")) {
            operation.setOperRequestAmountCurrency(element.getText());
        } else if (path.equals("/operation/oper_surcharge_amount/amount_value")) {
            operation.setOperSurchargeAmount(new BigDecimal(element.getText()));
        } else if (path.equals("/operation/oper_surcharge_amount/currency")) {
            operation.setOperSurchargeAmountCurrency(element.getText());
        } else if (path.equals("/operation/oper_cashback_amount/amount_value")) {
            operation.setOperCashbackAmount(new BigDecimal(element.getText()));
        } else if (path.equals("/operation/oper_cashback_amount/currency")) {
            operation.setOperCashbackAmountCurrency(element.getText());
        } else if (path.equals("/operation/interchange_fee/amount_value")) {
            operation.setInterchangeFee(new BigDecimal(element.getText()));
        } else if (path.equals("/operation/interchange_fee/currency")) {
            operation.setInterchangeFeeCurrency(element.getText());
        } else if (path.equals("/operation/oper_reason")) {
            operation.setOperReason(element.getText());
        } else if (path.equals("/operation/status")) {
            operation.setStatus(element.getText());
        } else if (path.equals("/operation/status_reason")) {
            operation.setStatusReason(element.getText());
        } else if (path.equals("/operation/is_reversal")) {
            operation.setIsReversal(element.getText().equals("1"));
        } else if (path.equals("/operation/originator_refnum")) {
            operation.setOriginatorRefnum(element.getText());
        } else if (path.equals("/operation/network_refnum")) {
            operation.setNetworkRefnum(element.getText());
        } else if (path.equals("/operation/acq_inst_bin")) {
            operation.setAcqInstBin(element.getText());
        } else if (path.equals("/operation/forwarding_inst_bin")) {
            operation.setForwInstBin(element.getText());
        } else if (path.equals("/operation/merchant_number")) {
            operation.setMerchantNumber(element.getText());
        } else if (path.equals("/operation/mcc")) {
            operation.setMccCode(element.getText());
        } else if (path.equals("/operation/merchant_name")) {
            operation.setMerchantName(element.getText());
        } else if (path.equals("/operation/merchant_street")) {
            operation.setMerchantStreet(element.getText());
        } else if (path.equals("/operation/merchant_city")) {
            operation.setMerchantCity(element.getText());
        } else if (path.equals("/operation/merchant_region")) {
            operation.setMerchantRegion(element.getText());
        } else if (path.equals("/operation/merchant_country")) {
            operation.setMerchantCountry(element.getText());
        } else if (path.equals("/operation/merchant_postcode")) {
            operation.setMerchantPostCode(element.getText());
        } else if (path.equals("/operation/terminal_type")) {
            operation.setTerminalType(element.getText());
        } else if (path.equals("/operation/terminal_number")) {
            operation.setTerminalNumber(element.getText());
        } else if (path.equals("/operation/sttl_date")) {
            operation.setSttlData(df.parse(element.getText()));
        } else if (path.equals("/operation/acq_sttl_date")) {
            operation.setAcqSttlDate(df.parse(element.getText()));
        } else if (path.equals("/operation/auth_data/external_auth_id")) {
            operation.setExternalAuthId(element.getText());
        } else if (path.equals("/operation/auth_data/external_orig_id")) {
            operation.setExternalOrigId(element.getText());
        } else if (path.equals("/operation/auth_data/trace_number")) {
            operation.setTraceNumber(element.getText());
        } else if (path.equals("/operation/payment_order/payment_order_id")) {
            operation.setPaymentOrderId(Long.valueOf(element.getText()));
        } else if (path.equals("/operation/payment_order/payment_order_status")) {
            operation.setPaymentOrderStatus(element.getText());
        } else if (path.equals("/operation/payment_order/payment_order_number")) {
            operation.setPaymentOrderNumber(element.getText());
        } else if (path.equals("/operation/payment_order/purpose_id")) {
            operation.setPurposeId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/payment_order/purpose_number")) {
            operation.setPurposeNumber(element.getText());
        } else if (path.equals("/operation/payment_order/payment_amount/amount_value")) {
            operation.setPaymentOrderAmount(new BigDecimal(element.getText()));
        } else if (path.equals("/operation/payment_order/payment_amount/currency")) {
            operation.setPaymentOrderCurrency(element.getText());
        } else if (path.equals("/operation/payment_order/participant_type")) {
            operation.setPaymentOrderPrtyType(element.getText());
        } else if (path.equals("/operation/payment_order/payment_parameter")) {
            operation.setPaymentParameters(getXML(element));
        } else if (path.equals("/operation/issuer/client_id_type")) {
            operation.setIssClientIdType(element.getText());
        } else if (path.equals("/operation/issuer/client_id_value")) {
            operation.setIssClientIdValue(element.getText());
        } else if (path.equals("/operation/issuer/card_number")) {
            operation.setIssCardNumber(element.getText());
        } else if (path.equals("/operation/issuer/card_id")) {
            operation.setIssCardId(Long.valueOf(element.getText()));
        } else if (path.equals("/operation/issuer/card_seq_number")) {
            operation.setIssCardSeqNumber(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/issuer/card_expir_date")) {
            operation.setIssCardExpirDate(df.parse(element.getText()));
        } else if (path.equals("/operation/issuer/inst_id")) {
            operation.setIssInstId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/issuer/network_id")) {
            operation.setIssNetworkId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/issuer/auth_code")) {
            operation.setIssAuthCode(element.getText());
        } else if (path.equals("/operation/issuer/account_amount")) {
            operation.setIssAccountAmount(Long.valueOf(element.getText()));
        } else if (path.equals("/operation/issuer/account_currency")) {
            operation.setIssAccountCurrency(element.getText());
        } else if (path.equals("/operation/issuer/account_number")) {
            operation.setIssAccountNumber(element.getText());
        } else if (path.equals("/operation/acquirer/client_id_type")) {
            operation.setAcqClientIdType(element.getText());
        } else if (path.equals("/operation/acquirer/client_id_value")) {
            operation.setAcqClientIdvalue(element.getText());
        } else if (path.equals("/operation/acquirer/card_number")) {
            operation.setAcqCardNumber(element.getText());
        } else if (path.equals("/operation/acquirer/card_seq_number")) {
            operation.setAcqCardSeqNumber(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/acquirer/card_expir_date")) {
            operation.setAcqCardExpirDate(df.parse(element.getText()));
        } else if (path.equals("/operation/acquirer/inst_id")) {
            operation.setAcqInstId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/acquirer/network_id")) {
            operation.setAcqNetworkId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/acquirer/auth_code")) {
            operation.setAcqAuthCode(element.getText());
        } else if (path.equals("/operation/acquirer/account_amount")) {
            operation.setAcqAccountAmount(Long.valueOf(element.getText()));
        } else if (path.equals("/operation/acquirer/account_currency")) {
            operation.setAcqAccountCurrency(element.getText());
        } else if (path.equals("/operation/acquirer/account_number")) {
            operation.setAcqAccountNumber(element.getText());
        } else if (path.equals("/operation/destination/client_id_type")) {
            operation.setDestinationClientIdType(element.getText());
        } else if (path.equals("/operation/destination/client_id_value")) {
            operation.setDestinationClientIdvalue(element.getText());
        } else if (path.equals("/operation/destination/card_number")) {
            operation.setDestinationCardNumber(element.getText());
        } else if (path.equals("/operation/destination/card_id")) {
            operation.setDestinationCardId(Long.valueOf(element.getText()));
        } else if (path.equals("/operation/destination/card_seq_number")) {
            operation.setDestinationCardSeqNumber(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/destination/card_expir_date")) {
            operation.setDestinationCardExpirDate(df.parse(element.getText()));
        } else if (path.equals("/operation/destination/inst_id")) {
            operation.setDestinationInstId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/destination/network_id")) {
            operation.setDestinationNetworkId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/destination/auth_code")) {
            operation.setDestinationAuthCode(element.getText());
        } else if (path.equals("/operation/destination/account_amount")) {
            operation.setDestinationAccountAmount(Long.valueOf(element.getText()));
        } else if (path.equals("/operation/destination/account_currency")) {
            operation.setDestinationAccountCurrency(element.getText());
        } else if (path.equals("/operation/destination/account_number")) {
            operation.setDestinationAccountNumber(element.getText());
        } else if (path.equals("/operation/aggregator/client_id_type")) {
            operation.setAggregatorClientIdType(element.getText());
        } else if (path.equals("/operation/aggregator/client_id_value")) {
            operation.setAggregatorClientIdvalue(element.getText());
        } else if (path.equals("/operation/aggregator/card_number")) {
            operation.setAggregatorCardNumber(element.getText());
        } else if (path.equals("/operation/aggregator/card_seq_number")) {
            operation.setAggregatorCardSeqNumber(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/aggregator/card_expir_date")) {
            operation.setAggregatorCardExpirDate(df.parse(element.getText()));
        } else if (path.equals("/operation/aggregator/inst_id")) {
            operation.setAggregatorInstId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/aggregator/network_id")) {
            operation.setAggregatorNetworkId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/aggregator/auth_code")) {
            operation.setAggregatorAuthCode(element.getText());
        } else if (path.equals("/operation/aggregator/account_amount")) {
            operation.setAggregatorAccountAmount(new BigDecimal(element.getText()));
        } else if (path.equals("/operation/aggregator/account_currency")) {
            operation.setAggregatorAccountCurrency(element.getText());
        } else if (path.equals("/operation/aggregator/account_number")) {
            operation.setAggregatorAccountNumber(element.getText());
        } else if (path.equals("/operation/service_provider/client_id_type")) {
            operation.setSrvpClientIdType(element.getText());
        } else if (path.equals("/operation/service_provider/client_id_value")) {
            operation.setSrvpClientIdvalue(element.getText());
        } else if (path.equals("/operation/service_provider/card_number")) {
            operation.setSrvpCardNumber(element.getText());
        } else if (path.equals("/operation/service_provider/card_seq_number")) {
            operation.setSrvpCardSeqNumber(element.getText());
        } else if (path.equals("/operation/service_provider/card_expir_date")) {
            operation.setSrvpCardExpirDate(df.parse(element.getText()));
        } else if (path.equals("/operation/service_provider/inst_id")) {
            operation.setSrvpInstId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/service_provider/network_id")) {
            operation.setSrvpNetworkId(Integer.valueOf(element.getText()));
        } else if (path.equals("/operation/service_provider/auth_code")) {
            operation.setSrvpAuthCode(element.getText());
        } else if (path.equals("/operation/service_provider/account_amount")) {
            operation.setSrvpAccountAmount(new BigDecimal(element.getText()));
        } else if (path.equals("/operation/service_provider/account_currency")) {
            operation.setSrvpAccountCurrency(element.getText());
        } else if (path.equals("/operation/service_provider/account_number")) {
            operation.setSrvpAccountNumber(element.getText());
        } else if (path.equals("/operation/participant")) {
            operation.setParticipant(getXML(element));
        } else if (path.equals("/operation/payment_order")) {
            operation.setPaymentOrderExists(true);
        } else if (path.equals("/operation/issuer")) {
            operation.setIssuerExists(true);
        } else if (path.equals("/operation/acquirer")) {
            operation.setAcquirerExists(true);
        } else if (path.equals("/operation/destination")) {
            operation.setDestinationExists(true);
        } else if (path.equals("/operation/aggregator")) {
            operation.setAggregatorExists(true);
        } else if (path.equals("/operation/service_provider")) {
            operation.setServiceProviderExists(true);
        } else if (path.equals("/operation/note")) {
            operation.setNote(getXML(element));
        } else if (path.equals("/operation/auth_data")) {
            operation.setAuthData(getXML(element));
        } else if (path.equals("/operation/ipm_data")) {
            operation.setIpmData(getXML(element));
        } else if (path.equals("/operation/baseII_data")) {
            operation.setBaseiiData(getXML(element));
        } else if (path.equals("/operation/match_status")) {
            operation.setMatchStatus(element.getText());
        } else if (path.equals("/operation/additional_amount")) {
            operation.setAdditionalAmount(getXML(element));
        } else if (path.equals("/operation/processing_stage")) {
            operation.setProcessingStage(getXML(element));
        }
    }

    private static String getXML(Element element){
        String xml = element.asXML();
        xml = xml.substring(0, xml.indexOf(">")) + " xmlns=\"http://bpc.ru/sv/SVXP/clearing\"" + xml.substring(xml.indexOf('>'));
        return xml;
    }
}