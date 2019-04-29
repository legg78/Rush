package ru.bpc.sv2.acs.util;

import java.nio.charset.Charset;

import org.bouncycastle.util.encoders.Base64;
import org.slf4j.Logger;

public class EncodingUtils {
	public static final Charset UTF_8_CHARSET = Charset.forName("UTF-8");

	public static byte[] encodeBase64(byte[] data) {
		return encodeBase64(data, null);
	}

	public static String encodeBase64ToString(byte[] data) {
		return new String(encodeBase64(data, null), UTF_8_CHARSET);
	}

	public static String encodeBase64ToString(byte[] data, Charset cs) {
		return new String(encodeBase64(data, null), cs);
	}

	public static String encodeBase64ToString(byte[] data, Logger logger) {
		return new String(encodeBase64(data, logger), UTF_8_CHARSET);
	}

	public static String encodeBase64ToString(byte[] data, Charset cs, Logger logger) {
		return new String(encodeBase64(data, logger), cs);
	}

	public static byte[] encodeBase64(byte[] data, Logger logger) {
		if (logger != null && logger.isInfoEnabled()) {
			logger.info("Start incoming data Base-64 encoding");
		}

		byte[] resultEncoded = Base64.encode(data);

		if (logger != null && logger.isInfoEnabled()) {
			logger.info("Finished incoming data Base-64 encoding");
		}

		return resultEncoded;
	}

	public static byte[] decodeBase64(byte[] data) {
		return decodeBase64(data, null);
	}

	public static byte[] decodeBase64(byte[] data, Logger logger) {
		if (logger != null && logger.isInfoEnabled()) {
			logger.info("Start incoming data Base-64 decoding");
		}

		byte[] resDecoded = Base64.decode(data);

		if (logger != null && logger.isInfoEnabled()) {
			logger.info("Finished incoming data Base-64 decoding");
		}

		return resDecoded;
	}

	public static String decodeBase64ToString(byte[] data) {
		return new String(decodeBase64(data), UTF_8_CHARSET);
	}

	public static String decodeBase64ToString(byte[] data, Charset cs) {
		return new String(decodeBase64(data), cs);
	}

	public static String decodeBase64ToString(byte[] data, Logger logger) {
		return new String(decodeBase64(data, logger), UTF_8_CHARSET);
	}

	public static String decodeBase64ToString(byte[] data, Charset cs, Logger logger) {
		return new String(decodeBase64(data, logger), cs);
	}
	
	public static byte[] hexStringToByteArray(String s) {
	    int len = s.length();
	    byte[] data = new byte[len / 2];
	    for (int i = 0; i < len; i += 2) {
	        data[i / 2] = (byte) ((Character.digit(s.charAt(i), 16) << 4)
	                             + Character.digit(s.charAt(i+1), 16));
	    }
	    return data;
	}
	
	public static String bytesToHex(byte[] bytes) {
	    final char[] hexArray = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
	    char[] hexChars = new char[bytes.length * 2];
	    int v;
	    for ( int j = 0; j < bytes.length; j++ ) {
	        v = bytes[j] & 0xFF;
	        hexChars[j * 2] = hexArray[v >>> 4];
	        hexChars[j * 2 + 1] = hexArray[v & 0x0F];
	    }
	    return new String(hexChars);
	}

}
