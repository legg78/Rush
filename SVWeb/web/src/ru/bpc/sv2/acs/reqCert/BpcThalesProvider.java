package ru.bpc.sv2.acs.reqCert;

import java.security.Provider;

public class BpcThalesProvider extends Provider {
	final public static Integer hsm_msg_header_length=new Integer("4");
	
	public BpcThalesProvider() {
		this("BpcThalesProvider", (double) 0.1, "BpcThalesProvider");
	}
	
	protected BpcThalesProvider(String name, double version, String info) {
		super(name, version, info);
		put("Signature.SHA1withRSA", BpcThalesSha1WithRsa.class.getName());
		put("KeyPairGenerator.RSA", BpcThalesKeyPairGeneratorRsa.class.getName());
	}
}
