package com.bpcbt.svng.auth.utils;

import org.springframework.security.crypto.codec.Base64;

import java.io.UnsupportedEncodingException;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom;
import java.util.Hashtable;
import java.util.Objects;

public final class PasswordHashUtility {
	public static final int DEFAULT_SALT_SIZE = 4;
	public static final String DEFAULT_ALGORITHM = "SHA-1";
	public static final String DEFAULT_ENCODING = "UTF-8";
	private PasswordHashAlgorithm hashAlg = null;
	private String salt = null;
	private String processed = null;
	private boolean allowPlaintext = false;

	private static Hashtable<String, PasswordHashAlgorithm> getAlgorithms() {
		return PasswordHashUtility.AlgorithmManagerHolder.manager.algorithms;
	}

	public PasswordHashUtility(String theAlgorithm) {
		if (theAlgorithm != null && theAlgorithm.trim().length() > 0) {
			this.hashAlg = this.getHashAlgorithm(theAlgorithm);
		}

	}

	public PasswordHashUtility(boolean allowPlaintextIn, String hashedPass) {
		this.allowPlaintext = allowPlaintextIn;
		this.processed = this.parsePassword(hashedPass);
	}

	public void clearData() {
		this.salt = null;
		this.processed = null;
		this.hashAlg = null;
	}

	public String getAlgorithm() {
		return this.hashAlg == null ? null : this.hashAlg.getName();
	}

	public boolean getIsSalted() {
		return this.salt != null;
	}

	public String hashUserPassword(String passIn, int saltSize) {
		if (this.hashAlg == null) {
			return passIn;
		} else {
			if (passIn.startsWith("{" + hashAlg + "}")) {
				return passIn;
			}
			String saltStr = null;
			if (saltSize > 0) {
				byte[] someBytes = new byte[saltSize];
				new SecureRandom().nextBytes(someBytes);
				try {
					saltStr = new String(Base64.encode(someBytes), "UTF-8");
					if (saltStr.length() > saltSize) {
						saltStr = saltStr.substring(0, saltSize);
					}
				} catch (UnsupportedEncodingException ignored) {
				}
			}

			String password = "{" + this.hashAlg.getName() + "}";
			if (saltStr != null) {
				password = password + saltStr;
			}

			password = password + this.convertPassword(passIn, saltStr);
			return password;
		}
	}

	public String hashPassword(String passIn, boolean allowPlaintext, boolean isSalted) {
		if (this.hashAlg == null) {
			if (allowPlaintext) {
				return passIn;
			} else {
				throw new PasswordHashException("Plaintext passwords are not allowed");
			}
		} else {
			return isSalted ? this.hashUserPassword(passIn, 4) : this.hashUserPassword(passIn, 0);
		}
	}

	public boolean comparePassword(String passToCompare) {
		if (passToCompare != null && this.processed != null) {
			String convertedPass;
			if (passToCompare.startsWith("{" + hashAlg.getName() + "}")) {
				convertedPass = this.parsePassword(passToCompare);
			} else {
				convertedPass = this.convertPassword(passToCompare, this.salt);
			}
			return convertedPass != null && this.processed.equals(convertedPass);
		} else {
			return Objects.equals(passToCompare, this.processed) && this.allowPlaintext;
		}
	}

