package ru.bpc.sv2.ui.security;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import ru.bpc.sv2.logic.SecurityDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.hsm.HsmDevice;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.HsmDao;
import ru.bpc.sv2.security.HmacKey;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.utils.UserException;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbHmacKey")
public class MbHmacKey extends AbstractBean {
	private static final long serialVersionUID = -2893162584283863614L;

	private static final Logger logger = Logger.getLogger("SECURITY");

	private SecurityDao daoSec = new SecurityDao();
	
	private HsmDao hsmDao = new HsmDao();

	private DictUtils dictUtils;

	private HmacKey filter;

	private HmacKey activeItem;

	private final DaoDataModel<HmacKey> dataModel;
	private final TableRowSelection<HmacKey> tableRowSelection;

	private List<SelectItem> entityTypes;

	private HmacKey editingItem;
	
	private static String COMPONENT_ID = "hmacKeyTable";
	private String tabName;
	private String parentSectionId;

	public MbHmacKey() {
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		dataModel = new DaoDataModel<HmacKey>() {
			private static final long serialVersionUID = 8015405366099656094L;

			@Override
			protected HmacKey[] loadDaoData(SelectionParams params) {
				HmacKey[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = daoSec.getHmacKeys(userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new HmacKey[0];
				}
				logger.debug("[MbHmacKey] loadDaoData length: " + result.length);
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = daoSec.getHmacKeysCount(userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = 0;
				}
				logger.debug("[MbHmacKey] loadDaoDataSize: " + result);
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<HmacKey>(null, dataModel);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);

		if (filter.getObjectId() != null){
			f = new Filter();
			f.setElement("objectId");
			f.setValue(filter.getObjectId());
			filters.add(f);
			logger.debug("[MbHmacKey] Filter [objectId: " + filter.getObjectId() + "]");
		}
	
		if (filter.getEntityType() != null){
			f = new Filter();
			f.setElement("entityType");
			f.setValue(filter.getEntityType());
			filters.add(f);
			logger.debug("[MbHmacKey] Filter [entityType]: " + filter.getEntityType() + "]");
		}
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}

	public void clearBeansStates() {

	}

	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public void createNewHmacKey() {
		editingItem = new HmacKey();
		editingItem.setEntityType(getFilter().getEntityType());
		editingItem.setObjectId(getFilter().getObjectId());
		curMode = AbstractBean.NEW_MODE;
	}

	public void editActiveHmacKey() {
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}

	public void saveEditingHmacKey() {
		try {
			editingItem = daoSec.createHmacKey(userSessionId, editingItem);
			
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		tableRowSelection.addNewObjectToList(editingItem);
		activeItem = editingItem;
		resetEditingHmacKey();
	}

	public void resetEditingHmacKey() {
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}

	public void deleteActiveHmacKey() {
		try {
			daoSec.removeHmacKey(userSessionId, activeItem);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
		if (activeItem == null) {
			clearState();
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (HmacKey) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
		if (activeItem != null) {
			setBeansState();
		}
	}

	private void setBeansState() {

	}

	public HmacKey getFilter() {
		if (filter == null) {
			filter = new HmacKey();
		}
		return filter;
	}

	public DaoDataModel<HmacKey> getDataModel() {
		return dataModel;
	}

	public HmacKey getActiveItem() {
		return activeItem;
	}

	public HmacKey getEditingItem() {
		if (editingItem == null){
			editingItem = new HmacKey();
		}
		return editingItem;
	}

	private List<SelectItem> hsms;
	private HashMap<Integer, HsmDevice> hsmsMap;
	
	public List<SelectItem> getHsms(){
		if (hsms == null) {
			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				HsmDevice[] hsmsTmp = hsmDao.getDevices(userSessionId, userLang);
				hsmsMap = new HashMap<Integer, HsmDevice>(hsmsTmp.length);
				for (HsmDevice hsm : hsmsTmp) {
					items.add(new SelectItem(hsm.getId(), hsm.getDescription()));
					hsmsMap.put(hsm.getId(), hsm);
				}
				hsms = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (hsms == null)
					hsms = new ArrayList<SelectItem>();
			}
		}
		return hsms;
	}
	
	public void generateHmacKey(){
		try {
			editingItem = daoSec.generateHmacKey(userSessionId, editingItem);
		} catch (DataAccessException e){
			logger.error(e);
			FacesUtils.addSystemError(e);
			return;
		} catch (UserException e){
			logger.error(e);
			FacesUtils.addMessageError(e);
			return;
		}
		tableRowSelection.addNewObjectToList(editingItem);
		activeItem = editingItem;
		resetEditingHmacKey();
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

}
