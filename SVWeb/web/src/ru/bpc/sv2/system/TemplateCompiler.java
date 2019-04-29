package ru.bpc.sv2.system;

import net.sf.jasperreports.engine.JRException;
import net.sf.jasperreports.engine.JasperCompileManager;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.reports.ReportTemplate;
import ru.bpc.sv2.utils.SystemException;
import ru.bpc.sv2.utils.UserException;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.UnsupportedEncodingException;

public class TemplateCompiler {
	private static final Logger logger = Logger.getLogger("REPORTS");
	
	public void compile(ReportTemplate template) throws SystemException, UserException{
		if (template.getText() == null){
			template.setTextBase64(null); 
			return;
		}
		
		ByteArrayOutputStream out = new ByteArrayOutputStream();
		byte[] encodedBytes = new byte[0];
		try {
			JasperCompileManager.compileReportToStream(new ByteArrayInputStream(template.getText().getBytes("UTF-8")), out);
			Base64 encoder = new Base64();
			encodedBytes = encoder.encode(out.toByteArray());		
		} catch (UnsupportedEncodingException e) {
			logger.error(e);
			return;
		} catch (JRException e) {
			// TODO This is a very bad practice.
			// This is done due to the groovy possibility in
			// JasperReports.
			// But we have to show error and continue working
			logger.error("Error occured during template compilation. Template Id: " + template.getId());
			logger.error("", e);
			throw new SystemException("Report compilation error", e);
		} finally {
			IOUtils.closeQuietly(out);
		}
		String base64 = new String(encodedBytes);
		template.setTextBase64(base64);
	}	
}
