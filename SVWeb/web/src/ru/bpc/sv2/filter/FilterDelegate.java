package ru.bpc.sv2.filter;

import org.apache.commons.collections.KeyValue;

import javax.servlet.*;
import java.io.IOException;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.concurrent.atomic.AtomicBoolean;

public class FilterDelegate implements Filter {
	private AtomicBoolean filterInitialized = new AtomicBoolean(false);
	private Filter delegate;
	private final Map<String, String> initParams;

	public FilterDelegate(Filter delegate, KeyValue... initParams) {
		this.delegate = delegate;
		this.initParams = new HashMap<>();
		for (KeyValue param : initParams) {
			this.initParams.put((String) param.getKey(), (String) param.getValue());
		}
	}

	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
		boolean notInitialized = filterInitialized.compareAndSet(false, true);
		if (notInitialized) {
			delegate.init(new DelegateFilterConfig(filterConfig.getServletContext()));
		}
	}

	@Override
	public void doFilter(ServletRequest servletRequest, ServletResponse servletResponse, FilterChain filterChain) throws IOException, ServletException {
		if (!filterInitialized.get()) {
			boolean notInitialized = filterInitialized.compareAndSet(false, true);
			if (notInitialized) {
				delegate.init(new DelegateFilterConfig(servletRequest.getServletContext()));
			}
		}
		delegate.doFilter(servletRequest, servletResponse, filterChain);
	}

	@Override
	public void destroy() {

	}

	private class DelegateFilterConfig implements FilterConfig {
		private ServletContext servletContext;

		public DelegateFilterConfig() {
		}

		public DelegateFilterConfig(ServletContext servletContext) {
			this.servletContext = servletContext;
		}

		@Override
		public String getFilterName() {
			return delegate.getClass().getSimpleName();
		}

		@Override
		public ServletContext getServletContext() {
			return servletContext;
		}

		@Override
		public String getInitParameter(String name) {
			return initParams.get(name);
		}

		@Override
		public Enumeration<String> getInitParameterNames() {
			return new Enumeration<String>() {
				private Iterator<String> iterator = initParams.keySet().iterator();

				@Override
				public boolean hasMoreElements() {
					return iterator.hasNext();
				}

				@Override
				public String nextElement() {
					return iterator.next();
				}
			};
		}
	}
}
