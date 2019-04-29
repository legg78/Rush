package ru.bpc.sv2.security.ldap;

import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.config.annotation.authentication.ProviderManagerBuilder;
import org.springframework.security.ldap.authentication.LdapAuthenticationProvider;

public class LdapProviderManagerBuilderAdapter implements ProviderManagerBuilder<LdapProviderManagerBuilderAdapter> {
	private LdapAuthenticationProvider authenticationProvider = null;
	@Override
	public LdapProviderManagerBuilderAdapter authenticationProvider(AuthenticationProvider authenticationProvider) {
		this.authenticationProvider = (LdapAuthenticationProvider) authenticationProvider;
		return this;
	}
	@Override
	public AuthenticationManager build() {
		throw new UnsupportedOperationException("Method 'build' does not support for this implementation");
	}

	public LdapAuthenticationProvider getAuthenticationProvider() {
		return authenticationProvider;
	}
}
