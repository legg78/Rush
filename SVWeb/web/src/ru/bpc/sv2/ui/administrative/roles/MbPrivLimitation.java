package ru.bpc.sv2.ui.administrative.roles;

import org.ajax4jsf.model.KeepAlive;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acm.PrivLimitation;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbPrivLimitation")
public class MbPrivLimitation extends AbstractBean{
	private AccessManagementDao acmDao = new AccessManagementDao();
	
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");
	
	private final DaoDataModel<PrivLimitation> dataModel;
	private Integer privId;
	
	private static String COMPONENT_ID = "privLimitationTable";
	private String tabName;
	private String parentSectionId;
	private PrivLimitation newPrivLimitation;
	private PrivLimitation _activePrivLimitation;
	private final TableRowSelection<PrivLimitation> _itemSelection;
	protected List<SelectItem> limitationTypes = null;

	public List<SelectItem> getLimitationTypes() {
		if (limitationTypes == null) {
			limitationTypes = getDictUtils().getLov(LovConstants.LIMITATION_TYPES);
		}
		return limitationTypes;
	}

	public void setLimitationTypes(List<SelectItem> limitationTypes) {
		this.limitationTypes = limitationTypes;
	}

	public MbPrivLimitation(){
		dataModel = new DaoDataModel<PrivLimitation>() {
			
			@Override
			protected PrivLimitation[] loadDaoData(SelectionParams params) {
				if (!searching || privId != null){
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters
								.size()]));
						return acmDao.getPrivLimitations(userSessionId, params);
					} catch (DataAccessException e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return new PrivLimitation[0];
			}
			
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || privId != null) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters
								.size()]));
						return acmDao.getPrivLimitationsCount(userSessionId,
								params);
					} catch (DataAccessException e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return 0;
			}

		};
		
		_itemSelection = new TableRowSelection<PrivLimitation>(null, dataModel);
	}
	
	public void search() {
		_activePrivLimitation = null;
		_itemSelection.clearSelection();
		dataModel.flushCache();
	}
	
	private void setFilters(){
		filters = new ArrayList<Filter>();
		Filter filter = new Filter();
		filter.setElement("privId");
		filter.setValue(privId);
		filters.add(filter);
		
		filter = new Filter();
		filter.setElement("lang");
		filter.setValue(userLang);
		filters.add(filter);
	}
	
	private void resetBean(){
		dataModel.flushCache();
	}
	
	public DaoDataModel<PrivLimitation> getDataModel() {
		return dataModel;
	}
	public Integer getPrivId() {
		return privId;
	}
	public void setPrivId(Integer privId) {
		resetBean();
		this.privId = privId;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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
	
	public void add() {
		newPrivLimitation = new PrivLimitation();
		newPrivLimitation.setPrivId(privId);
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newPrivLimitation = (PrivLimitation) _activePrivLimitation.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newPrivLimitation = _activePrivLimitation;
		}
		curMode = EDIT_MODE;
	}


	
	public void save() {
		try {
			if (isEditMode()) {
				newPrivLimitation = acmDao.modifyLimitation(userSessionId, newPrivLimitation);
				dataModel.replaceObject(_activePrivLimitation, newPrivLimitation);
			} else {
				newPrivLimitation = acmDao.addLimitation(userSessionId, newPrivLimitation);
				_itemSelection.addNewObjectToList(newPrivLimitation);
			}
			_activePrivLimitation = newPrivLimitation;

			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void delete() {
		try {
			acmDao.removeLimitation(userSessionId, _activePrivLimitation);
			_activePrivLimitation = _itemSelection.removeObjectFromList(_activePrivLimitation);

			if (_activePrivLimitation == null) {
				clearBean();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void preparePrivLimitationFields() {
		try {
			MbPrivLimitationField privLimitationField = ManagedBeanWrapper.getManagedBean(MbPrivLimitationField.class);
			privLimitationField.setPrivLimitation(getActivePrivLimitation());
			privLimitationField.setSearching(true);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void clearBean() {
		searching = false;
		_activePrivLimitation = null;
		_itemSelection.clearSelection();
		dataModel.flushCache();
	}
	
	public void close() {
		curMode = VIEW_MODE;
	}

	public PrivLimitation getNewPrivLimitation() {
		return newPrivLimitation;
	}

	public void setNewPrivLimitation(PrivLimitation newPrivLimitation) {
		this.newPrivLimitation = newPrivLimitation;
	}

	public PrivLimitation getActivePrivLimitation() {
		return _activePrivLimitation;
	}

	public void setActivePrivLimitation(PrivLimitation activePrivLimitation) {
		this._activePrivLimitation = activePrivLimitation;
	}
	
	public SimpleSelection getItemSelection() {
		if (_activePrivLimitation == null && dataModel.getRowCount() > 0) {
			dataModel.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activePrivLimitation = (PrivLimitation) dataModel.getRowData();
			selection.addKey(_activePrivLimitation.getModelId());
			_itemSelection.setWrappedSelection(selection);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activePrivLimitation = _itemSelection.getSingleSelection();
	}
	
	public void confirmEditLanguage() {
		curLang = newPrivLimitation.getLang();
		PrivLimitation tmp = getNodeByLang(newPrivLimitation.getId(), newPrivLimitation.getLang());
		if (tmp != null) {
			newPrivLimitation.setShortDesc(tmp.getShortDesc());
		}
	}


	public PrivLimitation getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id);
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			PrivLimitation[] privLimits = acmDao.getPrivLimitations(userSessionId, params);
			if (privLimits != null && privLimits.length > 0) {
				return privLimits[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}
}
