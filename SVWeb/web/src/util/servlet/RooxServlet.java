package util.servlet;

import java.io.IOException;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * Servlet implementation class AuthServlet
 */
public class RooxServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
       
    /**
     * @see HttpServlet#HttpServlet()
     */
    public RooxServlet() {
        super();
    }

	/**
	 * @see HttpServlet#doGet(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
		String out = "{ " +				
		"\"result\": 0," +
		"\"errMsg\": \"OK\"," +
		"\"amount\": \"1234557.69\"," +
		"\"creditLimitAmount\": \".00\"," +
		"\"reserveAmount\": \".06\"," +
		"\"currency\": \"643\"," +
		"\"externalTransactionID\": \"00000000000000000000000000000000000000000000000002\"" +
		"}";
		response.getOutputStream().write(out.getBytes());
	}

	/**
	 * @see HttpServlet#doPost(HttpServletRequest request, HttpServletResponse response)
	 */
	protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
	}

}
