package uk.ac.cf.twin.milling.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import uk.ac.cf.milling.objects.Billet;
import uk.ac.cf.milling.objects.Nc;
import uk.ac.cf.milling.objects.SettingsSingleton;
import uk.ac.cf.milling.utils.data.IoUtils;
import uk.ac.cf.milling.utils.db.BilletUtils;
import uk.ac.cf.milling.utils.db.NcUtils;
import uk.ac.cf.milling.utils.webapp.MonitoringUtils;

/**
 * Servlet implementation class TwinMain
 */
public class ServletMain extends HttpServlet {

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;
	private String dbFolderPath = "C:\\Users\\Alexo\\OneDrive\\PhD - Work\\Eclipse 2018-09\\milling-vm";

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("In doGet");
		String action = request.getParameter("action");

		if (action == null || action.equals("")) return;

		switch(action) {
		case "load-database" : {
			String dbFile = request.getParameter("db-name");
			SettingsSingleton instance = SettingsSingleton.getInstance();
			instance.dbFilePath = dbFolderPath + "\\" + dbFile;
			System.out.println("selected database: " + instance.dbFilePath);
			request.getRequestDispatcher("machine.jsp").forward(request, response);
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
//		case "monitoringtest" : {
//			int ncId = Integer.parseInt(request.getParameter("ncId"));
//
//			//Initiate the process to send data to server
//			//				
//			//				
//			//				
//			response.setContentType("application/json");
//			// Get the printwriter object from response to write the required json object to the output stream      
//			PrintWriter out = response.getWriter();
//			// Assuming your json object is **jsonObject**, perform the following, it will return your json object  
//			out.print("{ ncId: '" + ncId + "', key2: 'value2' }");
//			out.flush();
//			break;
//		}
		case "login" : {
			List<String> dbNames = IoUtils.getFileNames(dbFolderPath, ".db");
			request.setAttribute("databases", dbNames);
			request.getRequestDispatcher("select-database.jsp").forward(request, response);
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
