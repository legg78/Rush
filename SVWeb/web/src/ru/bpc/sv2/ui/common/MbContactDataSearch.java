package ru.bpc.sv2.ui.common;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.ContactData;
import ru.bpc.sv2.constants.DatePatterns;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.utils.UserException;

@ViewScoped
@ManagedBean (name = "MbContactDataSearch")
public class MbContactDataSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMON");

	private CommonDao _commonDao = new CommonDao();

	private final DaoDataModel<ContactData> _contactDataSource;
	private ContactData _activeContactData;
	private ContactData filter;
	private ContactData newContactData;
	private final TableRowSelection<ContactData> _itemSelection;
	private Integer instId;
	
	private Long contactId;
	
	private List<SelectItem> types = null;
	private boolean activeOnly = true;
	
	private static String COMPONENT_ID = "bottomContactDatasTable";
	private String tabName;
	private String parentSectionId;
	
	public MbContactDataSearch() {
		
		
		_contactDataSource = new DaoDataModel<ContactData>() {
			@Override
			protected ContactData[] loadDaoData(SelectionParams params) {
				try {
					if (!searching || contactId != null) {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						ContactData[] contactDatas = _commonDao.getContactDatas(userSessionId,
								params);
						logger.debug("MbContactDataSearch records received: " + contactDatas.length);
						return contactDatas;
					}
				} catch (Exception ee) {
					setDataSize(0);
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return new ContactData[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					int count = 0;
					if (!searching || contactId != null) {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						count = _commonDao.getContactDatasCount(userSessionId, params);
						logger.debug("MbContactDataSearch received records count: " + count);
					}
					return count;
				} catch (Exception ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ContactData>(null, _contactDataSource);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		Filter paramFilter = null;

		filters.add(new Filter("contactId", contactId));

		if (getFilter().getType() != null) {
			paramFilter = new Filter("type", getFilter().getType());
			filters.add(paramFilter);
		}
		
		if (activeOnly) {
			paramFilter = new Filter("activeOnly", getInstId());
			filters.add(paramFilter);
		}

		if (getFilter().getAddress() != null && getFilter().getAddress().trim().length() > 0) {
			paramFilter = new Filter("address", getFilter().getAddress().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_") +
					"%");
			filters.add(paramFilter);
		}
	}

	public DaoDataModel<ContactData> getContactDatas() {
		// _contactDataSource.flushCache();
		return _contactDataSource;
	}

	public ContactData getActiveContactData() {
		return _activeContactData;
	}

	public void setActiveContactData(ContactData activeContactData) {
		_activeContactData = activeContactData;
	}

	public SimpleSelection getItemSelection() {
		if (_activeContactData == null && _contactDataSource.getRowCount() > 0) {
			_contactDataSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeContactData = (ContactData) _contactDataSource.getRowData();
			selection.addKey(_activeContactData.getModelId());
			_itemSelection.setWrappedSelection(selection);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeContactData = _itemSelection.getSingleSelection();
	}

	public void search() {
		_itemSelection.clearSelection();
		_activeContactData = null;
		_contactDataSource.flushCache();
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void clearBean() {
		searching = false;
		_activeContactData = null;
		_itemSelection.clearSelection();
		_contactDataSource.flushCache();
		clearBeansState();
	}
	
	public void clearFilter() {
		filter = null;
		contactId = null;
		clearBean();
	}
	
	public void clearBeansState() {
		
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public void add() {
		newContactData = new ContactData();
		newContactData.setContactId(contactId);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newContactData = (ContactData) _activeContactData.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newContactData = _activeContactData;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_commonDao.deleteContactData(userSessionId, _activeContactData);
			_activeContactData = _itemSelection.removeObjectFromList(_activeContactData);

			if (_activeContactData == null) {
				clearBean();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private static Pattern EMAIL_PATTERN = Pattern.compile(
			"^[_A-Za-z0-9-]+(\\.[_A-Za-z0-9-]+)*@[-A-Za-z0-9]+(\\.[-A-Za-z0-9]+)*(\\.[A-Za-z]{2,})$");
	
	public void save() {
		try {
			checkForm();
			
			if (isEditMode()) {
				newContactData = _commonDao.modifyContactData(userSessionId, newContactData);
				_contactDataSource.replaceObject(_activeContactData, newContactData);
			} else {
				newContactData = _commonDao.addContactData(userSessionId, newContactData);
				_itemSelection.addNewObjectToList(newContactData);
			}
			_activeContactData = newContactData;

			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	private void checkForm() throws UserException, ParseException{
		Date shortDate = null;
		if (newContactData.getStartDate() == null) {
			Date currentDate = new Date();
			SimpleDateFormat sdf = new SimpleDateFormat();
			sdf.applyPattern(DatePatterns.DATE_PATTERN);
			shortDate = sdf.parse(sdf.format(currentDate));
		} else {
			shortDate = newContactData.getStartDate();
		}
		// deactivation date can't be in the past
		if (newContactData.getEndDate() != null && newContactData.getEndDate().compareTo(shortDate) <= 0) {
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "deactivation_date_before_registration_date");
			throw new UserException(msg);
		}
		
		if ("CMNM0002".equals(newContactData.getType())){
			Matcher matcher = EMAIL_PATTERN.matcher(newContactData.getAddress());
			if (!matcher.matches()){
				String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg", "invalid_email", newContactData.getAddress());
				throw new UserException(msg);
			}
		}
	}

	public Long getContactId() {
		return contactId;
	}

	public void setContactId(Long contactId) {
		this.contactId = contactId;
	}
	
	public void fullCleanBean() {
		contactId = null;
		clearBean();
	}


	public ContactData getFilter() {
		if (filter == null)
			filter = new ContactData();
		return filter;
	}

	public void setFilter(ContactData filter) {
		this.filter = filter;
	}

	public ContactData getNewContactData() {
		return newContactData;
	}

	public void setNewContactData(ContactData newContactData) {
		this.newContactData = newContactData;
	}	
	
	public List<SelectItem> getTypes() {
		if (types == null) {
			types = getDictUtils().getLov(LovConstants.COMMUNICATION_METHODS);
		}
		return types;
	}

	public boolean isActiveOnly() {
		return activeOnly;
	}

	public void setActiveOnly(boolean activeOnly) {
		this.activeOnly = activeOnly;
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

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}
}
