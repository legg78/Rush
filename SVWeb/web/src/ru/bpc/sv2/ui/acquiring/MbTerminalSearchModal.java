package ru.bpc.sv2.ui.acquiring;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbTerminalSearchModal")
public class MbTerminalSearchModal extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private static final String SEARCH_TAB_CUSTOMER = "terminalTab";

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private Terminal filter;

	

	private final DaoDataModel<Terminal> _terminalsSource;
	private final TableRowSelection<Terminal> _itemSelection;
	private Terminal _activeTerminal;

	private String searchTabName;

	private ArrayList<SelectItem> institutions;

	private String beanName;
	private String methodName;
	private String rerenderList;

	public MbTerminalSearchModal() {
		

		_terminalsSource = new DaoDataModel<Terminal>() {
			@Override
			protected Terminal[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Terminal[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setRowIndexEnd(-1);
					if (isSearchTerminalByTerminal()) {
						return _acquiringDao.getTerminals(userSessionId, params);
					} else {
						return new Terminal[0];
					}
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new Terminal[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					if (isSearchTerminalByTerminal()) {
						return _acquiringDao.getTerminalsCount(userSessionId, params);
					} else {
						// return _productsDao.getTerminalsCount(userSessionId, params, curLang);
						return 0;
					}
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<Terminal>(null, _terminalsSource);

		setSearchTabName(SEARCH_TAB_CUSTOMER);

	}

	public DaoDataModel<Terminal> getTerminals() {
		return _terminalsSource;
	}

	public Terminal getActiveTerminal() {
		return _activeTerminal;
	}

	public void setActiveTerminal(Terminal activeTerminal) {
		_activeTerminal = activeTerminal;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeTerminal == null && _terminalsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeTerminal != null && _terminalsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeTerminal.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeTerminal = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTerminal = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_terminalsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTerminal = (Terminal) _terminalsSource.getRowData();
		selection.addKey(_activeTerminal.getModelId());
		_itemSelection.setWrappedSelection(selection);

	}

	public void setFilters() {
		setFiltersTerminal();
	}

	public void setFiltersTerminal() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getTerminalNumber() != null && filter.getTerminalNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalNumber");
			paramFilter.setValue(filter.getTerminalNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getMerchantNumber() != null && filter.getMerchantNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("merchantNumber");
			paramFilter.setValue(filter.getMerchantNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getMerchantName() != null && filter.getMerchantName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("merchantName");
			paramFilter.setValue(filter.getMerchantName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		if (filter.getContractNumber() != null && filter.getContractNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("contractNumber");
			paramFilter.setValue(filter.getContractNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
	}

	public void setFiltersAddress() {

		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getAddressObj().getCountry() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("country");
			paramFilter.setValue(filter.getAddressObj().getCountry());
			filters.add(paramFilter);
		}
		if (filter.getAddressObj().getCity() != null &&
				filter.getAddressObj().getCity().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("city");
			paramFilter.setValue(filter.getAddressObj().getCity().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddressObj().getStreet() != null &&
				filter.getAddressObj().getStreet().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("street");
			paramFilter.setValue(filter.getAddressObj().getStreet().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddressObj().getHouse() != null &&
				filter.getAddressObj().getHouse().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("house");
			paramFilter.setValue(filter.getAddressObj().getHouse().trim().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getAddressObj().getPostalCode() != null &&
				filter.getAddressObj().getPostalCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("postalCode");
			paramFilter.setValue(filter.getAddressObj().getPostalCode());
			filters.add(paramFilter);
		}
	}

	public Terminal getFilter() {
		if (filter == null) {
			filter = new Terminal();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Terminal filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		searching = false;
	}

	public void searchByTerminal() {
		// getFilter().setEntityType(EntityNames.CUSTOMER);
		search();
	}

	public void searchByAddress() {
		// getFilter().setEntityType(EntityNames.ADDRESS);
		search();
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void clearBean() {
		curLang = userLang;
		_terminalsSource.flushCache();
		_itemSelection.clearSelection();
		_activeTerminal = null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getAgents() {
		if (getFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getFilter().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	private boolean isSearchTerminalByTerminal() {
		// return EntityNames.CUSTOMER.equals(filter.getEntityType());
		return true;
	}

	private boolean isSearchTerminalByAddress() {
		// return EntityNames.ADDRESS.equals(filter.getEntityType());
		return false;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getBeanName() {
		return beanName;
	}

	public void setBeanName(String beanName) {
		this.beanName = beanName;
	}

	public String getRerenderList() {
		return rerenderList;
	}

	public void setRerenderList(String rerenderList) {
		this.rerenderList = rerenderList;
	}

	public String getMethodName() {
		if (methodName == null || "".equals(methodName)) {
			return "selectTerminal";
		}
		return methodName;
	}

	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}

}
