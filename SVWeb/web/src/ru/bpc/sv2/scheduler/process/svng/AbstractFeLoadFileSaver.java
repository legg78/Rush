package ru.bpc.sv2.scheduler.process.svng;

import org.apache.commons.io.IOUtils;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.scheduler.process.ResultableFileSaver;
import ru.bpc.sv2.scheduler.process.external.svng.FileSessionDataSave;
import ru.bpc.sv2.utils.SystemUtils;

import java.io.*;

public abstract class AbstractFeLoadFileSaver extends AbstractFeBaseFileSaver implements ResultableFileSaver {
	private File tempFile;

	protected OutputStream getOutputStream() throws Exception {
		tempFile = SystemUtils.getTempFile(getClass().getSimpleName() + "_");
		return new FileOutputStream(tempFile);
	}

	@Override
	public void save() throws Exception {
		try {
			super.save();
			FileSessionDataSave fsd = new FileSessionDataSave(process.getContainerBindId(), userSessionId, fileAttributes, getStatusSessionFile());
			fsd.setSessionId(sessionId);
			fsd.setSessionFileId(fileAttributes.getSessionId());
			fsd.setConnection(getConnection());
			Reader reader = null;
			try {
				reader = new BufferedReader(new InputStreamReader(new FileInputStream(tempFile), SystemConstants.DEFAULT_CHARSET));
				fsd.createSqlQuery(reader, fileAttributes.getName(), 1 /*as we do not know exact number of records*/, tempFile.length());
				fsd.executeUpdate();
			} finally {
				IOUtils.closeQuietly(reader);
			}
		} finally {
			if (tempFile != null) {
				//noinspection ResultOfMethodCallIgnored
				tempFile.delete();
			}
		}
	}

	public String getStatusSessionFile() {
		return null;
	}

	@Override
	public String getFileStatus() {
		return getStatusSessionFile();
	}
}
