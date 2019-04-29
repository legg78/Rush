package ru.bpc.sv2.acs.reqCert;

import java.nio.charset.Charset;
import java.security.InvalidKeyException;
import java.security.InvalidParameterException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.SignatureException;
import java.security.SignatureSpi;
import java.util.Arrays;

public class BpcThalesSha1WithRsa extends SignatureSpi{
	private static final Charset UTF_8 = Charset.forName("UTF-8");

	private byte[] data;
	private BpcThalesPrivateKey privateKey;

	@Override
	protected void engineInitVerify(PublicKey publicKey) throws InvalidKeyException {
		// TODO Auto-generated method stub
		throw new RuntimeException("Not supported");
	}

	@Override
	protected void engineInitSign(PrivateKey privateKey) throws InvalidKeyException {
		// TODO Auto-generated method stub
		System.out.println("\n\n\nBpcThalesSha1WithRsa#InitSign Called");

		if (privateKey == null) {
			throw new NullPointerException();
		}

		if (!(privateKey instanceof BpcThalesPrivateKey)) {
			throw new IllegalArgumentException("Private key must be of type " + BpcThalesPrivateKey.class.getName());
		}

		BpcThalesPrivateKey pk = (BpcThalesPrivateKey) privateKey;

		if (pk.getId() == 99 && pk.getKeyBytes() == null) {
//			throw new IllegalArgumentException("Private key with id = 99 must contain key bytes");
		}

		this.privateKey = pk;

	}

	@Override
	protected void engineUpdate(byte b) throws SignatureException {
		// TODO Auto-generated method stub
		throw new RuntimeException("Not supported");
	}

	@Override
	protected void engineUpdate(byte[] b, int off, int len) throws SignatureException {
		if (b == null) {
			throw new NullPointerException();
		}
		if ((b.length < (off + len)) || (off < 0) || (len <= 0)) {
			throw new IllegalArgumentException("Invalid array bounds specified");
		}
		if (data == null) {
			data = new byte[len];
			System.arraycopy(b, off, data, 0, len);
		} else {
			int oldLength = data.length;
			data = Arrays.copyOf(data, data.length + len);
			System.arraycopy(b, off, data, oldLength, len);
		}
	}

	@Override
	protected byte[] engineSign() throws SignatureException {
		// TODO Auto-generated method stub 
		
		
		try {
			byte[] reply = BpcThalesConnection.getSignData(data, (String)privateKey.getParam("bin_id"));
			return reply; //signature; 
		}
		catch (Exception btce) {
			btce.printStackTrace();
			throw new SignatureException("Failed to generate signarute due to communication error", btce);
		}
	}

	@Override
	protected boolean engineVerify(byte[] sigBytes) throws SignatureException {
		// TODO Auto-generated method stub
		throw new RuntimeException("Not supported");
	}

	@Override
	protected void engineSetParameter(String param, Object value) throws InvalidParameterException {
		// TODO Auto-generated method stub
		throw new RuntimeException("Not supported");
	}

	@Override
	protected Object engineGetParameter(String param) throws InvalidParameterException {
		// TODO Auto-generated method stub
		throw new RuntimeException("Not supported");
	}
}
