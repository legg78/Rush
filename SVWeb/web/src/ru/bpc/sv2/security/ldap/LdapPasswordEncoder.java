package ru.bpc.sv2.security.ldap;

import org.apache.commons.lang3.StringUtils;
import org.springframework.security.authentication.encoding.MessageDigestPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;

public class LdapPasswordEncoder implements PasswordEncoder {
	private final MessageDigestPasswordEncoder encoder;
	private final String passwordPrefix;
	public LdapPasswordEncoder(String algorithm, String passwordPrefix, boolean encodeHashAsBase64) {
		encoder = new MessageDigestPasswordEncoder(algorithm, encodeHashAsBase64);
		this.passwordPrefix = passwordPrefix != null ? passwordPrefix : "";
	}

	@Override
	public String encode(CharSequence rawPassword) {
		return passwordPrefix + encoder.encodePassword(rawPassword.toString(), null);
	}
	@Override
	public boolean matches(CharSequence rawPassword, String encodedPassword) {
		return encoder.isPasswordValid(encodedPassword, rawPassword.toString(), null);
	}
}
