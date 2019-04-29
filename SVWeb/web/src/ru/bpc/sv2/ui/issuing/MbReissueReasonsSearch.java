package ru.bpc.sv2.ui.issuing;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.FilterFactory;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.issuing.ReissueReason;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbReissueReasonsSearch")
public class MbReissueReasonsSearch extends AbstractBean{
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ISSUING");
	
	private static String COMPONENT_ID = "2323:issReissueReasonsTable";
	private static String SECTION_ID = "2323";
	
	private IssuingDao _issuingDao = new IssuingDao();
	
	private List<SelectItem> institutions = null;
	private List<SelectItem> eventTypes = null;
	private List<SelectItem> reissueCommands = null;
	private List<SelectItem> pinRequests = null;
	private ArrayList<SelectItem> pinMailerRequests = null;
	private ArrayList<SelectItem> embossingRequests = null;
	private List<SelectItem> reissStartDateRules = null;
	private List<SelectItem> reissExpirDateRules = null;
	private List<SelectItem> persoPriorities = null;
	private List<SelectItem> cloneOptionalServices = null;
	private ReissueReason activeItem;
	private ReissueReason filter;
	private ReissueReason editingItem;
	
	private final DaoDataModel<ReissueReason> _reissueReasonSource;
	private final TableRowSelection<ReissueReason> _itemSelection;
			
