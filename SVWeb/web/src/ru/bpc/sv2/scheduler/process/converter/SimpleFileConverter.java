package ru.bpc.sv2.scheduler.process.converter;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.InputStream;
import java.io.InputStreamReader;

import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSystemException;
import org.apache.log4j.Logger;

import ru.bpc.sv2.process.ProcessFileAttribute;

public class SimpleFileConverter implements FileConverter{
	
	private FileObject fileObject;
	private String newLocation;
	private InputStream inputStream;
	
	private final int type = 1;
	
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	@Override
	public byte[] convert(byte[] source) {
		return null;
	}

	@Override
	public String convert(String source) {
		return null;
	}

	@Override
	public void convertFile() 
	throws Exception{
		if (inputStream == null) {
			try {
				inputStream = fileObject.getContent().getInputStream();
			} catch (FileSystemException e) {
				logger.error("Converter: Cannot get input stream from file object in XML Processor", e);
				throw e;
			}
		}
		
		File newFile = new File(newLocation);
		if (newFile.exists()){
			newFile.delete();
		}
		if (!newFile.createNewFile()){
			logger.error("Converter: Cannot create tmp file on local file system");
		} else {
			try {
				saveFileOnLocalSystem(newFile);
			} catch (Exception e) {
				newFile.delete();
				fileObject.getContent().close();
				logger.error("Converter: Cannot create tmp file on local file system", e);
				return;
			}
		}
		
		inputStream.close();
		inputStream = new FileInputStream(newFile);
		fileObject.getContent().close();
	}

	private void saveFileOnLocalSystem(File file) 
	throws Exception{
		FileWriter fw = null;
		BufferedWriter bw = null;
		try {
			fw = new FileWriter( file );
			bw = new BufferedWriter(fw);
			
			BufferedReader br = new BufferedReader(new InputStreamReader(inputStream));
			String strLine;
			String result;
			while ((strLine = br.readLine()) != null) {		
				String termId = strLine.substring(19, 28);
				String date = strLine.substring(35, 50);
				result = "date: " + date + "; termId: "+ termId + " " + strLine;
				bw.write(result + "\r\n");
			}
			
			//TODO here you must implement logic of this converter
						
		    bw.flush();
		} catch (Exception e) {
			throw e;
		} finally {
			try {
				bw.close();
			} catch (Exception error) {}
			
			try {
				fw.close();
			} catch (Exception error) {}
		}
	}
	
	@Override
	public ProcessFileAttribute getFileAttributes() {
		return null;
	}

	@Override
	public FileObject getFileObject() {
		return fileObject;
	}

	@Override
	public InputStream getInputStream() {
		return inputStream;
	}

	@Override
	public void setFileAttributes(ProcessFileAttribute fileAttributes) {
	}

	@Override
	public void setFileObject(FileObject fileObject) {
		this.fileObject = fileObject;
	}

	@Override
	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}

	@Override
	public void setLocation(String location) {
		this.newLocation = location;
	}

	@Override
	public String convertByteArrayToString(byte[] source) {
		return null;
	}

	public int getType() {
		return type;
	}

}
