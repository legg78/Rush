package ru.bpc.sv2.scheduler.process;

import java.io.InputStream;
import java.security.MessageDigest;
import java.util.Arrays;
import java.util.Random;

import org.apache.commons.codec.binary.Base64;
import org.apache.commons.vfs.FileObject;

import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.security.AESEncryptor;

public class YotaSignatureEncryptor implements SignatureEncryptor {
	private final String HARDCODED_KEY = "-Some32bytesKey-0123456789ABCDEF";	// 256 bit key
	private final int TAIL_LENGTH = 4;
	private final int MIN_KEY_LENGTH = 32; 
	
	@Override
	public boolean checkFile(FileObject file, byte[] signature, String securityKey64) throws Exception {
		byte[] securityKey = getPureSecurityKey(securityKey64);
		
		// decrypt signature
		byte[] decryptedSignature = AESEncryptor.decrypt(signature, securityKey);
		
		byte[] signatureSHA1 = Arrays.copyOfRange(decryptedSignature, 0, decryptedSignature.length - 4);
		byte[] fileSHA1 = createSha1(file.getContent().getInputStream());
		
		boolean result = Arrays.equals(signatureSHA1, fileSHA1);
		return result;
	}

	@Override
	public boolean checkFile(FileObject file, String signatureBase64, String securityKey64) throws Exception {
		byte[] signature = Base64.decodeBase64(signatureBase64);
		
		return checkFile(file, signature, securityKey64);
	}

	@Override
	public byte[] generateSignature(FileObject file, String securityKey64) throws Exception {
		byte[] securityKey = getPureSecurityKey(securityKey64);
				
		byte[] fileSHA1 = createSha1(file.getContent().getInputStream());
		byte[] extendedFileSHA1 = addRandomTail(fileSHA1);
		
		byte[] signature = AESEncryptor.encrypt(extendedFileSHA1, securityKey);
		return signature;
	}

	@Override
	public String generateSignatureBase64(FileObject file, String securityKey64) throws Exception {
		byte[] signature = generateSignature(file, securityKey64);
		String signatureB64 = Base64.encodeBase64String(signature);
		return signatureB64;
	}

	/**
	 * @param key - BASE64 encoded key
	 */
	@Override
	public String encryptKey(String key) throws Exception {
		if (key == null || key.isEmpty()) { // TODO: i18n
			throw new Exception("Key value must be a not empty BASE64 encoded string.");
		}
		byte[] decodedKey = Base64.decodeBase64(key);
		if (decodedKey.length < MIN_KEY_LENGTH) { // TODO: i18n
			throw new Exception("Key value must be at least 256-bit long.");
		}
		byte[] aesKey = AESEncryptor.encrypt(decodedKey, HARDCODED_KEY.getBytes(SystemConstants.DEFAULT_CHARSET));
		String aesKeyB64 = Base64.encodeBase64String(aesKey);
		return aesKeyB64;
	}

	/**
	 *  decode and decrypt security key
	 * @param securityKey64
	 * @return
	 * @throws Exception
	 */
	private byte[] getPureSecurityKey(String securityKey64) throws Exception {
		byte[] encryptedKey = Base64.decodeBase64(securityKey64);
		return AESEncryptor.decrypt(encryptedKey, HARDCODED_KEY.getBytes(SystemConstants.DEFAULT_CHARSET));
	}
	
	private byte[] createSha1(InputStream fis) throws Exception {
		MessageDigest digest = MessageDigest.getInstance("SHA-1");
		int n = 0;
		byte[] buffer = new byte[8192];
		while (n != -1) {
			n = fis.read(buffer);
			if (n > 0) {
				digest.update(buffer, 0, n);
			}
		}
		return digest.digest();
	}
	
	private byte[] addRandomTail(byte[] array) {
		byte[] extendedArray = Arrays.copyOf(array, array.length + TAIL_LENGTH);
		
		byte[] tail = new byte[TAIL_LENGTH];
		new Random().nextBytes(tail);
		
		for (int i = extendedArray.length - 1, j = 1; j <= TAIL_LENGTH; i--, j++) {
			extendedArray[i] = tail[TAIL_LENGTH - j];
		}
		
		return extendedArray;
	}
}
