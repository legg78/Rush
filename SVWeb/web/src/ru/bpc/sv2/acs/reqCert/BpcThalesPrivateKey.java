package ru.bpc.sv2.acs.reqCert;

import java.security.PrivateKey;
import java.util.HashMap;
import java.util.Map;

public class BpcThalesPrivateKey implements PrivateKey {
	private static final long serialVersionUID = 5737700785112605458L;
    
    private final int id;
    private byte[] keyBytes;
    private Integer lmkId;
    private Map<String, Object> params = new HashMap<String, Object>();
    
    public BpcThalesPrivateKey(int id) {
    	if (id < 0 || id > 99) {
    		throw new IllegalArgumentException("Private key id must be between 0 and 99");
    	}
    	this.id = id;
    }

	public int getId() {
    	return id;
    }

	public byte[] getKeyBytes() {
    	return keyBytes;
    }

	public void setKeyBytes(byte[] keyBytes) {
    	this.keyBytes = keyBytes;
    }

	public Integer getLmkId() {
    	return lmkId;
    }

	public void setLmkId(Integer lmkId) {
		if (lmkId != null && (lmkId < 0 || lmkId > 4)) {
			throw new IllegalArgumentException("LMK Id must be between 0 and 4");
		}
    	this.lmkId = lmkId;
    }

	public String getAlgorithm() {	    
	    return "RSA";
    }

	public String getFormat() {
	    // TODO Auto-generated method stub
	    return null;
    }

	public byte[] getEncoded() {
	    // TODO Auto-generated method stub
	    return null;
    }

	public void setParam(String key, Object value){
		params.put(key, value);
	}
	
	public Object getParam(String key){
		return params.get(key);
	}
}
