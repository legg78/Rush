package ru.bpc.sv2.security;

import com.bpcbt.svng.auth.utils.PasswordHashUtility;

public class PasswordEncoder implements org.springframework.security.crypto.password.PasswordEncoder {
	@Override
	public String encode(CharSequence rawPassword) {
		return new PasswordHashUtility(PasswordHashUtility.DEFAULT_ALGORITHM).hashPassword(rawPassword.toString(), false, false);
	}

	@Override
	public boolean matches(CharSequence rawPassword, String encodedPassword) {
		return new PasswordHashUtility(false, encodedPassword).comparePassword(rawPassword.toString());
	}
}
