package ru.bpc.sv2.ui.accounts;

import java.util.*;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.accounts.AccTypeModifier;
import ru.bpc.sv2.accounts.EntryTemplatePair;
import ru.bpc.sv2.audit.EntityType;
import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccountsDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbEntryTemplates")
public class MbEntryTemplates extends AbstractBean{
	private AccountsDao _accountsDao = new AccountsDao();
	private CommonDao _commonDao = new CommonDao();

	public static final String DEBIT = "Debit";
	public static final String CREDIT = "Credit";
	public static final int ADDED = 1;
	public static final int SKIPPED = 0;

	private boolean resultOK;
	private HashMap<String, EntityType> entityTypes;
	private EntryTemplatePair entryTemplateFilter;
	private EntryTemplatePair _activeEntryTemplatePair;
	private Integer bunchTypeId;
	private String bunchTypeName;
	private EntryTemplatePair newEntryTemplatePair;

	private ArrayList<SelectItem> accountPurposes;
	private ArrayList<SelectItem> amountTypes;
	private ArrayList<SelectItem> datePurposes;

	private final DaoDataModel<EntryTemplatePair> _entryTemplatePairSource;

	private final TableRowSelection<EntryTemplatePair> _itemSelection;
	private static final Logger logger = Logger.getLogger("ACCOUNTING");

