package uk.ac.cf.twin.milling.servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class TwinMain
 */
public class TwinMain extends HttpServlet {
       
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("In doGet");
		response.setContentType("text/event-stream");
		response.setCharacterEncoding("UTF-8");
		PrintWriter pw = null;
		while(true){
			try {
				pw = response.getWriter();
				pw.print("data:" + Math.random() + "\n\n");
				response.flushBuffer();
				System.out.println("Ready to sleep");
				Thread.sleep(1000);
			} catch (IOException | InterruptedException e) {
				System.out.println("Exception of type: " + e.getClass().getCanonicalName());
				pw.close();
				break;
			}
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("In doPost");
		doGet(request, response);
	}

}
