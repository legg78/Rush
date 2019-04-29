package ru.bpc.sv2.deliveries;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;

/**
 * Created by Viktorov on 20.02.2017.
 */
public class Delivery implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;

    private String deliveryRefNum;
    private String deliveryStatus;
    private Long id;
    private Integer splitHash;
    private Long cardId;
    private Integer seqNum;
    private String state;
    private Date regDate;
    private Date issDate;
    private Date startDate;
    private Date expDate;
    private String cardholderName;
    private String companyName;
    private String pinRequest;
    private String pinMailerRequest;
    private String embossingRequest;
    private String status;
    private String persoPriority;
    private Integer persoMethodId;
    private Integer binId;
    private Integer agentId;
    private Integer instId;
    private Integer blankTypeId;
    private String deliveryChannel;
    private Long precedingCardInstanceId;
    private String reissueReason;
    private Date reissueDate;
    private Long sessionId;
    private String cardUID;
    private String cardMask;
    private String cardNumber;
    private Integer cardTypeId;
    private Integer productId;
    private String productName;

    //UI
    private Date dateFrom;
    private Date dateTo;
    private Boolean selected;

    @Override
    public Object getModelId() {
        return getId();
    }

    public String getDeliveryRefNum() {
        return deliveryRefNum;
    }

    public void setDeliveryRefNum(String deliveryRefNum) {
        this.deliveryRefNum = deliveryRefNum;
    }

    public String getDeliveryStatus() {
        return deliveryStatus;
    }

    public void setDeliveryStatus(String deliveryStatus) {
        this.deliveryStatus = deliveryStatus;
    }

    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public Integer getSplitHash() {
        return splitHash;
    }

    public void setSplitHash(Integer splitHash) {
        this.splitHash = splitHash;
    }

    public Long getCardId() {
        return cardId;
    }

    public void setCardId(Long cardId) {
        this.cardId = cardId;
    }

    public Integer getSeqNum() {
        return seqNum;
    }

    public void setSeqNum(Integer seqNum) {
        this.seqNum = seqNum;
    }

    public String getState() {
        return state;
    }

    public void setState(String state) {
        this.state = state;
    }

    public Date getRegDate() {
        return regDate;
    }

    public void setRegDate(Date regDate) {
        this.regDate = regDate;
    }

    public Date getIssDate() {
        return issDate;
    }

    public void setIssDate(Date issDate) {
        this.issDate = issDate;
    }

    public Date getStartDate() {
        return startDate;
    }

    public void setStartDate(Date startDate) {
        this.startDate = startDate;
    }

    public Date getExpDate() {
        return expDate;
    }

    public void setExpDate(Date expDate) {
        this.expDate = expDate;
    }

    public String getCardholderName() {
        return cardholderName;
    }

    public void setCardholderName(String cardholderName) {
        this.cardholderName = cardholderName;
    }

    public String getCompanyName() {
        return companyName;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public String getPinRequest() {
        return pinRequest;
    }

    public void setPinRequest(String pinRequest) {
        this.pinRequest = pinRequest;
    }

    public String getPinMailerRequest() {
        return pinMailerRequest;
    }

    public void setPinMailerRequest(String pinMailerRequest) {
        this.pinMailerRequest = pinMailerRequest;
    }

    public String getEmbossingRequest() {
        return embossingRequest;
    }

    public void setEmbossingRequest(String embossingRequest) {
        this.embossingRequest = embossingRequest;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getPersoPriority() {
        return persoPriority;
    }

    public void setPersoPriority(String persoPriority) {
        this.persoPriority = persoPriority;
    }

    public Integer getPersoMethodId() {
        return persoMethodId;
    }

    public void setPersoMethodId(Integer persoMethodId) {
        this.persoMethodId = persoMethodId;
    }

    public Integer getBinId() {
        return binId;
    }

    public void setBinId(Integer binId) {
        this.binId = binId;
    }

    public Integer getAgentId() {
        return agentId;
    }

    public void setAgentId(Integer agentId) {
        this.agentId = agentId;
    }

    public Integer getInstId() {
        return instId;
    }

    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public Integer getBlankTypeId() {
        return blankTypeId;
    }

    public void setBlankTypeId(Integer blankTypeId) {
        this.blankTypeId = blankTypeId;
    }

    public String getDeliveryChannel() {
        return deliveryChannel;
    }

    public void setDeliveryChannel(String deliveryChannel) {
        this.deliveryChannel = deliveryChannel;
    }

    public Long getPrecedingCardInstanceId() {
        return precedingCardInstanceId;
    }

    public void setPrecedingCardInstanceId(Long precedingCardInstanceId) {
        this.precedingCardInstanceId = precedingCardInstanceId;
    }

    public String getReissueReason() {
        return reissueReason;
    }

    public void setReissueReason(String reissueReason) {
        this.reissueReason = reissueReason;
    }

    public Date getReissueDate() {
        return reissueDate;
    }

    public void setReissueDate(Date reissueDate) {
        this.reissueDate = reissueDate;
    }

    public Long getSessionId() {
        return sessionId;
    }

    public void setSessionId(Long sessionId) {
        this.sessionId = sessionId;
    }

    public String getCardUID() {
        return cardUID;
    }

    public void setCardUID(String cardUID) {
        this.cardUID = cardUID;
    }

    public String getCardMask() {
        return cardMask;
    }

    public void setCardMask(String cardMask) {
        this.cardMask = cardMask;
    }

    public String getCardNumber() {
        return cardNumber;
    }

    public void setCardNumber(String cardNumber) {
        this.cardNumber = cardNumber;
    }

    public Integer getCardTypeId() {
        return cardTypeId;
    }

    public void setCardTypeId(Integer cardTypeId) {
        this.cardTypeId = cardTypeId;
    }

    public Date getDateFrom() {
        return dateFrom;
    }

    public void setDateFrom(Date dateFrom) {
        this.dateFrom = dateFrom;
    }

    public Date getDateTo() {
        return dateTo;
    }

    public void setDateTo(Date dateTo) {
        this.dateTo = dateTo;
    }

    public Boolean getSelected() {
        return selected;
    }

    public void setSelected(Boolean selected) {
        this.selected = selected;
    }

    public Integer getProductId() {
        return productId;
    }

    public void setProductId(Integer productId) {
        this.productId = productId;
    }

    public String getProductName() {
        return productName;
    }

    public void setProductName(String productName) {
        this.productName = productName;
    }

}
