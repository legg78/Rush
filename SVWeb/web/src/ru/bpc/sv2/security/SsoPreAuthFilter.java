package ru.bpc.sv2.security;

import com.bpcbt.svng.auth.AuthParamsHolder;
import com.bpcbt.svng.auth.context.AuthContext;
import com.bpcbt.svng.auth.exceptions.NoThreadLocalValueException;
import org.springframework.security.authentication.AnonymousAuthenticationToken;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.preauth.PreAuthenticatedAuthenticationToken;

import javax.servlet.*;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class SsoPreAuthFilter implements Filter {
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		if (AuthParamsHolder.isUseSso()) {
			if (SecurityContextHolder.getContext().getAuthentication() == null
					|| SecurityContextHolder.getContext().getAuthentication() instanceof AnonymousAuthenticationToken) {
				try {
					List<GrantedAuthority> authorities = new ArrayList<>();
					for (String privilege : AuthContext.getInstance().getAppPrivileges()) {
						authorities.add(new SimpleGrantedAuthority(privilege));
					}
					SecurityContextHolder.getContext().setAuthentication(new PreAuthenticatedAuthenticationToken(
							AuthContext.getInstance().getLogin(), null, authorities));
				} catch (NoThreadLocalValueException ignored) {
				}
			}
		}
		chain.doFilter(request, response);
	}

	@Override
	public void destroy() {

	}
}
