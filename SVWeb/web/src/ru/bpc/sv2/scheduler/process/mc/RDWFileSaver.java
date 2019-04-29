package ru.bpc.sv2.scheduler.process.mc;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;
import ru.bpc.sv2.utils.KeyLabelItem;
import ru.bpc.sv2.utils.SystemException;

import java.io.DataInputStream;
import java.io.IOException;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

enum DictionaryParts {
	HEADER,
	BODY_ALLOWED,
	BODY_FORBIDDEN,
	TRAILER;
}

public class RDWFileSaver extends SimpleFileSaver {
	public static final int MAX_LINE_LENGTH    = 100000;
	public static final int TEXT_FILE_BLOCK    = 1012;
	public static final int ALLOWED_DICT_ARRAY = 10000080;
	public static final String TABLE_KEYS      = "IP0000T1";
	public static final String HEADER_1        = "UPDATE FILE";
	public static final String HEADER_2        = "REPLACEMENT FILE";
	public static final String TRAILER_1       = "TRAILER RECORD";
	public static final String TRAILER_2       = "TRAILER RCD";
	public static final int TABLE_NAME_START   = 11;
	public static final int TABLE_NAME_END     = 19;
	public static final int TABLE_CODE_START   = 8;
	public static final int TABLE_CODE_END     = 11;
	public static final int SUB_NAME_START     = 19;
	public static final int SUB_NAME_END       = 27;
	public static final int SUB_CODE_START     = 243;
	public static final int SUB_CODE_END       = 246;

	private DataInputStream dataStream = null;
	private long bytesRead;
	private int bytesInBlockRead;
	private boolean rdw1014;
	private List<String> allowedDicts;
	private Map<String, String> subIds;

	@Override
	public void save() throws Exception {
		long curtime = System.currentTimeMillis();

		dataStream = new DataInputStream(inputStream);

		getAllowedDictionaries();
		determineFormat();

		List<SimpleFileRec> rawsAsArray = new ArrayList<SimpleFileRec>();
		List<Integer> recNumList = new ArrayList<Integer>();

		String converted;
		String header = null;
		int i = 0;
		int seq = 1;
		bytesRead = 0L;
		bytesInBlockRead = 0;
		boolean writableBlock = false;
		int rdw;

		while ((rdw = readRDW()) > 0) {
			if (converter != null) {
				converted = converter.convert(new String(readMessage(rdw), getCharset()));
			} else {
				converted = new String(readMessage(rdw), getCharset());
			}

			processTableKeys(converted);
			switch (converterStringAllowed(converted)) {
				case HEADER:
					header = converted;
					writableBlock = false;
					break;
				case BODY_ALLOWED:
					if (header != null) {
						seq = writeString(rawsAsArray, recNumList, header, seq);
						i = storeBatch(rawsAsArray, recNumList, i);
						header = null;
					}
					seq = writeString(rawsAsArray, recNumList, converted, seq);
					i = storeBatch(rawsAsArray, recNumList, i);
					writableBlock = true;
					break;
				case TRAILER:
					if (writableBlock) {
						seq = writeString(rawsAsArray, recNumList, converted, seq);
						i = storeBatch(rawsAsArray, recNumList, i);
					}
					writableBlock = false;
					break;
				default:
					header = null;
					writableBlock = false;
					break;
			}
		}

		if (i > 0) {
			i = storeBatch(rawsAsArray, recNumList);
		}

		logger.info("Saved in time: " + (System.currentTimeMillis() - curtime));
	}

	public int readRDW() throws IOException, SystemException {
		int rdw = 0;

		byte[] rdwB = readMessage(4);
		if (rdwB.length <= 0)
			return 0;
		rdw += (rdwB[0] & 0xFF) << 24;
		rdw += (rdwB[1] & 0xFF) << 16;
		rdw += (rdwB[2] & 0xFF) << 8;
		rdw += (rdwB[3] & 0xFF);
		return rdw;
	}

