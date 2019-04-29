package ru.bpc.sv2.ui.fcl.fees;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fcl.fees.FeeType;
import ru.bpc.sv2.fcl.limits.Limit;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FeesDao;
import ru.bpc.sv2.logic.LimitsDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbFeeTypes")
public class MbFeeTypes extends AbstractBean {
	private static final long serialVersionUID = -4937757097217220560L;

	private static final Logger logger = Logger.getLogger("FCL");

	private static String COMPONENT_ID = "1058:feeTypesTable";

	private FeesDao _feesDao = new FeesDao();

	private LimitsDao _limitsDao = new LimitsDao();

	private FeeType filter;

	private boolean _managingNew;
	
	private FeeType newFeeType;

	private FeeType _activeFeeType;
	private final DaoDataModel<FeeType> _feeTypesSource;
	private final TableRowSelection<FeeType> _itemSelection;

	public MbFeeTypes() {
		pageLink = "fcl|fees|list_fee_types";
		_feeTypesSource = new DaoDataModel<FeeType>() {
			private static final long serialVersionUID = 493162907187327066L;

			@Override
			protected FeeType[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new FeeType[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _feesDao.getFeeTypes(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new FeeType[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _feesDao.getFeeTypesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<FeeType>(null, _feeTypesSource);
	}

	public DaoDataModel<FeeType> getFeeTypes() {
		return _feeTypesSource;
	}

	public FeeType getActiveFeeType() {
		return _activeFeeType;
	}

	public void setActiveFeeType(FeeType activeFeeType) {
		_activeFeeType = activeFeeType;
	}

	public SimpleSelection getItemSelection() {
		if (_activeFeeType == null && _feeTypesSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFeeType = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_feeTypesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFeeType = (FeeType) _feeTypesSource.getRowData();
		selection.addKey(_activeFeeType.getModelId());
		_itemSelection.setWrappedSelection(selection);
		// if (_activeFeeType != null) {
		// setBeans();
		// }
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (getFilter().getFeeType() != null && !getFilter().getFeeType().trim().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("feeType");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(DictNames.FEE_TYPE
					+ getFilter().getFeeType().trim().toUpperCase().replaceAll("[*]", "%")
							.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void clearFilter() {
		filter = new FeeType();
		clearBean();
		searching = false;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeFeeType = null;

		_feeTypesSource.flushCache();
	}

	public void createFeeType() {
		newFeeType = new FeeType();
		_managingNew = true;

		// return "open_details";
	}

	public void editFeeType() {
		_managingNew = false;
		try {
			newFeeType = (FeeType) _activeFeeType.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newFeeType = _activeFeeType;
		}
		// return "open_details";
	}

	public void commit() {
		try {
			if (_managingNew) {
				newFeeType.setFeeType(DictNames.FEE_TYPE + newFeeType.getFeeType());
				newFeeType = _feesDao.createFeeType(userSessionId, newFeeType);
				_itemSelection.addNewObjectToList(newFeeType);
			} else {
				newFeeType = _feesDao.updateFeeType(userSessionId, newFeeType);
				_feeTypesSource.replaceObject(_activeFeeType, newFeeType);
			}

			_activeFeeType = newFeeType;
			FacesUtils.addMessageInfo("Fee type with id=\"" + newFeeType.getId() + "\" saved");

			getDictUtils().flush();
		} catch (Exception ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public void deleteFeeType() {
		try {
			_feesDao.deleteFeeType(userSessionId, _activeFeeType);

			FacesUtils.addMessageInfo("Fee type \"" + _activeFeeType.getFeeType()
					+ "\" was deleted");

			_activeFeeType = _itemSelection.removeObjectFromList(_activeFeeType);
			if (_activeFeeType == null) {
				clearBean();
			}

		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	public ArrayList<SelectItem> getLimitTypes() {
		if (newFeeType != null && newFeeType.getEntityType() != null) {
			SelectionParams params = new SelectionParams();
			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("entityType");
			filters[0].setValue(newFeeType.getEntityType());

			params.setFilters(filters);
			try {
				Limit[] limits = _limitsDao.getLimits(userSessionId, params);
				ArrayList<SelectItem> items = new ArrayList<SelectItem>(limits.length);
				for (Limit lim : limits) {
					items.add(new SelectItem(lim.getLimitType(), lim.getDescription()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
				return new ArrayList<SelectItem>(0);
			}
		} else {
			return getDictUtils().getArticles(DictNames.LIMIT_TYPES, true, false);
		}
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.ENTITY_TYPES);
	}

	public ArrayList<SelectItem> getCycleTypes() {
		return getDictUtils().getArticles(DictNames.CYCLE_TYPES, true, false);
	}

	public void cancel() {

	}

	public FeeType getNewFeeType() {
		return newFeeType;
	}

	public void setNewFeeType(FeeType newFeeType) {
		this.newFeeType = newFeeType;
	}

	public FeeType getFilter() {
		if (filter == null) {
			filter = new FeeType();
		}
		return filter;
	}

	public void setFilter(FeeType filter) {
		this.filter = filter;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
