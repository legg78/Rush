package ru.bpc.sv2;

import com.bpcbt.svng.auth.AuthModuleFilter;
import org.apache.commons.collections.keyvalue.DefaultKeyValue;
import org.apache.log4j.Logger;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.core.annotation.Order;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.core.GrantedAuthorityDefaults;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.ldap.authentication.LdapAuthenticationProvider;
import org.springframework.security.web.access.intercept.FilterSecurityInterceptor;
import org.springframework.security.web.authentication.AnonymousAuthenticationFilter;
import ru.bpc.sv2.acm.AcmPrivConstants;
import ru.bpc.sv2.filter.FilterAdapter;
import ru.bpc.sv2.filter.FilterDelegate;
import ru.bpc.sv2.logic.utility.db.UserContextHolder;
import ru.bpc.sv2.security.*;
import ru.bpc.sv2.security.ldap.LdapAuthenticationProviderFactory;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.servlet.*;
import java.io.IOException;

@Configuration
@EnableWebSecurity
public class AuthConfiguration extends WebSecurityConfigurerAdapter {
	private final static Logger logger = Logger.getLogger(AuthConfiguration.class);

	@Override
	protected void configure(HttpSecurity http) throws Exception {
		http
				.authorizeRequests()
				.antMatchers("/pages/**").hasAnyAuthority(AcmPrivConstants.LOGIN)
				.antMatchers("/**").permitAll()
				.anyRequest().authenticated();
		http
				.addFilterBefore(ssoPreAuthFilter(), AnonymousAuthenticationFilter.class)
				.addFilterBefore(ssoAuthFilter(), SsoPreAuthFilter.class)
				.addFilterBefore(userContextHolderInitFilter(), FilterSecurityInterceptor.class);
		http
				.formLogin()
				.usernameParameter("j_username")
				.passwordParameter("j_password")
				.loginProcessingUrl("/j_security_check")
				.loginPage("/login.jsf").permitAll()
				.failureForwardUrl("/error.jsf").permitAll()
				.and()
				.logout().permitAll();
		http
				.csrf().disable()
				.headers()
				.frameOptions().sameOrigin();
	}

	@Autowired
	public void configureGlobal(AuthenticationManagerBuilder auth, AuthenticationProvider authenticationProvider) throws Exception {
		auth.authenticationProvider(authenticationProvider);
	}

	public boolean isLdapActive() {
		Boolean value = SettingsCache.getInstance().getParameterBooleanValue(SettingsConstants.LDAP_ACTIVE);
		if (value == null) {
			logger.warn(String.format("Can't find setting by name %s. Set LDAP active to false", SettingsConstants.LDAP_ACTIVE));
			value = false;
		}
		return value;
	}

	@Bean
	public AuthenticationProvider authenticationProvider(UserService userService) throws Exception {
		AuthenticationProvider provider;
		if (isLdapActive()) {
			logger.debug("Using LDAP authentication provider");
			provider = ldapAuthenticationProvider(userService);
		} else {
			logger.debug("Using BackOffice DAO authentication provider");
			provider = daoAuthenticationProvider(userService);
		}
		return new LimitingAuthenticationProvider(userService, provider);
	}

	public Filter ssoPreAuthFilter() {
		return new SsoPreAuthFilter();
	}

	@Bean
	public Filter ssoAuthFilter() {
		return new FilterDelegate(new AuthModuleFilter(),
				new DefaultKeyValue("provider", "com.bpcbt.svng.auth.Sv2ModuleProvider"),
				new DefaultKeyValue("exclude", "/sv/error.jsf;/sv/AuthWS;/sv/Processes;/sv/Cardbatch;" +
											   "/sv/ClearingWS;/sv/InfoWS;/sv/InstantIssue;/sv/SvACSWS;/sv/svcmWS;" +
											   "/sv/CallbackService;/sv/ApplicationService;/sv/Reports;" +
											   "/sv/ReportsWS;/sv/ApplicationServiceSecure;/sv/ApIntService")
		);
	}

	public Filter userContextHolderInitFilter() {
		return new FilterAdapter() {
			@Override
			public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
				if (SecurityUtils.isUserLogged()) {
					UserContextHolder.setUserName(SecurityContextHolder.getContext().getAuthentication().getName());
				}
				filterChain.doFilter(servletRequest, servletResponse);
			}
		};
	}

	@Bean
	public UserService userService(JdbcTemplate jdbcTemplate) {
		return new UserService(jdbcTemplate);
	}

	/******************************************************************
				LDAP AUTHENTICATION PROVIDER
	 ******************************************************************/
	public LdapAuthenticationProvider ldapAuthenticationProvider(final UserService userService) throws Exception {
		return LdapAuthenticationProviderFactory.createProvider(userService);
	}

	/******************************************************************
				DAO AUTHENTICATION PROVIDER
	 ******************************************************************/
	public DaoAuthenticationProvider daoAuthenticationProvider(final UserService userService) {
		return new DaoAuthenticationProvider() {{
			setUserDetailsService(new UserDetailsServiceImpl(userService));
			setPasswordEncoder(new ru.bpc.sv2.security.PasswordEncoder());
			setHideUserNotFoundExceptions(false);
		}};
	}

	@Bean
	public GrantedAuthorityDefaults grantedAuthorityDefaults() {
		return new GrantedAuthorityDefaults(""); // Remove the ROLE_ prefix
	}


	@Configuration
	@Order(1)
	public class RestSecurityConfig extends WebSecurityConfigurerAdapter {
		@Override
		protected void configure(HttpSecurity http) throws Exception {
			http
					.antMatcher("/rest/**")
					.authorizeRequests().anyRequest().authenticated()
					.and()
					.httpBasic();

			http
					.csrf().disable()
					.headers()
					.frameOptions().sameOrigin();
		}
	}
}

