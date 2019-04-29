package ru.bpc.sv2.scheduler.process;

import org.apache.commons.io.IOUtils;
import org.apache.commons.vfs.FileObject;
import org.apache.commons.vfs.FileSystemException;
import org.apache.log4j.Logger;
import org.xml.sax.SAXException;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.utils.SystemUtils;

import javax.xml.transform.TransformerException;
import javax.xml.validation.Schema;
import javax.xml.validation.SchemaFactory;
import javax.xml.validation.Validator;
import java.io.*;

public class XMLProcessor {

	private ProcessFileAttribute fileAttributes;
	private FileObject fileObject;
	private boolean needSave;
	private String newLocation;
	private InputStream inputStream;
	private boolean valid;
	private String validationMessage;
	private File xmlTempFile = null;

	private static final Logger logger = Logger.getLogger("PROCESSES");
	private static Logger loggerDB = Logger.getLogger("PROCESSES_DB");

	public XMLProcessor(ProcessFileAttribute fileAttributes, FileObject fileObject,
	                    boolean needSave, String newLocation) {
		this.fileAttributes = fileAttributes;
		this.fileObject = fileObject;
		this.needSave = needSave;
		this.newLocation = newLocation;
	}

	public XMLProcessor(ProcessFileAttribute fileAttributes, FileObject fileObject,
	                    boolean needSave, String newLocation, InputStream inputStream) {
		this.fileAttributes = fileAttributes;
		this.fileObject = fileObject;
		this.needSave = needSave;
		this.newLocation = newLocation;
		this.inputStream = inputStream;
	}

	public void process() throws IOException, TransformerException, SAXException {
		if (inputStream == null) {
			try {
				inputStream = fileObject.getContent().getInputStream();
			} catch (FileSystemException e) {
				logger.error("Cannot get input stream from file object in XML Processor", e);
				throw e;
			}
		}

		if (fileAttributes.getXsltSource() != null) {
			logger.trace("Openning xslt stream");
			InputStream xsltStream = new ByteArrayInputStream(fileAttributes.getXsltSource().getBytes());
			logger.trace("Openning xslt source");
			javax.xml.transform.Source xmlSource = new javax.xml.transform.stream.StreamSource(inputStream);
			javax.xml.transform.Source xsltSource = new javax.xml.transform.stream.StreamSource(xsltStream);

			xmlTempFile = SystemUtils.getTempFile(null);
			FileOutputStream xmlResultStream = new FileOutputStream(xmlTempFile);

			javax.xml.transform.Result result = new javax.xml.transform.stream.StreamResult(xmlResultStream);
			javax.xml.transform.TransformerFactory transFact = javax.xml.transform.TransformerFactory.newInstance();
			javax.xml.transform.Transformer trans = transFact.newTransformer(xsltSource);

			long curtime = System.currentTimeMillis();
			logger.trace("Transformation started");

			try {
				trans.transform(xmlSource, result);
			} catch (TransformerException e1) {
				logger.error("Cannot perform transformation of the file", e1);
				throw e1;
			}

			logger.trace("Transformation finished. Time taken for transformation: " + (System.currentTimeMillis() - curtime));

			try {
				inputStream.close();
			} catch (IOException e) {
				logger.error("Cannot close inputStream of the file", e);
				throw e;
			}
			IOUtils.closeQuietly(xmlResultStream);
			inputStream = new FileInputStream(xmlTempFile);
		}

		if (fileAttributes.isXml() && fileAttributes.getXsdSource() != null) {
			recreateInputStreamAsFile();
			// Validate XML file
			logger.trace("Openning xml source");
			javax.xml.transform.Source xmlSource = new javax.xml.transform.stream.StreamSource(inputStream);

			logger.trace("Openning xsd stream");
			InputStream xsdStream = new ByteArrayInputStream(fileAttributes.getXsdSource().getBytes("UTF-8"));
			logger.trace("Openning xsd source");
			javax.xml.transform.Source xsdSource = new javax.xml.transform.stream.StreamSource(xsdStream);

			try {
				// 1. Lookup a factory for the W3C XML Schema language
				SchemaFactory factory = SchemaFactory.newInstance("http://www.w3.org/2001/XMLSchema");

				// 2. Compile the schema.
				Schema schema = factory.newSchema(xsdSource);

				// 3. Get a validator from the schema.
				Validator validator = schema.newValidator();

				// 4. Check the document
				try {
					validator.validate(xmlSource);
				} catch (SAXException ex) {
					loggerDB.trace("Error during validation: " + ex.getMessage());
					validationMessage = ex.getMessage();
					valid = false;
					throw new IOException(ex.getMessage());
				}
				valid = true;
			} catch (IOException ex1) {
				logger.error("Error during validation: " + ex1.getMessage());
				throw ex1;
			} finally {
				xsdStream.close();
				recreateInputStreamAsFile();
			}
		}

		valid = true;
		if (needSave) {
			File newFile = new File(newLocation);
			if (newFile.exists()) {
				//noinspection ResultOfMethodCallIgnored
				newFile.delete();
			}
			if (!newFile.createNewFile()) {
				logger.error("Cannot create tmp file on local file system");
			} else {
				try {
					recreateInputStreamAsFile();
					FileOutputStream fos = new FileOutputStream(newFile);
					IOUtils.copy(inputStream, fos);
					IOUtils.closeQuietly(fos);
				} catch (Exception e) {
					logger.error("Cannot create tmp file on local file system", e);
				}
			}

			inputStream.close();
			inputStream = new FileInputStream(newFile);
			if (fileObject != null) {
				fileObject.getContent().close();
			}
		}
	}

	private void recreateInputStreamAsFile() throws IOException {
		if (xmlTempFile == null) {
			xmlTempFile = SystemUtils.getTempFile(null);
			FileOutputStream fos = new FileOutputStream(xmlTempFile);
			IOUtils.copy(inputStream, fos);
			IOUtils.closeQuietly(fos);
		}
		IOUtils.closeQuietly(inputStream);
		inputStream = new FileInputStream(xmlTempFile);
	}

	public InputStream getInputStream() {
		return inputStream;
	}

	public void setInputStream(InputStream inputStream) {
		this.inputStream = inputStream;
	}

	public boolean isValid() {
		return valid;
	}

	public String getValidationMessage() {
		return this.validationMessage;
	}
}
