package ru.bpc.sv2.acs.reqCert;

import java.security.spec.AlgorithmParameterSpec;
import java.util.HashMap;
import java.util.Map;

public class BpcThalesKeyPairGeneratorParams implements AlgorithmParameterSpec{
	private Map<String, Object> params = new HashMap<String, Object>();
	
	public Object getParam(String key) {
		return params.get(key);
	}
	
	public void setParam(String key, Object value) {
		params.put(key, value);
	}

}
