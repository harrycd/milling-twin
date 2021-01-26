/**
 * 
 */
package uk.ac.cf.twin.milling.servlets;

import java.io.IOException;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;

/**
 * @author Theocharis Alexopoulos
 * @date 21 Jan 2021
 *
 */
public class UserLoggedFilter implements Filter {

	@Override
	public void doFilter(ServletRequest request, ServletResponse response, FilterChain filterChain)
			throws IOException, ServletException {

		filterChain.doFilter(request, response);

	}
	
	@Override
	public void destroy() {
		// TODO Auto-generated method stub
	}
	
	@Override
	public void init(FilterConfig filterConfig) throws ServletException {
//		this.filterConfig = fc;
	}
	
}
