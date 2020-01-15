package uk.ac.cf.twin.milling.servlets;

import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import uk.ac.cf.milling.objects.Billet;
import uk.ac.cf.milling.objects.Nc;
import uk.ac.cf.milling.objects.SettingsSingleton;
import uk.ac.cf.milling.utils.BilletUtils;
import uk.ac.cf.milling.utils.MonitoringUtils;
import uk.ac.cf.milling.utils.NcUtils;

/**
 * Servlet implementation class TwinMain
 */
public class ServletMain extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("In doGet");
		String action = request.getParameter("action");

		if (action == null || action.equals("")) return;

		switch(action) {
		case "login" : {
			String dbFilePath = request.getParameter("dbFilePath");
			SettingsSingleton instance = SettingsSingleton.getInstance();
			instance.dbFilePath = dbFilePath;
			System.out.println("selected database: " + dbFilePath);
			break;
		}
		case "monitoring" : {
			int ncId = Integer.parseInt(request.getParameter("ncId"));
			MonitoringUtils.sendMonitoringEvents(response, ncId);
			break;
		}
		case "billetretrieve" : {
			int ncId = Integer.parseInt(request.getParameter("ncId"));
			Nc nc = NcUtils.getNc(ncId);
			Billet billet = BilletUtils.getBillet(nc.getBilletId());
			
			response.setContentType("application/json");
			PrintWriter out = response.getWriter();
			out.print("{ "
					+ "\"xBilletMin\": " + billet.getXBilletMin() + "," 
					+ "\"xBilletMax\": " + billet.getXBilletMax() + "," 
					+ "\"yBilletMin\": " + billet.getYBilletMin() + "," 
					+ "\"yBilletMax\": " + billet.getYBilletMax() + "," 
					+ "\"zBilletMin\": " + billet.getZBilletMin() + "," 
					+ "\"zBilletMax\": " + billet.getZBilletMax() 
					+ " }");
			out.flush();
			break;
		}
		case "monitoringtest" : {
			int ncId = Integer.parseInt(request.getParameter("ncId"));

			//Initiate the process to send data to server
			//				
			//				
			//				
			response.setContentType("application/json");
			// Get the printwriter object from response to write the required json object to the output stream      
			PrintWriter out = response.getWriter();
			// Assuming your json object is **jsonObject**, perform the following, it will return your json object  
			out.print("{ ncId: '" + ncId + "', key2: 'value2' }");
			out.flush();
			break;
		}
		case "example" : {break;}
		default : {
			System.out.println("Unknown action:" + action);
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
