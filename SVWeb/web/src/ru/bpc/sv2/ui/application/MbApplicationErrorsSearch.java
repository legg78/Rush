package ru.bpc.sv2.ui.application;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;

@ViewScoped
@ManagedBean (name = "MbApplicationErrorsSearch")
public class MbApplicationErrorsSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private ApplicationDao _applicationDao = new ApplicationDao();

	private ApplicationElement _activeError;
	DictUtils dictUtils;
	private ApplicationElement filter;

	private final DaoDataModel<ApplicationElement> _appErrorsSource;

	private final TableRowSelection<ApplicationElement> _itemSelection;

	public MbApplicationErrorsSearch() {
		

		_appErrorsSource = new DaoDataModel<ApplicationElement>() {
			@Override
			protected ApplicationElement[] loadDaoData(SelectionParams params) {
				try {
					if (!isSearching()) {
						return new ApplicationElement[0];
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationErrors(userSessionId,
							params);
				} catch (DataAccessException ee) {
					setDataSize(0);
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				} finally {

				}
				return new ApplicationElement[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!isSearching()) {
						return 0;
					}
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationErrorsCount(
							userSessionId, params);
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				} finally {

				}
				return 0;
			}
		};

		if (_activeError != null) {

			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeError.getModelId());
			_itemSelection = new TableRowSelection<ApplicationElement>(
					selection, _appErrorsSource);
			setInfo();
		} else {
			_itemSelection = new TableRowSelection<ApplicationElement>(null,
					_appErrorsSource);
		}
	}

	public DaoDataModel<ApplicationElement> getApplicationErrors() {
		return _appErrorsSource;
	}

	public ApplicationElement getActiveError() {
		return _activeError;
	}

	public void setActiveError(ApplicationElement activeError) {
		_activeError = activeError;
	}

	public SimpleSelection getItemSelection() {
		if (_activeError == null && _appErrorsSource.getRowCount() > 0) {
			_appErrorsSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeError = (ApplicationElement) _appErrorsSource.getRowData();
			selection.addKey(_activeError.getModelId());
			_itemSelection.setWrappedSelection(selection);
			setInfo();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeError = _itemSelection.getSingleSelection();
		setInfo();
	}

	public void setInfo() {
		if (_activeError != null) {

		}
	}

	public ApplicationElement getFilter() {
		if (filter == null)
			filter = new ApplicationElement();
		return filter;
	}

	public void setFilter(ApplicationElement filter) {
		this.filter = filter;
	}

	public void search() {
		setSearching(true);
		_activeError = null;
		_appErrorsSource.flushCache();
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getFilter().getAppId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("appId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getAppId().toString());
			filtersList.add(paramFilter);
		}

		filters = filtersList;
	}

	public void clearBeansState() {

	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		_activeError = null;
		_appErrorsSource.flushCache();
		curLang = userLang;
	}

	@Override
	public void clearFilter() {
		filter = new ApplicationElement();
		clearState();
		searching = false;
	}

}
