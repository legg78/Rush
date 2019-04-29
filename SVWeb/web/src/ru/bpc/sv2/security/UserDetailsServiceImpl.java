package ru.bpc.sv2.security;

import org.apache.log4j.Logger;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.userdetails.User;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;

import java.util.List;

public class UserDetailsServiceImpl implements UserDetailsService {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private final UserService userService;

	public UserDetailsServiceImpl(UserService userService) {
		this.userService = userService;
	}

	@Override
	public UserDetails loadUserByUsername(final String userName) throws UsernameNotFoundException {
		try {
			logger.debug("loadUserByUsername: " + userName);
			userService.initUser(userName);
			String passwordHash = userService.getPasswordHash(userName);
			List<GrantedAuthority> authorities = userService.getAuthorities();
			logger.debug(String.format("User %s has %d privileges", userName, authorities.size()));
			assert passwordHash != null;
			return new User(userName, passwordHash, authorities);
		} catch (UsernameNotFoundException e) {
			logger.error(e.getMessage());
			throw e;
		}
	}
}
