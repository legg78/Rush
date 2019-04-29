package ru.bpc.sv2.ui.notifications;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import org.w3c.dom.CharacterData;
import org.w3c.dom.*;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NotificationsDao;
import ru.bpc.sv2.notifications.NotificationMessage;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.transform.Result;
import javax.xml.transform.Source;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import javax.xml.transform.stream.StreamSource;
import javax.xml.xpath.XPath;
import javax.xml.xpath.XPathConstants;
import javax.xml.xpath.XPathExpression;
import javax.xml.xpath.XPathFactory;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;


@ViewScoped
@ManagedBean (name = "MbNotificationMessage")
public class MbNotificationMessage extends AbstractBean{

	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private NotificationMessage filter;
	private NotificationMessage _activeNotification;
	private final DaoDataModel<NotificationMessage> _notificationSource;
	private final TableRowSelection<NotificationMessage> _itemSelection;
	private static final Logger logger = Logger.getLogger("NOTIFICATION");
	private Date dateFrom;
	private Date dateTo;
	private Date deliveryDateFrom;
	private Date deliveryDateTo;
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> eventTypes;
	private ArrayList<SelectItem> channelNames;
	private ArrayList<SelectItem> delivered;
	private Map<String, Object> paramsMap;
	private boolean disable;
	private static final String SMS = "SMS";
	
	private String activeNotificationText;
	
	private NotificationsDao _notificationsDao = new NotificationsDao();
	
