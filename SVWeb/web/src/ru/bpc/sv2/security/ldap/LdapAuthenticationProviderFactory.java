package ru.bpc.sv2.security.ldap;

import com.bpcbt.sv.utils.StringCrypter;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.springframework.security.config.annotation.authentication.configurers.ldap.LdapAuthenticationProviderConfigurer;
import org.springframework.security.ldap.authentication.LdapAuthenticationProvider;
import ru.bpc.sv2.security.UserService;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

public class LdapAuthenticationProviderFactory {
	private final static Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private final static String USER_DN_PATTERNS_SEPARATOR = ";";

	public static LdapAuthenticationProvider createProvider(UserService userService) throws Exception {
		LdapProviderManagerBuilderAdapter builder = new LdapProviderManagerBuilderAdapter();
		LdapAuthenticationProviderConfigurer<LdapProviderManagerBuilderAdapter> configurer = new LdapAuthenticationProviderConfigurer<>();

		configurer
				.ldapAuthoritiesPopulator(new LdapAuthoritiesPopulator(userService))
				.userDnPatterns(getUserDnPatterns())
				.userSearchBase(getUserSearchBase())
				.userSearchFilter(getUserSearchFilter())
				.contextSource()
				.url(getUrl())
				.port(getPort())
				.managerDn(getManagerDn())
				.managerPassword(getManagerPassword());

		String passwordAttribute = getPasswordAttribute();
		if (StringUtils.isNotEmpty(passwordAttribute)) {
			configurer
					.passwordCompare()
					.passwordAttribute(passwordAttribute);
		}

		String passwordAlgorithm = getPasswordAlgorithm();
		if (StringUtils.isNotEmpty(passwordAlgorithm)) {
			configurer.passwordEncoder(new LdapPasswordEncoder(passwordAlgorithm, getPasswordPrefix(), isPasswordBase64()));
		}

		configurer
				.withObjectPostProcessor(new LdapContextSourcePostProcessor())
				.rolePrefix("")
				.configure(builder);

		LdapAuthenticationProvider provider = builder.getAuthenticationProvider();
		provider.setHideUserNotFoundExceptions(false);
		return provider;
	}

	private static String[] getUserDnPatterns() {
		String value = getStringSetting(SettingsConstants.LDAP_USER_DN_PATTERNS, false, "Ldap user dn patterns: %s");
		if (value == null) {
			return null;
		}
		return value.split(USER_DN_PATTERNS_SEPARATOR);
	}

	private static String getUserSearchBase() {
		String value = getStringSetting(SettingsConstants.LDAP_USER_SEARCH_BASE, false, "Ldap user search base: %s");
		if (value == null) {
			return "";
		}
		return value;
	}

	private static String getUserSearchFilter() {
		return getStringSetting(SettingsConstants.LDAP_USER_SEARCH_FILTER, false, "Ldap user search filter: %s");
	}

	private static String getUrl() {
		return getStringSetting(SettingsConstants.LDAP_URL, true, "Ldap context url: %s");
	}

	private static int getPort() {
		int value = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.LDAP_PORT).intValue();
		logger.debug("Ldap context port: " + value);
		return value;
	}

	private static String getManagerDn() {
		return getStringSetting(SettingsConstants.LDAP_MANAGER_DN, false, "Ldap manager dn: %s");
	}

	private static String getManagerPassword() {
		String value = getStringSetting(SettingsConstants.LDAP_MANAGER_PASSWORD, false, null);
		if (StringUtils.isEmpty(value)) {
			return value;
		}
		return (new StringCrypter()).decrypt(value);
	}

	private static String getPasswordAttribute() {
		return getStringSetting(SettingsConstants.LDAP_PASSWORD_ATTRIBUTE, false, "Ldap password attribute: %s");
	}

	private static String getPasswordAlgorithm() {
		return getStringSetting(SettingsConstants.LDAP_PASSWORD_ALGORITHM, false, "Ldap password algorithm: %s");
	}

	private static String getPasswordPrefix() {
		return getStringSetting(SettingsConstants.LDAP_PASSWORD_PREFIX, false, "Ldap password prefix: %s");
	}

	private static boolean isPasswordBase64() {
		boolean value = SettingsCache.getInstance().getParameterBooleanValue(SettingsConstants.LDAP_PASSWORD_AS_BASE64);
		logger.debug("Ldap encode hash as base64: " + value);
		return value;
	}


	private static String getStringSetting(String setting, boolean required, String log) {
		String value = SettingsCache.getInstance().getParameterStringValue(setting);
		if (required && StringUtils.isEmpty(value)) {
			throw new IllegalStateException(String.format("Parameter '%s' can't be empty", setting));
		}
		if (StringUtils.isNotEmpty(log)) {
			logger.debug(String.format(log, value));
		}
		return value;
	}
}
