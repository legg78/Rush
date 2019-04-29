package ru.bpc.sv2.ui.common;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.Contact;
import ru.bpc.sv2.common.ContactData;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

@ViewScoped
@ManagedBean (name = "MbContactSearch")
public class MbContactSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao _commonDao = new CommonDao();

	private final DaoDataModel<Contact> _contactSource;
	private Contact _activeContact;
	private Contact filter;
	private Contact newContact;
	private final TableRowSelection<Contact> _itemSelection;
	
	private Long objectId;
	private Long personId;
	private String entityType;
	private String contactType;
	private MbContact contactBean; // related session bean
	private String backLink;
	private boolean showModal;
	private String contactPanelName;

	private List<SelectItem> jobTitles = null;
	private List<SelectItem> contactTypes = null;
	protected MbContactDataSearch contactDataBean;
	
	private String jobTitle;
	
	private static String COMPONENT_ID = "bottomContactsTable";
	private String tabName;
	private String parentSectionId;

	public MbContactSearch() {
		
		contactBean = (MbContact) ManagedBeanWrapper.getManagedBean("MbContact");
		contactDataBean = (MbContactDataSearch) ManagedBeanWrapper.getManagedBean("MbContactDataSearch");
		showModal = false;

		_contactSource = new DaoDataModel<Contact>() {
			@Override
			protected Contact[] loadDaoData(SelectionParams params) {
				try {
					if (objectId != null) {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						Contact[] contacts;
						if (personId != null) {
							contacts = _commonDao.getUserPersonContacts(userSessionId, params, curLang);
						} else {
							contacts = _commonDao.getContacts(userSessionId, params, curLang);
						}
						return contacts;
					}
				} catch (Exception ee) {
					setDataSize(0);
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return new Contact[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					int count = 0;
					if (objectId != null) {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						if (personId != null) {
							count = _commonDao.getUserPersonContactsCount(userSessionId, params, curLang);
						} else {
							count = _commonDao.getContactsCount(userSessionId, params, curLang);
						}
					}
					return count;
				} catch (Exception ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Contact>(null, _contactSource);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		Filter paramFilter = null;
		if (objectId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(objectId.toString());
			filters.add(paramFilter);
		}
		if (personId != null) {
			filters.add(Filter.create("personId", personId));
		}
		if (entityType != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(entityType);
			filters.add(paramFilter);
		}
		if (userLang != null) {
			paramFilter = new Filter();
			paramFilter.setElement("defaultLang");
			paramFilter.setValue(userLang);
			filters.add(paramFilter);
		}
		if (curLang != null) {
			paramFilter = new Filter();
			paramFilter.setElement("currentLang");
			paramFilter.setValue(curLang);
			filters.add(paramFilter);
		}
		if (getFilter().getJobTitle() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("jobTitle");
			paramFilter.setValue(getFilter().getJobTitle());
			filters.add(paramFilter);
		}
		if (getFilter().getContactType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("contactType");
			paramFilter.setValue(getFilter().getContactType());
			filters.add(paramFilter);
		}
		if (getFilter().getType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("type");
			paramFilter.setValue(getFilter().getType());
			filters.add(paramFilter);
		}
		if (getFilter().getAddress() != null && getFilter().getAddress().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("address");
			paramFilter.setValue(getFilter().getAddress().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_") +
					"%");
			filters.add(paramFilter);
		}
	}

	public DaoDataModel<Contact> getContacts() {
		// _contactSource.flushCache();
		return _contactSource;
	}

	public Contact getActiveContact() {
		return _activeContact;
	}

	public void setActiveContact(Contact activeContact) {
		_activeContact = activeContact;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeContact == null && _contactSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeContact != null && _contactSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeContact.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeContact = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addErrorExceptionMessage(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeContact = _itemSelection.getSingleSelection();
		if (_activeContact != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_contactSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeContact = (Contact) _contactSource.getRowData();
		selection.addKey(_activeContact.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}
	
	public void setBeans() {
		if (_activeContact == null) return;
		contactDataBean.setContactId(_activeContact.getId());
		contactDataBean.setInstId(_activeContact.getInstId());
		contactDataBean.search();
	}
	
	public void search() {
		clearBean();
		searching = true;
	}

	public void close() {
		showModal = false;
		curMode = VIEW_MODE;
	}

	public void clearBean() {
		searching = false;
		_activeContact = null;
		_itemSelection.clearSelection();
		_contactSource.flushCache();
		clearBeansState();
	}
	
	public void clearFilter() {
		filter = null;
		clearBean();
	}
	
	public void clearBeansState() {
		if (contactDataBean != null) {
			contactDataBean.clearFilter();
		}
	}

	public void viewContact() {
		curMode = VIEW_MODE;
	}

	public void addContact() {
		newContact = new Contact();
		List<ContactData> datas = new ArrayList<ContactData>(3);
		newContact.setContactData(datas);
		curMode = NEW_MODE;
	}

	public void editContact() {
		try {
			newContact = (Contact) _activeContact.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newContact = _activeContact;
		}
		curMode = EDIT_MODE;
	}

	public void deleteContact() {
		try {
			_commonDao.deleteContact(userSessionId, _activeContact);
			_activeContact = _itemSelection.removeObjectFromList(_activeContact);

			if (_activeContact == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			checkForm();

			if (isEditMode()) {
				newContact = _commonDao.editContact(userSessionId, newContact);
				_contactSource.replaceObject(_activeContact, newContact);
			} else {
				newContact = _commonDao.addContact(userSessionId, newContact, entityType, objectId);
				_itemSelection.addNewObjectToList(newContact);
			}
			showModal = false;
			_activeContact = newContact;
			contactBean.setPersonNeeded(false);
			setBeans();
			
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private static Pattern EMAIL_PATTERN = Pattern.compile(
			"^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[-A-Za-z0-9]+(\\.[-A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$");
	
	private void checkForm() throws Exception {
		if (newContact.getType() == null)
			newContact.setAddress(null);

		if (newContact.getAddress() == null && !isEditMode()) {
			throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
					"contact_for_contact"));
		}
		
		if ("CMNM0002".equals(newContact.getType())){
			Matcher matcher = EMAIL_PATTERN.matcher(newContact.getAddress());
			if (!matcher.matches()){
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "invalid_email", newContact.getAddress());
				throw new UserException(msg);
			}
		}
	}

	public String selectPerson() {
		contactBean.setEntityType(entityType);
		contactBean.setObjectId(objectId);
		contactBean.setPersonId(personId);
		contactBean.setBackLink(backLink);
		contactBean.setPersonNeeded(true);
		contactBean.setCurMode(curMode);
		contactBean.setNewContact(newContact);
		contactBean.setContact(_activeContact);
		
		HashMap<String,Object> queueFilter = new HashMap<String,Object>();
		queueFilter.put("backLink", backLink);
		addFilterToQueue("MbPersonsSearch", queueFilter);

		String link = "selectPerson";
		
		//Menu menu = (Menu) ManagedBeanWrapper
	//			.getManagedBean("menu");
		//menu.getCurrentNode().setName(null);
		
		return link;
	}

	public void setPersonFromPersonBean() {
		MbPerson pers = (MbPerson) ManagedBeanWrapper.getManagedBean("MbPerson");
		if (pers.getPerson().getPersonId() != null) {
			newContact.setPersonId(pers.getPerson().getPersonId());
			newContact.setPerson(pers.getPerson());
		}
	}

	public void changeLang(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_contactSource.flushCache();
	}

	public Long getObjectId() {
		return objectId;
	}

	public void setObjectId(Long objectId) {
		this.objectId = objectId;
	}

	public Long getPersonId() {
		return personId;
	}

	public void setPersonId(Long personId) {
		this.personId = personId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public void fullCleanBean() {
		showModal = false;
		objectId = null;
		personId = null;
		entityType = null;
		contactBean.clearState();
		clearBean();
	}

	public String getContactPanelName() {
		return contactPanelName;
	}

	public String getJobTitle() {
		return jobTitle;
	}

	public void setJobTitle(String jobTitle) {
		this.jobTitle = jobTitle;
	}

	public String getContactType() {
		return contactType;
	}

	public void setContactType(String contactType) {
		this.contactType = contactType;
	}

	public Contact getFilter() {
		if (filter == null)
			filter = new Contact();
		return filter;
	}

	public void setFilter(Contact filter) {
		this.filter = filter;
	}

	public boolean isRenderAdd() {
		if (EntityNames.TERMINAL.equals(entityType) || EntityNames.MERCHANT.equals(entityType) ||
				EntityNames.CARDHOLDER.equals(entityType)) {
			return false;
		}
		return true;
	}

	public boolean isRenderEdit() {
		if (EntityNames.TERMINAL.equals(entityType) || EntityNames.MERCHANT.equals(entityType) ||
				EntityNames.CARDHOLDER.equals(entityType)) {
			return false;
		}
		return true;
	}

	public boolean isRenderDelete() {
		if (EntityNames.TERMINAL.equals(entityType) || EntityNames.MERCHANT.equals(entityType) ||
				EntityNames.CARDHOLDER.equals(entityType)) {
			return false;
		}
		return true;
	}

	public List<SelectItem> getPositions() {
		if (jobTitles == null) {
			jobTitles = getDictUtils().getLov(LovConstants.JOB_TITLES);
		}
		return jobTitles;
	}

	public List<SelectItem> getContactTypes() {
		if (contactTypes == null) {
			contactTypes = getDictUtils().getLov(LovConstants.CONTACT_TYPES);
		}
		return contactTypes;
	}

	public Contact getNewContact() {
		return newContact;
	}

	public void setNewContact(Contact newContact) {
		this.newContact = newContact;
	}

	public void restoreBean() {
		objectId = contactBean.getObjectId();
		personId = contactBean.getPersonId();
		entityType = contactBean.getEntityType();
		_activeContact = contactBean.getContact();
		newContact = contactBean.getNewContact();
		backLink = contactBean.getBackLink();
		contactPanelName = contactBean.getContactPanelName();
		curMode = contactBean.getCurMode();
		if (contactBean.isPersonNeeded()) {
			showModal = true;
			setPersonFromPersonBean();
			// contactBean.setPersonNeeded(false);
		}
		setBeans();
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
	@Override
	public List<SelectItem> getLanguages() {
		if (languages == null) {
			List<SelectItem> languagesList = sortLanguages(getDictUtils().getLov(LovConstants.LANGUAGES));
			languages = new ArrayList<SelectItem>();
			languages.add(new SelectItem("", ""));
			languages.addAll(languagesList);
			
		}		
		return languages;
	}
}
