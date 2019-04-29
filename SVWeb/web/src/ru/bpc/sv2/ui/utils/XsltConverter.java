package ru.bpc.sv2.ui.utils;

import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.OutputStream;
import java.io.StringReader;
import java.io.StringWriter;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;

import org.w3c.dom.Node;

public class XsltConverter {
	public static void convertFromNodes(Node template, Node xml, OutputStream out, String savePath)
			throws Exception {
		StringReader reader = new StringReader(nodeToString(xml));
		javax.xml.transform.Result result = null;
		FileOutputStream fos = null;
		FileInputStream fis = null;
		try {
			if (savePath == null) {
				result = new javax.xml.transform.stream.StreamResult(out);
			} else {
				fos = new FileOutputStream(savePath);
				result = new javax.xml.transform.stream.StreamResult(fos);
			}
	
			TransformerFactory tFactory = TransformerFactory.newInstance();
			Transformer transformer = tFactory
					.newTransformer(new javax.xml.transform.stream.StreamSource(new StringReader(
							template.getTextContent())));
			transformer.transform(new javax.xml.transform.stream.StreamSource(reader), result);
			
			if (savePath != null) {
				fis = new FileInputStream(savePath);
				byte[] buf = new byte[1024];
				int len;
				while ((len = fis.read(buf)) > 0){
					out.write(buf, 0, len);
				}
			}
		} catch (Exception e) {
			throw e;
		} finally {
			if (fos != null) {
				try {
					fos.close();
				} catch (Exception e) {
				}
			}
			if (fis != null) {
				try {
					fis.close();
				} catch (Exception e) {
				}
			}
		}
	}

	private static String nodeToString(Node node) throws TransformerException {
		StringWriter sw = new StringWriter();
		Transformer t = TransformerFactory.newInstance().newTransformer();
		t.setOutputProperty(OutputKeys.OMIT_XML_DECLARATION, "yes");
		t.transform(new DOMSource(node), new StreamResult(sw));
		return sw.toString();
	}
}
