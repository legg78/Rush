package ru.bpc.sv2.ui.emv;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;


import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.emv.EmvCardInstance;
import ru.bpc.sv2.emv.EmvObjectScript;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.EmvDao;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.products.Customer;
import ru.bpc.sv2.ui.products.MbCustomerSearchModal;
import ru.bpc.sv2.ui.utils.*;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbEmvCardInstances")
@SuppressWarnings("serial")
public class MbEmvCardInstances extends AbstractBean{
	private static final Logger logger = Logger.getLogger("EMV");
	private EmvDao emvDao = new EmvDao();
	
	private DictUtils dictUtils;
	private List<SelectItem> institutions = null;
	private List<SelectItem> emvApplicationTypes = null;
	
	private EmvCardInstance filter;
	private EmvCardInstance activeItem;
	
	private final DaoDataModel<EmvCardInstance> dataModel;
	private final TableRowSelection<EmvCardInstance> tableRowSelection;
	
	private static final String SCRIPT_TAB = "scriptTab";
	private String tabName = SCRIPT_TAB;
	private String lang;
	
	private MbEmvObjectScript scriptBean;
	
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;
	private String timeZone;
	
	private IssuingDao _issuingDao = new IssuingDao();
	
	private ProductsDao _productsDao = new ProductsDao();

	
	public MbEmvCardInstances(){
		pageLink = "emv|cardInstances";
		scriptBean =  (MbEmvObjectScript) ManagedBeanWrapper
				.getManagedBean("MbEmvObjectScript");
		dataModel = new DaoDataModel<EmvCardInstance>(){

			@Override
			protected EmvCardInstance[] loadDaoData(SelectionParams params) {
				EmvCardInstance[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getCartInstance(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);
					}
				} else {
					result = new EmvCardInstance[0];
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				setTabName(tabName);
				int result = 0;
				if (searching){
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try{
						result = emvDao.getCartInstanceCount(userSessionId, params);
					}catch (DataAccessException e){
			    		FacesUtils.addMessageError(e);
    					logger.error("", e);						
					}
				} else {
					result = 0;
				}
				return result;
			}
			
		};
		tableRowSelection = new TableRowSelection<EmvCardInstance>(null, dataModel);
	}
	
	private void setFilters() {
		
		filters = new ArrayList<Filter>();
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getInstId() != null){
			f = new Filter("instId", filter.getInstId());			
			filters.add(f);
		}
		
/*		if (filter.getCardMask() != null && filter.getCardMask().trim().length() > 0){
			f = new Filter("cardMask", filter.getCardMask());
			filters.add(f);
		}
*/		
		if (filter.getCardNumber() != null && filter.getCardNumber().trim().length() > 0){
			String filterValue = filter.getCardNumber();
			Filter filter = null;
			if (filterValue.indexOf("*") >= 0 || filterValue.indexOf("?") >= 0){
				String mask = filterValue.trim().replaceAll("[*]", "%").replaceAll("[?]",
						"_").toUpperCase();
				filter = new Filter("cardMask", mask);
				filter.setCondition("like");
			} else {
				filter = new Filter("cardNumber", filterValue);
				filter.setCondition("=");
			}
			filters.add(filter);
		}
		
