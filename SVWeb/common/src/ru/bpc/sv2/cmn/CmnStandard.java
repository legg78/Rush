package ru.bpc.sv2.cmn;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.TreeIdentifiable;

public class CmnStandard implements Serializable, TreeIdentifiable<CmnStandard>, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Long id;
	private Integer seqNum;
	private String appPlugin;
	private Integer respCodeLovId;
	private String respCodeLovName;
	private String label;
	private String description;
	private String lang;
	private String standardType;
	private Integer additionalModelIdKey;	// is used only on interfaces config form to divide online and offline interfaces if they are the same 
	private Integer keyTypeLovId;
	private String keyTypeLovName;
	private List<CmnStandard> children;
	private int level;
	private Long parentId;
	private String entityType;
	private boolean isLeaf;
	
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

	public String getAppPlugin() {
		return appPlugin;
	}

	public void setAppPlugin(String appPlugin) {
		this.appPlugin = appPlugin;
	}

	public Integer getRespCodeLovId() {
		return respCodeLovId;
	}

	public void setRespCodeLovId(Integer respCodeLovId) {
		this.respCodeLovId = respCodeLovId;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}
	
	public String getWrittenLabel() {
		return label != null ? label : appPlugin;
	}

	public Object getModelId() {
		return entityType + "_" + additionalModelIdKey + "_" + getId();
	}

	@Override
	public Object clone() throws CloneNotSupportedException {
		return super.clone();
	}

	public String getStandardType() {
		return standardType;
	}

	public void setStandardType(String standardType) {
		this.standardType = standardType;
	}

	public String getRespCodeLovName() {
		return respCodeLovName;
	}

	public void setRespCodeLovName(String respCodeLovName) {
		this.respCodeLovName = respCodeLovName;
	}

	public void setAdditionalModelIdKey(Integer additionalModelIdKey) {
		this.additionalModelIdKey = additionalModelIdKey;
	}

	public Integer getAdditionalModelIdKey() {
		return additionalModelIdKey;
	}

	public Integer getKeyTypeLovId() {
		return keyTypeLovId;
	}

	public void setKeyTypeLovId(Integer keyTypeLovId) {
		this.keyTypeLovId = keyTypeLovId;
	}

	public String getKeyTypeLovName() {
		return keyTypeLovName;
	}

	public void setKeyTypeLovName(String keyTypeLovName) {
		this.keyTypeLovName = keyTypeLovName;
	}

	public List<CmnStandard> getChildren() {
		return children;
	}

	public void setChildren(List<CmnStandard> children) {
		this.children = children;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public Long getParentId() {
		return parentId;
	}

	public void setParentId(Long parentId) {
		this.parentId = parentId;
	}

	public boolean isHasChildren() {
		return children == null ? false : !children.isEmpty();
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public CmnVersion getVersion() {
		CmnVersion version = new CmnVersion();
		version.setId(id);
		version.setLang(lang);
		version.setStandardId(parentId);
		version.setVersionNumber(label);
		version.setDescription(description);
		
		return version;
	}
	
	public void setVersion(CmnVersion version) {
		id = version.getId();
		lang = version.getLang();
		parentId = version.getStandardId();
		label = version.getVersionNumber();
		description = version.getDescription();
		entityType = EntityNames.STANDARD_VERSION;
		
		// we have two level structure where version is always leaf and has level "2"
		isLeaf = true;
		level = 2;
	}

	public boolean isLeaf() {
		return isLeaf;
	}

	public void setLeaf(boolean isLeaf) {
		this.isLeaf = isLeaf;
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
         CmnStandard other = (CmnStandard) obj;
         if (id == null) {
              if (other.id != null)
                   return false;
         } else if (!id.equals(other.id))
              return false;
         return true;
    }

	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("appPlugin", this.getAppPlugin());
		result.put("standardType", this.getStandardType());
		result.put("respCodeLovId", this.getRespCodeLovId());
		result.put("keyTypeLovId", this.getKeyTypeLovId());
		result.put("lang", this.getLang());
		result.put("label", this.getLabel());
		result.put("description", this.getDescription());
		
		return result;
	}
}
