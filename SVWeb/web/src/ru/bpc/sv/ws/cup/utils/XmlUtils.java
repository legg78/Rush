package ru.bpc.sv.ws.cup.utils;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Marshaller;
import javax.xml.bind.Unmarshaller;
import javax.xml.namespace.QName;
import javax.xml.stream.XMLEventReader;
import javax.xml.transform.stream.StreamSource;
import java.io.StringReader;
import java.io.StringWriter;

public class XmlUtils {
	public static String toXMLString(String xmlNamespace, String namespaceObject, Object obj) throws Exception {
		StringWriter sw = null;
		try {
			Marshaller marshaller = JAXBContext.newInstance(obj.getClass()).createMarshaller();
			sw = new StringWriter();
			marshaller.marshal(new JAXBElement(new QName(xmlNamespace, namespaceObject), obj.getClass(), obj), sw);
			return sw.toString();
		} finally {
			if (sw != null) {
				sw.close();
			}
		}
	}

	public static Object toXMLObject(String rawXml, Class objClass) throws Exception {
		StringReader reader = null;
		try {
			Unmarshaller unmarshaller = JAXBContext.newInstance(objClass).createUnmarshaller();
			reader = new StringReader(rawXml);
			JAXBElement obj = unmarshaller.unmarshal(new StreamSource(reader), objClass);
			return obj.getValue();
		} finally {
			if (reader != null) {
				reader.close();
			}
		}
	}

	public static Object toXMLObject(XMLEventReader xmlReader, Class objClass) throws Exception {
		Unmarshaller unmarshaller = JAXBContext.newInstance(objClass).createUnmarshaller();
		JAXBElement obj = unmarshaller.unmarshal(xmlReader, objClass);
		return obj.getValue();
	}
}
