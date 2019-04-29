package ru.bpc.sv2.ui.reconciliation;

import org.apache.poi.ss.usermodel.Row;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.reconciliation.*;
import ru.bpc.sv2.reconciliation.export.atm.ReconciliationATMAdapter;
import ru.bpc.sv2.reconciliation.export.atm.ReconciliationATMDTO;
import ru.bpc.sv2.reconciliation.export.operations.ReconciliationAdapter;
import ru.bpc.sv2.reconciliation.export.operations.ReconciliationDTO;
import ru.bpc.sv2.reconciliation.export.sp.ReconciliationSRVPAdapter;
import ru.bpc.sv2.reconciliation.export.sp.ReconciliationSRVPDTO;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.ExportUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import util.auxil.ManagedBeanWrapper;
import util.servlet.FileServlet;

import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;
import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.text.SimpleDateFormat;
import java.util.*;

public class RcnExport {
    private static final String ROOT_OPERATIONS = "operations";
    private static final String ROOT_ORDERS = "orders";
    private static final String BUNDLE = "ru.bpc.sv2.ui.bundles.Rec";

    private String format;
    private List<SelectItem> formats;
    private List<RcnMessage> operations;
    private Long userSessionId;
    private String lang;
    private ByteArrayOutputStream outStream;
    private String prefix;

    public String getFormat() {
        return format;
    }
    public void setFormat(String format) {
        this.format = format;
    }

    public List<RcnMessage> getOperations() {
        if (operations == null) {
            operations = new ArrayList<RcnMessage>();
        }
        return operations;
    }
    public void setOperations(List<RcnMessage> operations) {
        this.operations = operations;
    }