	public MbReissueReasonsSearch(){
		pageLink = "issuing|reissueReasons";
		
		_reissueReasonSource = new DaoDataModel<ReissueReason>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ReissueReason[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ReissueReason[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getReissueReasons(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ReissueReason[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getReissueReasonsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		
		_itemSelection = new TableRowSelection<ReissueReason>(null, _reissueReasonSource);
	}
		
	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		return institutions;
	}
	
	public List<SelectItem> getEventTypes() {
		if (eventTypes == null) {
			eventTypes = getDictUtils().getLov(LovConstants.REISSUE_REASONS);
		}
		return eventTypes;
	}
	
	public List<SelectItem> getReissueCommands() {
		if (reissueCommands == null) {
			reissueCommands = getDictUtils().getLov(LovConstants.REISS_COMMANDS);
		}
		return reissueCommands;
	}

	public List<SelectItem> getReissStartDateRules() {
		if (reissStartDateRules == null) {
			reissStartDateRules = getDictUtils().getLov(LovConstants.PERSO_REISS_START_DATE_RULE);
		}
		return reissStartDateRules;
	}
	
	public List<SelectItem> getReissExpirDateRules() {
		if (reissExpirDateRules == null) {
			reissExpirDateRules = getDictUtils().getLov(LovConstants.PERSO_REISS_EXPIR_DATE_RULE);
		}
		return reissExpirDateRules;
	}
	
	public List<SelectItem> getPersoPriorities(){
		if (persoPriorities == null) {
			persoPriorities = getDictUtils().getLov(LovConstants.PERSO_PRIORITY);
		}
		return persoPriorities;
	}

	public List<SelectItem> getCloneOptionalServices() {
		if (cloneOptionalServices == null) {
			cloneOptionalServices = getDictUtils().getLov(LovConstants.YES_NO_LIST);
		}
		return cloneOptionalServices;
	}

	public List<SelectItem> getPinRequests(){
		if (pinRequests == null) {
			pinRequests = getDictUtils().getLov(LovConstants.PIN_REQUEST);
		}
		return pinRequests;
	}
	
	public ArrayList<SelectItem> getPinMailerRequests(){
		if (pinMailerRequests == null) {
			pinMailerRequests = getDictUtils().getArticles(DictNames.PIN_MAILER_REQUEST, true);
		}
		
		if (pinMailerRequests == null)
			pinMailerRequests = new ArrayList<SelectItem>();
		return pinMailerRequests;
	}
	
	public ArrayList<SelectItem> getEmbossingRequests(){
		if (embossingRequests == null) {
			embossingRequests = getDictUtils().getArticles(DictNames.EMBOSSING_REQUEST, true);
		}
		
		if (embossingRequests == null)
			embossingRequests = new ArrayList<SelectItem>();
		return embossingRequests;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (activeItem == null && _reissueReasonSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (activeItem != null && _reissueReasonSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(activeItem.getModelId());
				_itemSelection.setWrappedSelection(selection);
				activeItem = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_reissueReasonSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (ReissueReason) _reissueReasonSource.getRowData();
		selection.addKey(activeItem.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			//setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		activeItem = _itemSelection.getSingleSelection();
		if (activeItem != null) {
			//setInfo();
		}
	}
	
	public DaoDataModel<ReissueReason> getDataModel() {
		return _reissueReasonSource;
	}
	
	
	public ReissueReason getFilter() {
		if (filter == null) {
			filter = new ReissueReason();
		}
		return filter;
	}

	public void setFilter(ReissueReason filter) {
		this.filter = filter;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();
		
		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getReissueReason()!= null) {
			paramFilter = new Filter();
			paramFilter.setElement("reissueReason");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getReissueReason());
			filters.add(paramFilter);
		}
		if (filter.getReissueCommand()!= null) {
			paramFilter = new Filter();
			paramFilter.setElement("reissueCommand");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getReissueCommand());
			filters.add(paramFilter);
		}
		if (filter.getPinRequest()!= null) {
			paramFilter = new Filter();
			paramFilter.setElement("pinRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPinRequest());
			filters.add(paramFilter);
		}
		if (filter.getPinMailerRequest()!= null) {
			paramFilter = new Filter();
			paramFilter.setElement("pinMailerRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPinMailerRequest());
			filters.add(paramFilter);
		}
		if (filter.getEmbossingRequest()!= null) {
			paramFilter = new Filter();
			paramFilter.setElement("embossingRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEmbossingRequest());
			filters.add(paramFilter);
		}
	}
			
	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = null;
		clearState();
		searching = false;
	}
	
	public void clearState() {
		_itemSelection.clearSelection();
		activeItem = null;
		_reissueReasonSource.flushCache();
		curLang = userLang;
	}
	
	public ReissueReason getActiveItem(){
		return activeItem;
	}
	
	public void add(){
		editingItem = new ReissueReason();
		curMode = AbstractBean.NEW_MODE;		
	}
	
	public void edit(){
		curMode = AbstractBean.EDIT_MODE;
		editingItem = activeItem ;
	}
		
	public void delete(){
		try{
			_issuingDao.deleteReissueReason(userSessionId, activeItem);
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = _itemSelection.removeObjectFromList(activeItem);
	}
	
	public void save(){
		try {
			editingItem.setLang(curLang);
			ReissueReason updatedEditingItem = null;
			if (isNewMode()) {
				updatedEditingItem = _issuingDao.addReissueReason(userSessionId, editingItem);
			} else if (isEditMode()){
				updatedEditingItem = _issuingDao.modifyReissueReason(userSessionId, editingItem);
			}
			editingItem = updatedEditingItem;
		}catch (DataAccessException e){
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
			return;
		}
		if (isNewMode()) {
			_itemSelection.addNewObjectToList(editingItem);
		} else {
			try {
				_reissueReasonSource.replaceObject(activeItem, editingItem);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		activeItem = editingItem;
		cancel();
		search();
	}
	
	public void cancel(){
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;		
	}
	
	public ReissueReason getEditingItem(){
		return editingItem;
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
			ReissueReason[] reissueReasons = _issuingDao.getReissueReasons(userSessionId, params);
			if (reissueReasons != null && reissueReasons.length > 0) {
				activeItem = reissueReasons[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		
	}
	
	public String getComponentId() {
		return COMPONENT_ID;
	}
	
	public String getSectionId() {
		return SECTION_ID;
	}
	
	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper
					.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new ReissueReason();
				if (filterRec.get("instId") != null) {
					filter.setInstId(Integer.parseInt(filterRec.get("instId")));
				}
				if (filterRec.get("reissueReason") != null) {
					filter.setReissueReason(filterRec.get("reissueReason"));
				}
				if (filterRec.get("reissueCommand") != null) {
					filter.setReissueCommand(filterRec.get("reissueCommand"));
				}
				if (filterRec.get("pinRequest") != null) {
					filter.setPinRequest(filterRec.get("pinRequest"));
				}
				if (filterRec.get("pinMailerRequest") != null) {
					filter.setPinMailerRequest(filterRec.get("pinMailerRequest"));
				}
				if (filterRec.get("embossingRequest") != null) {
					filter.setEmbossingRequest(filterRec.get("embossingRequest"));
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

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			if (filter.getInstId() != null) {
				filterRec.put("instId", filter.getInstId().toString());
			}
			if (filter.getReissueReason() != null) {
				filterRec.put("reissueReason", filter.getReissueReason().toString());
			}
			if (filter.getReissueCommand() != null) {
				filterRec.put("reissueCommand", filter.getReissueCommand().toString());
			}
			if (filter.getPinRequest() != null) {
				filterRec.put("pinRequest", filter.getPinRequest().toString());
			}
			if (filter.getPinMailerRequest() != null) {
				filterRec.put("pinMailerRequest", filter.getPinMailerRequest().toString());
			}
			if (filter.getEmbossingRequest() != null) {
				filterRec.put("embossingRequest", filter.getEmbossingRequest().toString());
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
}
