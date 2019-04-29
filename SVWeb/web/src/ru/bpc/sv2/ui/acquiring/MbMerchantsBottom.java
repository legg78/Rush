package ru.bpc.sv2.ui.acquiring;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acquiring.Merchant;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbMerchantsBottom")
public class MbMerchantsBottom extends AbstractBean {

	private static final long serialVersionUID = 6987970369772404434L;

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private Merchant merchantFilter;

	private final DaoDataModel<Merchant> _merchantSource;
	private final TableRowSelection<Merchant> _itemSelection;
	private Merchant _activeMerchant;

	private static final Logger logger = Logger.getLogger("ACQUIRING");
	
	private ContextType ctxType;
	private String ctxItemEntityType;
	
	private static String COMPONENT_ID = "merchantsTable";
	private String tabName;
	private String searchTabName;
	private String parentSectionId;
	private HashMap <String, Object> paramMap;

	public MbMerchantsBottom() {
		merchantFilter = new Merchant();
		rowsNum = 50;
		
		_merchantSource = new DaoDataModel<Merchant>() {
			private static final long serialVersionUID = -1062113724460852251L;

			@Override
			protected Merchant[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Merchant[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getMerchantsCur(userSessionId, params, paramMap);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Merchant[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
					return _acquiringDao.getMerchantsCurCount(userSessionId, paramMap);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Merchant>(null, _merchantSource);
	}

	public DaoDataModel<Merchant> getMerchants() {
		return _merchantSource;
	}

	public Merchant getActiveMerchant() {
		return _activeMerchant;
	}

	public void setActiveMerchant(Merchant activeMerchant) {
		_activeMerchant = activeMerchant;
		if (activeMerchant != null) {
			setBeans();
		}
	}

	public SimpleSelection getItemSelection() {
		if (_activeMerchant == null && _merchantSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeMerchant != null && _merchantSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeMerchant.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeMerchant = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMerchant = _itemSelection.getSingleSelection();
		if (_activeMerchant != null) {
			setBeans();
		}

	}

	public void setFirstRowActive() {
		if (_activeMerchant == null && _merchantSource.getRowCount() > 0) {
			_merchantSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeMerchant = (Merchant) _merchantSource.getRowData();
			selection.addKey(_activeMerchant.getModelId());
			_itemSelection.setWrappedSelection(selection);
			if (_activeMerchant != null) {
				setBeans();
			}
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void search() {
		clearState();
		paramMap = new HashMap<String, Object>();
		searching = true;
	}

	public void clearFilter() {
		clearState();
		curLang = userLang;
		merchantFilter = new Merchant();
		searching = false;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeMerchant = null;
		_merchantSource.flushCache();
		
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (merchantFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(merchantFilter.getId());
			filters.add(paramFilter);
		}
		if (merchantFilter.getAccountId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(merchantFilter.getAccountId());
			filters.add(paramFilter);
		}

		if (merchantFilter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(merchantFilter.getInstId());
			filters.add(paramFilter);
		}

		if (merchantFilter.getStatus() != null && merchantFilter.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(merchantFilter.getStatus());
			filters.add(paramFilter);
		}

		if (merchantFilter.getMerchantType() != null
				&& merchantFilter.getMerchantType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_TYPE");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(merchantFilter.getMerchantType());
			filters.add(paramFilter);
		}

		if (merchantFilter.getMerchantNumber() != null 
				&& merchantFilter.getMerchantNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("MERCHANT_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(merchantFilter.getMerchantNumber());
			filters.add(paramFilter);
		}

		if (merchantFilter.getContractId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CONTRACT_ID");
			paramFilter.setValue(merchantFilter.getContractId());
			filters.add(paramFilter);
		}

		if (merchantFilter.getMerchantName() != null 
				&& merchantFilter.getMerchantName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("merchantName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(merchantFilter.getMerchantName());
			filters.add(paramFilter);
		}
		
		if (merchantFilter.getLabel() != null 
				&& merchantFilter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(merchantFilter.getLabel());
			filters.add(paramFilter);
		}
		
		if (merchantFilter.getCustomerNumber() != null 
				&& merchantFilter.getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(merchantFilter.getCustomerNumber());
			filters.add(paramFilter);
		}
		
		if (merchantFilter.getCustomerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(merchantFilter.getCustomerId());
			filters.add(paramFilter);
		}
		
		if (merchantFilter.getCompanyName() != null 
				&& merchantFilter.getCompanyName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("COMPANY_NAME");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(merchantFilter.getCompanyName());
			filters.add(paramFilter);
		}
		
		if (searchTabName != null && searchTabName.trim().length() > 0){
			getParamMap().put("tab_name", getSearchTabName());
		}
	}

	public void resetBean() {
	}

	public Merchant getFilter() {
		if (merchantFilter == null) {
			merchantFilter = new Merchant();
		}
		return merchantFilter;
	}

	public void setFilter(Merchant merchantFilter) {
		this.merchantFilter = merchantFilter;
	}

	public String gotoMerchants() {
		MbMerchant merchBean = (MbMerchant)ManagedBeanWrapper.getManagedBean("MbMerchant");
		Merchant filter = new Merchant();		
		filter.setMerchantNumber(_activeMerchant.getMerchantNumber());
		filter.setInstId(_activeMerchant.getInstId());
		merchBean.setFilter(filter);
		merchBean.setSearching(true);
		return "acquiring|merchants";
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) setCtxItemEntityType();
		Map <String, Object> map = new HashMap<String, Object>();

		if (_activeMerchant != null) {
			if (EntityNames.MERCHANT.equals(ctxItemEntityType)) {
				map.put("id", _activeMerchant.getId());
				map.put("instId", _activeMerchant.getInstId());
				map.put("merchantNumber", _activeMerchant.getMerchantNumber());
				ctxType.setParams(map);
			}
		}
			
		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return true;
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

	public HashMap <String, Object> getParamMap() {
		if(paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(HashMap <String, Object> paramMap) {
		this.paramMap = paramMap;
	}

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}
}
