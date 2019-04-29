package ru.bpc.sv2.ui.issuing.personalization;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.common.CommonWizardStepInfo;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.hsm.HsmDevice;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.personalization.*;
import ru.bpc.sv2.logic.HsmDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.common.wizard.callcenter.MbOperTypeSelectionStep;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbPersoBatchesSearch")
public class MbPersoBatchesSearch extends AbstractBean {
	private static final long serialVersionUID = -5296718458171246507L;
	private static final Logger logger = Logger.getLogger("PERSONALIZATION");
    private static Logger classLogger = Logger.getLogger(MbPersoBatchesSearch.class);

	private static String COMPONENT_ID = "batchTable";

	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	private HsmDao _hsmDao = new HsmDao();
	
	private NetworkDao _networkDao = new NetworkDao();

	private PrsBatch filter;
	private PrsBatch _activeBatch;
	private PrsBatch newBatch;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<PrsBatch> _batchesSource;

	private final TableRowSelection<PrsBatch> _itemSelection;

	private String oldLang;
	
	private String tabName;
	private HashMap<String, Object> paramMap;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private String needRerender;
	private List<String> rerenderList;

    CloneCandidateCard[] batchCloneCandidateCards = null;
    private List<SelectItem> cloningOptions = null;
    public static final int OPTION_ALL = 1;
    public static final int OPTION_SELECT = 2;
    public static final int OPTION_RANGE = 3;
    public static final int OPTION_START_FROM = 4;
    private int cloningOption = OPTION_ALL;
    private int checkedCardCount = 0;
    private String clonedBatchName;
    private static final String FROM = "from";
    private static final String TO = "to";
    private List<SelectItem> eventTypes;
    private String pinRequest;
    private String pinMailerRequest;
    private String embossingRequest;

