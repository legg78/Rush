package ru.bpc.sv2.scheduler.process.converter;

import java.io.InputStream;

import org.apache.commons.vfs.FileObject;

import ru.bpc.sv2.process.ProcessFileAttribute;

public interface FileConverter {
	
	public void convertFile()
	throws Exception;
	
	public byte[] convert(byte[] source);
	
	public String convert(String source);
	
	public String convertByteArrayToString(byte[] source);
	
	public InputStream getInputStream();
	
	public void setInputStream(InputStream inputStream);
	
	public FileObject getFileObject();
	
	public void setFileObject(FileObject fileObject);
	
	public ProcessFileAttribute getFileAttributes();

	public void setFileAttributes(ProcessFileAttribute fileAttributes);
	
	public void setLocation(String location);
	
	public int getType();
}
