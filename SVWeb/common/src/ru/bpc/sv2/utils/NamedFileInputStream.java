package ru.bpc.sv2.utils;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;

public class NamedFileInputStream extends FileInputStream {
	private String filePath;

	public NamedFileInputStream(String filePath) throws FileNotFoundException {
		super(filePath);
		this.filePath = filePath;
	}

	public NamedFileInputStream(File file) throws FileNotFoundException {
		super(file);
		this.filePath = file.getAbsolutePath();
	}

	public String getFilePath() {
		return filePath;
	}

	public void closeAndDelete() {
		try {
			super.close();
		} catch (IOException ignored) {
		}
		//noinspection ResultOfMethodCallIgnored
		new File(filePath).delete();
	}
}
