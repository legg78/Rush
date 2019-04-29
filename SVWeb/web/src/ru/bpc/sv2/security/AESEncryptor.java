package ru.bpc.sv2.security;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

public class AESEncryptor {
	private final static String ALGORITHM = "AES";
	private final static String PADDING = "PKCS5Padding";
	
	/**
	 * 
	 * @param toEncrypt - data to encrypt
	 * @param secretKey - 16 bytes key
	 * @return AES encrypted key
	 * @throws Exception
	 */
	public static byte[] encrypt(byte[] toEncrypt, byte[] secretKey) throws Exception {
		SecretKeySpec key = new SecretKeySpec(secretKey, ALGORITHM);
        Cipher c = Cipher.getInstance("AES/ECB/" + PADDING);
        c.init(Cipher.ENCRYPT_MODE, key);
        byte[] encrypted = c.doFinal(toEncrypt);
        return encrypted;
    }

    public static byte[] decrypt(byte[] toDecrypt, byte[] secretKey) throws Exception {
		SecretKeySpec key = new SecretKeySpec(secretKey, ALGORITHM);
        Cipher c = Cipher.getInstance("AES/ECB/" + PADDING);
        c.init(Cipher.DECRYPT_MODE, key);
        byte[] decrypted = c.doFinal(toDecrypt);
        return decrypted;
    }

//    public static void main(String[] a) {
//    	String key = "mySuperReliableAndAbsolutelyHijackResistantKey";
//    	String secretKey = "sixteencharacter";
//    	try {
//    		byte[] encryptedKey = AESEncryptor.encrypt(key.getBytes(), secretKey.getBytes());
//    		byte[] decryptedKey = AESEncryptor.decrypt(encryptedKey, secretKey.getBytes());
//    		System.out.println(new String(decryptedKey));
//    	} catch (Exception e) {
//    		System.out.println(e.getMessage());
//    	}
//    }
}
