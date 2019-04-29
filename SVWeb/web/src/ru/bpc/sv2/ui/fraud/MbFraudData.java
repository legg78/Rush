package ru.bpc.sv2.ui.fraud;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.fraud.Case;
import ru.bpc.sv2.fraud.FraudData;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbFraudData")
public class MbFraudData extends AbstractBean {
	private static final long serialVersionUID = -8513059557294073207L;

	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");

	private static String COMPONENT_ID = "1821:fraudDataTable";

	private FraudDao _fraudDao = new FraudDao();

	private FraudData filter;
	private FraudData _activeFraudData;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<FraudData> _fraudDataSource;
	private final TableRowSelection<FraudData> _itemSelection;
	
	public MbFraudData() {
		pageLink = "fraud|monitoring";
		_fraudDataSource = new DaoDataModel<FraudData>() {
			private static final long serialVersionUID = 2657173978546970821L;

			@Override
			protected FraudData[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new FraudData[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getFraudData(userSessionId, params, userLang);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new FraudData[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getFraudDataCount(userSessionId, params, userLang);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<FraudData>(null, _fraudDataSource);
	}

	public DaoDataModel<FraudData> getFraudData() {
		return _fraudDataSource;
	}

	public FraudData getActiveFraudData() {
		return _activeFraudData;
	}

	public void setActiveFraudData(FraudData activeFraudData) {
		_activeFraudData = activeFraudData;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeFraudData == null && _fraudDataSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeFraudData != null && _fraudDataSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeFraudData.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeFraudData = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_fraudDataSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeFraudData = (FraudData) _fraudDataSource.getRowData();
		selection.addKey(_activeFraudData.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeFraudData = _itemSelection.getSingleSelection();
		if (_activeFraudData != null) {
			setBeans();
		}
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {
	}

	public void clearBeansStates() {
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public FraudData getFilter() {
		if (filter == null) {
			filter = new FraudData();
		}
		return filter;
	}

	public void setFilter(FraudData filter) {
		this.filter = filter;
	}

	private void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
		
		if (filter.getAuthId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("authId");
			paramFilter.setValue(filter.getAuthId());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getObjectId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("objectId");
			paramFilter.setValue(filter.getObjectId());
			filters.add(paramFilter);
		}
		if (filter.getMsgType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("msgType");
			paramFilter.setValue(filter.getMsgType());
			filters.add(paramFilter);
		}
		if (filter.getOperDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operDateFrom");
			paramFilter.setValue(filter.getOperDateFrom());
			filters.add(paramFilter);
		}
		if (filter.getOperDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operDateTo");
			paramFilter.setValue(filter.getOperDateTo());
			filters.add(paramFilter);
		}
		if (filter.getCardNumber() != null && filter.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardNumber");
			paramFilter.setValue(filter.getCardNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getTerminalNumber() != null && filter.getTerminalNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalNumber");
			paramFilter.setValue(filter.getTerminalNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getMerchantNumber() != null && filter.getMerchantNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("merchantNumber");
			paramFilter.setValue(filter.getMerchantNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getEventType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("eventType");
			paramFilter.setValue(filter.getEventType());
			filters.add(paramFilter);
		}
		if (filter.getSerialNumber() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("serialNumber");
			paramFilter.setValue(filter.getSerialNumber());
			filters.add(paramFilter);
		}
		if (filter.getOperAmount() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operAmount");
			paramFilter.setValue(filter.getOperAmount());
			filters.add(paramFilter);
		}
		if (filter.getOperCurrency() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operCurrency");
			paramFilter.setValue(filter.getOperCurrency());
			filters.add(paramFilter);
		}
		if (filter.getCaseId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("caseId");
			paramFilter.setValue(filter.getCaseId());
			filters.add(paramFilter);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeFraudData = null;
		_fraudDataSource.flushCache();

		clearBeansStates();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.FRAUD_ENTITY_TYPES);
	}

	public List<SelectItem> getEventTypes() {
		return getDictUtils().getLov(LovConstants.FRAUD_EVENT_TYPES);
	}

	public List<SelectItem> getMsgTypes() {
		return getDictUtils().getArticles(DictNames.MSG_TYPE, true);
	}

	public ArrayList<SelectItem> getCases() {
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		
		try {
			Case[] cases = _fraudDao.getCases(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(cases.length);
			
			for (Case frpCase: cases) {
				items.add(new SelectItem(frpCase.getId(), frpCase.getLabel()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
