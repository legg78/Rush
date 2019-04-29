package ru.bpc.sv2.reports;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class Report implements Serializable, ModelIdentifiable, Cloneable, TreeIdentifiable<Report>, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private String lang;
	private String name;
	private String description;
	private Integer instId;
	private String instName;
	
	private int level;
	private boolean isLeaf;
	private String reportSource;
	private String sourceType;
	
	private Integer roleId;
	
	private List<ReportTag> tags;
	private String tagsLabel;
	private boolean reReadTagsLabel;
	private Boolean isDeterministic;
	private Boolean isNotification;
	private Integer nameFormatId;
	private String nameFormatName;
	private String documentType;

	public Object getModelId() {
		return getId();
	}

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

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
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

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getInstName() {
		return instName;
	}

	public void setInstName(String instName) {
		this.instName = instName;
	}

	public String getReportSource() {
		return reportSource;
	}

	public void setReportSource(String reportSource) {
		this.reportSource = reportSource;
	}

	public String getSourceType() {
		return sourceType;
	}

	public void setSourceType(String sourceType) {
		this.sourceType = sourceType;
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

	public boolean isSimple() {
		return ReportConstants.REPORT_SOURCE_TYPE_SIMPLE.equals(sourceType);
	}
	
	public boolean isXml() {
		return ReportConstants.REPORT_SOURCE_TYPE_XML.equals(sourceType);
	}
	
	public Integer getRoleId() {
		return roleId;
	}

	public void setRoleId(Integer roleId) {
		this.roleId = roleId;
	}

	@Override
	public Report clone() throws CloneNotSupportedException {
		return (Report) super.clone();
	}
	
	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());		
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Report other = (Report) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}

	public List<Report> getChildren() {

		return null;
	}

	public void setChildren(List<Report> children) {

		
	}

	public boolean isHasChildren() {

		return false;
	}

	public Long getParentId() {

		return null;
	}

	public List<ReportTag> getTags() {
		if (tags == null){
			tags = new ArrayList<ReportTag>();
		}
		return tags;
	}

	public void setTags(List<ReportTag> tags) {
		this.tags = tags;
		reReadTagsLabel = true;
	}
	
	public void setTagsLabel(String tagsLabel){
		this.tagsLabel = tagsLabel;
	}

	public String getTagsLabel(){
		if(tags != null){
			if (reReadTagsLabel){
				StringBuilder sb = new StringBuilder(); 
				for (ReportTag reportTag : tags){
					sb.append(reportTag.getLabel());
					sb.append(";");
				}
				tagsLabel = sb.toString();
				reReadTagsLabel = false;
			}
		}
		return tagsLabel;
	}

	public Boolean getIsDeterministic() {
		return isDeterministic;
	}

	public void setIsDeterministic(Boolean isDeterministic) {
		this.isDeterministic = isDeterministic;
	}

	public Integer getNameFormatId() {
		return nameFormatId;
	}

	public void setNameFormatId(Integer nameFormatId) {
		this.nameFormatId = nameFormatId;
	}

	public String getNameFormatName() {
		return nameFormatName;
	}

	public void setNameFormatName(String nameFormatName) {
		this.nameFormatName = nameFormatName;
	}

	public Boolean getIsNotification() {
		return isNotification;
	}

	public void setIsNotification(Boolean notification) {
		isNotification = notification;
	}

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("name", getName());
		result.put("description", getDescription());
		result.put("reportSource", getReportSource());
		result.put("sourceType", getSourceType());
		result.put("instId", getInstId());
		result.put("lang", getLang());
		result.put("isDeterministic", getIsDeterministic());
		result.put("isNotification", getIsNotification());
		result.put("nameFormatId", getNameFormatId());
		return result;
	}

	public String getDocumentType() {
		return documentType;
	}

	public void setDocumentType(String documentType) {
		this.documentType = documentType;
	}
}
