package ru.bpc.sv2.security.ldap;

import org.apache.log4j.Logger;
import org.springframework.ldap.core.DirContextOperations;
import org.springframework.security.core.GrantedAuthority;
import ru.bpc.sv2.security.UserService;

import java.util.Collection;
import java.util.List;

public class LdapAuthoritiesPopulator implements org.springframework.security.ldap.userdetails.LdapAuthoritiesPopulator {
	private final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
	private final UserService userService;

	public LdapAuthoritiesPopulator(UserService userService) {
		this.userService = userService;
	}

	@Override
	public Collection<? extends GrantedAuthority> getGrantedAuthorities(DirContextOperations userData, final String userName) {
		logger.debug("Check user in BackOffice and load privileges: " + userName + " (ldap)");
		userService.initUser(userName);
		List<GrantedAuthority> authorities = userService.getAuthorities();
		logger.debug(String.format("User %s has %d privileges", userName, authorities.size()));
		return authorities;
	}
}
