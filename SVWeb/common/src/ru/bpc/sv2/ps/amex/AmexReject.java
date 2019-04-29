package ru.bpc.sv2.ps.amex;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class AmexReject implements Serializable, ModelIdentifiable, Cloneable  {
    private static final long serialVersionUID = -367857103126887792L;

    private Long id;
    private Integer instId;
    private String nameInstName;
    private boolean incoming;
    private Long msgNumber;
    private Long forwInstCode;
    private Long receivInstCode;
    private Long originFileId;
    private Long originMsgId;
    private Long fileId;
    private String fileName;
    private Date fileDate;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public String getNameInstName() {
        return nameInstName;
    }
    public void setNameInstName(String nameInstName) {
        this.nameInstName = nameInstName;
    }

    public boolean isIncoming() {
        return incoming;
    }
    public void setIncoming(boolean incoming) {
        this.incoming = incoming;
    }

    public Long getMsgNumber() {
        return msgNumber;
    }
    public void setMsgNumber(Long msgNumber) {
        this.msgNumber = msgNumber;
    }

    public Long getForwInstCode() {
        return forwInstCode;
    }
    public void setForwInstCode(Long forwInstCode) {
        this.forwInstCode = forwInstCode;
    }

    public Long getReceivInstCode() {
        return receivInstCode;
    }
    public void setReceivInstCode(Long receivInstCode) {
        this.receivInstCode = receivInstCode;
    }

    public Long getOriginFileId() {
        return originFileId;
    }
    public void setOriginFileId(Long originFileId) {
        this.originFileId = originFileId;
    }

    public Long getOriginMsgId() {
        return originMsgId;
    }
    public void setOriginMsgId(Long originMsgId) {
        this.originMsgId = originMsgId;
    }

    public Long getFileId() {
        return fileId;
    }
    public void setFileId(Long fileId) {
        this.fileId = fileId;
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
