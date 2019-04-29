package ru.bpc.sv2.ui.acquiring;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acquiring.RevenueSharing;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbRevenueSharing")
public class MbRevenueSharing extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACQUIRING");
	// TODO define sectionID
	private static String COMPONENT_ID = "xxx:revenueSharing";
	private static String SCALE_TYPE_REVENUE_SHARING = "SCTPRVSH";

	private AcquiringDao _acquiringDao = new AcquiringDao();
	private ProductsDao _productsDao = new ProductsDao();
	private RulesDao _rulesDao = new RulesDao();

	private RevenueSharing filter;
	private RevenueSharing newRevenueSharing;

	private final DaoDataModel<RevenueSharing> _revenueSharingSource;
	private final TableRowSelection<RevenueSharing> _itemSelection;
	private RevenueSharing _activeRevenueSharing;

	private String tabName;
	private List<SelectItem> institutions;

	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;
	private List<SelectItem> feeTypes;
	private List<SelectItem> providers;
	private List<SelectItem> purposes;
	private List<SelectItem> modifiers;
	private List<SelectItem> fees;
	private List<SelectItem> customerAccounts;

	public MbRevenueSharing() {
		pageLink = "acquiring|revenue_sharing";
		tabName = "detailsTab";

		_revenueSharingSource = new DaoDataModel<RevenueSharing>() {
			@Override
			protected RevenueSharing[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new RevenueSharing[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getRevenueSharings(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new RevenueSharing[0];
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
					return _acquiringDao.getRevenueSharingsCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<RevenueSharing>(null, _revenueSharingSource);
	}

	public DaoDataModel<RevenueSharing> getRevenueSharings() {
		return _revenueSharingSource;
	}

	public RevenueSharing getActiveRevenueSharing() {
		return _activeRevenueSharing;
	}

	public void setActiveRevenueSharing(RevenueSharing activeRevenueSharing) {
		_activeRevenueSharing = activeRevenueSharing;
	}

	public SimpleSelection getItemSelection() {
		if (_activeRevenueSharing == null && _revenueSharingSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeRevenueSharing != null && _revenueSharingSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeRevenueSharing.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeRevenueSharing = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeRevenueSharing = _itemSelection.getSingleSelection();

		if (_activeRevenueSharing != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_revenueSharingSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeRevenueSharing = (RevenueSharing) _revenueSharingSource.getRowData();
		selection.addKey(_activeRevenueSharing.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

		if (getFilter().getCustomerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("customerId");
			paramFilter.setValue(filter.getCustomerId());
			filters.add(paramFilter);
		} else {
			if (getFilter().getCustomerNumber() != null &&
					getFilter().getCustomerNumber().trim().length() > 0) {
				paramFilter = new Filter();
				paramFilter.setElement("customerNumber");
				paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll(
						"[*]", "%").replaceAll("[?]", "_"));
				filters.add(paramFilter);
			}
		}

		if (getFilter().getTerminalId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("terminalId");
			paramFilter.setValue(filter.getTerminalId());
			filters.add(paramFilter);
		} else {
			if (getFilter().getTerminalNumber() != null &&
					getFilter().getTerminalNumber().trim().length() > 0) {
				paramFilter = new Filter();
				paramFilter.setElement("terminalNumber");
				paramFilter.setValue(filter.getTerminalNumber().trim().toUpperCase().replaceAll(
						"[*]", "%").replaceAll("[?]", "_"));
				filters.add(paramFilter);
			}
		}
		if (getFilter().getAccountNumber() != null &&
				getFilter().getAccountNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("accountNumber");
			paramFilter.setCondition("=");
			paramFilter.setValue(filter.getAccountNumber().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || filter.getAccountNumber().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}

	}

	public RevenueSharing getFilter() {
		if (filter == null) {
			filter = new RevenueSharing();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(RevenueSharing filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newRevenueSharing = new RevenueSharing();
		if (getFilter().getInstId() != null) {
			newRevenueSharing.setInstId(filter.getInstId());
		}
		newRevenueSharing.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newRevenueSharing = (RevenueSharing) _activeRevenueSharing.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newRevenueSharing = _activeRevenueSharing;
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_acquiringDao.removeRevenueSharing(userSessionId, _activeRevenueSharing);

			_activeRevenueSharing = _itemSelection.removeObjectFromList(_activeRevenueSharing);
			if (_activeRevenueSharing == null) {
				clearBean();
			} else {
				setBeans();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newRevenueSharing = _acquiringDao.addRevenueSharing(userSessionId, newRevenueSharing);
				_itemSelection.addNewObjectToList(newRevenueSharing);
			} else {
				newRevenueSharing = _acquiringDao.modifyRevenueSharing(userSessionId, newRevenueSharing);
				_revenueSharingSource.replaceObject(_activeRevenueSharing, newRevenueSharing);
			}
			_activeRevenueSharing = newRevenueSharing;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public RevenueSharing getNewRevenueSharing() {
		if (newRevenueSharing == null) {
			newRevenueSharing = new RevenueSharing();
		}
		return newRevenueSharing;
	}

	public void setNewRevenueSharing(RevenueSharing newRevenueSharing) {
		this.newRevenueSharing = newRevenueSharing;
	}

	public void clearBean() {
		curLang = userLang;
		_revenueSharingSource.flushCache();
		_itemSelection.clearSelection();
		_activeRevenueSharing = null;
		loadedTabs.clear();

		clearBeans();
	}

	private void clearBeans() {
		MbAccountPatterns patterns = (MbAccountPatterns) ManagedBeanWrapper
				.getManagedBean("MbAccountPatterns");
		patterns.setFilter(null);
		patterns.clearBean();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;

		Boolean isLoadedCurrentTab = loadedTabs.get(tabName);

		if (isLoadedCurrentTab == null) {
			isLoadedCurrentTab = Boolean.FALSE;
		}

		if (isLoadedCurrentTab.equals(Boolean.TRUE)) {
			return;
		}

		loadTab(tabName);
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (_activeRevenueSharing == null || _activeRevenueSharing.getId() == null) {
			needRerender = tab;
			loadedTabs.put(tab, Boolean.TRUE);

			return;
		}

		if (tab.equalsIgnoreCase("patternsTab")) {

		}
		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}

	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeRevenueSharing.getId().toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			RevenueSharing[] types = _acquiringDao.getRevenueSharings(userSessionId, params);
			if (types != null && types.length > 0) {
				_activeRevenueSharing = types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		return institutions;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public String getSectionId() {
		return SectionIdConstants.REVENUE_SHARING;
	}

	public List<SelectItem> getFeeTypes() {
		if (feeTypes == null) {
			feeTypes = getDictUtils().getLov(LovConstants.FEE_TYPE_FOR_REVENUE_SHARING);
		}
		return feeTypes;
	}
	
	public List<SelectItem> getProviders() {
		if (providers == null) {
			providers = getDictUtils().getLov(LovConstants.PAYMENT_ORDER_PROVIDERS);
		}
		return providers;
	}
	
//	public List<SelectItem> getScales() {
//		if (scales == null) {
//			scales = getDictUtils().getLov(LovConstants.);
//		}
//		return scales;
//	}
//	
	public List<SelectItem> getModifiers() {
		if (modifiers == null) {
			try {
				modifiers = new ArrayList<SelectItem>();
				Modifier[] mods = _rulesDao.getModifiersByScaleType(userSessionId, SCALE_TYPE_REVENUE_SHARING);
				for (Modifier mod: mods) {
					modifiers.add(new SelectItem(mod.getId(), mod.getName()));
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);			
			} finally {
				modifiers = new ArrayList<SelectItem>(0);
			}
		}
		return modifiers;
	}
	
	public List<SelectItem> getFees() {
		if (getNewRevenueSharing().getCustomerId() == null ||
			getNewRevenueSharing().getFeeType() == null ||
			"".equals(getNewRevenueSharing().getFeeType())) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(2);
		params.put("CUSTOMER_ID", getNewRevenueSharing().getCustomerId());
		params.put("FEE_TYPE", getNewRevenueSharing().getFeeType());
		fees = getDictUtils().getLov(LovConstants.REVENUE_SHARING_FEES, params);
		return fees;
	}

	public List<SelectItem> getCustomerAccounts() {
		if (getNewRevenueSharing().getCustomerId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		Map<String, Object> params = new HashMap<String, Object>(1);
		params.put("CUSTOMER_ID", getNewRevenueSharing().getCustomerId());
		customerAccounts = getDictUtils().getLov(LovConstants.CUSTOMER_ACCOUNTS, params);

		return customerAccounts;
	}

	public void showCustomers() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		custBean.clearFilter();
		custBean.setDefaultInstId(getFilter().getInstId());
	}

	public void selectCustomer() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		Customer selected = custBean.getActiveCustomer();
		if (selected != null) {
			getFilter().setCustomerNumber(selected.getCustomerNumber());
			getFilter().setCustomerId(selected.getId());
			getFilter().setCustomerName(selected.getName());
			getFilter().setInstId(selected.getInstId());
		}
	}

	public void selectNewCustomer() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		Customer selected = custBean.getActiveCustomer();
		if (selected != null) {
			getNewRevenueSharing().setCustomerNumber(selected.getCustomerNumber());
			getNewRevenueSharing().setCustomerId(selected.getId());
			getNewRevenueSharing().setCustomerName(selected.getName());
			getNewRevenueSharing().setInstId(selected.getInstId());
		}
	}
	
	public void showTerminals() {
		MbTerminalSearchModal custBean = (MbTerminalSearchModal) ManagedBeanWrapper
				.getManagedBean("MbTerminalSearchModal");
		custBean.clearFilter();
		Terminal filterCustomer = new Terminal();
		filterCustomer.setInstId(getFilter().getInstId());
		custBean.setFilter(filterCustomer);
	}


	public void selectTerminal() {
		MbTerminalSearchModal termBean = (MbTerminalSearchModal) ManagedBeanWrapper
				.getManagedBean("MbTerminalSearchModal");
		Terminal selected = termBean.getActiveTerminal();
		if (selected != null) {
			getFilter().setTerminalNumber(selected.getTerminalNumber());
			getFilter().setTerminalId(selected.getId().longValue());
			getFilter().setTerminalName(selected.getTerminalName());			
		}
	}

	public void selectNewTerminal() {
		MbTerminalSearchModal termBean = (MbTerminalSearchModal) ManagedBeanWrapper
				.getManagedBean("MbTerminalSearchModal");
		Terminal selected = termBean.getActiveTerminal();
		if (selected != null) {
			getNewRevenueSharing().setTerminalNumber(selected.getTerminalNumber());
			getNewRevenueSharing().setTerminalId(selected.getId().longValue());
			getNewRevenueSharing().setTerminalName(selected.getTerminalName());
		}
	}

	public void displayCustInfo() {
		if (getFilter().getCustomerName() == null || "".equals(getFilter().getCustomerName())) {
			getFilter().setCustomerNumber(null);
			getFilter().setCustomerId(null);
			return;
		}

		// process wildcard
		Pattern p = Pattern.compile("\\*|%|\\?");
		Matcher m = p.matcher(getFilter().getCustomerName());
		if (m.find() || getFilter().getInstId() == null) {
			getFilter().setCustomerNumber(getFilter().getCustomerName());
			return;
		}

		// search and redisplay
		Filter[] filters = new Filter[3];
		filters[0] = new Filter("LANG", curLang);
		filters[1] = new Filter("INST_ID", getFilter().getInstId());
		filters[2] = new Filter("CUSTOMER_NUMBER", getFilter().getCustomerName());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] cust = _productsDao.getCombinedCustomersProc(userSessionId, params,
					"CUSTOMER");
			if (cust != null && cust.length > 0) {
				getFilter().setCustomerName(cust[0].getName());
				getFilter().setCustomerNumber(cust[0].getCustomerNumber());
				getFilter().setCustomerId(cust[0].getId());
			} else {
				getFilter().setCustomerNumber(getFilter().getCustomerName());
				getFilter().setCustomerId(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void displayTerminalInfo() {
		// process wildcard
		Pattern p = Pattern.compile("\\*|%|\\?");
		Matcher m = p.matcher(getFilter().getTerminalName());
		if (m.find()) {
			getFilter().setTerminalNumber(getFilter().getTerminalName());
			return;
		}

		// search and redisplay
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("terminalNumber");
		filters[0].setValue(getFilter().getTerminalName());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Terminal[] term = _acquiringDao.getTerminals(userSessionId, params);
			if (term != null && term.length > 0) {
				getFilter().setTerminalName(term[0].getTerminalName());
				getFilter().setTerminalNumber(term[0].getTerminalNumber());
				getFilter().setTerminalId(term[0].getId().longValue());
			} else {
				getFilter().setTerminalNumber(getFilter().getTerminalName());
				getFilter().setTerminalId(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

}