	public MbEntryTemplates() {
		

		_entryTemplatePairSource = new DaoDataModel<EntryTemplatePair>() {
			@Override
			protected EntryTemplatePair[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new EntryTemplatePair[0];

				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					EntryTemplatePair[] result = _accountsDao.getEntryTemplatePairs(userSessionId, params);
					result = groupBy(result);
					setDataSize(result.length);
					return result;
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new EntryTemplatePair[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _accountsDao.getEntryTemplatePairsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<EntryTemplatePair>(null, _entryTemplatePairSource);
	}

	public DaoDataModel<EntryTemplatePair> getEntryTemplatePairs() {
		return _entryTemplatePairSource;
	}

	public EntryTemplatePair getActiveEntryTemplatePair() {
		return _activeEntryTemplatePair;
	}

	public void setActiveEntryTemplatePair(EntryTemplatePair activeEntryTemplate) {
		_activeEntryTemplatePair = activeEntryTemplate;
	}

	public SimpleSelection getItemSelection() {
		if (_activeEntryTemplatePair == null && _entryTemplatePairSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeEntryTemplatePair != null && _entryTemplatePairSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeEntryTemplatePair.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeEntryTemplatePair = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeEntryTemplatePair = _itemSelection.getSingleSelection();

		if (_activeEntryTemplatePair != null) {
		}
	}

	public void setFirstRowActive() {
		_entryTemplatePairSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeEntryTemplatePair = (EntryTemplatePair) _entryTemplatePairSource.getRowData();
		selection.addKey(_activeEntryTemplatePair.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	private void setFilters() {
		entryTemplateFilter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = null;
		filters = new ArrayList<Filter>();
		paramFilter = new Filter();
		paramFilter.setElement("bunchTypeId");
		paramFilter.setValue(bunchTypeId);
		filters.add(paramFilter);

		if (entryTemplateFilter.getTransactionType() != null
				&& entryTemplateFilter.getTransactionType().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("transType");
			paramFilter.setValue(entryTemplateFilter.getTransactionType());
			filters.add(paramFilter);
		}

		if (entryTemplateFilter.getTransactionNum() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("transNum");
			paramFilter.setValue(entryTemplateFilter.getTransactionNum());
			filters.add(paramFilter);
		}
	}

	public EntryTemplatePair getFilter() {
		if (entryTemplateFilter == null)
			entryTemplateFilter = new EntryTemplatePair();
		return entryTemplateFilter;
	}

	public void setFilter(EntryTemplatePair filter) {
		this.entryTemplateFilter = filter;
	}

	public void add() {
		newEntryTemplatePair = new EntryTemplatePair();
		newEntryTemplatePair.setBunchTypeId(bunchTypeId);
		newEntryTemplatePair.setCreditBalanceImpact(1);
		newEntryTemplatePair.setDebitBalanceImpact(-1);

		newEntryTemplatePair.setEditDebit(true);
		newEntryTemplatePair.setEditCredit(true);
		
		MbAccTypeModifier crdAccTypeModBean = (MbAccTypeModifier) ManagedBeanWrapper.getManagedBean("MbAccTypeModifier");
		crdAccTypeModBean.clearFilter();
		
		MbAccTypeModifier dbtAccTypeModBean = (MbAccTypeModifier) ManagedBeanWrapper.getManagedBean("MbDbtAccTypeModifier");
		dbtAccTypeModBean.clearFilter();

		curMode = NEW_MODE;
	}

	public void view() {

	}

	public void edit() {
		try {
			newEntryTemplatePair = _activeEntryTemplatePair.clone();
		} catch (CloneNotSupportedException e) {
			newEntryTemplatePair = _activeEntryTemplatePair;
		}
		if (newEntryTemplatePair.getDebitId() != null)
			newEntryTemplatePair.setEditDebit(true);
		if (newEntryTemplatePair.getCreditId() != null)
			newEntryTemplatePair.setEditCredit(true);

		MbAccTypeModifier crdAccTypeModBean = (MbAccTypeModifier) ManagedBeanWrapper.getManagedBean("MbAccTypeModifier");
		crdAccTypeModBean.clearFilter();
		crdAccTypeModBean.addAccTypeMods(newEntryTemplatePair.getCreditAccTypeModifiers());

		MbAccTypeModifier dbtAccTypeModBean = (MbAccTypeModifier) ManagedBeanWrapper.getManagedBean("MbDbtAccTypeModifier");
		dbtAccTypeModBean.clearFilter();
		dbtAccTypeModBean.addAccTypeMods(newEntryTemplatePair.getDebitAccTypeModifiers());
		
		curMode = EDIT_MODE;
	}

	public void save() {
		if (!newEntryTemplatePair.isEditCredit() && !newEntryTemplatePair.isEditDebit()) {
			FacesUtils.addMessageError(new Exception(
					"Debit or credit or both must be checked."));
			return;
		}
		if (!checkFields()) {
			FacesUtils.addMessageError(new Exception(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Msg", "fill_all_mandatories")));
			return;
		}
		try {
			if (isEditMode()) {
				newEntryTemplatePair = _accountsDao.editEntryTemplatePair(userSessionId,
						newEntryTemplatePair);
				saveRefMod();
				_entryTemplatePairSource.replaceObject(_activeEntryTemplatePair,
						newEntryTemplatePair);
			} else {
				newEntryTemplatePair = _accountsDao.addEntryTemplatePair(userSessionId,
						newEntryTemplatePair);
				saveRefMod();
				_itemSelection.addNewObjectToList(newEntryTemplatePair);
			}
			curMode = VIEW_MODE;
			_activeEntryTemplatePair = newEntryTemplatePair;
			resultOK = true;
			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acc",
					"entry_set_saved"));
		} catch (Exception e) {
			resultOK = false;
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}
	
	public void saveRefMod() throws CloneNotSupportedException{
		MbAccTypeModifier crdAccTypeModBean = (MbAccTypeModifier) ManagedBeanWrapper.getManagedBean("MbAccTypeModifier");
		List<AccTypeModifier> accTypeModifiers;
		List<Integer> removeAccTypeMods;
		EntryTemplatePair newEntryTemplateMod = newEntryTemplatePair.clone();
		newEntryTemplateMod.setEditCredit(true);
		newEntryTemplateMod.setEditDebit(false);
		newEntryTemplateMod.setDebitId(null);;
		if(crdAccTypeModBean.getRemovedAccTypeMod().size()>0){
			removeAccTypeMods = crdAccTypeModBean.getRemovedAccTypeMod();
			for(Integer removeAccTypeMod:removeAccTypeMods){
				newEntryTemplateMod.setCreditId(removeAccTypeMod);
				_accountsDao.removeEntryTemplatePair(userSessionId, newEntryTemplateMod);
			}
		}
		if(crdAccTypeModBean.getAddedAccTypeMod().values().size()>0){
			accTypeModifiers = new ArrayList<AccTypeModifier>(crdAccTypeModBean.getAddedAccTypeMod().values());
			for(AccTypeModifier accTypeModifier:accTypeModifiers){
				if(accTypeModifier.getAccountType()==null || accTypeModifier.getModId()==null){
					continue;
				}
				newEntryTemplateMod.setCreditDestAccountType(accTypeModifier.getAccountType());
				newEntryTemplateMod.setCreditModId(accTypeModifier.getModId());
				newEntryTemplateMod.setCreditId(null);
				 _accountsDao.editEntryTemplatePair(userSessionId, newEntryTemplateMod);
			}
		}
		newEntryTemplatePair.getCreditAccTypeModifiers().addAll(crdAccTypeModBean.getStoredAccTypeMod());
		newEntryTemplateMod.setEditCredit(false);
		newEntryTemplateMod.setCreditId(null);;
		newEntryTemplateMod.setEditDebit(true);
		MbAccTypeModifier dbtAccTypeModBean = (MbAccTypeModifier) ManagedBeanWrapper.getManagedBean("MbDbtAccTypeModifier");
		if(dbtAccTypeModBean.getRemovedAccTypeMod().size()>0){
			removeAccTypeMods = dbtAccTypeModBean.getRemovedAccTypeMod();
			for(Integer removeAccTypeMod:removeAccTypeMods){
				newEntryTemplateMod.setDebitId(removeAccTypeMod);
				_accountsDao.removeEntryTemplatePair(userSessionId, newEntryTemplateMod);
			}
		}
		if(dbtAccTypeModBean.getAddedAccTypeMod().values().size()>0){
			accTypeModifiers = new ArrayList<AccTypeModifier>(dbtAccTypeModBean.getAddedAccTypeMod().values());
			for(AccTypeModifier accTypeModifier:accTypeModifiers){
				if(accTypeModifier.getAccountType()==null || accTypeModifier.getModId()==null){
					continue;
				}
				newEntryTemplateMod.setDebitDestAccountType(accTypeModifier.getAccountType());
				newEntryTemplateMod.setDebitModId(accTypeModifier.getModId());
				newEntryTemplateMod.setDebitId(null);
				_accountsDao.editEntryTemplatePair(userSessionId, newEntryTemplateMod);
			}
		}
		newEntryTemplatePair.getDebitAccTypeModifiers().addAll(dbtAccTypeModBean.getStoredAccTypeMod());
	}

	public void delete() {
		try {
			_accountsDao.removeEntryTemplatePair(userSessionId, _activeEntryTemplatePair);
			curMode = VIEW_MODE;

			_activeEntryTemplatePair = _itemSelection
					.removeObjectFromList(_activeEntryTemplatePair);
			if (_activeEntryTemplatePair == null) {
				clearBean();
			} else {
				setBeans();
			}

			resultOK = true;
		} catch (Exception e) {
			resultOK = false;
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;

	}

	private void setBeans() {

	}

	/**
	 * <p>
	 * Checks all mandatory fields in case client side check was bypassed.
	 * </p>
	 * 
	 * @return true - if there's no empty mandatory fields, false - otherwise.
	 */
	public boolean checkFields() {
		boolean checked = true;
		if (newEntryTemplatePair.getTransactionType() == null)
			checked = false;
		if (newEntryTemplatePair.getTransactionNum() == null)
			checked = false;
		// if (newEntryTemplatePair.getDateName() == null ||
		// newEntryTemplatePair.getDateName().trim().length() == 0) checked =
		// false;

		if (newEntryTemplatePair.isEditDebit()) {
			if (newEntryTemplatePair.getDebitAmountName() == null
					|| newEntryTemplatePair.getDebitAmountName().trim().length() == 0)
				checked = false;
			if (newEntryTemplatePair.getDebitAccountName() == null
					|| newEntryTemplatePair.getDebitAccountName().trim().length() == 0)
				checked = false;
			if (newEntryTemplatePair.getDebitPostingMethod() == null)
				checked = false;
			if (newEntryTemplatePair.getDebitBalanceType() == null)
				checked = false;

			// debitDestEntityType is not mandatory but if it's set then
			// user must set debitDestAccountType too
			if (newEntryTemplatePair.getDebitDestEntityType() != null
					&& newEntryTemplatePair.getDebitDestAccountType() == null)
				checked = false;
		}

		if (newEntryTemplatePair.isEditCredit()) {
			if (newEntryTemplatePair.getCreditAmountName() == null
					|| newEntryTemplatePair.getCreditAmountName().trim().length() == 0)
				checked = false;
			if (newEntryTemplatePair.getCreditAccountName() == null
					|| newEntryTemplatePair.getCreditAccountName().trim().length() == 0)
				checked = false;
			if (newEntryTemplatePair.getCreditPostingMethod() == null)
				checked = false;
			if (newEntryTemplatePair.getCreditBalanceType() == null)
				checked = false;

			// creditDestEntityType is not mandatory but if it's set then
			// user must set creditDestAccountType too
			if (newEntryTemplatePair.getCreditDestEntityType() != null
					&& newEntryTemplatePair.getCreditDestAccountType() == null)
				checked = false;
		}

		return checked;
	}

	public EntryTemplatePair getNewEntryTemplatePair() {
		if (newEntryTemplatePair == null) {
			newEntryTemplatePair = new EntryTemplatePair();
		}
		return newEntryTemplatePair;
	}

	public void setNewEntryTemplatePair(EntryTemplatePair newEntryTemplatePair) {
		this.newEntryTemplatePair = newEntryTemplatePair;
	}

	public Integer getBunchTypeId() {
		return bunchTypeId;
	}

	public void setBunchTypeId(Integer bunchTypeId) {
		this.bunchTypeId = bunchTypeId;
	}

	public String getBunchTypeName() {
		return bunchTypeName;
	}

	public void setBunchTypeName(String bunchTypeName) {
		this.bunchTypeName = bunchTypeName;
	}

	public ArrayList<SelectItem> getTransactionTypes() {
		return getDictUtils().getArticles(DictNames.TRANSACTION_TYPE, true);
	}

	public ArrayList<SelectItem> getPostingMethods() {
		return getDictUtils().getArticles(DictNames.POSTING_METHOD, true);
	}

	public ArrayList<SelectItem> getBalanceTypes() {
		return getDictUtils().getArticles(DictNames.BALANCE_TYPE, true);
	}

	public ArrayList<SelectItem> getDestAccountTypes(String entityType, boolean showCode) {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			if (entityType != null) {
				List<String> accTypes = _accountsDao.getAccountTypesByEntityType(userSessionId, entityType);
				for (String accType : accTypes) {
					Dictionary accTypeDict = getDictUtils().getAllArticles().get(accType);
					String name = "";
					String desc = "";
					if (accTypeDict != null && showCode) {
						name = accType + " - " + accTypeDict.getName();
						desc = accTypeDict.getName();
					} else {
						name = accType;
					}
					items.add(new SelectItem(accType, name, desc));
				}
				Collections.sort(items, new Comparator<SelectItem>() {
					@Override
					public int compare(SelectItem item1, SelectItem item2) {
						return item1.getDescription().toLowerCase().compareTo(item2.getDescription().toLowerCase());
					}
				});
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return items;
	}

	public ArrayList<SelectItem> getCreditDestAccountTypes() {
		if (newEntryTemplatePair == null)
			return new ArrayList<SelectItem>(0);
		return getDestAccountTypes(newEntryTemplatePair.getCreditDestEntityType(), true);
	}

	public ArrayList<SelectItem> getDebitDestAccountTypes() {
		if (newEntryTemplatePair == null)
			return new ArrayList<SelectItem>(0);
		return getDestAccountTypes(newEntryTemplatePair.getDebitDestEntityType(), true);
	}

	public SelectItem[] getDestEntityTypes() {
		SelectItem[] items = new SelectItem[3];
		int i = 0;
		items[i++] = new SelectItem(EntityNames.INSTITUTION, "Institution");
		items[i++] = new SelectItem(EntityNames.AGENT, "Agent");
		items[i++] = new SelectItem(EntityNames.CUSTOMER, "Customer");
		return items;
	}

	public SelectItem[] getBalanceImpacts() {
		SelectItem[] items = new SelectItem[2];
		items[0] = new SelectItem(new Integer(-1), DEBIT);
		items[1] = new SelectItem(new Integer(1), CREDIT);
		return items;
	}

	public HashMap<Integer, String> getImpactNames() {
		HashMap<Integer, String> names = new HashMap<Integer, String>();
		names.put(new Integer(-1), DEBIT);
		names.put(new Integer(1), CREDIT);
		return names;
	}

	public HashMap<String, EntityType> getEntityTypes() {
		try {
			if (entityTypes == null)
				entityTypes = _commonDao.getEntityTypeObjects(userSessionId);

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			if (entityTypes == null)
				entityTypes = new HashMap<String, EntityType>();
		}
		return entityTypes;
	}

	public String getTransactionTypeType() {
		return DictNames.TRANSACTION_TYPE;
	}

	public boolean getResultOK() {
		return resultOK;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeEntryTemplatePair = null;
		_entryTemplatePairSource.flushCache();
	}

	public void fullCleanBean() {
		bunchTypeId = null;
		bunchTypeName = null;
		entryTemplateFilter = null;
		
		clearBean();
	}
	
	public void search() {
		_itemSelection.clearSelection();
		_activeEntryTemplatePair = null;
		_entryTemplatePairSource.flushCache();
		setSearching(true);
	}

	public void changeDebit(ValueChangeEvent event) {
		Boolean enabled = (Boolean) event.getNewValue();
		newEntryTemplatePair.setEditDebit(enabled.booleanValue());
	}

	public void changeCredit(ValueChangeEvent event) {
		Boolean enabled = (Boolean) event.getNewValue();
		newEntryTemplatePair.setEditCredit(enabled.booleanValue());
	}

	public List<SelectItem> getAmountTypes() {
		if(amountTypes == null){
			amountTypes = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.AMOUNT_TYPES);
		}
		if (amountTypes == null)
			amountTypes = new ArrayList<SelectItem>();
		return amountTypes;
	}

	public List<SelectItem> getAccountPurposes() {
		if(accountPurposes == null){
			accountPurposes = (ArrayList<SelectItem>)getDictUtils().getLov(LovConstants.ACCOUNT_PURPOSES);
		}
		if (accountPurposes == null)
			accountPurposes = new ArrayList<SelectItem>();
		return accountPurposes;
	}

	public List<SelectItem> getDatePurposes() {
		if(datePurposes == null){
			datePurposes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATE_PURPOSES);
		}
		if (datePurposes == null)
			datePurposes = new ArrayList<SelectItem>();
		return datePurposes;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
	}
	
	public EntryTemplatePair[] groupBy(EntryTemplatePair[] entryTemplatePairs){
		Map<String, EntryTemplatePair> map = new HashMap<String, EntryTemplatePair>();
		for(EntryTemplatePair entryTemplatePair : entryTemplatePairs) {
			String key = entryTemplatePair.getBunchTypeId().toString() + entryTemplatePair.getTransactionNum();
				EntryTemplatePair value = map.get(key);
				map.put(key, refac(value, entryTemplatePair));
		}
		List<EntryTemplatePair> list = new ArrayList<EntryTemplatePair>(map.values());
		return list.toArray(new EntryTemplatePair[list.size()]);
	}

	public EntryTemplatePair refac(EntryTemplatePair receiver, EntryTemplatePair source){
		if(receiver == null) {
			addAccTypeModifier(source, source, CREDIT);
			addAccTypeModifier(source, source, DEBIT);
			return source;
		}
		if(isValidModifier(source, null)) {
			source.getCreditAccTypeModifiers().addAll(receiver.getCreditAccTypeModifiers());
			source.getDebitAccTypeModifiers().addAll(receiver.getDebitAccTypeModifiers());
			return source;
		}
		int result = SKIPPED;
		result += addAccTypeModifier(receiver, source, CREDIT);
		result += addAccTypeModifier(receiver, source, DEBIT);
		if (result == SKIPPED) {
			receiver.setCredit(source.getCredit());
			receiver.setDebit(source.getDebit());
		}
		return receiver;
	}

	private boolean isValidModifier(EntryTemplatePair pair, String type) {
		if (DEBIT.equals(type)) {
			if (pair.getDebitId() != null && pair.getDebitModId() != null) {
				return true;
			}
		} else if (CREDIT.equals(type)) {
			if (pair.getCreditId() != null && pair.getCreditModId() != null) {
				return true;
			}
		} else {
			if (pair.getDebitId() != null && pair.getDebitModId() != null) {
				if (pair.getCreditId() != null && pair.getCreditModId() != null) {
					return true;
				}
			}
		}
		return false;
	}

	private Integer addAccTypeModifier(EntryTemplatePair dest, EntryTemplatePair source, String type) {
		if (isValidModifier(source, type)) {
			if (DEBIT.equals(type)) {
				List<AccTypeModifier> list = dest.getDebitAccTypeModifiers();
				list.add(new AccTypeModifier(source.getDebitId(),
											 source.getDebitDestAccountType(),
											 source.getDebitModId(),
											 source.getDebitModDesc()));
				return ADDED;
			} else if (CREDIT.equals(type)) {
				List<AccTypeModifier> list = dest.getCreditAccTypeModifiers();
				list.add(new AccTypeModifier(source.getCreditId(),
											 source.getCreditDestAccountType(),
											 source.getCreditModId(),
											 source.getCreditModDesc()));
				return ADDED;
			}
		}
		return SKIPPED;
	}
}
