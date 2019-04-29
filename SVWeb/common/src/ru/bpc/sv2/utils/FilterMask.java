package ru.bpc.sv2.utils;

import java.io.File;
import java.io.FilenameFilter;

public class FilterMask implements FilenameFilter {
	
	private String mask;
	
	public FilterMask(String mask) {
		this.mask = mask;
	}
	
	public void setMask(String mask) {
		this.mask = mask;
	}

	public boolean accept(File dir, String name) {
		return name.matches(mask);
	}
}