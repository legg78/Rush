package ru.bpc.sv2.issuing;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

public class Token implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
    private static final long serialVersionUID = 1L;

    private Long id;
    private Long cardId;
    private Long cardInstanceId;
    private Date expirationDate;
    private String status;
    private String token;
    private Long initOperId;
    private String walletProvider;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Long getCardId() {
        return cardId;
    }
    public void setCardId(Long cardId) {
        this.cardId = cardId;
    }

    public Long getCardInstanceId() {
        return cardInstanceId;
    }
    public void setCardInstanceId(Long cardInstanceId) {
        this.cardInstanceId = cardInstanceId;
    }

    public Date getExpirationDate() {
        return expirationDate;
    }
    public void setExpirationDate(Date expirationDate) {
        this.expirationDate = expirationDate;
    }

    public String getStatus() {
        return status;
    }
    public void setStatus(String status) {
        this.status = status;
    }

    public String getToken() {
        return token;
    }
    public void setToken(String token) {
        this.token = token;
    }

    public Long getInitOperId() {
        return initOperId;
    }
    public void setInitOperId(Long initOperId) {
        this.initOperId = initOperId;
    }

    public String getWalletProvider() { return walletProvider; }
    public void setWalletProvider(String walletProvider) { this.walletProvider = walletProvider; }

    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("cardId", getCardId());
        result.put("initOperId", getInitOperId());
        result.put("cardInstanceId", getCardInstanceId());
        result.put("expirationDate", getExpirationDate());
        result.put("status", getStatus());
        result.put("token", getToken());
        result.put("walletProvider", getWalletProvider());
        return result;
    }
}
