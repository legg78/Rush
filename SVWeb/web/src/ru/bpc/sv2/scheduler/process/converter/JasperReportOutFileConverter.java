package ru.bpc.sv2.scheduler.process.converter;

import org.apache.commons.codec.binary.Base64OutputStream;
import org.apache.commons.io.IOUtils;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.JasperReportsUtils;
import ru.bpc.sv2.utils.SystemUtils;

import javax.xml.stream.XMLEventReader;
import javax.xml.stream.XMLEventWriter;
import javax.xml.stream.XMLInputFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.events.Characters;
import javax.xml.stream.events.XMLEvent;
import java.io.*;
import java.math.BigDecimal;
import java.util.concurrent.*;

public class JasperReportOutFileConverter implements OutgoingFileConverter {

	public static final String TAG_DATASOURCE = "datasource";
	public static final String TAG_TEMPLATE = "template";
	public static final int DEFAULT_NUMBER_OF_THREADS = 2;
	private static volatile ExecutorService reportExecutor;

	private InputStream inputStream = null;
	private OutputStream outputStream = null;
	private String fileFormat;
	private String htmlReportImagePath;
	private String filePassword = null;

	@Override
	public void convertFile() throws Exception {
		File dataSourceFile = null;
		File templateFile = null;
		InputStream templateInputStream = null;
		InputStream datasourceInputStream = null;
		try {
			dataSourceFile = SystemUtils.getTempFile("reportDs");
			templateFile = SystemUtils.getTempFile("reportTemplate");
			XMLInputFactory inputFactory = XMLInputFactory.newInstance();
			inputFactory.setProperty(XMLInputFactory.IS_COALESCING, false);
			XMLEventReader xer = inputFactory.createXMLEventReader(inputStream);
			FileOutputStream dsFos = new FileOutputStream(dataSourceFile);
			XMLEventWriter xew = XMLOutputFactory.newInstance().createXMLEventWriter(dsFos);
			Base64OutputStream templateFos = new Base64OutputStream(new FileOutputStream(templateFile), false);

			boolean writeDs = false;
			boolean writeTemplate = false;
			// Extracting template and datasource from input stream
			while (xer.hasNext()) {
				XMLEvent event = xer.nextEvent();
				// Data source
				if (!writeTemplate) {
					if (!writeDs && event.isStartElement() && event.asStartElement().getName().getLocalPart().equals(TAG_DATASOURCE)) {
						writeDs = true;
						continue;
					}
					if (writeDs && event.isEndElement() && event.asEndElement().getName().getLocalPart().equals(TAG_DATASOURCE)) {
						writeDs = false;
						continue;
					}
					if (writeDs || event.isStartDocument() || event.isEndDocument()) {
						xew.add(event);
					}
				}
				// Template
				if (!writeDs) {
					if (!writeTemplate && event.isStartElement() && event.asStartElement().getName().getLocalPart().equals(TAG_TEMPLATE)) {
						writeTemplate = true;
						continue;
					}
					if (writeTemplate && event.isCharacters()) {
						Characters characters = event.asCharacters();
						if (characters.isCData())
							templateFos.write(characters.getData().getBytes(SystemConstants.DEFAULT_CHARSET));
					}
				}
			}

			xer.close();
			xew.close();
			IOUtils.closeQuietly(dsFos);
			IOUtils.closeQuietly(templateFos);

			datasourceInputStream = new FileInputStream(dataSourceFile);
			templateInputStream = new FileInputStream(templateFile);

			final InputStream finalDatasourceInputStream = datasourceInputStream;
			final InputStream finalTemplateInputStream = templateInputStream;
			Future<Object> future = getExecutor().submit(new Callable<Object>() {
				@Override
				public Object call() throws Exception {
					System.out.println("generating report");
					JasperReportsUtils.execute(finalDatasourceInputStream, finalTemplateInputStream,
											   outputStream, fileFormat, htmlReportImagePath,
											   filePassword);
					return null;
				}
			});
			try {
				future.get();
			} catch (ExecutionException e) {
				throw e.getCause() instanceof Exception ? (Exception) e.getCause() : e;
			}
		} finally {
			IOUtils.closeQuietly(datasourceInputStream);
			IOUtils.closeQuietly(templateInputStream);
			if (templateFile != null)
				//noinspection ResultOfMethodCallIgnored
				templateFile.delete();
			if (dataSourceFile != null)
				//noinspection ResultOfMethodCallIgnored
				dataSourceFile.delete();
		}

	}

	@Override
	public InputStream getInputStream() {
		return inputStream;
	}

	@Override
	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}

	public OutputStream getOutputStream() {
		return outputStream;
	}

	public void setOutputStream(OutputStream outputStream) {
		this.outputStream = outputStream;
	}

	public String getFileFormat() {
		return fileFormat;
	}

	public void setFileFormat(String fileFormat) {
		this.fileFormat = fileFormat;
	}

	@SuppressWarnings("UnusedDeclaration")
	public String getHtmlReportImagePath() {
		return htmlReportImagePath;
	}

	public void setHtmlReportImagePath(String htmlReportImagePath) {
		this.htmlReportImagePath = htmlReportImagePath;
	}

	private static ExecutorService getExecutor() {
		if (reportExecutor == null) {
			synchronized (JasperReportOutFileConverter.class) {
				if (reportExecutor == null) {
					BigDecimal value = SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.REPORTS_CONCURRENT_GENERATE_COUNT);
					int nThreads = value == null || value.intValue() <= 0 ? DEFAULT_NUMBER_OF_THREADS : value.intValue();
					reportExecutor = Executors.newFixedThreadPool(nThreads);
				}
			}
		}
		return reportExecutor;
	}

	public void setFilePassword(String filePassword) {
		this.filePassword = filePassword;
	}
}
