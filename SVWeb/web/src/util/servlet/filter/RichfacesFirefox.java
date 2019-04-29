package util.servlet.filter;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;

/**
 * Servlet Filter implementation class RichfacesFirefox
 */
public class RichfacesFirefox implements Filter {

    /**
     * Default constructor. 
     */
    public RichfacesFirefox() {
    }

	/**
	 * @see Filter#destroy()
	 */
	public void destroy() {
	}

	/**
	 * @see Filter#doFilter(ServletRequest, ServletResponse, FilterChain)
	 */
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException {
		 chain.doFilter(new HttpServletRequestWrapper((HttpServletRequest) request) {
			 
             public String getRequestURI() {
              try {
                  return URLDecoder.decode(super.getRequestURI(), "ISO-8859-1");
              } catch (UnsupportedEncodingException e) {
                  throw new IllegalStateException("Cannot decode request URI.", e);
              }
          }
      }, response);

	}

	/**
	 * @see Filter#init(FilterConfig)
	 */
	public void init(FilterConfig fConfig) throws ServletException {
		// TODO Auto-generated method stub
	}

}
