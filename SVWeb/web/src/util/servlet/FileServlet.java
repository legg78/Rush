package util.servlet;

import org.apache.commons.io.FilenameUtils;
import ru.bpc.sv2.utils.SystemUtils;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.File;
import java.io.IOException;

public class FileServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;
	public static final String FILE_SERVLET_CONTENT_TYPE = "FILE_SERVLET_CONTENT_TYPE";
	public static final String FILE_SERVLET_FILE_CONTENT = "FILE_SERVLET_FILE_CONTENT";
	public static final String FILE_SERVLET_FILE_PATH = "FILE_SERVLET_FILE_PATH";
	public static final String FILE_SERVLET_FILE_DELETE = "FILE_SERVLET_FILE_DELETE";

	@Override
	protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
		HttpSession session = req.getSession();

		String contentType = (String) session.getAttribute(FILE_SERVLET_CONTENT_TYPE);
		byte[] fileContent = (byte[]) session.getAttribute(FILE_SERVLET_FILE_CONTENT);
		String fileContentPath = (String) session.getAttribute(FILE_SERVLET_FILE_PATH);
		boolean deleteFile = session.getAttribute(FILE_SERVLET_FILE_DELETE) != null;
		session.removeAttribute(FILE_SERVLET_CONTENT_TYPE);
		session.removeAttribute(FILE_SERVLET_FILE_CONTENT);
		session.removeAttribute(FILE_SERVLET_FILE_PATH);
		session.removeAttribute(FILE_SERVLET_FILE_DELETE);

		resp.setContentType(contentType);
		resp.setHeader("Content-Disposition","attachment; filename=\"" + FilenameUtils.getName(req.getRequestURI()) + "\"");

		if (fileContent != null) {
			resp.getOutputStream().write(fileContent);
		} else if (fileContentPath != null) {
			File file = new File(fileContentPath);
			SystemUtils.copy(file, resp.getOutputStream());
			if (deleteFile)
				//noinspection ResultOfMethodCallIgnored
				file.delete();
		}
	}
}