	public byte[] readMessage(int length) throws IOException, SystemException {
		if (length > MAX_LINE_LENGTH) {
			throw new SystemException(getClass().getSimpleName() + ": file " + fileAttributes.getFileName() +
									  " probably contains incorrect data. Line length=" + length +
									  " at position " + bytesRead);
		}
		byte[] line = new byte[length];
		int read = 0;
		if (rdw1014 && bytesInBlockRead + length > TEXT_FILE_BLOCK) {
			while (read < length) {
				int read1;
				if (bytesInBlockRead < TEXT_FILE_BLOCK) {
					read1 = dataStream.read(line, read, Math.min(length - read, TEXT_FILE_BLOCK - bytesInBlockRead));
					if (read1 < 0)
						return new byte[0];
					bytesRead += read1;
					read += read1;
				}
				bytesInBlockRead = 0;
				int skipped = dataStream.skipBytes(2);
				if (skipped < 2)
					return new byte[0];
				bytesRead += skipped;
				read1 = dataStream.read(line, read, Math.min(length - read, TEXT_FILE_BLOCK));
				if (read1 < 0)
					return new byte[0];
				bytesInBlockRead += read1;
				bytesRead += read1;
				read += read1;
			}
		} else {
			read = dataStream.read(line, 0, length);
			if (read < 0)
				return new byte[0];
			bytesInBlockRead += read;
			bytesRead += read;
		}
		return line;
	}

	private void determineFormat() {
		// By default format is RDW_1014
		rdw1014 = params == null || !params.containsKey(MCWFileSaver.RECORD_FORMAT) || params.get(MCWFileSaver.RECORD_FORMAT).equals(MCWFileSaver.RDW_1014);
	}

	private void getAllowedDictionaries() throws SystemException {
		allowedDicts = new ArrayList<String>();
		subIds = new HashMap<String, String>();

		CommonDao commonDao = new CommonDao();
		KeyLabelItem items[] = commonDao.getArray(userSessionId, ALLOWED_DICT_ARRAY);
		for(KeyLabelItem item : items) {
			if (item.getValue() != null && !item.getValue().toString().isEmpty()) {
				allowedDicts.add(item.getValue().toString().trim());
			}
		}
	}

	private int writeString(List<SimpleFileRec> raws, List<Integer> recs, String str, int seq) throws SQLException {
		raws.add(new SimpleFileRec(str));
		recs.add(seq++);
		return seq;
	}

	private int storeBatch(List<SimpleFileRec> raws, List<Integer> recs, int i) throws SQLException {
		i++;
		if (i >= NUM_IN_BATCH) {
			i = storeBatch(raws, recs);
		}
		return i;
	}

	private int storeBatch(List<SimpleFileRec> raws, List<Integer> recs) throws SQLException {
		storeData(raws, recs);
		raws.clear();
		recs.clear();
		return 0;
	}

	private DictionaryParts converterStringAllowed(String raw) {
		if (StringUtils.isNotEmpty(raw)) {
			if (raw.startsWith(HEADER_1) || raw.startsWith(HEADER_2)) {
				return DictionaryParts.HEADER;
			}
			if (raw.startsWith(TRAILER_1) || raw.startsWith(TRAILER_2)) {
				return DictionaryParts.TRAILER;
			}

			// Check normal layouts
			if (raw.length() > TABLE_NAME_END) {
				String table = raw.substring(TABLE_NAME_START, TABLE_NAME_END);
				for (String dict : allowedDicts) {
					if (dict.equalsIgnoreCase(table)) {
						return DictionaryParts.BODY_ALLOWED;
					}
				}
			}

			// Check compressed layouts
			if (raw.length() > TABLE_CODE_END) {
				String code = subIds.get(raw.substring(TABLE_CODE_START, TABLE_CODE_END));
				if (StringUtils.isNotEmpty(code)) {
					for (String dict : allowedDicts) {
						if (dict.equalsIgnoreCase(code)) {
							return DictionaryParts.BODY_ALLOWED;
						}
					}
				}
			}
		}
		return DictionaryParts.BODY_FORBIDDEN;
	}

	private void processTableKeys(String raw) {
		if (StringUtils.isNotEmpty(raw) && raw.length() > SUB_CODE_END) {
			if (TABLE_KEYS.equalsIgnoreCase(raw.substring(TABLE_NAME_START, TABLE_NAME_END))) {
				subIds.put(raw.substring(SUB_CODE_START, SUB_CODE_END), raw.substring(SUB_NAME_START, SUB_NAME_END));
			}
		}
	}
}
