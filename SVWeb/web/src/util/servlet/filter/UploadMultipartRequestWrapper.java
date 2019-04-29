package util.servlet.filter;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileUploadException;
import org.apache.commons.fileupload.servlet.ServletFileUpload;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletRequestWrapper;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class UploadMultipartRequestWrapper extends HttpServletRequestWrapper{

    private Map<String, List<String>> formParameters;
    private Map<String, List<FileItem>> fileParameters;
	
	public UploadMultipartRequestWrapper(HttpServletRequest request) throws ServletException {
		super(request);
		try{
			ServletFileUpload upload = new ServletFileUpload();
			upload.setFileItemFactory(new ProgressMonitorFileItemFactory(request));

			formParameters = new HashMap<String, List<String>>();
			fileParameters = new HashMap<String, List<FileItem>>();

            List fileItems = upload.parseRequest(request);
            for (int i = 0; i < fileItems.size(); i++) {
                FileItem item = (FileItem) fileItems.get(i);
                if (item.isFormField()) {
                    addParameter(item.getFieldName(), item.getString(), formParameters);
                } else {
                    addParameter(item.getFieldName(), item, fileParameters);
                }
            }
		}catch(FileUploadException fe){
            ServletException servletException = new ServletException();
            servletException.initCause(fe);
            throw servletException;
		}catch(Exception ne){
			throw new RuntimeException(ne);
		}
	}

    private <T> void addParameter(String key, T value, Map<String, List<T>> map) {
        if (map.containsKey(key)) {
            map.get(key).add(value);
        } else {
            List<T> values = new ArrayList<T>();
            values.add(value);
            map.put(key, values);
        }
    }

	@Override
	public String getParameter(String name) {
        if (formParameters.containsKey(name)) {
            List<String> values = formParameters.get(name);
            if (values.isEmpty()) {
                return "";
            }
            else {
                return values.get(0);
            }
        } else if(fileParameters.containsKey(name)){
			return "file";
		} else {
            return super.getParameter(name);
        }
	}

	public Enumeration<String> getFileNames(){
		return Collections.enumeration(fileParameters.keySet());
	}

	public FileItem getFileItem(String name){
        if (fileParameters.containsKey(name)) {
            List<FileItem> items = fileParameters.get(name);
            // We assume that each request has only one file item.
            if ( items.size() != 1 ) {
                throw new UnsupportedOperationException("Cannot handle multiple files in a single request.");
            }
            return items.get(0);
        } else {
            return null;
        }
	}

	@Override
	public Map<String, String[]> getParameterMap() {
        Map<String, String[]> map = new HashMap<String, String[]>();
        for (String formParam : formParameters.keySet()) {
            List<String> list = formParameters.get(formParam);
            map.put(formParam, list.toArray(new String[list.size()]));
        }
        map.putAll(super.getParameterMap());
        return Collections.unmodifiableMap(map);
	}

	@Override
	public Enumeration<String> getParameterNames() {
        Set<String> paramNames = new LinkedHashSet<String>();
        paramNames.addAll(formParameters.keySet());
        Enumeration<String> original = super.getParameterNames();
        while (original.hasMoreElements()) {
            paramNames.add(original.nextElement());
        }
        return Collections.enumeration(paramNames);
	}

	@Override
	public String[] getParameterValues(String name) {
        if (formParameters.containsKey(name)) {
            List<String> values = formParameters.get(name);
            if (values.isEmpty()) {
                return new String[] {};
            }
            else {
                return values.toArray(new String[values.size()]);
            }
        } else {
            return super.getParameterValues(name);
        }
	}
	

	
	
	
	
}