package ru.bpc.sv2.scheduler.process;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.Reader;

public class FixedLineLengthReader extends BufferedReader {
	private static final int DEFAULT_BUFFER_SIZE = 65536;
	private int lineSize;
	private boolean skipCrLf;

	public FixedLineLengthReader(int lineSize, Reader in) {
		this(lineSize, in, true);
	}

	public FixedLineLengthReader(int lineSize, Reader in, boolean skipCrLf) {
		this(lineSize, in, skipCrLf, DEFAULT_BUFFER_SIZE);
	}

	public FixedLineLengthReader(int lineSize, Reader in, boolean skipCrLf, int bufferSize) {
		super(in, bufferSize);
		this.lineSize = lineSize;
		this.skipCrLf = skipCrLf;
	}

	@Override
	public String readLine() throws IOException {
		char[] lineBuf = new char[lineSize];
		int read = read(lineBuf);
		if (read == -1)
			return null;
		if (skipCrLf) {
			read = skipCrLfAndFill(lineBuf, 0, read);
		}
		return new String(lineBuf, 0, read);
	}

	private int skipCrLfAndFill(char[] buf, int startIndex, int fullLength) throws IOException {
		int skipped = 0;
		for (int i = startIndex; i < fullLength - skipped; ) {
			char c = buf[i];
			if (c == '\r' || c == '\n') {
				int toSkip = 1;
				if (i < fullLength - skipped - 1) {
					c = buf[i + 1];
					if (c == '\r' || c == '\n') {
						toSkip++;
					}
				}
				System.arraycopy(buf, i + toSkip, buf, i, fullLength - i - toSkip);
				skipped += toSkip;
			} else
				i++;
		}
		if (skipped > 0 && ready()) {
			int read = read(buf, fullLength - skipped, skipped);
			if (read > 0)
				return skipCrLfAndFill(buf, fullLength - skipped, fullLength - skipped + read);
		}
		return fullLength - skipped;
	}
}
