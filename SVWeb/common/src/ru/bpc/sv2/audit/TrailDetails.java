package ru.bpc.sv2.audit;

import java.io.Serializable;
import java.math.BigDecimal;
import java.util.Date;

import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class TrailDetails implements ModelIdentifiable, Serializable {

	private static final long serialVersionUID = 1L;

	private long id;
	private long trailId;
	private String columnName;
	private String dataType;
	private String dataFormat;
	private Object newValue;
	private Object oldValue;
	private String oldValueV;
	private BigDecimal oldValueN;
	private Date oldValueD;	
	private String newValueV;
	private BigDecimal newValueN;
	private Date newValueD;

	public long getId() {
		return id;
	}

	public void setId(long id) {
		this.id = id;
	}

	public long getTrailId() {
		return trailId;
	}

	public void setTrailId(long trailId) {
		this.trailId = trailId;
	}

	public String getColumnName() {
		return columnName;
	}

	public void setColumnName(String columnName) {
		this.columnName = columnName;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public String getDataFormat() {
		return dataFormat;
	}

	public void setDataFormat(String dataFormat) {
		this.dataFormat = dataFormat;
	}

	public static long getSerialversionuid() {
		return serialVersionUID;
	}

	public Object getModelId() {
		return getId();
	}

	public Object getNewValue() {
		return newValue;
	}

	public void setNewValue(Object newValue) {
		this.newValue = newValue;
	}

	public Object getOldValue() {
		return oldValue;
	}

	public void setOldValue(Object oldValue) {
		this.oldValue = oldValue;
	}

	public String getOldValueV() {
		return oldValueV;
	}

	public void setOldValueV(String oldValueV) {
		this.oldValueV = oldValueV;
		if (isChar()) {
			oldValue = oldValueV;
		}
	}

	public BigDecimal getOldValueN() {
		return oldValueN;
	}

	public void setOldValueN(BigDecimal oldValueN) {
		this.oldValueN = oldValueN;
		if (isNumber()) {
			oldValue = oldValueN;
		}
	}

	public Date getOldValueD() {
		return oldValueD;
	}

	public void setOldValueD(Date oldValueD) {
		this.oldValueD = oldValueD;
		if (isDate()) {
			oldValue = oldValueD;
		}
	}

	public String getNewValueV() {
		return newValueV;
	}

	public void setNewValueV(String newValueV) {
		this.newValueV = newValueV;
		if (isChar()) {
			newValue = newValueV;
		}
	}

	public BigDecimal getNewValueN() {
		return newValueN;
	}

	public void setNewValueN(BigDecimal newValueN) {
		this.newValueN = newValueN;
		if (isNumber()) {
			newValue = newValueN;
		}
	}

	public Date getNewValueD() {
		return newValueD;
	}

	public void setNewValueD(Date newValueD) {
		this.newValueD = newValueD;
		if (isDate()) {
			newValue = newValueD;
		}
	}

	public boolean isChar(){
		return DataTypes.CHAR.equals(dataType);
	}
	
	public boolean isNumber(){
		return DataTypes.NUMBER.equals(dataType);
	}
	
	public boolean isDate(){
		return DataTypes.DATE.equals(dataType);
	}
}
