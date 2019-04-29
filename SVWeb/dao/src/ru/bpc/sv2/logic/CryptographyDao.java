package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;



import ru.bpc.sv2.logic.utility.db.IbatisAware;
import com.ibatis.sqlmap.client.SqlMapSession;

public class CryptographyDao extends IbatisAware {
	private String certificate;

	private String sign_data;
	
	public String getSign_data() {
		return sign_data;
	}
	public String getCertificate() {
		return certificate;
	}

    /**
     * Default constructor. 
     */
    public CryptographyDao() {
        // TODO Auto-generated constructor stub
    }
    
    public Map<String, String> getSignData(Map<String, String> map){
    	SqlMapSession ssn = null;
    	try{
	    	ssn = getIbatisSessionNoContext();
	    	ssn.queryForObject("crypto.get-sign-data", map);
			return map;
    	} 
    	catch (SQLException e) {
    		e.printStackTrace();
    		return null;
		} 
    	finally {
	    	close(ssn);
	    }
    	
    }
    
    public Object getPublicKey(String bin_id) throws SQLException{
    	SqlMapSession ssn = null;
    	try{
	    	ssn = getIbatisSessionNoContext();
	    	Map<String, Object> params = new HashMap<String, Object>();
	    	params.put("bin_id", Long.valueOf(bin_id));
	    	ssn.queryForObject("crypto.get-acs-public-key", params);
			return params.get("key"); 
    	} 
    	finally {
	    	close(ssn);
	    }
    }

}
