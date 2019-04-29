package util.servlet.filter;

import java.io.IOException;
import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletResponse;

public class NoCacheFilter implements Filter {

	public void init( FilterConfig config )
	throws ServletException
	{
	}
	
	public void doFilter( ServletRequest request, ServletResponse response, FilterChain chain )
		throws IOException, ServletException
	{
		if( response instanceof HttpServletResponse )
		{
			HttpServletResponse httpresp = (HttpServletResponse)response;
	
			httpresp.setHeader( "Pragma", "no-cache" );
			httpresp.setHeader( "Cache-control", "no-cache" );
			httpresp.setHeader( "Cache", "no-cache" );
			httpresp.setHeader( "Expires", "Thu, 05 Mar 1998 10:00:00 GMT" );
//			httpresp.setStatus(HttpServletResponse.SC_FOUND);
		}
	
		chain.doFilter( request, response );
	}
	
	public void destroy() {
	}
}
