package ru.bpc.sv2.reports;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.IAuditableObject;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class ReportTemplate implements Serializable, ModelIdentifiable, Cloneable, IAuditableObject {
	private static final long serialVersionUID = 1L;

	private Integer id;
	private Integer reportId;
	private Integer seqNum;
	private String lang;
	private String name;
	private String description;
	private String templateLang;
	private String text;
	private String textBase64;
	private String processor;
	private String format;
	
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


	public String getTemplateLang() {
		return templateLang;
	}


	public void setTemplateLang(String templateLang) {
		this.templateLang = templateLang;
	}


	public String getText() {
		return text;
	}


	public void setText(String text) {
		this.text = text;
	}
	
	public String getTextBase64() {
		return textBase64;
	}


	public void setTextBase64(String textBase64) {
		this.textBase64 = textBase64;
	}

	public boolean isProcessorJasper() {
		return ReportConstants.TEMPLATE_PROCESSOR_JASPER.equals(processor);
	}
	
	public boolean isProcessorXslt() {
		return ReportConstants.TEMPLATE_PROCESSOR_XSLT.equals(processor);
	}
	
	public String getProcessor() {
		return processor;
	}


	public void setProcessor(String processor) {
		this.processor = processor;
	}


	public String getFormat() {
		return format;
	}


	public void setFormat(String format) {
		this.format = format;
	}


	@Override
	public ReportTemplate clone() throws CloneNotSupportedException {
		return (ReportTemplate)super.clone();
	}


	@Override
	public Map<String, Object> getAuditParameters() {
		Map<String, Object> result = new HashMap<String, Object>();
		result.put("id", getId());
		result.put("reportId", getReportId());
		result.put("templateLang", getTemplateLang());
		result.put("processor", getProcessor());
		result.put("format", getFormat());
		result.put("name", getName());
		result.put("lang", getLang());
		return result;
	}
}
