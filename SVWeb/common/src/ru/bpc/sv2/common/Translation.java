package ru.bpc.sv2.common;

import java.io.Serializable;

import ru.bpc.sv2.invocation.ModelIdentifiable;

public class Translation implements Serializable, ModelIdentifiable, Cloneable {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
//	private Long id;
	private String sourceLang;
	private String destLang;
	private String tableName;
	private String columnName;
	private Long objectId;
	private String srcText;
	private String dstText;
	private String srcTextOld;
	private String dstTextOld;
	private boolean checkUnique;
	private boolean translateExists;
	
	public Object getModelId() {
		StringBuffer result = new StringBuffer();
		result.append(tableName).append("_").append(columnName).append("_").append(objectId).
			append("_").append(sourceLang).append("_").append(destLang);
		return result.toString();
	}

	public String getSourceLang() {
		return sourceLang;
	}

	public void setSourceLang(String sourceLang) {
		this.sourceLang = sourceLang;
	}

	public String getDestLang() {
		return destLang;
	}

	public void setDestLang(String destLang) {
		this.destLang = destLang;
	}

	public String getTableName() {
		return tableName;
	}

	public void setTableName(String tableName) {
		this.tableName = tableName;
	}

	public String getColumnName() {
		return columnName;
	}

	public void setColumnName(String columnName) {
		this.columnName = columnName;
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public String getSrcText() {
		return srcText;
	}

	public void setSrcText(String srcText) {
		this.srcText = srcText;
	}

	public String getDstText() {
		return dstText;
	}

	public void setDstText(String dstText) {
		this.dstText = dstText;
	}

	public boolean isCheckUnique() {
		return checkUnique;
	}

	public void setCheckUnique(boolean checkUnique) {
		this.checkUnique = checkUnique;
	}

	public String getSrcTextOld() {
		return srcTextOld;
	}

	public void setSrcTextOld(String srcTextOld) {
		this.srcTextOld = srcTextOld;
	}

	public String getDstTextOld() {
		return dstTextOld;
	}

	public void setDstTextOld(String dstTextOld) {
		this.dstTextOld = dstTextOld;
	}
	
	public Translation clone() throws CloneNotSupportedException {
		return (Translation)super.clone();
	}

	public boolean isTranslateExists() {
		return translateExists;
	}

	public void setTranslateExists(boolean translateExists) {
		this.translateExists = translateExists;
	}
	
}
