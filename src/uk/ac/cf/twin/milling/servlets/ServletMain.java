package uk.ac.cf.twin.milling.servlets;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.stream.Collectors;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.json.simple.JSONObject;
import org.json.simple.JSONValue;

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
			
			// Load NCs that have both simulator and monitoring data specified
			List<Nc> ncs = NcUtils
					.getNcs()
					.stream()
					.filter(x -> (  !( x.getMonitoringPath().equals("") || x.getAnalysisPath().equals("")) )  )
					.collect(Collectors.toList());
			request.setAttribute("ncs", ncs);
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
		case "login" : {
			String dbFile = request.getParameter("db-name");
			SettingsSingleton instance = SettingsSingleton.getInstance();
			instance.dbFilePath = dbFolderPath + "\\" + dbFile;
			System.out.println("selected database: " + instance.dbFilePath);
			request.getRequestDispatcher("machine.jsp").forward(request, response);
			break;
		}
		case "get-database-list" : {
			response.setContentType("application/json");
			PrintWriter out = response.getWriter();

			List<String> dbNames = IoUtils.getFileNames(dbFolderPath, ".db");
			
			
			out.print("{ \"dbList\" : " + JSONValue.toJSONString(dbNames) + "}");
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
