package ru.bpc.sv2.scheduler.process.converter;

import java.io.InputStream;
import java.io.OutputStream;

public interface OutgoingFileConverter {
	
	public void convertFile()
	throws Exception;
	
	public InputStream getInputStream();
	
	public void setInputStream(InputStream inputStream);
	
	public OutputStream getOutputStream();
	
	public void setOutputStream(OutputStream ouputStream);

	public String getFileFormat();
	
	public void setFileFormat(String fileFormat);
}
