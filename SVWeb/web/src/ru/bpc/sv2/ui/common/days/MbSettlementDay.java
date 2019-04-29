package ru.bpc.sv2.ui.common.days;

import java.text.SimpleDateFormat;
import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.SettlementDay;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbSettlementDay")
public class MbSettlementDay extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "1035:mainTable";

	private CommonDao _commonDao = new CommonDao();

	private SettlementDay filter;
	private SettlementDay _activeDay;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<SettlementDay> _settlementDaysSource;
	private final TableRowSelection<SettlementDay> _itemSelection;

	public MbSettlementDay() {
		pageLink = "common|settlements";
		_settlementDaysSource = new DaoDataModel<SettlementDay>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected SettlementDay[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new SettlementDay[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getSettlementDays(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new SettlementDay[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getSettlementDaysCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<SettlementDay>(null, _settlementDaysSource);
	}

	public DaoDataModel<SettlementDay> getSettlementDays() {
		return _settlementDaysSource;
	}

	public SettlementDay getActiveDay() {
		return _activeDay;
	}

	public void setActiveDay(SettlementDay activeDay) {
		_activeDay = activeDay;
	}

	public SimpleSelection getItemSelection() {
		if (_activeDay == null && _settlementDaysSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeDay != null && _settlementDaysSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeDay.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeDay = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_settlementDaysSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeDay = (SettlementDay) _settlementDaysSource.getRowData();
		selection.addKey(_activeDay.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeDay != null) {
//			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeDay = _itemSelection.getSingleSelection();
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public SettlementDay getFilter() {
		if (filter == null) {
			filter = new SettlementDay();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(SettlementDay filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (getFilter().getSttlDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sttlDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getSttlDateFrom()));
			filters.add(paramFilter);
		}
		if (getFilter().getSttlDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sttlDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getSttlDateTo()));
			filters.add(paramFilter);
		}
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

	}

	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeDay = null;
		_settlementDaysSource.flushCache();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
