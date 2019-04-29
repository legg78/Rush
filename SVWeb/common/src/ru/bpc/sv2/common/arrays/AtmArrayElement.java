package ru.bpc.sv2.common.arrays;

import java.util.HashMap;
import java.util.Map;

public class AtmArrayElement extends BaseArrayElement {

    private String terminalNumber;
    private String terminalDescription;
    private Integer standardId;
    private String standardName;
    private String merchantNumber;
    private String merchantDescription;
    private Integer agentId;
    private String agentName;
    private String atmAddress;
    private String serialNumber;
    private String atmModel;
    private String serviceStatus;
    private String connectionStatus;
    private String financeStatus;
    private String techStatus;
    private String consumablesStatus;
    private Integer elementId; //used for delete element from array.
    private String agentNumber;




    public Integer getStandardId() {
        return standardId;
    }

    public String getStandardIdAsString(){
        return standardId.toString();
    }

    public void setStandardId(Integer standardId) {
        this.standardId = standardId;
    }

    public String getStandardName() {
        return standardName;
    }

    public void setStandardName(String standardName) {
        this.standardName = standardName;
    }

    public String getMerchantNumber() {
        return merchantNumber;
    }

    public void setMerchantNumber(String merchantNumber) {
        this.merchantNumber = merchantNumber;
    }

    public String getMerchantDescription() {
        return merchantDescription;
    }

    public void setMerchantDescription(String merchantDescription) {
        this.merchantDescription = merchantDescription;
    }

    public Integer getAgentId() {
        return agentId;
    }

    public void setAgentId(Integer agentId) {
        this.agentId = agentId;
    }

    public String getAgentName() {
        return agentName;
    }

    public void setAgentName(String agentName) {
        this.agentName = agentName;
    }

    public String getAtmAddress() {
        return atmAddress;
    }

    public void setAtmAddress(String atmAddress) {
        this.atmAddress = atmAddress;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public String getAtmModel() {
        return atmModel;
    }

    public void setAtmModel(String atmModel) {
        this.atmModel = atmModel;
    }

    public String getServiceStatus() {
        return serviceStatus;
    }

    public void setServiceStatus(String serviceStatus) {
        this.serviceStatus = serviceStatus;
    }

    public String getConnectionStatus() {
        return connectionStatus;
    }

    public void setConnectionStatus(String connectionStatus) {
        this.connectionStatus = connectionStatus;
    }

    public String getFinanceStatus() {
        return financeStatus;
    }

    public void setFinanceStatus(String financeStatus) {
        this.financeStatus = financeStatus;
    }

    public String getTechStatus() {
        return techStatus;
    }

    public void setTechStatus(String techStatus) {
        this.techStatus = techStatus;
    }

    public String getConsumablesStatus() {
        return consumablesStatus;
    }

    public void setConsumablesStatus(String consumablesStatus) {
        this.consumablesStatus = consumablesStatus;
    }

    public String getTerminalDescription() {
        return terminalDescription;
    }

    public void setTerminalDescription(String terminalDescription) {
        this.terminalDescription = terminalDescription;
    }

    public String getTerminalNumber() {
        return terminalNumber;
    }

    public void setTerminalNumber(String terminalNumber) {
        this.terminalNumber = terminalNumber;
    }

    public Integer getElementId() {
        return elementId;
    }

    public void setElementId(Integer elementId) {
        this.elementId = elementId;
    }

    public String getAgentNumber() {
        return agentNumber;
    }

    public void setAgentNumber(String agentNumber) {
        this.agentNumber = agentNumber;
    }

    //todo must define such as in the DefaultArrayElement
    @Override
    public DefaultArrayElement clone() throws CloneNotSupportedException {
        return (DefaultArrayElement) super.clone();
    }

    //todo must define such as in the DefaultArrayElement
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        return result;
    }

}
