package uk.ac.cf.twin.milling.servlets;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class TwinMain
 */
public class JacobRead extends HttpServlet {
       
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("In doGet");
		String pathToFile = "C:\\Users\\Alexo\\OneDrive\\PhD\\CylWearTest_180510\\test2.csv";
		double[][] coords = parseJacobFile(pathToFile);
		
		
		response.setContentType("text/event-stream");
		response.setCharacterEncoding("UTF-8");
		PrintWriter pw = null;
		int counter = 0;
		int counterMax = coords[0].length;
		while(counter < counterMax){
//			System.out.println(counter + " x:" + coords[0][counter] + " y:" + coords[1][counter] + " z: "+ coords[2][counter]);
			try {
				pw = response.getWriter();
				pw.print("data:{"
						+ "\"xcoord\":" + coords[0][counter] + ", "
						+ "\"ycoord\":" + coords[1][counter] + ", "
						+ "\"zcoord\":" + coords[2][counter] + "}\n\n");
				response.flushBuffer();
				//TODO Set it according to the sample rate of the file
				Thread.sleep(150);
			} catch (IOException | InterruptedException e) {
				System.out.println("Exception of type: " + e.getClass().getCanonicalName());
				pw.close();
				break;
			}
			
			
			if (++counter >= counterMax) counter = 0;
		}
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		System.out.println("In doPost");
		doGet(request, response);
	}
	
	/**
	 * @param pathToFile - The path to the .csv file to read from
	 * @param titleLines - Number of lines containing title/header
	 * @return A list of String arrays containing the data of the .csv file
	 */
	private List<String[]> readCSVFile(String pathToFile, int titleLines){
		List<String[]> entries = new ArrayList<String[]>();

		try {
			BufferedReader br = new BufferedReader(new FileReader(pathToFile));
			String line;

			// Skip title lines
			for (int i = 0; i < titleLines; i++){
				br.readLine();
			}
			
			while ((line = br.readLine()) != null) {
				String[] entry = line.split(",");
				entries.add(entry);
			}

			br.close();
		} catch (IOException e) {
			e.printStackTrace();
		}
		System.out.println("File entries:" + entries.size());
		return entries;
	}
	
	/**
	 * @param jacobFilePath - the path to the input file
	 * @return 
	 */
	private double[][] parseJacobFile(String jacobFilePath){
		int firstDataRowIndex = 0;
		int timeColumnIndex = 0;
		int xColumnIndex = 0;
		int yColumnIndex = 0;
		int zColumnIndex = 0;
		int spindleSpeedColumnIndex = 0;
		
		//Read the analysis file
		List<String[]> dataBlocks = readCSVFile(jacobFilePath, 0);
		String[] formatVersion = dataBlocks.get(0);
		
		// Configure parsing based on the format of the file
		if (formatVersion[0].equals("*LL1HB0C4J*")){
			firstDataRowIndex = 9;
			timeColumnIndex = 0;
			xColumnIndex = 9;
			yColumnIndex = 10;
			zColumnIndex = 11;
			spindleSpeedColumnIndex = 3;
			
			// Remove the title rows to keep only the data
			for (int i = 0; i < firstDataRowIndex; i++){
				dataBlocks.remove(0);
			}
		}
		else {
			return new double[0][0];
		}
		
		/*
		 * Parse the List based on the configuration
		 * The section below should be common for all file formats
		 */
		
		int listSize = dataBlocks.size();
		
		//Create the arrays to store file data
		float[] timePoint = new float[listSize];
		double[] xTool = new double[listSize];
		double[] yTool = new double[listSize];
		double[] zTool = new double[listSize];
		
		double[] spindleSpeed = new double[listSize];
		int i = 0;
		
		//TODO Calibrate coordinates so the part is close to (0,0,0)
		// Iterate over the lines of the file and parse the values
		for (String[] block : dataBlocks){
			timePoint[i] = Float.parseFloat(block[timeColumnIndex]);
			xTool[i] = Double.parseDouble(block[xColumnIndex]);
			yTool[i] = Double.parseDouble(block[yColumnIndex]);
			zTool[i] = Double.parseDouble(block[zColumnIndex]);
			spindleSpeed[i] = Double.parseDouble(block[spindleSpeedColumnIndex]);
			i++;
		}

		double[][] results = {xTool, yTool, zTool}; 
		return results;
	}
}
