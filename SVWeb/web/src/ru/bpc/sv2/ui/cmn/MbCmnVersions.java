package ru.bpc.sv2.ui.cmn;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.cmn.CmnVersion;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbCmnVersions")
public class MbCmnVersions extends AbstractBean {

	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private CommunicationDao _cmnDao = new CommunicationDao();

	private CmnVersion filter;

	
	private CmnVersion newVersion;

	private final DaoDataModel<CmnVersion> _versionSource;
	private final TableRowSelection<CmnVersion> _itemSelection;

	private CmnVersion _activeVersion;

	private Long standardId;

	public MbCmnVersions() {
		
		_versionSource = new DaoDataModel<CmnVersion>() {
			@Override
			protected CmnVersion[] loadDaoData(SelectionParams params) {
				if (standardId == null) {
					return new CmnVersion[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getCmnVersions(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CmnVersion[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (standardId == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getCmnVersionsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CmnVersion>(null, _versionSource);
	}

	public DaoDataModel<CmnVersion> getVersions() {
		return _versionSource;
	}

	public CmnVersion getActiveVersion() {
		return _activeVersion;
	}

	public void setActiveVersion(CmnVersion activeVersion) {
		_activeVersion = activeVersion;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeVersion = _itemSelection.getSingleSelection();
		if (_activeVersion != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_versionSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeVersion = (CmnVersion) _versionSource.getRowData();
		selection.addKey(_activeVersion.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeVersion != null) {
			setBeans();
		}
	}

	public void setBeans() {
		MbVersionParameters versionsBean = (MbVersionParameters) ManagedBeanWrapper
		        .getManagedBean("MbVersionParameters");
		versionsBean.clearBean();
		versionsBean.setVersion(_activeVersion);
		versionsBean.search();
	}

	public CmnVersion getFilter() {
		if (filter == null) {
			filter = new CmnVersion();
		}
		return filter;
	}

	public void setFilter(CmnVersion filter) {
		this.filter = filter;
	}

	public Long getStandardId() {
		return standardId;
	}

	public void setStandardId(Long standardId) {
		this.standardId = standardId;
	}

	public void search() {
		clearBean();
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new CmnVersion();
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (standardId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("standardId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(standardId.toString());
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
	}

	public void add() {
		newVersion = new CmnVersion();
		newVersion.setLang(userLang);
		newVersion.setStandardId(standardId);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newVersion = (CmnVersion) _activeVersion.clone();
		} catch (CloneNotSupportedException e) {
			newVersion = _activeVersion;
		}
		curMode = EDIT_MODE;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public void delete() {
		try {
			_cmnDao.deleteCmnVersion(userSessionId, _activeVersion);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
			        "version_deleted", "(id = " + _activeVersion.getId() + ")");

			_activeVersion = _itemSelection.removeObjectFromList(_activeVersion);
			if (_activeVersion == null) {
				clearBean();
			} else {
				setBeans();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newVersion = _cmnDao.addCmnVersion(userSessionId, newVersion);
				_itemSelection.addNewObjectToList(newVersion);
			} else {
				newVersion = _cmnDao.editCmnVersion(userSessionId, newVersion);
				_versionSource.replaceObject(_activeVersion, newVersion);
			}
			_activeVersion = newVersion;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
			        "version_saved"));
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public CmnVersion getNewVersion() {
		return newVersion;
	}

	public void setNewVersion(CmnVersion newVersion) {
		this.newVersion = newVersion;
	}

	public void clearBean() {
		_versionSource.flushCache();
		_itemSelection.clearSelection();

		_activeVersion = null;
		curLang = userLang;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeVersion.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			CmnVersion[] versions = _cmnDao.getCmnVersions(userSessionId, params);
			if (versions != null && versions.length > 0) {
				_activeVersion = versions[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newVersion.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newVersion.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			CmnVersion[] versions = _cmnDao.getCmnVersions(userSessionId, params);
			if (versions != null && versions.length > 0) {
				newVersion = versions[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

}