    public Long getUserSessionId() {
        return userSessionId;
    }
    public void setUserSessionId(Long userSessionId) {
        this.userSessionId = userSessionId;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public String getPrefix() {
        if (prefix == null) {
            setPrefix("");
        }
        return prefix;
    }
    public void setPrefix(String prefix) {
        this.prefix = prefix;
    }

    public List<SelectItem> getFormats() {
        if (formats == null) {
            DictUtils utils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
            Map<String, String> map = utils.getArticlesMap(ReportConstants.REPORT_FORMAT);
            formats = new ArrayList<SelectItem>(2);
            formats.add(new SelectItem(ReportConstants.FORMAT_EXCEL, map.get(ReportConstants.REPORT_FORMAT_EXCEL)));
            formats.add(new SelectItem(ReportConstants.FORMAT_XML, map.get(ReportConstants.REPORT_FORMAT_HTML)));
        }
        return formats;
    }

    public String getReportName() {
        String date = new SimpleDateFormat(DatePatterns.REPORT_DATE_TIME_PATTERN).format(new Date());
        return getPrefix() + date + "." + getFormat();
    }

    public void process() {
        outStream = new ByteArrayOutputStream();
        if (ReportConstants.FORMAT_EXCEL.equals(format)) {
            exportXLS(getOperations());
        } else if (ReportConstants.FORMAT_XML.equals(format)) {
            exportXML(getOperations());
        }
        generateFileByServlet();
    }

    @SuppressWarnings("unchecked")
    public void exportXML(final List<RcnMessage> list) {
        try {
            switch (getPrefix()) {
                case RcnConstants.EXPORT_PREFIX_ATM:
                    ExportUtils.exportXML(outStream, list, ROOT_OPERATIONS,
                                          new ReconciliationATMAdapter(),
                                          new ReconciliationATMDTO(),
                                          ReconciliationATMDTO.class);
                    break;
                case RcnConstants.EXPORT_PREFIX_SP:
                    ExportUtils.exportXML(outStream, list, ROOT_ORDERS,
                                          new ReconciliationSRVPAdapter(),
                                          new ReconciliationSRVPDTO(),
                                          ReconciliationSRVPDTO.class);
                    break;
                default:
                    ExportUtils.exportXML(outStream, list, ROOT_OPERATIONS,
                                          new ReconciliationAdapter(),
                                          new ReconciliationDTO(),
                                          ReconciliationDTO.class);
                    break;
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
        }
    }

    @SuppressWarnings("unchecked")
    private void exportXLS(final List<RcnMessage> list) {
        try {
            final UserSession session = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
            final ExportUtils ex = new ExportUtils() {
                @Override
                public void createHeadRow() {
                    Row head = sheet.createRow((short)0);
                    head = fillHeadRow(head);
                    sheet.setColumnWidth(0, 32 * 128);
                }
                @Override
                public void createRows() {
                    int i = 1;
                    for (RcnMessage msg : list) {
                        Row row = sheet.createRow(i++);
                        if (RcnConstants.EXPORT_PREFIX_ATM.equals(getPrefix())) {
                            fillCellString(row.createCell(0), msg.getReconType());
                            fillCellDate(row.createCell(1), msg.getOperDate(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
                            fillCellString(row.createCell(2), msg.getCardMask());
                            fillCellNumber(row.createCell(3), msg.getAcqInstId());
                            fillCellString(row.createCell(4), msg.getTerminalNum());
                            fillCellNumber(row.createCell(5), msg.getOperAmount());
                            fillCellString(row.createCell(6), msg.getOperCurrency());
                            fillCellString(row.createCell(7), msg.getTraceNumber());
                            fillCellString(row.createCell(8), msg.getAuthCode());
                            fillCellString(row.createCell(9), msg.getAccFrom());
                            fillCellString(row.createCell(10), msg.getAccTo());
                            fillCellString(row.createCell(11), msg.getReconStatus());
                            fillCellDate(row.createCell(12), msg.getReconLastDateTime(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
                        } else if (RcnConstants.EXPORT_PREFIX_SP.equals(getPrefix())) {
                            fillCellString(row.createCell(0), msg.getReconType());
                            fillCellString(row.createCell(1), msg.getReconStatus());
                            fillCellDate(row.createCell(2), msg.getReconLastDateTime(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
                            fillCellString(row.createCell(3), msg.getMsgSource());
                            fillCellDate(row.createCell(4), msg.getMsgDateTime(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
                            fillCellNumber(row.createCell(5), msg.getOrderId());
                            fillCellString(row.createCell(6), msg.getStatus());
                            fillCellString(row.createCell(7), msg.getPaymentOrderNumber());
                            fillCellDate(row.createCell(8), msg.getOrderDate(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
                            fillCellNumber(row.createCell(9), msg.getOrderAmount());
                            fillCellString(row.createCell(10), msg.getOrderCurrency());
                            fillCellNumber(row.createCell(11), msg.getCustomerId());
                            fillCellString(row.createCell(12), msg.getCustomerNumber());
                            fillCellNumber(row.createCell(13), msg.getPurposeId());
                            fillCellString(row.createCell(14), msg.getPurposeNumber());
                            fillCellNumber(row.createCell(15), msg.getProviderId());
                            fillCellString(row.createCell(16), msg.getProviderNumber());
                        } else {
                            fillCellString(row.createCell(0), msg.getOperType());
                            fillCellString(row.createCell(1), msg.getMsgType());
                            fillCellString(row.createCell(2), msg.getSttlType());
                            fillCellDate(row.createCell(3), msg.getOperDate(), session.getFullDatePatternSeconds(), session.getCurrentLocale());
                            fillCellNumber(row.createCell(4), msg.getOperAmount());
                            fillCellString(row.createCell(5), msg.getOperCurrency());
                            fillCellNumber(row.createCell(6), msg.getOperRequestAmount());
                            fillCellString(row.createCell(7), msg.getOperRequestCurrency());
                            fillCellNumber(row.createCell(8), msg.getOperSurchargeAmount());
                            fillCellString(row.createCell(9), msg.getOperSurchargeCurrency());
                            fillCellString(row.createCell(10), msg.getOriginatorRefnum());
                            fillCellString(row.createCell(11), msg.getNetworkRefnum());
                            fillCellString(row.createCell(12), msg.getAcqInstBin());
                            fillCellString(row.createCell(13), msg.getStatus());
                            fillCellBoolean(row.createCell(14), msg.getReversal());
                            fillCellNumber(row.createCell(15), msg.getMcc());
                            fillCellString(row.createCell(16), msg.getMerchantNum());
                            fillCellString(row.createCell(17), msg.getMerchantName());
                            fillCellString(row.createCell(18), msg.getMerchantStreet());
                            fillCellString(row.createCell(19), msg.getMerchantCity());
                            fillCellString(row.createCell(20), msg.getMerchantRegion());
                            fillCellString(row.createCell(21), msg.getMerchantCountry());
                            fillCellString(row.createCell(22), msg.getMerchantPostcode());
                            fillCellString(row.createCell(23), msg.getTerminalType());
                            fillCellString(row.createCell(24), msg.getTerminalNum());
                            fillCellString(row.createCell(25), msg.getCardNumber());
                            fillCellNumber(row.createCell(26), msg.getCardSeqNum());
                            fillCellDate(row.createCell(27), msg.getCardExpirDate(), session.getFullExpDatePattern(), session.getCurrentLocale());
                            fillCellString(row.createCell(28), msg.getCardCountry());
                            fillCellNumber(row.createCell(29), msg.getAcqInstId());
                            fillCellNumber(row.createCell(30), msg.getIssInstId());
                            fillCellString(row.createCell(31), msg.getAuthCode());
                        }
                    }
                }
            };
            ex.exportXLS(outStream);
        } catch (IOException e) {
            FacesUtils.addMessageError(e);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
        }
    }

    private void generateFileByServlet() {
        if (outStream != null) {
            byte[] reportContent = outStream.toByteArray();
            try {
                outStream.close();
            } catch (IOException ignored) {}
            HttpServletRequest req = RequestContextHolder.getRequest();
            HttpSession session = req.getSession();
            session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
            session.setAttribute(FileServlet.FILE_SERVLET_FILE_CONTENT, reportContent);
        }
    }

    private Row fillHeadRow(Row head) {
        if (RcnConstants.EXPORT_PREFIX_ATM.equals(getPrefix())) {
            head.createCell(0).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_type"));
            head.createCell(1).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_date"));
            head.createCell(2).setCellValue(FacesUtils.getMessage(BUNDLE, "card_number"));
            head.createCell(3).setCellValue(FacesUtils.getMessage(BUNDLE, "acquirer_inst_id"));
            head.createCell(4).setCellValue(FacesUtils.getMessage(BUNDLE, "terminal_number"));
            head.createCell(5).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_amount"));
            head.createCell(6).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_currency"));
            head.createCell(7).setCellValue(FacesUtils.getMessage(BUNDLE, "originator_refnum"));
            head.createCell(8).setCellValue(FacesUtils.getMessage(BUNDLE, "authorization_code"));
            head.createCell(9).setCellValue(FacesUtils.getMessage(BUNDLE, "account_from"));
            head.createCell(10).setCellValue(FacesUtils.getMessage(BUNDLE, "account_to"));
            head.createCell(11).setCellValue(FacesUtils.getMessage(BUNDLE, "status"));
            head.createCell(12).setCellValue(FacesUtils.getMessage(BUNDLE, "reconciliation_date"));
        } if (RcnConstants.EXPORT_PREFIX_SP.equals(getPrefix())) {
            head.createCell(0).setCellValue(FacesUtils.getMessage(BUNDLE, "recon_type"));
            head.createCell(1).setCellValue(FacesUtils.getMessage(BUNDLE, "recon_status"));
            head.createCell(2).setCellValue(FacesUtils.getMessage(BUNDLE, "recon_date"));
            head.createCell(3).setCellValue(FacesUtils.getMessage(BUNDLE, "msg_source"));
            head.createCell(4).setCellValue(FacesUtils.getMessage(BUNDLE, "msg_date"));
            head.createCell(5).setCellValue(FacesUtils.getMessage(BUNDLE, "order_id"));
            head.createCell(6).setCellValue(FacesUtils.getMessage(BUNDLE, "status"));
            head.createCell(7).setCellValue(FacesUtils.getMessage(BUNDLE, "payment_order_number"));
            head.createCell(8).setCellValue(FacesUtils.getMessage(BUNDLE, "order_date"));
            head.createCell(9).setCellValue(FacesUtils.getMessage(BUNDLE, "order_amount"));
            head.createCell(10).setCellValue(FacesUtils.getMessage(BUNDLE, "order_currency"));
            head.createCell(11).setCellValue(FacesUtils.getMessage(BUNDLE, "customer_id"));
            head.createCell(12).setCellValue(FacesUtils.getMessage(BUNDLE, "customer_number"));
            head.createCell(13).setCellValue(FacesUtils.getMessage(BUNDLE, "purpose_id"));
            head.createCell(14).setCellValue(FacesUtils.getMessage(BUNDLE, "purpose_number"));
            head.createCell(15).setCellValue(FacesUtils.getMessage(BUNDLE, "provider_id"));
            head.createCell(16).setCellValue(FacesUtils.getMessage(BUNDLE, "provider_number"));
        } else {
            head.createCell(0).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_type"));
            head.createCell(1).setCellValue(FacesUtils.getMessage(BUNDLE, "message_type"));
            head.createCell(2).setCellValue(FacesUtils.getMessage(BUNDLE, "settlement_type"));
            head.createCell(3).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_date"));
            head.createCell(4).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_amount"));
            head.createCell(5).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_currency"));
            head.createCell(6).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_req_amount"));
            head.createCell(7).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_req_currency"));
            head.createCell(8).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_surcharge_amount"));
            head.createCell(9).setCellValue(FacesUtils.getMessage(BUNDLE, "operation_surcharge_currency"));
            head.createCell(10).setCellValue(FacesUtils.getMessage(BUNDLE, "originator_refnum"));
            head.createCell(11).setCellValue(FacesUtils.getMessage(BUNDLE, "acquirer_refnum"));
            head.createCell(12).setCellValue(FacesUtils.getMessage(BUNDLE, "acquirer_inst_bin"));
            head.createCell(13).setCellValue(FacesUtils.getMessage(BUNDLE, "status"));
            head.createCell(14).setCellValue(FacesUtils.getMessage(BUNDLE, "is_reversal"));
            head.createCell(15).setCellValue(FacesUtils.getMessage(BUNDLE, "mcc"));
            head.createCell(16).setCellValue(FacesUtils.getMessage(BUNDLE, "merchant_number"));
            head.createCell(17).setCellValue(FacesUtils.getMessage(BUNDLE, "merchant_name"));
            head.createCell(18).setCellValue(FacesUtils.getMessage(BUNDLE, "merchant_street"));
            head.createCell(19).setCellValue(FacesUtils.getMessage(BUNDLE, "merchant_city"));
            head.createCell(20).setCellValue(FacesUtils.getMessage(BUNDLE, "merchant_region"));
            head.createCell(21).setCellValue(FacesUtils.getMessage(BUNDLE, "merchant_country"));
            head.createCell(22).setCellValue(FacesUtils.getMessage(BUNDLE, "merchant_postcode"));
            head.createCell(23).setCellValue(FacesUtils.getMessage(BUNDLE, "terminal_type"));
            head.createCell(24).setCellValue(FacesUtils.getMessage(BUNDLE, "terminal_number"));
            head.createCell(25).setCellValue(FacesUtils.getMessage(BUNDLE, "card_number"));
            head.createCell(26).setCellValue(FacesUtils.getMessage(BUNDLE, "card_seqnum"));
            head.createCell(27).setCellValue(FacesUtils.getMessage(BUNDLE, "card_exp_date"));
            head.createCell(28).setCellValue(FacesUtils.getMessage(BUNDLE, "card_country"));
            head.createCell(29).setCellValue(FacesUtils.getMessage(BUNDLE, "acquirer_inst_id"));
            head.createCell(30).setCellValue(FacesUtils.getMessage(BUNDLE, "issuer_inst_id"));
            head.createCell(31).setCellValue(FacesUtils.getMessage(BUNDLE, "authorization_code"));
        }
        return head;
    }
}
