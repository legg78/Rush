package ru.bpc.sv2.ps.amex;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

public class AmexFile implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = -367857103126887792L;

    private Long id;
    private boolean isIncoming;
    private boolean isRejected;
    private Integer networkId;
    private Date dateTo;
    private Date dateFrom;
    private Date transmittalDate;
    private Integer instId;
    private String instName;
    private String forwInstCode;
    private String receivInstCode;
    private String actionCode;
    private String fileNumber;
    private String rejectCode;
    private Long msgTotal;
    private Long creditCount;
    private Long debitCount;
    private BigDecimal creditAmount;
    private BigDecimal debitAmount;
    private BigDecimal totalAmount;
    private Long receiptFileId;
    private Long rejectMessageId;
    private Long sessionFileId;
    private Long sessionId;
    private String fileName;
    private Date fileDate;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public boolean isIncoming() {
        return isIncoming;
    }
    public void setIncoming(boolean incoming) {
        isIncoming = incoming;
    }

    public boolean isRejected() {
        return isRejected;
    }
    public void setRejected(boolean rejected) {
        isRejected = rejected;
    }

    public Integer getNetworkId() {
        return networkId;
    }
    public void setNetworkId(Integer networkId) {
        this.networkId = networkId;
    }

    public Date getDateTo() {
        return dateTo;
    }
    public void setDateTo(Date dateTo) {
        this.dateTo = dateTo;
    }

    public Date getDateFrom() {
        return dateFrom;
    }
    public void setDateFrom(Date dateFrom) {
        this.dateFrom = dateFrom;
    }

    public Date getTransmittalDate() {
        return transmittalDate;
    }
    public void setTransmittalDate(Date transmittalDate) {
        this.transmittalDate = transmittalDate;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public String getInstName() {
        return instName;
    }
    public void setInstName(String instName) {
        this.instName = instName;
    }

    public String getForwInstCode() {
        return forwInstCode;
    }
    public void setForwInstCode(String forwInstCode) {
        this.forwInstCode = forwInstCode;
    }

    public String getReceivInstCode() {
        return receivInstCode;
    }
    public void setReceivInstCode(String receivInstCode) {
        this.receivInstCode = receivInstCode;
    }

    public String getActionCode() {
        return actionCode;
    }
    public void setActionCode(String actionCode) {
        this.actionCode = actionCode;
    }

    public String getFileNumber() {
        return fileNumber;
    }
    public void setFileNumber(String fileNumber) {
        this.fileNumber = fileNumber;
    }

    public String getRejectCode() {
        return rejectCode;
    }
    public void setRejectCode(String rejectCode) {
        this.rejectCode = rejectCode;
    }

    public Long getMsgTotal() {
        return msgTotal;
    }
    public void setMsgTotal(Long msgTotal) {
        this.msgTotal = msgTotal;
    }

    public Long getCreditCount() {
        return creditCount;
    }
    public void setCreditCount(Long creditCount) {
        this.creditCount = creditCount;
    }

    public Long getDebitCount() {
        return debitCount;
    }
    public void setDebitCount(Long debitCount) {
        this.debitCount = debitCount;
    }

    public BigDecimal getCreditAmount() {
        return creditAmount;
    }
    public void setCreditAmount(BigDecimal creditAmount) {
        this.creditAmount = creditAmount;
    }

    public BigDecimal getDebitAmount() {
        return debitAmount;
    }
    public void setDebitAmount(BigDecimal debitAmount) {
        this.debitAmount = debitAmount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }
    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public Long getReceiptFileId() {
        return receiptFileId;
    }
    public void setReceiptFileId(Long receiptFileId) {
        this.receiptFileId = receiptFileId;
    }

    public Long getRejectMessageId() {
        return rejectMessageId;
    }
    public void setRejectMessageId(Long rejectMessageId) {
        this.rejectMessageId = rejectMessageId;
    }

    public Long getSessionFileId() {
        return sessionFileId;
    }
    public void setSessionFileId(Long sessionFileId) {
        this.sessionFileId = sessionFileId;
    }

    public Long getSessionId() {
        return sessionId;
    }
    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public String getFileName() {
        return fileName;
    }
    public void setFileName(String fileName) {
        this.fileName = fileName;
    }

    public Date getFileDate() {
        return fileDate;
    }
    public void setFileDate(Date fileDate) {
        this.fileDate = fileDate;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
}
