package ru.bpc.sv2.ui.configuration;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import ru.bpc.sv.ws.svng.CamelConfigClient;
import ru.bpc.sv2.configuration.KeyValuePair;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbConvertersConfig")
public class MbConvertersConfig extends AbstractBean {
	private static final long serialVersionUID = 9180917082872879276L;

	private static final Logger logger = Logger.getLogger("SETTINGS");

	private List<KeyValuePair> items;
	private KeyValuePair currentItem;

	private String selectedFile;
	private String currentKey;
	private CamelConfigClient configClient;

	private String configContent;
	private boolean xml = true;

	private List<KeyValuePair> getPairs(String xml) {
		List<KeyValuePair> result = new ArrayList<KeyValuePair>();
		StringReader stringReader = null;
		try {
			DocumentBuilderFactory builderFactory = DocumentBuilderFactory.newInstance();
			DocumentBuilder documentBuilder = builderFactory.newDocumentBuilder();
			InputSource is = new InputSource();
			stringReader = new StringReader(xml);
			is.setCharacterStream(stringReader);
			Document doc = documentBuilder.parse(is);
			doc.getDocumentElement().normalize();
			NodeList nodeList = doc.getElementsByTagName("transfer");
			for (int i = 0; i < nodeList.getLength(); i++) {
				Node node = nodeList.item(i);
				if (node.getNodeType() == Node.ELEMENT_NODE) {
					Element element = (Element) node;
					KeyValuePair pair = new KeyValuePair();
					pair.setKey(element.getElementsByTagName("code").item(0).getTextContent());
					pair.setValue(element.getElementsByTagName("value").item(0).getTextContent());
					result.add(pair);
				}
			}
		} catch (Exception ex) {
			logger.error("Xml parsing error", ex);
		} finally {
			if (stringReader != null) {
				stringReader.close();
			}
		}
		return result;
	}

	public MbConvertersConfig() {
		try {
			SettingsCache settingParamsCache = SettingsCache.getInstance();
			String camelUrl = settingParamsCache.getParameterStringValue(SettingsConstants.APACHE_CAMEL_LOCATION);
			logger.debug("camel location:" + camelUrl);
			configClient = new CamelConfigClient(camelUrl + "/services/config");
		} catch (Exception ex) {
			logger.error("Cannot initiate config client", ex);
			FacesUtils.addMessageError(ex);
		}
	}

	@Override
	public void clearFilter() {

	}

	public KeyValuePair getCurrentItem() {
		return currentItem;
	}

	public List<KeyValuePair> getItems() {
		return items;
	}

	public void load() {
		try {
			if (selectedFile == null) {
				return;
			}
			configContent = configClient.getConfig(selectedFile);
			if (configContent.contains("<transfers>")) {
				items = getPairs(configContent);
				xml = true;
			} else {
				xml = false;
			}
		} catch (Exception ex) {
			logger.error("Service is unavailable", ex);
			FacesUtils.addMessageError("Service is unavailable");
		}
	}

	public String getConfigContent() {
		return configContent;
	}

	public void setConfigContent(String configContent) {
		this.configContent = configContent;
	}

	public void clear() {
		items = null;
		currentKey = null;
		currentItem = null;
		configContent = null;
	}

	public void save() {
		if (xml) {
			XMLOutputFactory factory = XMLOutputFactory.newInstance();
			XMLStreamWriter writer = null;
			try {
				StringWriter sw = new StringWriter();
				writer = factory.createXMLStreamWriter(sw);
				writer.writeStartDocument("UTF-8", "1.0");
				writer.writeStartElement("transfers");
				for (KeyValuePair pair : items) {
					writer.writeStartElement("transfer");
					writer.writeStartElement("code");
					writer.writeCharacters(pair.getKey());
					writer.writeEndElement();
					writer.writeStartElement("value");
					writer.writeCharacters(pair.getValue());
					writer.writeEndElement();
					writer.writeEndElement();
				}
				writer.writeEndElement();
				writer.writeEndDocument();
				writer.flush();
				String content = sw.toString();
				configClient.saveConfig(selectedFile, content);
			} catch (Exception e) {
				logger.error(e);
				FacesUtils.addMessageError(e);
			} finally {
				if (writer != null) {
					try {
						writer.close();
					} catch (Exception ex) {
						logger.error(ex);
						FacesUtils.addMessageError(ex);
					}
				}
			}
		} else {
			try {
				configClient.saveConfig(selectedFile, configContent);
			} catch (Exception ex) {
				logger.error(ex);
				FacesUtils.addMessageError(ex);
			}
		}
		clear();
	}

	public void delete() {
		if (currentKey != null && items != null) {
			for (int i = 0; i < items.size(); i++) {
				if (items.get(i).getKey().equals(currentKey)) {
					items.remove(i);
					return;
				}
			}
		}
	}

	public void add() {
		currentItem = new KeyValuePair();
		items.add(currentItem);
	}

	public void cancel() {
		if (currentItem.getKey() == null) {
			items.remove(currentItem);
		}
		currentItem = null;
	}

	public String getCurrentKey() {
		return currentKey;
	}

	public List<String> getFiles() {
		try {
			return configClient.getFiles();
		} catch (Exception ex) {
			logger.error("Service is unavailable", ex);
			FacesUtils.addMessageError("Service is unavailable");
		}
		return null;
	}

	public String getSelectedFile() {
		return selectedFile;
	}

	public void setCurrentKey(String currentKey) {
		this.currentKey = currentKey;
		for (KeyValuePair pair : items) {
			if (pair.getKey().equals(currentKey)) {
				this.currentItem = pair;
				return;
			}
		}
	}

	public void setSelectedFile(String selectedFile) {
		this.selectedFile = selectedFile;
	}

	public boolean isXml() {
		return xml;
	}
}
