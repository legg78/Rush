package ru.bpc.sv2.issuing;

import java.io.Serializable;

/**
 * Created by Gasanov on 23.09.2016.
 */
public class CardData implements Serializable {
    private String cardXml;
    private String accountXml;

    public String getCardXml() {
        return cardXml;
    }

    public void setCardXml(String cardXml) {
        this.cardXml = cardXml;
    }

    public String getAccountXml() {
        return accountXml;
    }

    public void setAccountXml(String accountXml) {
        this.accountXml = accountXml;
    }
}
