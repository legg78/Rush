package ru.bpc.sv2.acm;

import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

public class PrivLimitation implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject{

	private static final long serialVersionUID = 1L;

	public static final String LIMITATION_TYPE_FILTER = "PRLMFLTR";
	public static final String LIMITATION_TYPE_RESULT = "PRLMRSLT";

	private Integer id;
	private Integer seqNum;
	private Integer privId;
	private String shortDesc;
	private String condition;
	private String lang;
	private String limitationType;
    private String limitationTypeDesc;

    public String getLimitationTypeDesc() {
        return limitationTypeDesc;
    }

    public void setLimitationTypeDesc(String limitationTypeDesc) {
        this.limitationTypeDesc = limitationTypeDesc;
    }

    public String getLimitationType() {
		return limitationType;
	}

	public void setLimitationType(String limitationType) {
		this.limitationType = limitationType;
	}

	public Object getModelId() {
		return getId();
	}
	
	public Integer getId(){
		return this.id;
	}
	
	public void setId(Integer id){
		this.id = id;
	}
	
	public Integer getPrivId(){
		return this.privId;
	}
	
	public void setPrivId(Integer privId){
		this.privId = privId;
	}
	
	public String getShortDesc(){
		return this.shortDesc;
	}
	
	public void setShortDesc(String shortDesc){
		this.shortDesc = shortDesc;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
	}

	public String getCondition() {
		return condition;
	}

	public void setCondition(String condition) {
		this.condition = condition;
	}

	public boolean isFilter() {
		return LIMITATION_TYPE_FILTER.equals(getLimitationType());
	}

	public boolean isResult() {
    	return LIMITATION_TYPE_RESULT.equals(getLimitationType());
	}


	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("privId", getPrivId());
		result.put("shortDesc", getShortDesc());
		result.put("condition", getCondition());
		result.put("lang", getLang());
		return result;
	}
	
	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}
	
}
