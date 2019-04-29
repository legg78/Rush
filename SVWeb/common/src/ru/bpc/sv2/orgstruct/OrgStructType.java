package ru.bpc.sv2.orgstruct;

import java.io.Serializable;
import java.util.List;

public abstract class OrgStructType implements Serializable {
	private static final long serialVersionUID = 1L;

	public static final String DIRECT_GRANT = "DIRECT";
	public static final String ROOT_GRANT = "ROOT";
	public static final String DEFAULT_GRANT = "DEFAULT";
	public static final String PARENT_GRANT = "PARENT";
	
	protected Long id;
	protected Integer seqNum;
	protected Long parentId;
	protected String name;
	protected String description;
	protected String lang;
	protected String type;
	protected int level;
	protected boolean isLeaf;
	protected String grantType;
	
	@SuppressWarnings("rawtypes")
	protected List children;

	//need for ACM module when assign to user
	protected boolean defaultForUser;
	protected boolean defaultForInst;
	protected boolean entirelyForUser;
	protected boolean assignedToUser;
	protected boolean defaultAgent = false;

	private String idFilter;	// to filter objects by ID using wildcards
	
	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Integer getSeqNum() {
		return seqNum;
	}

	public void setSeqNum(Integer seqNum) {
		this.seqNum = seqNum;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public boolean isDefaultForUser() {
		return defaultForUser;
	}

	public void setDefaultForUser(boolean defaultForUser) {
		this.defaultForUser = defaultForUser;
	}

	public boolean isEntirelyForUser() {
		return entirelyForUser;
	}

	public void setEntirelyForUser(boolean entirelyForUser) {
		this.entirelyForUser = entirelyForUser;
	}

	public boolean isAssignedToUser() {
		return assignedToUser;
	}

	public void setAssignedToUser(boolean assignedToUser) {
		this.assignedToUser = assignedToUser;
	}
	
	public void setDefaultForInst(boolean defaultForInst){
		this.defaultForInst = defaultForInst;
	}
	
	public boolean isDefaultForInst(){
		return defaultForInst;
	}

	@SuppressWarnings("rawtypes")
	public List getChildren() {
		return children;
	}

	@SuppressWarnings("rawtypes")
	public void setChildren(List children) {
		this.children = children;
	}

	public boolean isHasChildren() {
		return children != null ? children.size() > 0 : false;
	}

	public String getGrantType() {
		return grantType;
	}

	public void setGrantType(String grantType) {
		this.grantType = grantType;
	}

	public abstract boolean isAgent();
	
	public boolean isGrantFromRole() {
		return DEFAULT_GRANT.equals(grantType) || ROOT_GRANT.equals(grantType);
	}

	public String getIdFilter() {
		return idFilter;
	}

	public void setIdFilter(String idFilter) {
		this.idFilter = idFilter;
	}
	
	public boolean isDefaultAgent(){
		return defaultAgent;
	}
	
	public void setDefaultAgent(boolean defaultAgent){
		this.defaultAgent = defaultAgent;
	}
}
