package ru.bpc.sv2.ps.jcb;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class JcbFile implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private Long sessionId;
    private Long fileId;
    private Long rejectId;
    private Integer instituteId;
    private Integer networkId;
    private Boolean isIncoming;
    private Boolean isRejected;
    private Date procDate;
    private String fileName;
    private String instituteName;
    private Integer headerMti;
    private Integer headerDe024;
    private Long headerDe071;
    private Integer trailerMti;
    private Integer trailerDe024;
    private Long trailerDe071;
    private String p3901;
    private String p39011;
    private String p39013;
    private Date p39012;
    private String p39014;
    private Long p3902;
    private Long p3903;
    private Date dateFrom;
    private Date dateTo;

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

    public Long getFileId(){
        return fileId;
    }
    public void setFileId( Long fileId ){
        this.fileId = fileId;
    }

    public Long getRejectId(){
        return rejectId;
    }
    public void setRejectId( Long rejectId ){
        this.rejectId = rejectId;
    }

    public Integer getInstituteId(){
        return instituteId;
    }
    public void setInstituteId( Integer instituteId ){
        this.instituteId = instituteId;
    }

    public Integer getNetworkId(){
        return networkId;
    }
    public void setNetworkId( Integer networkId ){
        this.networkId = networkId;
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

    public Date getProcDate(){
        return procDate;
    }
    public void setProcDate( Date procDate ){
        this.procDate = procDate;
    }

    public String getFileName(){
        return fileName;
    }
    public void setFileName( String fileName ){
        this.fileName = fileName;
    }

    public String getInstituteName(){
        return instituteName;
    }
    public void setInstituteName( String instituteName ){
        this.instituteName = instituteName;
    }

    public Integer getHeaderMti(){
        return headerMti;
    }
    public void setHeaderMti( Integer headerMti ){
        this.headerMti = headerMti;
    }

    public Integer getHeaderDe024(){
        return headerDe024;
    }
    public void setHeaderDe024( Integer headerDe024 ){
        this.headerDe024 = headerDe024;
    }

    public Long getHeaderDe071(){
        return headerDe071;
    }
    public void setHeaderDe071( Long headerDe071 ){
        this.headerDe071 = headerDe071;
    }

    public Integer getTrailerMti(){
        return trailerMti;
    }
    public void setTrailerMti( Integer trailerMti ){
        this.trailerMti = trailerMti;
    }

    public Integer getTrailerDe024(){
        return trailerDe024;
    }
    public void setTrailerDe024( Integer trailerDe024 ){
        this.trailerDe024 = trailerDe024;
    }

    public Long getTrailerDe071(){
        return trailerDe071;
    }
    public void setTrailerDe071( Long trailerDe071 ){
        this.trailerDe071 = trailerDe071;
    }

    public String getP3901(){
        return p3901;
    }
    public void setP3901( String p3901 ){
        this.p3901 = p3901;
    }

    public String getP39011(){
        return p39011;
    }
    public void setP39011( String p39011 ){
        this.p39011 = p39011;
    }

    public String getP39013(){
        return p39013;
    }
    public void setP39013( String p39013 ){
        this.p39013 = p39013;
    }

    public Date getP39012(){
        return p39012;
    }
    public void setP39012( Date p39012 ){
        this.p39012 = p39012;
    }

    public String getP39014(){
        return p39014;
    }
    public void setP39014( String p39014 ){
        this.p39014 = p39014;
    }

    public Long getP3902(){
        return p3902;
    }
    public void setP3902( Long p3902 ){
        this.p3902 = p3902;
    }

    public Long getP3903(){
        return p3903;
    }
    public void setP3903( Long p3903 ){
        this.p3903 = p3903;
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
