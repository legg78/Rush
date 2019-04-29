package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.TechnicalMessage;
import ru.bpc.sv2.operations.TechnicalMessageDetail;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "mbTechnicalMessageDetails")
public class MbTechnicalMessageDetails extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private OperationDao _oprDao = new OperationDao();

	private TechnicalMessage filter;
	
	private final DaoDataModel<TechnicalMessageDetail> _msgSource;
	private final TableRowSelection<TechnicalMessageDetail> _itemSelection;
	private TechnicalMessageDetail _activeMsg;
	
	private static String COMPONENT_ID = "techMessageDetailsTable";
	private String tabName;
	private String parentSectionId;
	private boolean notemptyValues = false;

	public MbTechnicalMessageDetails() {
		
		
		_msgSource = new DaoDataModel<TechnicalMessageDetail>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected TechnicalMessageDetail[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new TechnicalMessageDetail[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _oprDao.getTechnicalMessageDetails(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new TechnicalMessageDetail[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _oprDao.getTechnicalMessageDetailsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<TechnicalMessageDetail>(null, _msgSource);
	}

	public DaoDataModel<TechnicalMessageDetail> getMsgs() {
		return _msgSource;
	}

	public TechnicalMessageDetail getActiveMsg() {
		return _activeMsg;
	}

	public void setActiveMsg(TechnicalMessageDetail activeMsg) {
		_activeMsg = activeMsg;
	}

	public SimpleSelection getItemSelection() {
		if (_activeMsg == null && _msgSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeMsg != null && _msgSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeMsg.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeMsg = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMsg = _itemSelection.getSingleSelection();

		if (_activeMsg != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_msgSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMsg = (TechnicalMessageDetail) _msgSource.getRowData();
		selection.addKey(_activeMsg.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeMsg != null) {
			setBeans();
		}
	}

	public void setBeans() {

	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		notemptyValues = false;
		filter = new TechnicalMessage();
		clearBean();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter("lang", userLang);
		filters.add(paramFilter);

		if(notemptyValues) {
			paramFilter = new Filter("notemptyValues", notemptyValues);
			filters.add(paramFilter);
		}

		if (filter.getOperId() != null) {
			paramFilter = new Filter("operId", filter.getOperId());
			filters.add(paramFilter);
		}

		if (filter.getTechId() != null) {
			paramFilter = new Filter("techId", filter.getTechId());
			filters.add(paramFilter);
		}

		if (filter.getViewName() != null) {
			paramFilter = new Filter("viewName", filter.getViewName());
			filters.add(paramFilter);
		}
		
	}

	public void add() {
		curMode = NEW_MODE;
	}

	public void edit() {
		curMode = EDIT_MODE;
	}

	public void delete() {
	}

	public void save() {
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public TechnicalMessage getFilter() {
		if (filter == null) {
			filter = new TechnicalMessage();
		}
		return filter;
	}

	public void setFilter(TechnicalMessage filter) {
		this.filter = filter;
	}

	public void clearBean() {
		_msgSource.flushCache();
		_itemSelection.clearSelection();
		_activeMsg = null;
	}

	public Logger getLogger() {
		return logger;
	}

	private TechnicalMessageDetail getCurrentItem2() {
		return (TechnicalMessageDetail) Faces.var("item2");
	}

	public String getLovValue() {
		TechnicalMessageDetail currentItem = getCurrentItem2();
		if (currentItem != null && currentItem.getValue() == null) {
			return null;
		}
		List<SelectItem> lov = getDictUtils().getLov(currentItem.getLovId());
		
		for (SelectItem item : lov) {
			// lov.getValue() != null is redundant, i think, but
			// during development such situations are possible, unfortunately.
			if (item.getValue() != null) {
				if (item.getValue().equals(currentItem.getValue())
						|| (DataTypes.NUMBER.equals(currentItem.getDataType())
								&& currentItem.getValueN() != null && item.getValue().equals(
								String.valueOf(currentItem.getValueN().longValue())))) {
					return item.getLabel();
				}
			}
		}
		return currentItem.getValue().toString();
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

	public boolean isNotEmptyValues() {
		return notemptyValues;
	}

	public void setNotEmptyValues(boolean notemptyValues) {
		this.notemptyValues = notemptyValues;
	}
}
