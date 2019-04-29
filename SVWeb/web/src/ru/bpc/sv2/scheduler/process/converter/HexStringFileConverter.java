package ru.bpc.sv2.scheduler.process.converter;

import java.io.InputStream;

import org.apache.commons.vfs.FileObject;

import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.utils.StringUtils;

public class HexStringFileConverter implements FileConverter{

	private final int type = 0;
	
	public String convertByteArrayToString(byte[] source) {
		
		StringUtils strUtils = new StringUtils();
		String output = strUtils.getHexString1(source);
		return output;
	}

	@Override
	public ProcessFileAttribute getFileAttributes() {
		return null;
	}

	@Override
	public FileObject getFileObject() {
		return null;
	}

	@Override
	public InputStream getInputStream() {
		return null;
	}

	@Override
	public void setFileAttributes(ProcessFileAttribute fileAttributes) {
	}

	@Override
	public void setFileObject(FileObject fileObject) {
	}

	@Override
	public void setInputStream(InputStream inputStream) {
	}

	@Override
	public void setLocation(String location) {
	}

	@Override
	public byte[] convert(byte[] source) {
		return null;
	}

	@Override
	public String convert(String source) {
		return null;
	}

	@Override
	public void convertFile() throws Exception {
	}

	public int getType() {
		return type;
	}
}
