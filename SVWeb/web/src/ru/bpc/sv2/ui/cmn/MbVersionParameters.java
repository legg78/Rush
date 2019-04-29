package ru.bpc.sv2.ui.cmn;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.cmn.CmnVersion;
import ru.bpc.sv2.cmn.CmnVersionParameter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommunicationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbVersionParameters")
public class MbVersionParameters extends AbstractBean {

	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private CommunicationDao _cmnDao = new CommunicationDao();

	private CmnVersionParameter filter;
	private List<Filter> filters;

	private CmnVersionParameter newParameter;

	private final DaoDataModel<CmnVersionParameter> _paramSource;
	private final TableRowSelection<CmnVersionParameter> _itemSelection;

	private CmnVersionParameter _activeParameter;

	private CmnVersion version;

	public MbVersionParameters() {
		
		_paramSource = new DaoDataModel<CmnVersionParameter>() {
			@Override
			protected CmnVersionParameter[] loadDaoData(SelectionParams params) {
				if (version == null) {
					return new CmnVersionParameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getCmnVersionParameters(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CmnVersionParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (version == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _cmnDao.getCmnVersionParametersCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CmnVersionParameter>(null, _paramSource);
	}

	public DaoDataModel<CmnVersionParameter> getParameters() {
		return _paramSource;
	}

	public CmnVersionParameter getActiveParameter() {
		return _activeParameter;
	}

	public void setActiveParameter(CmnVersionParameter activeParameter) {
		_activeParameter = activeParameter;
	}

	public SimpleSelection getItemSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeParameter = _itemSelection.getSingleSelection();
	}

	public CmnVersionParameter getNewParameter() {
		return newParameter;
	}

	public void setNewParameter(CmnVersionParameter newParameter) {
		this.newParameter = newParameter;
	}

	public SimpleSelection getSelection() {
		return _itemSelection.getWrappedSelection();
	}

	public void setSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeParameter = _itemSelection.getSingleSelection();
	}

	public CmnVersionParameter getFilter() {
		if (filter == null) {
			filter = new CmnVersionParameter();
		}
		return filter;
	}

	public void setFilter(CmnVersionParameter filter) {
		this.filter = filter;
	}

	public CmnVersion getVersion() {
		return version;
	}

	public void setVersion(CmnVersion version) {
		this.version = version;
	}

	public void search() {
		clearBean();
	}

	public void clearFilter() {
		curLang = userLang;
		filter = new CmnVersionParameter();
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (version != null) {
			paramFilter = new Filter();
			paramFilter.setElement("versionId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(version.getId().toString());
			filters.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("standardId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(version.getStandardId().toString());
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

	public void clearBean() {
		_paramSource.flushCache();
		_itemSelection.clearSelection();

		_activeParameter = null;
		curLang = userLang;
	}

	public void add() {
		newParameter = new CmnVersionParameter();
		newParameter.setLang(userLang);
		newParameter.setStandardId(version.getStandardId());
		newParameter.setVersionId(version.getId());
		curMode = NEW_MODE;
	}

	public void delete() {
		try {
			_cmnDao.deleteCmnVersionParameter(userSessionId, _activeParameter);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
			        "version_parameter_deleted", "(id = " + _activeParameter.getId() + ")");

			_activeParameter = _itemSelection.removeObjectFromList(_activeParameter);
			if (_activeParameter == null) {
				clearBean();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			newParameter = _cmnDao.addCmnVersionParameter(userSessionId, newParameter);
			_itemSelection.addNewObjectToList(newParameter);
			_activeParameter = newParameter;
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Cmn",
			        "version_parameter_saved"));
		} catch (Exception e) {
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_paramSource.flushCache();
	}

}
