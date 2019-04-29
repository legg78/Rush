package ru.bpc.sv2.ui.common.application;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.products.Contract;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbContractsModalPanel")
public class MbContractsModalPanel extends AbstractBean {
	private static final Logger logger = Logger.getLogger("APPLICATIONS");
	private ProductsDao _productsDao = new ProductsDao();
	
	private Contract filterContract;
	private List<SelectItem> contractTypes;
	private String applicationType;
	private final TableRowSelection<Contract> _contractsSelection;
	private boolean searchingContract;
	private Contract _activeContract;
	private DaoDataModel<Contract> _contractsSource;
	private List<Filter> filtersContract;
	private boolean blockCustomerNumber;

	private Map<String, Object> paramMaps;
	
	public MbContractsModalPanel(){
		_contractsSource = new DaoDataModel<Contract>() {

			@Override
			protected Contract[] loadDaoData(SelectionParams params) {
				try {
					if (!isSearchingContract()) {
						return new Contract[0];
					}
					
					setFiltersContract();
					params.setFilters(filtersContract.toArray(new Filter[filtersContract.size()]));
					getParamMaps().put("param_tab", filtersContract.toArray(new Filter[filtersContract.size()]));
					getParamMaps().put("tab_name", "CONTRACT");
					return _productsDao.getContractsCur(userSessionId, params, getParamMaps());
				} catch (DataAccessException ee) {
					setDataSize(0);
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				} finally {

				}
				return new Contract[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				try {
					if (!isSearchingContract()) {
						return 0;
					}
					setFiltersContract();
					params.setFilters(filtersContract.toArray(new Filter[filtersContract.size()]));
					getParamMaps().put("param_tab", filtersContract.toArray(new Filter[filtersContract.size()]));
					getParamMaps().put("tab_name", "CONTRACT");
					return _productsDao.getContractsCurCount(userSessionId, params, getParamMaps());
				} catch (DataAccessException ee) {
					FacesUtils.addMessageError(ee);
					logger.error("", ee);
				} finally {

				}
				return 0;
			}
		};
		_contractsSelection = new TableRowSelection<Contract>(null, _contractsSource);
	}
	
	public Contract getFilterContract() {
		if (filterContract == null) {
			filterContract = new Contract();
		}
		return filterContract;
	}
	
	public void setFilterContract(Contract filterContract) {
		this.filterContract = filterContract;
	}
	
	public List<SelectItem> getContractTypes() {
		if (contractTypes == null){
			contractTypes = new ArrayList<SelectItem>(0);
		}
		return contractTypes;
	}
	
	public void updateContractTypes(){
		Map<String, Object> paramMap = new HashMap<String, Object>();
		contractTypes = null;
		if (ApplicationConstants.TYPE_ACQUIRING.equals(applicationType)) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		} else if (ApplicationConstants.TYPE_ISSUING.equals(applicationType)) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		} else {
			return;
		}
		if (getFilterContract().getCustomerType() != null &&
				!getFilterContract().getCustomerType().trim().equals("")) {
			paramMap.put("CUSTOMER_ENTITY_TYPE", getFilterContract().getCustomerType());
		} else {
			return;
		}
		
		contractTypes = getDictUtils().getLov(LovConstants.CONTRACT_TYPES, paramMap);
	}

	public String getApplicationType() {
		return applicationType;
	}

	public void setApplicationType(String applicationType) {
		this.applicationType = applicationType;
	}
	
	public void searchContracts() {
		setSearchingContract(true);
		_contractsSelection.clearSelection();
		_activeContract = null;
		_contractsSource.flushCache();
		updateContractTypes();
	}

	@Override
	public void clearFilter() {
		blockCustomerNumber = false;
		filterContract = null;
	}
	
	public void setSearchingContract(boolean searchingContract) {
		this.searchingContract = searchingContract;
	}
	
	public boolean isSearchingContract() {
		return searchingContract;
	}	
	
	public SimpleSelection getContractsSelection() {
		if (_activeContract == null && _contractsSource.getRowCount() > 0) {
			_contractsSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeContract = (Contract) _contractsSource.getRowData();
			selection.addKey(_activeContract.getModelId());
			_contractsSelection.setWrappedSelection(selection);
		}		
		return _contractsSelection.getWrappedSelection();
	}

	public void setContractsSelection(SimpleSelection selection) {
		_contractsSelection.setWrappedSelection(selection);
		_activeContract = _contractsSelection.getSingleSelection();
	}
	
	public Contract getActiveContract() {
		return _activeContract;
	}

	public void setActiveContract(Contract activeContract) {
		_activeContract = activeContract;
	}
	
	public void setFiltersContract() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = null;
		Contract filter = getFilterContract();
		if (filter.getAccountNumber() != null && !filter.getAccountNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getAccountNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (filter.getCardNumber() != null && !filter.getCardNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getCardNumber().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (filter.getCustomerNumber() != null && !filter.getCustomerNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getCustomerNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (filter.getCustomerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCustomerId().toString());
			filtersList.add(paramFilter);
		}
		if (filter.getContractNumber() != null && !filter.getContractNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getContractNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (filter.getTerminalNumber() != null && !filter.getTerminalNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("TERMINAL_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getTerminalNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (filter.getMerchantNumber() != null && !filter.getMerchantNumber().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getMerchantNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filtersList.add(paramFilter);
		}
		if (filter.getAgentId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("AGENT_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getAgentId().toString());
			filtersList.add(paramFilter);
		}
		if (filter.getContractType() != null && !filter.equals(filter.getContractType())){
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_TYPE");
			paramFilter.setValue(filter.getContractType());
			filtersList.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("PRODUCT_TYPE");
		paramFilter.setOp(Operator.eq);
		if (ApplicationConstants.TYPE_ACQUIRING.equals(applicationType)) {
			paramFilter.setValue(ProductConstants.ACQUIRING_PRODUCT);
		} else {
			paramFilter.setValue(ProductConstants.ISSUING_PRODUCT);
		}
		filtersList.add(paramFilter);

		filtersContract = filtersList;
	}	
	
	public DaoDataModel<Contract> getContracts() {
		return _contractsSource;
	}
	
	public boolean isIssuingType(){
		return ApplicationConstants.TYPE_ISSUING.equals(applicationType);
	}
	
	public boolean isAcquiringType(){
		return ApplicationConstants.TYPE_ACQUIRING.equals(applicationType);
	}

	public boolean isBlockCustomerNumber() {
		return blockCustomerNumber;
	}

	public void setBlockCustomerNumber(boolean blockCustomerNumber) {
		this.blockCustomerNumber = blockCustomerNumber;
	}

	public Map<String, Object> getParamMaps() {
		if (paramMaps == null) {
			paramMaps = new HashMap<String, Object>();
		}
		return paramMaps;
	}
}
