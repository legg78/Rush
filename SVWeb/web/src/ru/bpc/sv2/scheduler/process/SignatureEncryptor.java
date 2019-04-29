package ru.bpc.sv2.scheduler.process;

import org.apache.commons.vfs.FileObject;

public interface SignatureEncryptor {
	/**
	 * 
	 * @param file
	 * @param signature
	 *            - contents of file with signature
	 * @param securityKey64
	 *            - BASE64 encoded and possibly encrypted security key
	 * @return <code>true</code> if <code>file</code> is signed with
	 *         <code>signature</code>; <code>false</code> otherwise
	 */
	public boolean checkFile(FileObject file, byte[] signature, String securityKey64) throws Exception;
	
	/**
	 * 
	 * @param file
	 * @param signatureBase64
	 *            - contents of file with signature in BASE64
	 * @param securityKey64
	 *            - BASE64 encoded and possibly encrypted security key
	 * @return <code>true</code> if <code>file</code> is signed with
	 *         <code>signature</code>; <code>false</code> otherwise
	 */
	public boolean checkFile(FileObject file, String signatureBase64, String securityKey64) throws Exception;

	/**
	 * 	
	 * @param file
	 * @param securityKey64 - BASE64 encoded and possibly encrypted security key
	 * @return
	 * @throws Exception
	 */
	public byte[] generateSignature(FileObject file, String securityKey64) throws Exception;
	
	/**
	 * 	
	 * @param file
	 * @param securityKey64 - BASE64 encoded and possibly encrypted security key
	 * @return signature encoded in BASE64
	 * @throws Exception
	 */
	public String generateSignatureBase64(FileObject file, String securityKey64) throws Exception;

	/**
	 * @param key
	 * @return BASE64 encoded and possibly encrypted security key
	 */
	public String encryptKey(String key) throws Exception;
}
