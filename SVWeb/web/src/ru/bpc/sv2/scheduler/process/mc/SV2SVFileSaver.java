package ru.bpc.sv2.scheduler.process.mc;

import org.apache.poi.util.ArrayUtil;
import ru.bpc.sv2.process.file.SimpleFileRec;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;
import ru.bpc.sv2.ui.utils.CommonUtils;
import ru.bpc.sv2.utils.SystemException;

import javax.xml.bind.DatatypeConverter;
import java.io.DataInputStream;
import java.io.EOFException;
import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

public class SV2SVFileSaver extends SimpleFileSaver {
	private static final int MAX_LINE_LENGTH = 4000;

	private DataInputStream dataStream = null;

	private static final int NUM_IN_BATCH = 10000;
	private Long bytesRead;

	@Override
	public void save() throws Exception {
		long curtime = System.currentTimeMillis();

		dataStream = new DataInputStream(inputStream);

		String strLine;
		List<SimpleFileRec> rawsAsArray = new ArrayList<>();
		List<Integer> recNumList = new ArrayList<>();

		int i = 0;
		int num = 1;
		byte[] source;
		bytesRead = 0L;

		while ((source = readMessage()) != null) {
			if (converter != null) {
				strLine = converter.convertByteArrayToString(source);
			} else {
				strLine = DatatypeConverter.printHexBinary(source);
			}

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

		if (i > 0) {
			storeData(rawsAsArray, recNumList);
			rawsAsArray.clear();
			recNumList.clear();
		}

		logger.debug("Saved in time: " + (System.currentTimeMillis() - curtime));
	}

	public byte[] readMessage() {
		byte[] line = new byte[MAX_LINE_LENGTH];
		byte currentByte;
		long j = bytesRead;
		int bytesInLineRead = 0;
		for (int i = 0;i < MAX_LINE_LENGTH;i++) {
			try {
				currentByte = dataStream.readByte();
				if (currentByte == 0x0A) {
					break;
				} else {
					line[i] = currentByte;
				}
			} catch (EOFException e) {
				logger.debug("End of file has been reached.");
				break;
			} catch (IOException e) {
				logger.error("Error during reading bytes.", e);
				break;
			}
			bytesInLineRead++;
			j++;
		}
		bytesRead = j;

		byte[] actualLine = new byte[bytesInLineRead];

		if (bytesInLineRead > 0) {
			ArrayUtil.arraycopy(line, 0, actualLine, 0, bytesInLineRead);
			return actualLine;
		} else {
			return null;
		}
	}
}
