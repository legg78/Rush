package ru.bpc.sv2.reports;

import java.io.Serializable;

import java.util.ArrayList;
import java.util.HashMap;

public class QueryResult implements Serializable {
	
	private static final long serialVersionUID = 1L;
	public ArrayList<String> fieldNames 				= null;
    public ArrayList<HashMap<String, String>> fields	= null;
    
    public QueryResult (){}
    
    public QueryResult (QueryResult result) {
    	this.fieldNames = result.fieldNames;
    	this.fields = result.fields;
    }
    
    public ArrayList<String> getFieldNames() {
    	if (fieldNames == null)
    		fieldNames = new ArrayList<String>();
		return fieldNames;
	}
	
	public void setFieldNames(ArrayList<String> fieldNames) {
		this.fieldNames = fieldNames;
	}
	public ArrayList<HashMap<String, String>> getFields() {
		if (fields == null)
			fields = new ArrayList<HashMap<String,String>>();
		return fields;
	}
	public void setFields(ArrayList<HashMap<String, String>> fields) {
		this.fields = fields;
	}

	public void setResult(QueryResult result) {
		this.fieldNames = result.fieldNames;
    	this.fields = result.fields;
	}
    
}
