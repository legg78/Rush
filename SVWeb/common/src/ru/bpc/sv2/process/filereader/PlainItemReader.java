package ru.bpc.sv2.process.filereader;

import org.beanio.BeanReader;
import org.beanio.BeanReaderException;
import org.beanio.StreamFactory;

import java.io.*;

@SuppressWarnings("unused")
public class PlainItemReader<T> extends ItemReader<FlatFileItem> {
	private BeanReader bnReader = null;

	public PlainItemReader(String configXml, File file, String encoding, String streamName) throws ItemReaderException, FileNotFoundException, UnsupportedEncodingException {
		this(configXml, new InputStreamReader(new FileInputStream(file), encoding), streamName);
	}

	public PlainItemReader(String configXml, Reader reader, String streamName) throws ItemReaderException {
		// create a StreamFactory
		StreamFactory stFactory = StreamFactory.newInstance();

		// load the mapping file
		stFactory.loadResource(configXml);

		// use a StreamFactory to create a BeanReader
		bnReader = stFactory.createReader(streamName, reader);
	}

	public void releaseResources() {
		if (bnReader != null) {
			bnReader.close();
			bnReader = null;
		}
	}

	@SuppressWarnings("unchecked")
	@Override
	public FlatFileItem next() throws ItemReaderException {
		try {
			T obj = (T) bnReader.read();
			if (obj == null) {
				releaseResources();
				return null;
			}
			return new FlatFileItem(
					bnReader.getRecordName(),
					bnReader.getRecordContext(0).getRecordText(),
					obj,
					obj.getClass());
		} catch (BeanReaderException e) {
			throw new ItemReaderException(e);
		}
	}
}