	public MbPersoBatchesSearch() {
		tabName = "detailsTab";
		pageLink = "issuing|perso|batches";
		_batchesSource = new DaoDataModel<PrsBatch>() {
			private static final long serialVersionUID = -6636609104606236150L;

			@Override
			protected PrsBatch[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new PrsBatch[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getBatchesCur(userSessionId, params, paramMap);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PrsBatch[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					return _personalizationDao.getBatchesCurCount(userSessionId, paramMap);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PrsBatch>(null, _batchesSource);
		
		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");
				
		if (sectionId != null && filterId != null) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);			
		}
	}


    public void setupOperTypeSelection(){
        classLogger.trace("setupOperTypeSelection...");
        CommonWizardStepInfo step = new CommonWizardStepInfo();
        step.setOrder(0);
        step.setSource(MbOperTypeSelectionStep.class.getSimpleName());
        step.setName(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Opr","select_oper_type"));
        List<CommonWizardStepInfo> stepsList = new ArrayList<CommonWizardStepInfo>();
        stepsList.add(step);
        Map<String, Object> context = new HashMap<String, Object>();
        context.put(MbCommonWizard.STEPS, stepsList);
        context.put(MbOperTypeSelectionStep.ENTITY_TYPE, EntityNames.PERSONALIZATION_BATCH);
        context.put(MbOperTypeSelectionStep.OBJECT_ID, (long) _activeBatch.getId());
        context.put("INSTITUTION_ID", (long) _activeBatch.getInstId());
        context.put("AGENT_ID", _activeBatch.getAgentId()!= null ? (int) _activeBatch.getAgentId() : null);
        context.put(MbOperTypeSelectionStep.OBJECT_TYPE, Participant.ISS_PARTICIPANT);
        MbCommonWizard wizard = ManagedBeanWrapper.getManagedBean(MbCommonWizard.class);
        wizard.init(context);
    }

	public DaoDataModel<PrsBatch> getBatchs() {
		return _batchesSource;
	}

	public PrsBatch getActiveBatch() {
		return _activeBatch;
	}

	public void setActiveBatch(PrsBatch activeBatch) {
		_activeBatch = activeBatch;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeBatch == null && _batchesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeBatch != null && _batchesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeBatch.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeBatch = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_batchesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBatch = (PrsBatch) _batchesSource.getRowData();
		selection.addKey(_activeBatch.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeBatch != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBatch = _itemSelection.getSingleSelection();
		if (_activeBatch != null) {
			setInfo();
		}
	}

	public void setInfo() {
		MbPersoCardsSearch cardsSearch = (MbPersoCardsSearch) ManagedBeanWrapper
				.getManagedBean("MbPersoCardsSearch");
		PersoCard cardsFilter = new PersoCard();
		cardsFilter.setBatchId(_activeBatch.getId());
		cardsFilter.setInstId(_activeBatch.getInstId());
		if (_activeBatch.getAgentId() != null) {
			cardsFilter.setAgentId(_activeBatch.getAgentId());
			cardsFilter.setBlockAgentId(true);
		}
		if (_activeBatch.getProductId() != null) {
			cardsFilter.setProductId(_activeBatch.getProductId());
			cardsFilter.setBlockProductId(true);
		}
		if (_activeBatch.getBlankTypeId() != null) {
			cardsFilter.setBlankTypeId(_activeBatch.getBlankTypeId());
			cardsFilter.setBlockBlankTypeId(true);
		}
		if (_activeBatch.getCardTypeId() != null) {
			cardsFilter.setCardTypeId(_activeBatch.getCardTypeId());
			cardsFilter.setBlockCardTypeId(true);
		}
		if (_activeBatch.getPersoPriority() != null){ 
			cardsFilter.setPersoPriority(_activeBatch.getPersoPriority());
			cardsFilter.setBlockPersoPriority(true);
		}
		cardsSearch.setFilter(cardsFilter);
		cardsSearch.search();
		
		MbPersoBatchCardsSearch batchCardsSearch = (MbPersoBatchCardsSearch) ManagedBeanWrapper.getManagedBean("MbPersoBatchCardsSearch");
		PersoBatchCard batchCardsFilter = new PersoBatchCard();
		batchCardsFilter.setBatchId(_activeBatch.getId());
		batchCardsSearch.setFilter(batchCardsFilter);
		batchCardsSearch.setSortCondition(_activeBatch.getSortCondition());
		batchCardsSearch.search();
		
		loadedTabs.clear();
		loadTab(getTabName());
	}

	public void search() {
		clearState();
		paramMap = new HashMap<String, Object>();
		clearBeansStates();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		clearSectionFilter();
		searching = false;
	}

	public PrsBatch getFilter() {
		if (filter == null) {
			filter = new PrsBatch();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(PrsBatch filter) {
		this.filter = filter;
	}

	private void setFilters() {
        boolean inCardsSearch = false;
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

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("BATCH_NAME");
			paramFilter.setValue(filter.getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getStatus() != null && filter.getStatus().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("STATUS");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStatus());
			filters.add(paramFilter);
		}

		if (filter.getStatusDateFrom() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("DATE_FROM");
            Date statusDateFrom = filter.getStatusDateFrom();
            if(statusDateFrom != null) {
                Calendar calendar = new GregorianCalendar();
                calendar.setTime(statusDateFrom);
                calendar.set(Calendar.HOUR, 0);
                calendar.set(Calendar.MINUTE, 0);
                calendar.set(Calendar.SECOND, 0);
                calendar.set(Calendar.MILLISECOND, 0);
                statusDateFrom = calendar.getTime();
            }
            paramFilter.setValue(statusDateFrom);
			filters.add(paramFilter);
		}

		if (filter.getStatusDateTo() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("DATE_TO");
            Date statusDateTo = filter.getStatusDateTo();
            if(statusDateTo != null) {
                Calendar calendar = new GregorianCalendar();
                calendar.setTime(statusDateTo);
                calendar.set(Calendar.HOUR, 23);
                calendar.set(Calendar.MINUTE, 59);
                calendar.set(Calendar.SECOND, 59);
                calendar.set(Calendar.MILLISECOND, 999);
                statusDateTo = calendar.getTime();
            }
            paramFilter.setValue(statusDateTo);
			filters.add(paramFilter);
		}

        if (filter.getCardholderName() != null && filter.getCardholderName().trim().length() > 0) {
            paramFilter = new Filter();
            paramFilter.setElement("CARDHOLDER_NAME");
            paramFilter.setValue(filter.getCardholderName().trim().replaceAll("[*]", "%").replaceAll("[?]",
                    "_").toUpperCase());
            filters.add(paramFilter);
        }

        if (filter.getCardNumber() != null && filter.getCardNumber().trim().length() > 0) {
            String filterValue = filter.getCardNumber();
            paramFilter = new Filter();
            if (filterValue.contains("*") || filterValue.contains("?")){
            	filterValue = filterValue.trim().replaceAll("[*]", "%").replaceAll("[?]",
                        "_").toUpperCase();
            }
            paramFilter.setElement("CARD_NUMBER");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(filterValue.trim());
            filters.add(paramFilter);
        }

        if (filter.getCardUid() != null && filter.getCardUid().trim().length() > 0) {
            String filterValue = filter.getCardUid();
            paramFilter = new Filter();
            if (filterValue.contains("*") || filterValue.contains("?")){
                filterValue = filterValue.trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase();
            }
            paramFilter.setElement("CARD_UID");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(filterValue.trim());
            filters.add(paramFilter);
            }

        if (filter.getReissueReason() != null && filter.getReissueReason().trim().length() > 0) {
            String filterValue = filter.getReissueReason();
            paramFilter = new Filter();
            paramFilter.setElement("REISSUE_REASON");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(filterValue);
            filters.add(paramFilter);
        }
        
        getParamMap().put("param_tab", filters.toArray(new Filter[filters.size()]));
        getParamMap().put("tab_name", "BATCH");

	}

	public void add() {
		newBatch = new PrsBatch();
		newBatch.setStatus(PersonalizationConstants.BATCH_STATUS_JUST_CREATED);
		newBatch.setLang(userLang);
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newBatch = (PrsBatch) _activeBatch.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newBatch = _activeBatch;
		}
		curMode = EDIT_MODE;
	}

    public void cloneSelectedBatch(){
        checkedCardCount = 0;
        cloningOption = OPTION_ALL;
        pinRequest = null;
        pinMailerRequest = null;
        embossingRequest = null;
        if(_activeBatch != null && _activeBatch.getId() != null) {
            clonedBatchName = "Copy of: " + _activeBatch.getName();

            Long batchId = _activeBatch.getId().longValue();
            this.batchCloneCandidateCards =  _personalizationDao.getBatchCloneCandidateCards(userSessionId, batchId);
            return;
        }
        this.batchCloneCandidateCards = null;
    }

	public void view() {

	}

	public void save() {
		try {
			if ((newBatch.getCardCount() != null) && (newBatch.getCardCount() <= 0)) {
				FacesUtils.addMessageError("'Max cards count' must be greater than 0.");
				return;
			}
			if (isNewMode()) {
				newBatch = _personalizationDao.addBatch(userSessionId, newBatch);
				_itemSelection.addNewObjectToList(newBatch);
			} else if (isEditMode()) {
				newBatch = _personalizationDao.modifyBatch(userSessionId, newBatch);
				_batchesSource.replaceObject(_activeBatch, newBatch);
			}

			_activeBatch = newBatch;
			setInfo();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			if (FacesUtils.getMessage(e).equals("BATCH_NAME_ALREADY_EXISTS")) {
				FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
				        "batch_name_institution_already_exists"));
			} else {
				FacesUtils.addMessageError(e);
			}
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_personalizationDao.deleteBatch(userSessionId, _activeBatch);
			_activeBatch = _itemSelection.removeObjectFromList(_activeBatch);
			if (_activeBatch == null) {
				clearState();
			} else {
				setInfo();
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public PrsBatch getNewBatch() {
		if (newBatch == null) {
			newBatch = new PrsBatch();
		}
		return newBatch;
	}

	public void setNewBatch(PrsBatch newBatch) {
		this.newBatch = newBatch;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeBatch = null;
		_batchesSource.flushCache();
		curLang = userLang;
		clearBeansStates();
		loadedTabs.clear();
	}

	public void clearBeansStates() {
		MbPersoCardsSearch cardsSearch = (MbPersoCardsSearch) ManagedBeanWrapper
				.getManagedBean("MbPersoCardsSearch");
		cardsSearch.clearState();
		cardsSearch.setFilter(null);
		cardsSearch.setSearching(false);
		
		MbPersoBatchCardsSearch batchCardsSearch = (MbPersoBatchCardsSearch) ManagedBeanWrapper
				.getManagedBean("MbPersoBatchCardsSearch");
		batchCardsSearch.clearState();
		batchCardsSearch.setFilter(null);
		batchCardsSearch.setSearching(false);
	}

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.BATCH_STATUSES, false, false);
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeBatch.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		PrsBatch temp = updateActiveBatch(filters);
		if(temp != null) {
			_activeBatch = temp;
		}
	}

	public void updateActiveBatch() {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeBatch.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;

		PrsBatch temp = updateActiveBatch(filters);
		if(temp == null){
			return;
		}
		try {
			_batchesSource.replaceObject(_activeBatch, temp);
			_activeBatch = temp;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public PrsBatch updateActiveBatch(List<Filter> filters){
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			PrsBatch[] schemas = _personalizationDao.getBatches(userSessionId, params);
			if (schemas != null && schemas.length > 0) {
				return schemas[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getAgents() {
		if (getNewBatch().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getNewBatch().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
	}

	public List<SelectItem> getHsms() {
		String ACTION_HSM_PERSONALIZATION = "HSMAPSWE";
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			HsmDevice[] hsms = _hsmDao.getHsmLov(userSessionId, newBatch.getInstId(), newBatch
					.getAgentId(), ACTION_HSM_PERSONALIZATION);			
			for (HsmDevice hsm : hsms) {
				items.add(new SelectItem(hsm.getId(), hsm.getId() + " - " + hsm.getDescription()));
			}
			logger.debug(String.format("HSM records obtained: %d", items.size()));
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		return items;
	}
	
	public List<SelectItem> getProducts(){
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (getFilter().getInstId() != null) {
				paramMap.put("INSTITUTION_ID", getNewBatch().getInstId());
			}		
			return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}
	
	public ArrayList<SelectItem> getCardTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			if (getNewBatch().getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getNewBatch().getInstId().toString());
				filtersList.add(paramFilter);
			}
			if (getNewBatch().getProductId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("productId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getNewBatch().getProductId().toString());
				filtersList.add(paramFilter);
			}
			
			paramFilter = new Filter();
			paramFilter.setElement("isVirtual");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue("0");
			filtersList.add(paramFilter);
			
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

			CardType[] types = _networkDao.getCardTypesList(userSessionId, params);
			for (CardType type : types) {
				items.add(new SelectItem(type.getId(), type.getId() + " - " + type.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		return items;
	}
	
	public ArrayList<SelectItem> getBlankTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			if (getNewBatch().getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getNewBatch().getInstId().toString());
				filtersList.add(paramFilter);
			}
			if (getNewBatch().getCardTypeId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("cardTypeId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getNewBatch().getCardTypeId().toString());
				filtersList.add(paramFilter);
			}
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

			BlankType[] types = _personalizationDao.getBlankTypes(userSessionId, params);
			for (BlankType type : types) {
				items.add(new SelectItem(type.getId(),type.getId() + " - " + type.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		return items;
	}
	
	public List<SelectItem> getSorting() {
		Map<String, Object> map = new HashMap<String, Object>();
		if (getNewBatch().getInstId() != null) {
			map.put("INSTITUTION_ID", getNewBatch().getInstId());
		}
		return getDictUtils().getLov(LovConstants.SORTING, map);
	}
	
	public boolean isBatchProcessed() {
		if (_activeBatch == null) {
			return true;
		} else {
			return _activeBatch.isProcessed();
		}
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newBatch.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newBatch.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			PrsBatch[] items = _personalizationDao.getBatches(userSessionId, params);
			if (items != null && items.length > 0) {
				newBatch.setName(items[0].getName());
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void cancelEditLanguage() {
		newBatch.setLang(oldLang);
	}
	
	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new PrsBatch();
				setFilterForm(filterRec);
				if (searchAutomatically) search();
			}
		
			sectionFilterModeEdit = true;
					
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} 
	}
	
	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		if (filterRec.get("id") != null) {
			filter.setId(Integer.valueOf(filterRec.get("id")));
		}
		if (filterRec.get("instId") != null) {
			filter.setInstId(Integer.valueOf(filterRec.get("instId")));
		}
		if (filterRec.get("name") != null) {
			filter.setName(filterRec.get("name"));
		}
		if (filterRec.get("status") != null) {
			filter.setStatus(filterRec.get("status"));
		}
		
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filterRec.get("statusDateFrom") != null) {
			filter.setStatusDateFrom(df.parse(filterRec.get("statusDateFrom")));
		}
		
		if (filterRec.get("statusDateTo") != null) {
			filter.setStatusDateTo(df.parse(filterRec.get("statusDateTo")));
		}
	}
	
	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			
			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);
			
			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true; 
			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} 
	}
	
	private void setFilterRec(Map<String, String> filterRec) {
		
		if (filter.getId() != null) {
			filterRec.put("id", filter.getId().toString());
		}
		if (filter.getInstId() != null) {
			filterRec.put("instId", filter.getInstId().toString());
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			filterRec.put("name", filter.getName());
		}
		if (filter.getStatus() != null 
				&& filter.getStatus().trim().length() > 0) {
			filterRec.put("status", filter.getStatus());
		}
		SimpleDateFormat df = new SimpleDateFormat(DatePatterns.DATE_PATTERN);
		if (filter.getStatusDateFrom() != null) {
			filterRec.put("statusDateFrom", df.format(filter.getStatusDateFrom()));
		}
		
		if (filter.getStatusDateTo() != null) {
			filterRec.put("statusDateTo", df.format(filter.getStatusDateTo()));
		}
	}
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("cardsTab")) {
			MbPersoCardsSearch bean = (MbPersoCardsSearch) ManagedBeanWrapper
					.getManagedBean("MbPersoCardsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("batchCardsTab")) {
			MbPersoBatchCardsSearch bean = (MbPersoBatchCardsSearch) ManagedBeanWrapper
					.getManagedBean("MbPersoBatchCardsSearch");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	public void loadCurrentTab() {
		loadTab(tabName);
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;

		needRerender = tab;
		loadedTabs.put(tab, Boolean.TRUE);
	}
	
	public HashMap<String, Boolean> getLoadedTabs() {
		return loadedTabs;
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
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_PERSONALIZATION_BATCH;
	}

	public String getComponentId() {
		return getSectionId() + ":" + COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public List<SelectItem> getPersoPriorities(){
		List<SelectItem> result = getDictUtils().getArticles(DictNames.PERSO_PRIORITY);
		return result;
	}

	public HashMap<String, Object> getParamMap() {
		if (paramMap == null){
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(HashMap<String, Object> paramMap) {
		this.paramMap = paramMap;
	}


    public CloneCandidateCard[] getBatchCloneCandidateCards() {

        CloneCandidateCard[] result = batchCloneCandidateCards;


        if(batchCloneCandidateCards!=null) {
            if (cloningOption == OPTION_RANGE && checkedCardCount == 2) {
                List<CloneCandidateCard> resultList = new ArrayList<CloneCandidateCard>();
                boolean start = false;
                for (CloneCandidateCard card : batchCloneCandidateCards) {
                    if (card.getChecked() && !start) {
                        start = true;
                        resultList.add(card);
                        continue;
                    }
                    if (start) resultList.add(card);
                    if (card.getChecked() && start) break;
                }
                return resultList.toArray(new CloneCandidateCard[resultList.size()]);
            }

            if (cloningOption == OPTION_START_FROM && checkedCardCount == 1) {
                List<CloneCandidateCard> resultList = new ArrayList<CloneCandidateCard>();
                boolean start = false;
                for (CloneCandidateCard card : batchCloneCandidateCards) {
                    if (card.getChecked() && !start) {
                        start = true;
                    }
                    if (start) resultList.add(card);
                }
                return resultList.toArray(new CloneCandidateCard[resultList.size()]);
            }
        }

        return result;
    }

    public List<SelectItem> getCloningOptions() {
        if (cloningOptions == null) {
            cloningOptions = new ArrayList<SelectItem>(4);
            String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prs", "clone_option_all");
            SelectItem item = new SelectItem(OPTION_ALL, "All");
            cloningOptions.add(item);
            msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prs", "clone_option_select");
            item = new SelectItem(OPTION_SELECT, "Select");
            cloningOptions.add(item);
            msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prs", "clone_option_range");
            item = new SelectItem(OPTION_RANGE, "Range");
            cloningOptions.add(item);
            msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prs", "clone_option_start_from");
            item = new SelectItem(OPTION_START_FROM, "Start from");
            cloningOptions.add(item);
        }
        return cloningOptions;
    }

    public int getCloningOption() {
        return cloningOption;
    }

    public void setCloningOption(int cloningOption) {
        this.cloningOption = cloningOption;
    }

    private void cloneWithAllOption(){
        Long batchId = _activeBatch.getId().longValue();
        String clonedBatchName = this.clonedBatchName;
        _personalizationDao.cloneBatchWithAllOption(userSessionId, batchId, clonedBatchName, pinRequest, pinMailerRequest, embossingRequest);
        return;
    }

    private Long[] getSelectedCardInstanceIds(){
        List<Long> instanceIds = new ArrayList<Long>();
        for(CloneCandidateCard card : batchCloneCandidateCards){
            if(card.getChecked()) instanceIds.add(card.getCardInstanceId());
        }
        return instanceIds.toArray(new Long[instanceIds.size()]);
    }

    private void cloneWithSelectOption(){
        Long batchId = _activeBatch.getId().longValue();
        String clonedBatchName = this.clonedBatchName;
        Long[] instanceList = getSelectedCardInstanceIds();
        _personalizationDao.cloneBatchWithSelectOption(userSessionId, batchId, clonedBatchName, instanceList, pinRequest, pinMailerRequest, embossingRequest);
        return;
    }

    private Map<String,Integer> getSelectedCardRangeIndexes(){
        Map<String,Integer> range = new HashMap<String,Integer>();
        int ind =1;
        for(CloneCandidateCard card : batchCloneCandidateCards){
            if(card.getChecked()){
                if(range.containsKey(FROM)) {
                    range.put(TO, ind);
                    return range;
                }
                else range.put(FROM, ind);
            }
            ind++;
        }
        return null;
    }

    private void cloneWithRangeOption(){
        Long batchId = _activeBatch.getId().longValue();
        String clonedBatchName = this.clonedBatchName;
        Map<String,Integer> range = getSelectedCardRangeIndexes();
        if(range == null) return;
        Integer firstRow = range.get(FROM);
        Integer lastRow = range.get(TO);
        _personalizationDao.cloneBatchWithRangeOption(userSessionId, batchId, clonedBatchName, firstRow, lastRow, pinRequest, pinMailerRequest, embossingRequest);
        return;
    }

    private Integer getSelectedCardFromIndex(){
        int ind = 1;
        for(CloneCandidateCard card : batchCloneCandidateCards){
            if(card.getChecked()) return ind;
            ind++;
        }
        return null;
    }

    private void cloneWithStartFromOption(){
        Long batchId = _activeBatch.getId().longValue();
        String clonedBatchName = this.clonedBatchName;
        Integer firstRow = getSelectedCardFromIndex();
        if(firstRow == null) return;
        _personalizationDao.cloneBatchWithRangeOption(userSessionId, batchId, clonedBatchName, firstRow, null, pinRequest, pinMailerRequest, embossingRequest);
        return;
    }



    public void cloneBatch(){

        switch(cloningOption) {
            case OPTION_ALL :
                 cloneWithAllOption();
                 break;
            case OPTION_SELECT :
                 cloneWithSelectOption();
                 break;
            case OPTION_RANGE :
                 cloneWithRangeOption();
                 break;
            case OPTION_START_FROM :
                 cloneWithStartFromOption(); // lastRow not used.
                 break;
        }

        checkedCardCount = 0;
        cloningOption = OPTION_ALL;
        search();

    }

    public void cancel() {
        curMode = VIEW_MODE;
    }

    public void changeCloningOption(){
        clearCloneCardSelection();
    }

    public void checkCardAction(){
        updateCheckedCardsCounter();
    }

    private void clearCloneCardSelection(){
        for(CloneCandidateCard card : batchCloneCandidateCards){
            card.setChecked(false);
        }
        checkedCardCount = 0;
    }

    private void updateCheckedCardsCounter(){
        checkedCardCount = 0;
        for(CloneCandidateCard card : batchCloneCandidateCards){
            if(card.getChecked()) checkedCardCount++;
        }
    }

    public int getCheckedCardCount() {
        return checkedCardCount;
    }

    public String getClonedBatchName() {
        return clonedBatchName;
    }

    public void setClonedBatchName(String clonedBatchName) {
        this.clonedBatchName = clonedBatchName;
    }

    public int  getClonedBatchNameLength(){
        return clonedBatchName!=null ? clonedBatchName.length() : 0;
    }
    
    public List<SelectItem> getEventTypes() {
		if (eventTypes == null) {
			eventTypes = getDictUtils().getLov(LovConstants.EVENT_TYPES_FOR_STATUS);
		}
		return eventTypes;
	}

	public String getPinRequest() {
		return pinRequest;
	}

	public void setPinRequest(String pinRequest) {
		this.pinRequest = pinRequest;
	}

	public String getPinMailerRequest() {
		return pinMailerRequest;
	}

	public void setPinMailerRequest(String pinMailerRequest) {
		this.pinMailerRequest = pinMailerRequest;
	}

	public String getEmbossingRequest() {
		return embossingRequest;
	}

	public void setEmbossingRequest(String embossingRequest) {
		this.embossingRequest = embossingRequest;
	}
	
	public ArrayList<SelectItem> getPinRequests() {
		return getDictUtils().getArticles(DictNames.PIN_REQUEST, true, false);		
	}
	
	public ArrayList<SelectItem> getPinMailerRequests() {
		return getDictUtils().getArticles(DictNames.PIN_MAILER_REQUEST, true, false);		
	}
	
	public ArrayList<SelectItem> getEmbossingRequests() {
		return getDictUtils().getArticles(DictNames.EMBOSSING_REQUEST, true, false);		
	}
}
