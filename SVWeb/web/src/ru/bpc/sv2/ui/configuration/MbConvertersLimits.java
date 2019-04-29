package ru.bpc.sv2.ui.configuration;

import org.apache.log4j.Logger;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;
import ru.bpc.sv.ws.svng.CamelConfigClient;
import ru.bpc.sv2.configuration.KeyValuePair;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.stream.XMLOutputFactory;
import javax.xml.stream.XMLStreamWriter;
import java.io.StringReader;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbConvertersLimits")
public class MbConvertersLimits extends AbstractBean {
	private static final long serialVersionUID = 9190917082872879276L;
	public static final String SUM_LIMITS_FILE = "%s/transfer_sum_limit_type.xml";
	public static final String COUNT_LIMITS_FILE = "%s/transfer_count_limit_type.xml";

	private List<SelectItem> entityTypes;
	private String entityType;

	private static final Logger logger = Logger.getLogger(MbConvertersLimits.class);

	private List<KeyValuePair> items;
	private KeyValuePair currentItem;

	private String selectedFile;
	private String currentKey;
	private CamelConfigClient configClient;
	private String currentFile;

	private String filterKey;
	private String filterCode;

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

	public String getSumLimitsFile() {
		return SUM_LIMITS_FILE;
	}

	public String getCountLimitsFile() {
		return COUNT_LIMITS_FILE;
	}

	public String getFilterKey() {
		return filterKey;
	}

	public void setFilterKey(String filterKey) {
		this.filterKey = filterKey;
	}

	public String getFilterCode() {
		return filterCode;
	}

	public void setFilterCode(String filterCode) {
		this.filterCode = filterCode;
	}

	public MbConvertersLimits() {
		try {
			SettingsCache settingParamsCache = SettingsCache.getInstance();
			String camelUrl = settingParamsCache.getParameterStringValue(SettingsConstants.APACHE_CAMEL_LOCATION);
			configClient = new CamelConfigClient(camelUrl + "/services/config");
			selectedFile = SUM_LIMITS_FILE;
		} catch (Exception ex) {
			logger.error("Cannot initiate config client", ex);
			FacesUtils.addMessageError(ex);
		}
	}

	@Override
	public void clearFilter() {
		clear();
		filterKey = null;
		filterCode = null;
		load();
	}

	public KeyValuePair getCurrentItem() {
		return currentItem;
	}

	public List<KeyValuePair> getItems() {
		if (items != null) {
			List<KeyValuePair> list = new ArrayList<KeyValuePair>();
			for (KeyValuePair p : items) {
				if (p.isShow()) {
					list.add(p);
				}
			}
			return list;
		}
		return null;
	}

	public void load() {
		try {
			clear();
			if (selectedFile == null) {
				return;
			}
			currentFile = String.format(selectedFile,entityType);
			String configContent = configClient.getConfig(currentFile);
			if (configContent.contains("<transfers>")) {
				items = getPairs(configContent);
				boolean keyFilter = (filterKey != null && !filterKey.trim().isEmpty());
				boolean codeFilter = (filterCode != null && !filterCode.trim().isEmpty());
				if (keyFilter || codeFilter) {
					for (KeyValuePair pair : items) {
						if ((keyFilter && !pair.getKey().equals(filterKey)) ||
								(codeFilter && !pair.getValue().equals(filterCode))) {
							pair.setShow(false);
						}
					}
				}
			} else {
				FacesUtils.addMessageInfo("Not supported file format");
			}
		} catch (Exception ex) {
			logger.error(ex.getMessage(), ex);
			FacesUtils.addMessageError("Service is unavailable: " + ex.getMessage());
		}
	}

	public void clear() {
		items = null;
		currentKey = null;
		currentItem = null;
	}

	public void save() {
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
			configClient.saveConfig(currentFile, content);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		} finally {
			if (writer != null) {
				try {
					writer.close();
				} catch (Exception ex) {
					FacesUtils.addMessageError(ex);
					ex.printStackTrace();
				}
			}
		}
		currentKey = null;
		currentItem = null;
		filterKey = null;
		filterCode = null;
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

	public void createItem() {
		currentItem = new KeyValuePair();
	}

	public void add() {
		if( currentItem != null && items != null) {
			items.add(currentItem);
		}
	}

	public void cancel() {
		if (currentItem != null && currentItem.getKey() != null) {
			if (items != null) {
				items.remove(currentItem);
			}
		}
		currentItem = null;
	}

	public String getCurrentKey() {
		return currentKey;
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

	public List<SelectItem> getEntityTypes(){
		if(entityTypes != null){
			return entityTypes;
		}
		List<SelectItem> tempTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ENTITY_TYPES);
		entityTypes = new ArrayList<SelectItem>();
		for(SelectItem entityType: tempTypes){
			if(entityType.getValue().equals("ENTTACCT")){
				entityType.setValue("dbal");
				entityTypes.add(entityType);
			}else if(entityType.getValue().equals("ENTTCARD")){
				entityType.setValue("cref");
				entityTypes.add(entityType);
			}else if(entityType.getValue().equals("ENTTTRMN")){
				entityType.setValue("term");
				entityTypes.add(entityType);
			}
		}
		return entityTypes;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}
}
