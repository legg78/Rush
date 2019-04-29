package ru.bpc.sv2.utils;

import org.apache.commons.io.FileUtils;
import org.apache.commons.io.FilenameUtils;
import org.apache.commons.io.IOUtils;
import org.apache.commons.vfs.FileName;
import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileType;
import org.apache.log4j.Logger;

import java.io.*;
import java.util.UUID;

public abstract class SystemUtils {
	private static Logger loggerDB = Logger.getLogger("SYSTEM");

	private SystemUtils() {
	}

	public static String getTempDirPath() {
		return FilenameUtils.normalizeNoEndSeparator(FileUtils.getTempDirectoryPath());
	}

	public static File getTempFile(String prefix) {
		String path = getTempDirPath();
		String fileName = (prefix != null && prefix.length() > 0 ? prefix : "") + UUID.randomUUID().toString() + ".tmp";
		File file = new File(path, fileName);
		file.deleteOnExit();
		return file;
	}

	public static void copy(File file, OutputStream outputStream) throws IOException {
		FileInputStream fis = null;
		try {
			fis = new FileInputStream(file);
			IOUtils.copy(fis, outputStream);
		} finally {
			IOUtils.closeQuietly(fis);
		}
	}

	public static NamedFileInputStream recreateInputStreamAsTempFile(InputStream src) {
		try {
			if (src == null)
				return null;
			if (src instanceof NamedFileInputStream) {
				src.close();
				return new NamedFileInputStream(((NamedFileInputStream) src).getFilePath());
			}
			File tempFile = SystemUtils.getTempFile(null);
			FileOutputStream fos = new FileOutputStream(tempFile);
			IOUtils.copy(src, fos);
			IOUtils.closeQuietly(fos);
			IOUtils.closeQuietly(src);
			return new NamedFileInputStream(tempFile);
		} catch (IOException e) {
			loggerDB.error(e.getMessage(), e);
			throw new RuntimeException("Could not recreate stream as file: "+e.getMessage(), e);
		}
	}

	public static String getFileDirectoryPath(FileObject fileObject) {
		FileName name = fileObject.getName();
		if (name.getType() == FileType.FILE) {
			name = name.getParent();
		}
		final String prefix = "file:///";
		if (name.getRootURI().startsWith(prefix)) {
			String root = name.getRootURI().substring(prefix.length());
			String path = name.getPath();
			if (root.endsWith("/") && path.startsWith("/")) {
				path = path.substring(1);
			}
			return root + path;
		} else {
			return name.getPath();
		}
	}

}