	private String parsePassword(String passInStr) {
		if (passInStr != null && passInStr.length() >= 1) {
			char[] passIn = passInStr.toCharArray();
			if (passIn[0] != '{') {
				if (this.allowPlaintext) {
					return passInStr;
				} else {
					throw new PasswordHashException("Unable to parse hashed password");
				}
			} else {
				int i;
				i = 1;
				while (i < passIn.length && passIn[i] != '}') {
					++i;
				}

				if (i >= passIn.length) {
					if (this.allowPlaintext) {
						return passInStr;
					} else {
						throw new PasswordHashException("Unable to parse hashed password");
					}
				} else {
					String algorithm = new String(passIn, 1, i - 1);
					int offset = i + 1;

					try {
						this.hashAlg = this.getHashAlgorithm(algorithm);
					} catch (PasswordHashException var9) {
						if (this.allowPlaintext) {
							return passInStr;
						}

						throw var9;
					}

					if (this.hashAlg != null && this.hashAlg.getB64Size() != -1) {
						int totalRemaining = passIn.length - offset;
						int saltSize = totalRemaining - this.hashAlg.getB64Size();
						if (saltSize < 0) {
							this.hashAlg = null;
							if (this.allowPlaintext) {
								return passInStr;
							} else {
								throw new PasswordHashException("Unable to parse hashed password");
							}
						} else {
							if (saltSize > 0) {
								this.salt = new String(passIn, offset, saltSize);
								offset += saltSize;
							}

							char[] encodedPwdHashFromDB = new char[passIn.length - offset];
							System.arraycopy(passIn, offset, encodedPwdHashFromDB, 0, passIn.length - offset);
							return new String(encodedPwdHashFromDB);
						}
					} else {
						this.hashAlg = null;
						if (this.allowPlaintext) {
							return passInStr;
						} else {
							throw new PasswordHashException("Unable to parse hashed password");
						}
					}
				}
			}
		} else if (this.allowPlaintext) {
			return passInStr;
		} else {
			throw new PasswordHashException("Plaintext passwords are not allowed");
		}
	}

	private String convertPassword(String passToConvert, String salt) {
		if (this.hashAlg == null) {
			return passToConvert;
		} else {
			try {
				MessageDigest digest = this.hashAlg.getMessageDigestInstance();
				if (salt != null) {
					digest.update(salt.getBytes("UTF-8"));
				}

				digest.update(passToConvert.getBytes("UTF-8"));
				byte[] pwdHashFromUser = digest.digest();
				return new String(Base64.encode(pwdHashFromUser), "UTF-8");
			} catch (NoSuchAlgorithmException var6) {
				throw new PasswordHashException("Hash algorythm not found: " + hashAlg, var6);
			} catch (UnsupportedEncodingException var7) {
				throw new PasswordHashException(var7);
			}
		}
	}

	private PasswordHashAlgorithm getHashAlgorithm(String algorithm) {
		if (algorithm == null) {
			return null;
		} else {
			algorithm = algorithm.toUpperCase();
			Hashtable<String, PasswordHashAlgorithm> algorithms = getAlgorithms();
			PasswordHashAlgorithm algInfo = algorithms.get(algorithm);
			if (algInfo == null) {
				try {
					algInfo = new PasswordHashAlgorithm(algorithm);
				} catch (NoSuchAlgorithmException var5) {
					throw new PasswordHashException("Hash algorythm not found: " + hashAlg, var5);
				}

				if (algInfo.getHashSize() == -1) {
					throw new PasswordHashException("Hash algorythm not usable: " + hashAlg);
				}

				algorithms.put(algorithm, algInfo);
			}

			return algInfo;
		}
	}

	private static class AlgorithmManager {
		public Hashtable<String, PasswordHashAlgorithm> algorithms = new Hashtable<>();

		public AlgorithmManager() {
			this.algorithms.put("SHA", new PasswordHashAlgorithm("SHA", "SHA-1", 20));
			this.algorithms.put("SSHA", new PasswordHashAlgorithm("SSHA", "SHA-1", 20));
			this.algorithms.put("SHA1", new PasswordHashAlgorithm("SHA1", "SHA-1", 20));
			this.algorithms.put("SHA-1", new PasswordHashAlgorithm("SHA-1", "SHA-1", 20));
			this.algorithms.put("MD5", new PasswordHashAlgorithm("MD5", "MD5", 16));
		}
	}

	private static class AlgorithmManagerHolder {
		public static final PasswordHashUtility.AlgorithmManager manager = new PasswordHashUtility.AlgorithmManager();

		private AlgorithmManagerHolder() {
		}
	}
}
