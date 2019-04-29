package ru.bpc.sv2.reports;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReportParameter extends Parameter implements ModelIdentifiable, Serializable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer reportId;
	private String defaultValue;
	private String selectionForm;

	public ReportParameter() {}
	public ReportParameter(String name, String dataType, Object value) {
		this.setSystemName(name);
		setDataType(dataType);
		if (isChar()) {
			setValueV((String) value);
		} else if (isNumber()) {
			setValueN((BigDecimal) value);
		} else if (isDate()) {
			setValueD((Date) value);
		}
	}

	public Object getModelId() {
		return getId();		
	}

	public Integer getId() {
		return id;
	}
	public void setId(Integer id) {
		this.id = id;
	}

	public Integer getReportId() {
		return reportId;
	}
	public void setReportId(Integer reportId) {
		this.reportId = reportId;
	}

	public String getDefaultValue() {
		return defaultValue;
	}
	public void setDefaultValue(String defaultValue) {
		this.defaultValue = defaultValue;
	}

	public String getSelectionForm() {
		return selectionForm;
	}
	public void setSelectionForm(String selectionForm) {
		this.selectionForm = selectionForm;
	}

	@Override
	public ReportParameter clone() throws CloneNotSupportedException {
		return (ReportParameter)super.clone();
	}
	@Override
	public void setLovId(Integer lovId) {
		super.setLovId(lovId);
		if (lovId == null){
			setValue(null);
			setValueV(null);
			setValueN((BigDecimal)null);
			setValueD(null);
			setLovValue(null);;
		}
	}
	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("reportId", getReportId());
		result.put("systemName", getSystemName());
		result.put("name", getName());
		result.put("dataType", getDataType());
		result.put("valueV", getValueV());
		result.put("valueN", getValueN());
		result.put("valueD", getValueD());
		result.put("mandatory", getMandatory());
		result.put("displayOrder", getDisplayOrder());
		result.put("lovId", getLovId());
		result.put("lang", getLang());
		return result;
	}
}
