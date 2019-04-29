package ru.bpc.sv2.ps.amex;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class AmexFinMessageAddendum implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = -367857103126887792L;

    private Long id;
    private Long finId;
    private Long fileId;
    private boolean isIncoming;
    private String mtid;
    private String addendaType;
    private String formatCode;
    private Integer messageSeqNumber;
    private String transactionId;
    private Long messageNumber;
    private String rejectReasonCode;
    private String iccData;
    private String iccVersionName;
    private String iccVersionNumber;
    private String emv9f26;
    private String emv9f10;
    private String emv9f37;
    private String emv9f36;
    private String emv95;
    private Date emv9a;
    private Integer emv9c;
    private Long emv9f02;
    private Integer emv5f2a;
    private Integer emv9f1a;
    private String emv82;
    private Long emv9f03;
    private Integer emv5f34;
    private String emv9f27;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Long getFinId() {
        return finId;
    }
    public void setFinId(Long finId) {
        this.finId = finId;
    }

    public Long getFileId() {
        return fileId;
    }
    public void setFileId(Long fileId) {
        this.fileId = fileId;
    }

    public boolean isIncoming() {
        return isIncoming;
    }
    public void setIncoming(boolean incoming) {
        isIncoming = incoming;
    }

    public String getMtid() {
        return mtid;
    }
    public void setMtid(String mtid) {
        this.mtid = mtid;
    }

    public String getAddendaType() {
        return addendaType;
    }
    public void setAddendaType(String addendaType) {
        this.addendaType = addendaType;
    }

    public String getFormatCode() {
        return formatCode;
    }
    public void setFormatCode(String formatCode) {
        this.formatCode = formatCode;
    }

    public Integer getMessageSeqNumber() {
        return messageSeqNumber;
    }
    public void setMessageSeqNumber(Integer messageSeqNumber) {
        this.messageSeqNumber = messageSeqNumber;
    }

    public String getTransactionId() {
        return transactionId;
    }
    public void setTransactionId(String transactionId) {
        this.transactionId = transactionId;
    }

    public Long getMessageNumber() {
        return messageNumber;
    }
    public void setMessageNumber(Long messageNumber) {
        this.messageNumber = messageNumber;
    }

    public String getRejectReasonCode() {
        return rejectReasonCode;
    }
    public void setRejectReasonCode(String rejectReasonCode) {
        this.rejectReasonCode = rejectReasonCode;
    }

    public String getIccData() {
        return iccData;
    }
    public void setIccData(String iccData) {
        this.iccData = iccData;
    }

    public String getIccVersionName() {
        return iccVersionName;
    }
    public void setIccVersionName(String iccVersionName) {
        this.iccVersionName = iccVersionName;
    }

    public String getIccVersionNumber() {
        return iccVersionNumber;
    }
    public void setIccVersionNumber(String iccVersionNumber) {
        this.iccVersionNumber = iccVersionNumber;
    }

    public String getEmv9f26() {
        return emv9f26;
    }
    public void setEmv9f26(String emv9f26) {
        this.emv9f26 = emv9f26;
    }

    public String getEmv9f10() {
        return emv9f10;
    }
    public void setEmv9f10(String emv9f10) {
        this.emv9f10 = emv9f10;
    }

    public String getEmv9f37() {
        return emv9f37;
    }
    public void setEmv9f37(String emv9f37) {
        this.emv9f37 = emv9f37;
    }

    public String getEmv9f36() {
        return emv9f36;
    }
    public void setEmv9f36(String emv9f36) {
        this.emv9f36 = emv9f36;
    }

    public String getEmv95() {
        return emv95;
    }
    public void setEmv95(String emv95) {
        this.emv95 = emv95;
    }

    public Date getEmv9a() {
        return emv9a;
    }
    public void setEmv9a(Date emv9a) {
        this.emv9a = emv9a;
    }

    public Integer getEmv9c() {
        return emv9c;
    }
    public void setEmv9c(Integer emv9c) {
        this.emv9c = emv9c;
    }

    public Long getEmv9f02() {
        return emv9f02;
    }
    public void setEmv9f02(Long emv9f02) {
        this.emv9f02 = emv9f02;
    }

    public Integer getEmv5f2a() {
        return emv5f2a;
    }
    public void setEmv5f2a(Integer emv5f2a) {
        this.emv5f2a = emv5f2a;
    }

    public Integer getEmv9f1a() {
        return emv9f1a;
    }
    public void setEmv9f1a(Integer emv9f1a) {
        this.emv9f1a = emv9f1a;
    }

    public String getEmv82() {
        return emv82;
    }
    public void setEmv82(String emv82) {
        this.emv82 = emv82;
    }

    public Long getEmv9f03() {
        return emv9f03;
    }
    public void setEmv9f03(Long emv9f03) {
        this.emv9f03 = emv9f03;
    }

    public Integer getEmv5f34() {
        return emv5f34;
    }
    public void setEmv5f34(Integer emv5f34) {
        this.emv5f34 = emv5f34;
    }

    public String getEmv9f27() {
        return emv9f27;
    }
    public void setEmv9f27(String emv9f27) {
        this.emv9f27 = emv9f27;
    }

    @Override
    public Object getModelId() {
        return getId();
    }
}