		if (getFilter().getCustomerNumber() != null &&
				getFilter().getCustomerNumber().trim().length() > 0) {
			f = new Filter();
			f.setElement("customerNumber");
			f.setCondition("=");
			f.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			if (((String)f.getValue()).indexOf("%") != -1 || filter.getCustomerNumber().indexOf("?") != -1) {
				f.setCondition("like");
			}
			filters.add(f);
		}
		
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);
		if (getFilter().getExpirDate() != null) {
			f = new Filter();
			f.setElement("expirDate");
			f.setOp(Operator.eq);
			f.setValue(df.format(getFilter().getExpirDate()));
			filters.add(f);
		}
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("id");
		f.setValue(activeItem.getId());
		filters.add(f);

		f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			EmvCardInstance[] applications = emvDao.getCartInstance(userSessionId, params);
			if (applications != null && applications.length > 0) {
				activeItem = applications[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void search() {
		clearState();
		searching = true;
	}
	
	public void clearBeansStates(){
		scriptBean.clearFilter();
	}
	
	public EmvCardInstance getFilter() {
		if (filter == null) {
			filter = new EmvCardInstance();
		}
		return filter;
	}
	
	public List<SelectItem> getInstitutions(){
		if (institutions == null) {
			institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		
		return institutions;
		
	}
	

	public String getTabName() {
		return tabName;
	}
	
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("scriptTab")) { 
			scriptBean.setTabName(tabName);
			scriptBean.setParentSectionId(getSectionId());
			scriptBean.setTableState(getSateFromDB(scriptBean.getComponentId()));
		} 
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_EMV_CARD;
	}
	
	@Override
	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
		
	}
	
	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
		clearBeansStates();
	}
	
	public DaoDataModel<EmvCardInstance> getDataModel(){
		return dataModel;
	}
	
	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			setFirstRowActive();
		} else if (activeItem != null && dataModel.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			tableRowSelection.setWrappedSelection(selection);
			activeItem = tableRowSelection.getSingleSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}
 	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();

		if (activeItem != null) {
			setBeansState();
		}
	}

	public void setFirstRowActive() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (EmvCardInstance) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}
	
	
	private void setBeansState(){
		scriptBean =  (MbEmvObjectScript) ManagedBeanWrapper
				.getManagedBean("MbEmvObjectScript");
		EmvObjectScript script = new  EmvObjectScript();
		script.setObjectId(activeItem.getId());
		script.setEntityType(EntityNames.CARD_INSTANCE);
		scriptBean.setFilter(script);
		scriptBean.search();
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (activeItem == null || activeItem.getId() == null)
			return;

		if (tab.equalsIgnoreCase("scriptTab")) { 

		
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
	
	public MbEmvObjectScript getScriptBean(){
		return scriptBean;
	}
	

	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
	}
	
	public EmvCardInstance getActiveItem(){
		return activeItem;
	}

	public String getLang() {
		return lang;
	}

	public void setLang(String lang) {
		this.lang = lang;
	}
	
	public List<SelectItem> getEmvApplicationTypes() {
		if (emvApplicationTypes == null) {
			emvApplicationTypes = getDictUtils().getLov(LovConstants.EMV_SCHEME_IDS);
		}
		return emvApplicationTypes;
	}
	
	public void viewCardNumber() {
		try {
			// just for audit
			_issuingDao.viewCardNumber(userSessionId, activeItem != null ? activeItem.getCardId() : 0L);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}
	
	public void showCustomers() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		custBean.clearFilter();
		if (getFilter().getInstId() != null) {
			custBean.setBlockInstId(true);
			custBean.setDefaultInstId(getFilter().getInstId());
		} else {
			custBean.setBlockInstId(false);
		}
	}
	
	public void selectCustomer() {
		MbCustomerSearchModal custBean = (MbCustomerSearchModal) ManagedBeanWrapper
				.getManagedBean("MbCustomerSearchModal");
		Customer selected = custBean.getActiveCustomer();
		if (selected != null) {
			getFilter().setCustomerNumber(selected.getCustomerNumber());
			getFilter().setInstId(custBean.getFilter().getInstId());
			getFilter().setCustomerId(selected.getId());
			getFilter().setCustInfo(selected.getName());
		}
	}
	
	public void displayCustInfo() {

		if (getFilter().getCustInfo() == null || "".equals(getFilter().getCustInfo())) {
			getFilter().setCustomerNumber(null);
			getFilter().setCustomerId(null);
			return;
		}

		// process wildcard
		Pattern p = Pattern.compile("\\*|%|\\?");
		Matcher m = p.matcher(getFilter().getCustInfo());
		if (m.find() || getFilter().getInstId() == null) {
			getFilter().setCustomerNumber(getFilter().getCustInfo());
			return;
		}

		// search and redisplay
		Filter[] filters = new Filter[3];
		filters[0] = new Filter("LANG", curLang);
		filters[1] = new Filter("INST_ID", getFilter().getInstId());
		filters[2] = new Filter("CUSTOMER_NUMBER", getFilter().getCustInfo());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Customer[] cust = _productsDao.getCombinedCustomersProc(userSessionId, params,
					"CUSTOMER");
			if (cust != null && cust.length > 0) {
				getFilter().setCustInfo(cust[0].getName());
				getFilter().setCustomerNumber(cust[0].getCustomerNumber());
				getFilter().setCustomerId(cust[0].getId());
			} else {
				getFilter().setCustomerNumber(getFilter().getCustInfo());
				getFilter().setCustomerId(null);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

}
