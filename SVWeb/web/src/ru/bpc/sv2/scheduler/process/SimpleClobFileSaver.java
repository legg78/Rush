package ru.bpc.sv2.scheduler.process;

import ru.bpc.sv2.utils.DBUtils;

import java.io.InputStream;
import java.io.StringReader;
import java.sql.CallableStatement;

public class SimpleClobFileSaver extends AbstractFileSaver {

	@Override
	public void save() throws Exception {
		setupTracelevel();
		logger.debug("SimpleClobFileSaver: start saving file to DB for session " + fileAttributes.getSessionId());
		String character;
		character = fileAttributes.getCharacterSet();
		if (character == null || character.length() == 0){
			character = "UTF-8";
		}
		logger.debug("SimpleClobFileSaver: set characher set of file to " + character);
		String result = null;
		try {
			result = readFileAsString(inputStream, character);
		} catch (Throwable e) {
			logger.error("Error during getting string from the file", e);
		}
		logger.debug("SimpleClobFileSaver: got content from disk, length =  " + (result == null ? 0 : result.length()));
		if (result != null) {
			CallableStatement cstmt = null;
			try {
				cstmt = con.prepareCall("{call prc_api_file_pkg.put_file(i_sess_file_id => ?, i_clob_content => ?)}");
				cstmt.setLong(1, fileAttributes.getSessionId());
				cstmt.setCharacterStream(2, new StringReader(result), result.length());
				cstmt.execute();
			} finally {
				DBUtils.close(cstmt);
			}
		}

		con.commit();
		logger.debug("file loaded for session " + fileAttributes.getSessionId());

	}

	public static String readFileAsString(InputStream is, String charsetName)
		    throws java.io.IOException {
		final int bufsize = 8192;
		int available = is.available();
		byte[] data = new byte[available < bufsize ? bufsize : available];
		int used = 0;
		while (true) {
		  if (data.length - used < bufsize) {
		    byte[] newData = new byte[data.length << 1];
		    System.arraycopy(data, 0, newData, 0, used);
		    data = newData;
		  }
		  int got = is.read(data, used, data.length - used);
		  if (got <= 0) break;
		  used += got;
		}
		return charsetName != null ? new String(data, 0, used, charsetName)
		                           : new String(data, 0, used);
	}
}
