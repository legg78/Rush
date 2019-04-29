package ru.bpc.sv2.ps.cup;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class CupFile implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private Boolean isIncoming;
    private Boolean isRejected;
    private Integer networkId;
    private Integer instituteId;
    private String instituteName;
    private Date transDate;
    private Integer fileNumber;
    private Integer actionCode;
    private String packNum;
    private String version;
    private String crc;
    private String encoding;
    private String fileType;
    private Date dateFrom;
    private Date dateTo;

    public Long getId(){
        return id;
    }
    public void setId( Long id ){
        this.id = id;
    }

    public Boolean getIsIncoming(){
        return isIncoming;
    }
    public void setIsIncoming( Boolean isIncoming ){
        this.isIncoming = isIncoming;
    }

    public Boolean getIsRejected(){
        return isRejected;
    }
    public void setIsRejected( Boolean isRejected ){
        this.isRejected = isRejected;
    }

    public Integer getNetworkId(){
        return networkId;
    }
    public void setNetworkId( Integer networkId ){
        this.networkId = networkId;
    }

    public Integer getInstituteId(){
        return instituteId;
    }
    public void setInstituteId( Integer instituteId ){
        this.instituteId = instituteId;
    }

    public String getInstituteName(){
        return instituteName;
    }
    public void setInstituteName( String instituteName ){
        this.instituteName = instituteName;
    }

    public Date getTransDate(){
        return transDate;
    }
    public void setTransDate( Date transDate ){
        this.transDate = transDate;
    }

    public Integer getFileNumber(){
        return fileNumber;
    }
    public void setFileNumber( Integer fileNumber ){
        this.fileNumber = fileNumber;
    }

    public Integer getActionCode(){
        return actionCode;
    }
    public void setActionCode( Integer actionCode ){
        this.actionCode = actionCode;
    }

    public String getPackNum(){
        return packNum;
    }
    public void setPackNum( String packNum ){
        this.packNum = packNum;
    }

    public String getVersion(){
        return version;
    }
    public void setVersion( String version ){
        this.version = version;
    }

    public String getCrc(){
        return crc;
    }
    public void setCrc( String crc ){
        this.crc = crc;
    }

    public String getEncoding(){
        return encoding;
    }
    public void setEncoding( String encoding ){
        this.encoding = encoding;
    }

    public String getFileType(){
        return fileType;
    }
    public void setFileType( String fileType ){
        this.fileType = fileType;
    }

    public Date getDateFrom(){
        return dateFrom;
    }
    public void setDateFrom( Date dateFrom ){
        this.dateFrom = dateFrom;
    }

    public Date getDateTo(){
        return dateTo;
    }
    public void setDateTo( Date dateTo ){
        this.dateTo = dateTo;
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
