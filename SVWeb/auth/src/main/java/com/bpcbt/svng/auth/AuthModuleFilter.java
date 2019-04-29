package com.bpcbt.svng.auth;

import com.bpcbt.svng.auth.utils.AppServerUtils;

import javax.servlet.*;
import javax.servlet.http.HttpServletRequest;
import java.io.IOException;

/**
 * Created by Perminov on 16.09.2016.
 */
public class AuthModuleFilter extends com.bpcbt.svng.auth.filters.AuthFilter {
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		// AuthParamsHolder should be initialized in ContextInitializedListener
		if (AuthParamsHolder.isUseSso()) {
			if (AuthParamsHolder.getSsoServer() != null) {
				System.setProperty("auth_module_url", AuthParamsHolder.getSsoServer());
			}
			super.init(filterConfig);
		}
	}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		if (AppServerUtils.isWebsphere()) {
			if ("/".equals(((HttpServletRequest) request).getPathInfo())) {
				request.getRequestDispatcher("/pages/data.jsf").forward(request, response);
				return;
			}
		}
		if (AuthParamsHolder.isUseSso()) {
			super.doFilter(request, response, chain);
		} else {
			chain.doFilter(request, response);
		}
	}
}
