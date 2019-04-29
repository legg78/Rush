package ru.bpc.sv2.ui.interchange;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.interchange.CalculatedFee;
import ru.bpc.sv2.interchange.CommonOperation;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AmexDao;
import ru.bpc.sv2.logic.DinersDao;
import ru.bpc.sv2.logic.JcbDao;
import ru.bpc.sv2.logic.MirDao;
import ru.bpc.sv2.logic.interchange.InterchangeDao;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.text.SimpleDateFormat;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbInterchangeOperation")
public class MbInterchangeOperation extends AbstractBean {
	private static final long serialVersionUID = 9180117082872879357L;
	private static Logger logger = Logger.getLogger("OPER_RPOCESSING");
	private static final String DB_DATE_FORMAT = "dd.MM.yyyy";

	private InterchangeDao interchangeDao = new InterchangeDao();
	private JcbDao jcbDao = new JcbDao();
	private DinersDao dinersDao = new DinersDao();
	private MirDao mirDao = new MirDao();
	private AmexDao amexDao = new AmexDao();

	private CommonOperation filter;
	private final DaoDataModel<CommonOperation> operSource;

	private CommonOperation activeItem;
	private final TableRowSelection<CommonOperation> itemSelection;
	private Map<String, Object> paramMap;
	private Date operDateTo;
	private String module;
	private List<CalculatedFee> calculatedFees;

	private Long prevSelectedOprationId;
	private Map<String, Object> finMessageData = new HashMap<String, Object>();

