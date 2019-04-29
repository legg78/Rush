package ru.bpc.sv2.filter;

import javax.servlet.*;
import java.io.IOException;

public abstract class FilterAdapter implements Filter {
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
	}

	@Override
	public abstract void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException;

	@Override
	public void destroy() {
	}
}
