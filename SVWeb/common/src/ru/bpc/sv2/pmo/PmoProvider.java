package ru.bpc.sv2.pmo;

import java.io.Serializable;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.acm.AcmActionGroup;
import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.invocation.TreeIdentifiable;
import ru.bpc.sv2.orgstruct.OrgStructType;

/**
 * Model Bean for List PMO Provider page.
 * extends OrgStructType implements Cloneable, IAuditableObject, TreeIdentifiable<AcmActionGroup>
 */
public class PmoProvider implements Cloneable, Serializable, IAuditableObject, TreeIdentifiable<PmoProvider> {
    private static final long serialVersionUID = 9160260928538889903L;

    private Long id;
    private Integer seqNum;
    private String label;
    private String description;
    private String regionCode;
    private String lang;
    private String shortName;
    private String providerNumber;
    private Integer srcProviderId;
    private Long parentId;
    private String logoPath;
    private boolean providerGroup;
    private int level;
    private boolean isLeaf;
    private Integer instId;
    private String instName;
    private List<PmoProvider> children;

    public PmoProvider() {}

    public Long getId() {
        return id;
    }
    public void setId(Long id) {
        this.id = id;
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

    public String getRegionCode() {
        return regionCode;
    }
    public void setRegionCode(String regionCode) {
        this.regionCode = regionCode;
    }

    public String getLang() {
        return lang;
    }
    public void setLang(String lang) {
        this.lang = lang;
    }

    public Integer getSeqNum() {
        return seqNum;
    }
    public void setSeqNum(Integer seqNum) {
        this.seqNum = seqNum;
    }

    public String getShortName() {
        return shortName;
    }
    public void setShortName(String shortName) {
        this.shortName = shortName;
    }

    public Integer getSrcProviderId() {
        return srcProviderId;
    }
    public void setSrcProviderId(Integer srcProviderId) {
        this.srcProviderId = srcProviderId;
    }

    public Long getParentId() {
        return parentId;
    }
    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public String getLogoPath() {
        return logoPath;
    }
    public void setLogoPath(String logoPath) {
        this.logoPath = logoPath;
    }

    public boolean isProviderGroup() {
        return providerGroup;
    }
    public void setProviderGroup(boolean providerGroup) {
        this.providerGroup = providerGroup;
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

    public String getProviderNumber() {
        return providerNumber;
    }
    public void setProviderNumber(String providerNumber) {
        this.providerNumber = providerNumber;
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

    @Override
    public List<PmoProvider> getChildren() {
        return children;
    }
    @Override
    public boolean isHasChildren() {
        return children != null ? children.size() > 0 : false;
    }
    @Override
    public void setChildren(List<PmoProvider> children) {
        this.children = children;
    }
    @Override
    public Object getModelId() {
        return getId();
    }
    @Override
    public PmoProvider clone() throws CloneNotSupportedException {
        PmoProvider provider = (PmoProvider) super.clone();
        return provider;
    }
    @Override
    public Map<String, Object> getAuditParameters() {
        Map<String, Object> result = new HashMap<String, Object>();
        result.put("id", getId());
        result.put("regionCode", getRegionCode());
        result.put("label", getLabel());
        result.put("description", getDescription());
        result.put("lang", getLang());
        result.put("shortName", getShortName());
        result.put("instId", getInstId());
        return result;
    }
}