	public MbInterchangeOperation() {
		pageLink = "interchange|operations";
		operSource = new DaoDataListModel<CommonOperation>(logger) {
			private static final long serialVersionUID = 6886825197574225938L;

			@Override
			protected List<CommonOperation> loadDaoListData(SelectionParams params) {
				if (searching) {
					try {
						setFilters();
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						return interchangeDao.getOperations(module, params);
					} catch (Exception e) {
						setDataSize(0);
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return new ArrayList<CommonOperation>();
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return (int) interchangeDao.getOperationsCount(module, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<CommonOperation>(null, operSource);
	}


	@PostConstruct
	public void init() {
		setDefaultValues();
	}

	public Date getOperDateTo() {
		return operDateTo;
	}

	public void setOperDateTo(Date operDateTo) {
		this.operDateTo = operDateTo;
	}

	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new CommonOperation();
				SimpleDateFormat df = new SimpleDateFormat(DB_DATE_FORMAT);
				if (filterRec.get("id") != null) {
					filter.setId(Long.parseLong(filterRec.get("id")));
				}
				if (filterRec.get("issCardNumber") != null) {
					filter.setIssCardNumber(filterRec.get("issCardNumber"));
				}
				if (filterRec.get("operDate") != null) {
					filter.setOperDate(df.parse(filterRec.get("operDate")));
				}
				if (filterRec.get("operDateTo") != null) {
					setOperDateTo(df.parse(filterRec.get("operDateTo")));
				}
				if (filterRec.get("calcStatus") != null) {
					filter.setCalcStatus(Integer.parseInt(filterRec.get("calcStatus")));
				}
			}
			if (searchAutomatically) {
				search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");

			SimpleDateFormat df = new SimpleDateFormat(DB_DATE_FORMAT);

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getId() != null) {
				filterRec.put("id", filter.getId().toString());
			}
			if (filter.getIssCardNumber() != null) {
				filterRec.put("issCardNumber", filter.getIssCardNumber());
			}
			if (filter.getOperDate() != null) {
				filterRec.put("operDate", df.format(filter.getOperDate()));
			}
			if (getOperDateTo() != null) {
				filterRec.put("operDateTo", df.format(getOperDateTo()));
			}
			if (filter.getCalcStatus() != null) {
				filterRec.put("calcStatus", filter.getCalcStatus().toString());
			}

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

	private void setFilters() {
		CommonOperation operFilter = getFilter();
		filters = new ArrayList<Filter>();
		if (operFilter.getId() != null) {
			filters.add(new Filter("id", operFilter.getId()));
		}
		if (operFilter.getAcqInstId() != null) {
			filters.add(new Filter("acqInstId", operFilter.getAcqInstId()));
		}
		if (operFilter.getCalcStatus() != null) {
			filters.add(new Filter("calcStatus", operFilter.getCalcStatus()));
		}
		if (operFilter.getIssCardNumber() != null && !operFilter.getIssCardNumber().trim().isEmpty()) {
			filters.add(new Filter("issCardNumber", operFilter.getIssCardNumber()));
		}
		if (operFilter.getIssInstId() != null) {
			filters.add(new Filter("issInstId", operFilter.getIssInstId()));
		}
		if (operFilter.getOperType() != null && !operFilter.getOperType().trim().isEmpty()) {
			filters.add(new Filter("operType", operFilter.getOperType()));
		}
		if (operFilter.getOperDate() != null) {
			filters.add(new Filter("operDate", operFilter.getOperDate()));
		}
		if (operDateTo != null) {
			filters.add(new Filter("operDateTo", operDateTo));
		}
	}


	public SimpleSelection getItemSelection() {
		if (activeItem != null && operSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(activeItem.getModelId());
			itemSelection.setWrappedSelection(selection);
		}
		return itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) throws Exception {
		itemSelection.setWrappedSelection(selection);
		activeItem = itemSelection.getSingleSelection();
		if (activeItem != null) {
			if (isFeeTabVisible()) {
				calculatedFees = interchangeDao.getCalculatedFees(module, activeItem.getId());
			} else {
				calculatedFees = new ArrayList<CalculatedFee>();
			}
		}
	}

	public List<CalculatedFee> getCalculatedFees() {
		return calculatedFees;
	}

	public String getModule() {
		return module;
	}

	public void setModule(String module) {
		this.module = module;
	}

	public void search() {
		setSearching(true);
		clearBean();
		paramMap = new HashMap<String, Object>();
	}

	private void clearBean() {
		operSource.flushCache();
		itemSelection.clearSelection();
		activeItem = null;
		calculatedFees = null;
		prevSelectedOprationId = null;
		finMessageData = new HashMap<String, Object>();
	}

	public void clearFilter() {
		filter = null;
		operDateTo = null;
		setSearching(false);
		clearBean();
		setDefaultValues();
	}

	public boolean getSearching() {
		return searching;
	}

	public void setFilter(CommonOperation filter) {
		this.filter = filter;
	}

	public CommonOperation getFilter() {
		if (filter == null) {
			filter = new CommonOperation();
		}
		return filter;
	}

	public DaoDataModel<CommonOperation> getItems() {
		return operSource;
	}

	public CommonOperation getActiveItem() {
		return activeItem;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public String getComponentId() {
		return "";
	}

	public Logger getLogger() {
		return logger;
	}

	private void setDefaultValues() {
		filter = new CommonOperation();
	}

	public Map<String, Object> getParamMap() {
		if (paramMap == null) {
			paramMap = new HashMap<String, Object>();
		}
		return paramMap;
	}

	public void setParamMap(Map<String, Object> paramMap) {
		this.paramMap = paramMap;
	}

	public Map<String, Object> getFinMessageData() {
		if (activeItem != null && !activeItem.getId().equals(prevSelectedOprationId)) {
			finMessageData = new HashMap<String, Object>();
			List<LinkedHashMap> finMessages;
			if ("JCB".equals(module)) {
				finMessages = jcbDao.getFinMessages(userSessionId, SelectionParams.build("id", activeItem.getId(), "lang", userLang));
			} else if ("DIN".equals(module)) {
				finMessages = dinersDao.getFinMessages(userSessionId, SelectionParams.build("id", activeItem.getId(), "lang", userLang));
			} else if ("MUP".equals(module)) {
				finMessages = mirDao.getFinMessagesAsMap(userSessionId, SelectionParams.build("id", activeItem.getId(), "lang", userLang));
			} else if ("AMX".equals(module)) {
				finMessages = amexDao.getLinkedFinMessages(userSessionId, SelectionParams.build("id", activeItem.getId(), "lang", userLang));
			} else {
				finMessages = Collections.EMPTY_LIST;
			}
			if (!finMessages.isEmpty()) {
				finMessageData = finMessages.get(0);
			}
			prevSelectedOprationId = activeItem.getId();
		}
		return finMessageData;
	}

	public List<String> getFinMessageDataKeys() {
		return new ArrayList<String>(getFinMessageData().keySet());
	}

	public boolean isFeeTabVisible() {
		return module == null || (!module.equals("JCB") && !module.equals("DIN") && !module.equals("CUP") && !module.equals("MUP"));
	}
}
