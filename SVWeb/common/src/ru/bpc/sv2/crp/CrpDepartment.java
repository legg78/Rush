package ru.bpc.sv2.crp;

import ru.bpc.sv2.invocation.TreeIdentifiable;

import java.io.Serializable;
import java.util.List;

public class CrpDepartment implements Serializable, TreeIdentifiable<CrpDepartment>, Cloneable{

	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqnum;
	private Long parentId;
	private Integer corpCompanyId;
	private Long corpCustomerId;
	private Long corpContractId;
	private Integer instId;
	private String label;
	private String lang;
	
	private int level;
	private List<CrpDepartment> children;
	
	public Object getModelId() {
		return getId();
	}
	
	public Long getId(){
		return this.id;
	}
	
	public void setId(Long id){
		this.id = id;
	}
	
	public Integer getSeqnum(){
		return this.seqnum;
	}
	
	public void setSeqnum(Integer seqnum){
		this.seqnum = seqnum;
	}
	
	public Long getParentId(){
		return this.parentId;
	}
	
	public void setParentId(Long parentId){
		this.parentId = parentId;
	}
	
	public Integer getCorpCompanyId(){
		return this.corpCompanyId;
	}
	
	public void setCorpCompanyId(Integer corpCompanyId){
		this.corpCompanyId = corpCompanyId;
	}
	
	public Long getCorpCustomerId(){
		return this.corpCustomerId;
	}
	
	public void setCorpCustomerId(Long corpCustomerId){
		this.corpCustomerId = corpCustomerId;
	}
	
	public Long getCorpContractId(){
		return this.corpContractId;
	}
	
	public void setCorpContractId(Long corpContractId){
		this.corpContractId = corpContractId;
	}
	
	public Integer getInstId(){
		return this.instId;
	}
	
	public void setInstId(Integer instId){
		this.instId = instId;
	}
	
	public String getLabel(){
		return this.label;
	}
	
	public void setLabel(String label){
		this.label = label;
	}
	
	public String getLang(){
		return this.lang;
	}
	
	public void setLang(String lang){
		this.lang = lang;
	}
	
	public Object clone(){
		Object result = null;
		try {
			result = super.clone();
		} catch (CloneNotSupportedException e) {
			e.printStackTrace();
		}
		return result;
	}

	public int getLevel() {
		return this.level;
	}

	public List<CrpDepartment> getChildren() {
		return this.children;
	}

	public void setChildren(List<CrpDepartment> children) {
		this.children = children;
		
	}

	public boolean isHasChildren() {
		boolean result = false;
		if (children != null){
			if (children.size() > 0){
				result = true;
			}
		}
		return result;
	}
}