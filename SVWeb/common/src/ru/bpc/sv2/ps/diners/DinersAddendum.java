package ru.bpc.sv2.ps.diners;

import ru.bpc.sv2.invocation.ModelIdentifiable;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.List;

public class DinersAddendum implements Serializable, ModelIdentifiable, Cloneable {
    private static final long serialVersionUID = 1L;
    private Long id;
    private Long finMessageId;
    private String funcCode;
    private String funcCodeDesc;
    private Long fileId;
    private Integer recordNumber;
    private ArrayList<DinersAddendumField> fields;

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
    }

    public Long getFinMessageId() {
        return finMessageId;
    }
    public void setFinMessageId(Long finMessageId) {
        this.finMessageId = finMessageId;
    }

    public String getFuncCode(){
        return funcCode;
    }
    public void setFuncCode(String funcCode){
        this.funcCode = funcCode;
    }

    public String getFuncCodeDesc(){
        return funcCodeDesc;
    }
    public void setFuncCodeDesc(String funcCodeDesc){
        this.funcCodeDesc = funcCodeDesc;
    }

    public Long getFileId(){
        return fileId;
    }
    public void setFileId(Long fileId){
        this.fileId = fileId;
    }

    public Integer getRecordNumber(){
        return recordNumber;
    }
    public void setRecordNumber(Integer recordNumber){
        this.recordNumber = recordNumber;
    }

    public List<DinersAddendumField> getFields(){
        return fields;
    }
    public void setFields(List<DinersAddendumField> fields){
        this.fields = (ArrayList<DinersAddendumField>)fields;
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