	public MbNotificationMessage(){
		_notificationSource = new DaoDataModel<NotificationMessage>() {

			private static final long serialVersionUID = 1L;

			@Override
			protected NotificationMessage[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new NotificationMessage[0];
				}
				try{
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
					NotificationMessage[] result = _notificationsDao.getNotificationMessagesCur(userSessionId, params, paramsMap);
					return result;
					//return _notificationsDao.getNotificationMessages(userSessionId, params);
				}catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new NotificationMessage[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
					int result = _notificationsDao.getNotificationMessagesCountCur(userSessionId, paramsMap);
					return result;
					//return _notificationsDao.getNotificationMEssagesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_itemSelection = new TableRowSelection<NotificationMessage>(null, _notificationSource);
	}
	
	public DaoDataModel<NotificationMessage> getNotifications() {
		return _notificationSource;
	}
	
	private void setFilters() throws Exception{
		getParamsMap().clear();
		getFilter();
		filters = new ArrayList<Filter>();
		
		if (filter.getAccountNumber() != null && 
				filter.getAccountNumber().trim().length() > 0){
			filters.add(new Filter("ACCOUNT_NUMBER", filter.getAccountNumber()));
		}
		
		if (filter.getCardNumber() != null && 
				filter.getCardNumber().trim().length() > 0){
			filters.add(new Filter("CARD_NUMBER", filter.getCardNumber()));
		}
		
		if (getDateFrom() != null){
			filters.add(new Filter("DATE_FROM", getDateFrom()));
		}
		
		if (getDateTo() != null){
			long diff = getDateTo().getTime() - getDateFrom().getTime();
			if (diff / (24 * 60 * 60 * 1000) > 60){
				
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "period_greate_60"));
				
			}
			filters.add(new Filter("DATE_TO", getDateTo()));
		}
		
        if(getDeliveryDateFrom() != null) {
            filters.add(new Filter("DELIVERY_DATE_FROM", getDeliveryDateFrom()));
        }

        if(getDeliveryDateTo() != null) {
            long diff = getDeliveryDateTo().getTime() - getDeliveryDateFrom().getTime();
            if (diff / (24 * 60 * 60 * 1000) > 60){

                throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "period_greate_60"));

            }
            filters.add(new Filter("DELIVERY_DATE_TO", getDeliveryDateTo()));
        }
        
		if (filter.getInstId() != null){
			filters.add(new Filter("INST_ID", filter.getInstId()));
		}
		
		if (filter.getEventType() != null){
			filters.add(new Filter("EVENT_TYPE", filter.getEventType()));
		}
		
		if (filter.getChannelId() != null){
			filters.add(new Filter("CANNEL_ID", filter.getChannelId()));
		}
		
		if (filter.getDelivered() != null){
			filters.add(new Filter("IS_DELIVERED", (filter.getDelivered())?1:0));
		}
		
		if (filter.getUrgencyLevel() != null &&
				filter.getUrgencyLevel().trim().length() > 0){
			filters.add(new Filter("URGENCY_LEVEL", Integer.parseInt(filter.getUrgencyLevel())));
		}
		
		if (filter.getDeliveryAddress() != null &&
				filter.getDeliveryAddress().trim().length() > 0){
			filters.add(new Filter("DELIVERY_ADDRESS", filter.getDeliveryAddress()));
		}
		
	}

	@Override
	public void clearFilter() {
		curLang = userLang;
		clearBean();
		setFilter(null);
		searching = false;
		dateFrom = null;
		dateTo = null;
        deliveryDateFrom = null;
        deliveryDateTo = null;
	}
	
	public void search(){
		curLang = userLang;
		clearBean();
		searching = true;

	}

	public NotificationMessage getFilter() {
		if (filter == null){
			filter = new NotificationMessage();
		}
	
		return filter;
	}

	public void setFilter(NotificationMessage filter) {
		this.filter = filter;
	}
	
	public void clearBean() {
		_notificationSource.flushCache();
		_itemSelection.clearSelection();
		setActiveNotification(null);
	}

	public NotificationMessage getActiveNotification() {
		return _activeNotification;
	}

	public void setActiveNotification(NotificationMessage _activeNotification) {
		this._activeNotification = _activeNotification;
	}
	
	public SimpleSelection getItemSelection() {
		try {
			if (_activeNotification == null && _notificationSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeNotification != null && _notificationSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeNotification.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeNotification = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			_activeNotification = _itemSelection.getSingleSelection();
			
			if(_activeNotification != null){
				parseMessage(_activeNotification);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_notificationSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeNotification = (NotificationMessage) _notificationSource.getRowData();
		selection.addKey(_activeNotification.getModelId());
		_itemSelection.setWrappedSelection(selection);
		
	}

	public Date getDateFrom() {
		if (dateFrom == null){
			dateFrom = new Date();
		}
		return dateFrom;
	}

	public void setDateFrom(Date dateFrom) {
		this.dateFrom = dateFrom;
	}

	public Date getDateTo() {
		return dateTo;
	}

	public void setDateTo(Date dateTo) {
		this.dateTo = dateTo;
	}

    public Date getDeliveryDateFrom() {
        return deliveryDateFrom;
    }

    public void setDeliveryDateFrom(Date deliveryDateFrom) {
        this.deliveryDateFrom = deliveryDateFrom;
    }

    public Date getDeliveryDateTo() {
        return deliveryDateTo;
    }

    public void setDeliveryDateTo(Date deliveryDateTo) {
        this.deliveryDateTo = deliveryDateTo;
    }

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null){
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		return institutions;
	}

	public ArrayList<SelectItem> getChannelNames() {
		if (channelNames == null){
			channelNames = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.CHANNEL_NAMES);
		}
		return channelNames;
	}

	public void setChannelNames(ArrayList<SelectItem> channelNames) {
		this.channelNames = channelNames;
	}

	public ArrayList<SelectItem> getDelivered() {
		if (delivered == null){
			delivered = new ArrayList<SelectItem>();
			delivered.add(new SelectItem(true, FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"yes")));
			delivered.add(new SelectItem(false, FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
					"no")));
		}
		return delivered;
	}

	public void setDelivered(ArrayList<SelectItem> delivered) {
		this.delivered = delivered;
	}

	public Map<String, Object> getParamsMap() {
		if (paramsMap == null){
			paramsMap = new HashMap<String, Object>();
		}
		return paramsMap;
	}

	public void setParamsMap(Map<String, Object> paramsMap) {
		this.paramsMap = paramsMap;
	}

	public ArrayList<SelectItem> getEventTypes() {
			if (filter.getInstId() != null){ 
				Map<String, Object>map = new HashMap<String, Object>();
				map.put("institution_id",filter.getInstId());
				eventTypes = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.NOTIFICATION_EVENT_TYPES, map);
				return eventTypes;
			}
		return new ArrayList<SelectItem>();
	}

	public void setEventTypes(ArrayList<SelectItem> eventTypes) {
		this.eventTypes = eventTypes;
	}
	
	public String getActiveNotificationText() throws Exception{
		return activeNotificationText;
	}
	
	private void parseMessage(NotificationMessage nmsg){
		activeNotificationText = nmsg.getText();
		try{
			switch (nmsg.getChannelId()){
				case 1:	parseMessageMail(nmsg.getText()); 
						break;
				case 3:	parseMessageSMS(nmsg.getText());
			}
		}catch(Exception e){
			
		}
	}

	private void parseMessageSMS(String text) throws Exception {
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		dbf.setNamespaceAware(true);
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document doc = db.parse(new ByteArrayInputStream(text.getBytes("UTF-8")));
		
		
		NodeList templateNodeList = doc.getElementsByTagName("template");
		Node templateNode = templateNodeList.item(0);
		// getting template
		if (templateNode != null && !"".equals(templateNode)) {
			String xslt = getCharacterDataFromElement((Element) templateNode);
			InputStream xsltStream = new ByteArrayInputStream(xslt.getBytes("UTF-8"));
			Source xsltSource = new StreamSource(xsltStream);
			
			NodeList datasourceNodeList = (NodeList) doc.getElementsByTagName("datasource");
			Node datasourceNode = datasourceNodeList.item(0);
			Source xmlSource = new DOMSource(datasourceNode);			
			ByteArrayOutputStream xmlResultStream = new ByteArrayOutputStream();
			Result result = new StreamResult(xmlResultStream);
			TransformerFactory transFact = TransformerFactory.newInstance();
			Transformer trans = transFact.newTransformer(xsltSource);	
			trans.transform(xmlSource, result);		
			activeNotificationText = new String(xmlResultStream.toByteArray(), "UTF-8");
		}
	}
	
	public String getCharacterDataFromElement(Element e) {
		Node child = e.getFirstChild();
		if (child instanceof CharacterData) {
			CharacterData cd = (CharacterData) child;
			return cd.getData();
		}
		return "";
	}
	
	private void parseMessageMail(String text) throws Exception {
		DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
		dbf.setNamespaceAware(true);
		DocumentBuilder db = dbf.newDocumentBuilder();
		Document doc = db.parse(new ByteArrayInputStream(text.getBytes("UTF-8")));

		XPathFactory factory = XPathFactory.newInstance();
		XPath xpath = factory.newXPath();
		// getting template
		XPathExpression expr = xpath.compile("//template");
		Node templateNode = (Node) expr.evaluate(doc, XPathConstants.NODE);
		if (templateNode != null && !"".equals(templateNode)) {
			String xslt = getCharacterDataFromElement((Element) templateNode);
			InputStream xsltStream = new ByteArrayInputStream(xslt.getBytes("UTF-8"));
			Source xsltSource = new StreamSource(xsltStream);

			// getting datasource
			expr = xpath.compile("//datasource");
			Node datasourceNode = (Node) expr.evaluate(doc, XPathConstants.NODE);
			// TODO find out what should be passed here
			Source xmlSource = new DOMSource(datasourceNode);

			ByteArrayOutputStream xmlResultStream = new ByteArrayOutputStream();
			Result result = new StreamResult(xmlResultStream);
			TransformerFactory transFact = TransformerFactory.newInstance();
			Transformer trans = transFact.newTransformer(xsltSource);

			trans.transform(xmlSource, result);
		
			activeNotificationText = new String(xmlResultStream.toByteArray(), "UTF-8");
		}	
	}
	
	public void changeStatus(){
		try{
			Map<String, Object>params = new HashMap<String, Object>();
			params.put("id", _activeNotification.getId());
			params.put("messageStatus", "SGMSRDY");
			params.put("error", false);
			_notificationsDao.changeStatus(userSessionId, params);
			_activeNotification.setMessageStatus("SGMSRDY");;
		}catch (Exception e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public boolean isDisable() {
		if (_activeNotification != null && _activeNotification.getMessageStatus()!=null && !_activeNotification.getMessageStatus().equals("SGMSRDY")){
			disable = false;
		}else{
			disable = true;
		}
		return disable;
	}
}
