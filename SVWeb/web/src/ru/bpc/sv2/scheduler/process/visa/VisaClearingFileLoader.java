package ru.bpc.sv2.scheduler.process.visa;

import ru.bpc.sv2.scheduler.process.FixedLineLengthReader;
import ru.bpc.sv2.scheduler.process.SimpleFileSaver;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.UnsupportedEncodingException;

@SuppressWarnings("UnusedDeclaration")
public class VisaClearingFileLoader extends SimpleFileSaver {
	private static final int LINE_SIZE = 168;

	@Override
	protected BufferedReader createReader(InputStream in, String charsetName) throws UnsupportedEncodingException {
		return new FixedLineLengthReader(LINE_SIZE, new InputStreamReader(in, charsetName));
	}
}
