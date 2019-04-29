package ru.bpc.sv2.common.arrays;

/**
 * Created by Boldyrev on 30.01.14.
 */
public class AtmGroup extends Array {
    private Integer atmId;
    private Integer elementId;
    private Integer elementSeqNum;
    private String agentNumber;

    public Integer getAtmId() {
        return atmId;
    }

    public void setAtmId(Integer atmId) {
        this.atmId = atmId;
    }

    public Integer getElementId() {
        return elementId;
    }

    public void setElementId(Integer elementId) {
        this.elementId = elementId;
    }

    public Integer getElementSeqNum() {
        return elementSeqNum;
    }

    public void setElementSeqNum(Integer elementSeqNum) {
        this.elementSeqNum = elementSeqNum;
    }

    public String getAgentNumber() {
        return agentNumber;
    }

    public void setAgentNumber(String agentNumber) {
        this.agentNumber = agentNumber;
    }
}

