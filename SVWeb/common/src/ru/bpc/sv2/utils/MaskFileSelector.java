package ru.bpc.sv2.utils;

import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSelectInfo;
import org.apache.commons.vfs.FileSelector;
import org.apache.commons.vfs.FileType;

public class MaskFileSelector implements FileSelector {

	private String mask;
	
	public MaskFileSelector(String mask){
		this.mask = mask;
	}
	
	public boolean includeFile(FileSelectInfo fileInfo) throws Exception {
		FileObject fo = fileInfo.getFile();
		if (fileInfo.getDepth() == 1 && FileType.FILE.equals(fo.getType()) && fo.getName().getBaseName().toLowerCase().matches(mask.toLowerCase())) {			
			return true;
		}
		return false;
	}

	public boolean traverseDescendents(FileSelectInfo fileInfo) throws Exception {
		if (fileInfo.getDepth() == 1 && FileType.FOLDER.equals(fileInfo.getFile().getType())) {
			return false;
		}
		return true;
	}

}
