package ru.bpc.sv2.scheduler.process.mc;

import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;
import ru.bpc.sv2.utils.SystemException;

import javax.xml.bind.DatatypeConverter;
import java.io.DataInputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class MCWFileSaver extends SimpleFileSaver {
	public static final int MAX_LINE_LENGTH = 4000;
	public static final String RECORD_FORMAT = "I_RECORD_FORMAT";
	public static final String RDW_1014 = "RCFM1014";

	private DataInputStream dataStream = null;

	private static final int NUM_IN_BATCH = 10000;
	Long bytesRead;
	Integer bytesInBlockRead;
	private boolean rdw1014;

	@Override
	public void save() throws Exception {
		long curtime = System.currentTimeMillis();

		dataStream = new DataInputStream(inputStream);

		String strLine;
		List<SimpleFileRec> rawsAsArray = new ArrayList<SimpleFileRec>();
		List<Integer> recNumList = new ArrayList<Integer>();

		int i = 0;
		int num = 1;
		int num_in_batch = NUM_IN_BATCH;
		int rdw;
		byte[] source;
		bytesRead = 0L;
		bytesInBlockRead = 0;
		determineFormat();
		while ((rdw = readRDW()) != 0) {
			source = readMessage(rdw);
			if (converter != null) {
				strLine = converter.convertByteArrayToString(source);
			} else {
				strLine = DatatypeConverter.printHexBinary(source);
			}

			rawsAsArray.add(new SimpleFileRec(strLine));
			recNumList.add(num);
			i++;
			if (i == num_in_batch) {
				storeData(rawsAsArray, recNumList);
				rawsAsArray.clear();
				recNumList.clear();
				i = 0;
			}
			num++;
		}

		if (i > 0) {
			storeData(rawsAsArray, recNumList);
			rawsAsArray.clear();
			recNumList.clear();
		}

		logger.debug("Saved in time: " + (System.currentTimeMillis() - curtime));
	}

	public int readRDW() throws SystemException {
		int rdw = 0;

		byte[] rdwB = readMessage(4);
		rdw += (rdwB[0] & 0xFF) << 24;
		rdw += (rdwB[1] & 0xFF) << 16;
		rdw += (rdwB[2] & 0xFF) << 8;
		rdw += (rdwB[3] & 0xFF);
		return rdw;
	}

	public byte[] readMessage(Integer length) throws SystemException {
		if (length > MAX_LINE_LENGTH)
			throw new SystemException(getClass().getSimpleName() + ": file " + fileAttributes.getFileName() +
					" probably contains incorrect data. Line length=" + length + " at position " + bytesRead);
		byte[] line = new byte[length];
		long j = bytesRead;
		for (int i = 0; i < length;) {
			if (bytesInBlockRead == 1012 && rdw1014) {
				try {
					//noinspection ResultOfMethodCallIgnored
					dataStream.skip(2);
					j += 2;
					bytesInBlockRead = 0;
					continue;
				} catch (IOException e) {
					e.printStackTrace();
				}
			} else {
				try {
					line[i] = dataStream.readByte();
				} catch (IOException e) {
					logger.error("Error during reading bytes.", e);
					break;
				} finally {
					i++;
				}
			}
			bytesInBlockRead++;
			j++;
		}
		bytesRead = j;
		return line;
	}

	private void determineFormat() {
		rdw1014 = params.containsKey(RECORD_FORMAT) && params.get(RECORD_FORMAT).equals(RDW_1014);
	}
}
