package ru.bpc.sv2.common;

import java.io.Serializable;
import java.text.SimpleDateFormat;
import java.util.Date;

public class TableColumn implements Serializable {
	private static final SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
	protected Long id;
	protected Long columnId;
	protected String table;
	protected String column;
	protected String value;
	protected String dataType;
	protected boolean editable = true;

	public TableColumn() {
	}

	public TableColumn(String column) {
		this.column = column;
	}

	public TableColumn(String column, String dataType) {
		this.column = column;
		this.dataType = dataType;
	}

	public TableColumn(String column, boolean editable) {
		this.column = column;
		this.editable = editable;
	}

	public void setDate(Date date) {
		this.value = sdf.format(date);
	}

	public Date getDate() throws Exception {
		if (value != null) {
			return sdf.parse(value);
		}
		return null;
	}

	public String getTable() {
		return table;
	}

	public void setTable(String table) {
		this.table = table;
	}

	public String getDataType() {
		return dataType;
	}

	public void setDataType(String dataType) {
		this.dataType = dataType;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Long getColumnId() {
		return columnId;
	}

	public void setColumnId(Long columnId) {
		this.columnId = columnId;
	}

	public String getColumn() {
		return column;
	}

	public void setColumn(String column) {
		this.column = column;
	}

	public String getValue() {
		return value;
	}

	public void setValue(String value) {
		this.value = value;
	}

	public boolean isEditable() {
		return editable;
	}

	public void setEditable(boolean editable) {
		this.editable = editable;
	}
}
