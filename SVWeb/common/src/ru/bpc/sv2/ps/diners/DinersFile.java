package ru.bpc.sv2.ps.diners;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class DinersFile implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = -367857103126887792L;
    private Long id;
    private Long sessionId;
    private String fileName;
    private Date dateFrom;
    private Date fileDate;
    private Date dateTo;
    private Boolean isIncoming;
    private Boolean isRejected;
    private Integer networkId;
    private Integer instId;
    private String instName;
    private Long recapTotal;

    public Long getId(){
        return id;
    }
    public void setId( Long id ){
        this.id = id;
    }

    public Long getSessionId(){
        return sessionId;
    }
    public void setSessionId( Long sessionId ){
        this.sessionId = sessionId;
    }

    public String getFileName(){
        return fileName;
    }
    public void setFileName( String fileName ){
        this.fileName = fileName;
    }

    public Date getDateFrom(){
        return dateFrom;
    }
    public void setDateFrom( Date dateFrom ){
        this.dateFrom = dateFrom;
    }

    public Date getFileDate(){
        return fileDate;
    }
    public void setFileDate( Date fileDate ){
        this.fileDate = fileDate;
    }

    public Date getDateTo(){
        return dateTo;
    }
    public void setDateTo( Date dateTo ){
        this.dateTo = dateTo;
    }

    public Boolean getIsIncoming(){
        return isIncoming;
    }
    public void setIsIncoming( Boolean incoming ){
        isIncoming = incoming;
    }

    public Boolean getIsRejected(){
        return isRejected;
    }
    public void setIsRejected( Boolean rejected ){
        isRejected = rejected;
    }

    public Integer getNetworkId(){
        return networkId;
    }
    public void setNetworkId( Integer networkId ){
        this.networkId = networkId;
    }

    public Integer getInstId(){
        return instId;
    }
    public void setInstId( Integer instId ){
        this.instId = instId;
    }

    public String getInstName(){
        return instName;
    }
    public void setInstName( String instName ){
        this.instName = instName;
    }

    public Long getRecapTotal(){
        return recapTotal;
    }
    public void setRecapTotal( Long recapTotal ){
        this.recapTotal = recapTotal;
    }

    @Override
    public Object clone(){
        Object result = null;
        try {
            result = super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return result;
    }
    @Override
    public Object getModelId() {
        return getId();
    }
}
