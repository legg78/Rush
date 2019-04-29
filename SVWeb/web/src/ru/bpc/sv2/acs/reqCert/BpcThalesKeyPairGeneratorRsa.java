package ru.bpc.sv2.acs.reqCert;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.nio.charset.Charset;
import java.security.InvalidAlgorithmParameterException;
import java.security.KeyFactory;
import java.security.KeyPair;
import java.security.KeyPairGeneratorSpi;
import java.security.NoSuchAlgorithmException;
import java.security.PublicKey;
import java.security.SecureRandom;
import java.security.spec.AlgorithmParameterSpec;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.RSAPublicKeySpec;

import org.bouncycastle.asn1.ASN1InputStream;
import org.bouncycastle.asn1.DERObject;
import org.bouncycastle.asn1.x509.RSAPublicKeyStructure;

public class BpcThalesKeyPairGeneratorRsa extends KeyPairGeneratorSpi{ 
	private BpcThalesKeyPairGeneratorParams params;
	
	@Override
	public void initialize(AlgorithmParameterSpec params, SecureRandom random) throws InvalidAlgorithmParameterException{
	    this.params = (BpcThalesKeyPairGeneratorParams) params;
	}

	@Override
	public KeyPair generateKeyPair() {
		try {
			byte[] reply = BpcThalesConnection.sendAndGetReply((String)((BpcThalesKeyPairGeneratorParams) params).getParam("bin_id"));
			return parseSuccessfulHsmReply(reply);
		
		} catch (Exception e) {
			e.printStackTrace();
		}
		return null;		
	}
	
	private KeyPair parseSuccessfulHsmReply(byte[] reply)
	        throws IOException, NoSuchAlgorithmException, InvalidKeySpecException
	    {
			String replyHeaderString = new String(reply, Charset.forName("UTF-8"));
			System.out.println(replyHeaderString);
			
		    ByteArrayInputStream bais = new ByteArrayInputStream(reply);
		    

			ASN1InputStream ais = new ASN1InputStream(reply);
			DERObject publicKeyDer = null;
//		    publicKeyDer = ais.readObject();
		    
		    RSAPublicKeyStructure pStruct = RSAPublicKeyStructure.getInstance(publicKeyDer); 
		    RSAPublicKeySpec spec = new RSAPublicKeySpec(pStruct.getModulus(), pStruct.getPublicExponent());
		    KeyFactory kf = KeyFactory.getInstance("RSA");
		    PublicKey publicKey = kf.generatePublic(spec);

		    BpcThalesPrivateKey privateKey = new BpcThalesPrivateKey(99);
		    privateKey.setParam("bin_id", (String)params.getParam("bin_id"));
		    KeyPair pair = new KeyPair(publicKey, privateKey);
		    return pair;
	    }

	@Override
	public void initialize(int arg0, SecureRandom arg1) {
		// TODO Auto-generated method stub
	}
	
	
}