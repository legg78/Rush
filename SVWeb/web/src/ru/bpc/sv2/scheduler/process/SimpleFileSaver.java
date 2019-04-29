package ru.bpc.sv2.scheduler.process;

import oracle.sql.ARRAY;
import org.apache.log4j.Logger;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.SystemUtils;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;
import java.sql.CallableStatement;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class SimpleFileSaver extends AbstractFileSaver {
	protected static final Logger logger = Logger.getLogger("PROCESSES");
	public static final String CHARSET_DEFAULT = "UTF-8";
	public static final String CHARSET_WE8EBCDIC37 = "WE8EBCDIC37";
	protected static final int NUM_IN_BATCH = 10000;
	public static final String CHARSET_EBCDIC_IBM01140 = "IBM01140";
	private boolean ebcdic;

	@Override
	public void save() throws Exception {
		setupTracelevel();
		logger.debug(String.format("Start incoming file saver: %s, prc_session_file.id: %d", this.getClass().getName(), fileAttributes.getSessionId()));
		try {
			if (converter != null) {
				convert();
				inputStream = converter.getInputStream();
			}

			long curtime = System.currentTimeMillis();
			BufferedReader br = createReader(inputStream, getCharset());

			List<SimpleFileRec> rawsAsArray = new ArrayList<SimpleFileRec>();
			List<Integer> recNumList = new ArrayList<Integer>();

			int i = 0;
			int num = 1;
			String strLine;
			while ((strLine = br.readLine()) != null) {
				rawsAsArray.add(new SimpleFileRec(strLine));
				recNumList.add(num);
				i++;
				if (i == NUM_IN_BATCH) {
					storeData(rawsAsArray, recNumList);
					rawsAsArray.clear();
					recNumList.clear();
					i = 0;
				}
				num++;
			}
			br.close();
			if (i > 0) {
				storeData(rawsAsArray, recNumList);
			}

			logger.debug("Saved in time: " + (System.currentTimeMillis() - curtime));
		} finally {
			//TODO here you must close inputStream of local tmp file
			inputStream.close();
			fileObject.close();
		}
	}


	private String cachedCharset;

	protected String getCharset() {
		if (cachedCharset == null) {
			String charset = fileAttributes.getCharacterSet();
			if (CHARSET_WE8EBCDIC37.equals(charset)) {
				charset = CHARSET_EBCDIC_IBM01140;
			} else if (!CommonUtils.hasText(charset)) {
				charset = CHARSET_DEFAULT;
			}
			cachedCharset = charset;
		}
		ebcdic = cachedCharset.equals(CHARSET_EBCDIC_IBM01140);
		return cachedCharset;
	}

	public boolean isEbcdic() {
		getCharset();
		return ebcdic;
	}

	protected BufferedReader createReader(InputStream in, String charsetName) throws UnsupportedEncodingException {
		return new BufferedReader(new InputStreamReader(in, charsetName));
	}

	protected void storeData(List<SimpleFileRec> rawData, List<Integer> recNums) throws SQLException {
		ARRAY oracleRecNums = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RECNUM_TAB, con,
				recNums.toArray(new Integer[recNums.size()]));
		ARRAY oracleRawData = DBUtils.createArray(AuthOracleTypeNames.PRC_SESSION_FILE_RAW_TAB, con,
				rawData.toArray(new SimpleFileRec[rawData.size()]));
		CallableStatement cstmt = null;
		logger.debug(String.format("Saving data put_bulk_web file_session_id=%d, rec nums=%d..%d",
				fileAttributes.getSessionId(), recNums.get(0), recNums.get(recNums.size() - 1)));
		try {
			cstmt = con.prepareCall("{call prc_api_file_pkg.put_bulk_web(?,?,?)}");
			cstmt.setLong(1, fileAttributes.getSessionId());
			cstmt.setArray(2, oracleRawData);
			cstmt.setArray(3, oracleRecNums);
			cstmt.execute();
		} finally {
			DBUtils.close(cstmt);
		}
	}

	private void convert() throws Exception {
		converter.setInputStream(inputStream);
		converter.setFileObject(fileObject);
		converter.setFileAttributes(fileAttributes);
		converter.setLocation(SystemUtils.getTempDirPath() + "/" + fileObject.getName().getBaseName());
		converter.convertFile();
	}
}
