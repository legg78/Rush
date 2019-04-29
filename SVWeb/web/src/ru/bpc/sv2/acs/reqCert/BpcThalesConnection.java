package ru.bpc.sv2.acs.reqCert;

import ru.bpc.sv2.acs.util.ConvToDer;
import ru.bpc.sv2.acs.util.EncodingUtils;
import ru.bpc.sv2.logic.CryptographyDao;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class BpcThalesConnection {
	public static byte[] sendAndGetReply(String bin_id) {
		try {
			CryptographyDao crypto = new CryptographyDao();
			Object obj = crypto.getPublicKey(bin_id);
			if (obj == null) {
				return null;
			}
			String key = (String) obj; 
			ConvToDer converter = new ConvToDer();
			converter.conv(key);
			String str = converter.conv(key);;
			return hexStringToByteArray(str); 
		} catch (SQLException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
		return null;

	}

	public static byte[] getSignData(byte[] data, String bin_id) {
		CryptographyDao crypto = new CryptographyDao();
		Map<String, String> params = new HashMap<String, String>();
		params.put("bin_id", bin_id);

		params.put("data", EncodingUtils.encodeBase64ToString(data));
		String temp = (String) crypto.getSignData(params).get("signed-data");
		return hexStringToByteArray(temp);
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
	
	public static String toHexString(byte[] data) {
		if (data == null) {
			throw new NullPointerException();
		}

		char[] hexChars = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F' };

		StringBuilder sb = new StringBuilder(data.length * 3);
		int high = 0;
		int low = 0;
		for (int i = 0; i < data.length; i++) {
			high = ((data[i] & 0xf0) >> 4);
			low = (data[i] & 0x0f);
			sb.append(hexChars[high]);
			sb.append(hexChars[low]);
		}
		return sb.toString();
	}
	
}
