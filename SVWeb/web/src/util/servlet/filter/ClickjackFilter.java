package util.servlet.filter;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletContext;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

public class ClickjackFilter implements Filter {
	FilterConfig config = null;
	ServletContext servletContext = null;

	private String commonMode = "DENY";
	private String fileMode = "SAMEORIGIN";
	private final static String FILE_CONTENT_TYPE = "MULTIPART/FORM-DATA";

	public ClickjackFilter() {
		super();
	}

	@Override
	public void destroy() {}

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		HttpServletRequest req = (HttpServletRequest) request;
		HttpServletResponse res = (HttpServletResponse)response;
		String type = req.getHeader("Content-Type");
		if (type != null && type.toUpperCase().contains(FILE_CONTENT_TYPE)) {
			res.addHeader("X-FRAME-OPTIONS", fileMode);
		} else {
			res.addHeader("X-FRAME-OPTIONS", commonMode);
		}
		chain.doFilter(request, response);
	}

	@Override
	public void init(FilterConfig fc) throws ServletException {
		String configCommonMode = fc.getInitParameter("commonMode");
		if ( configCommonMode != null ) {
			commonMode = configCommonMode;
		}

		String configFileMode = fc.getInitParameter("fileMode");
		if ( configFileMode != null ) {
			fileMode = configFileMode;
		}
	}

}
