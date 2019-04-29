package ru.bpc.sv2.utils;

import java.sql.SQLException;  

import com.ibatis.sqlmap.client.extensions.ParameterSetter;  
import com.ibatis.sqlmap.client.extensions.ResultGetter;  
import com.ibatis.sqlmap.client.extensions.TypeHandlerCallback; 

public class EmptyCursorTypeHandler implements TypeHandlerCallback {  
	   
	public void setParameter(ParameterSetter setter, Object parameter) throws SQLException {	
	}  
	   
	public Object getResult(ResultGetter getter) throws SQLException {		
		try {
			return getter.getObject();
		} catch (Exception e) {
			
		}   
		return null;
	}  
	   
	public Object valueOf(String arg0) {  
		return null;  
	} 
}