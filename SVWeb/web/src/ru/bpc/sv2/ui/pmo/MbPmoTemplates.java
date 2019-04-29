package ru.bpc.sv2.ui.pmo;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CyclesDao;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoSchedule;
import ru.bpc.sv2.pmo.PmoTemplate;
import ru.bpc.sv2.pmo.PmoTemplateParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

/**
 * Manage Bean for List PMO Templates tab.
 */
@ViewScoped
@ManagedBean (name = "MbPmoTemplates")
public class MbPmoTemplates extends AbstractBean {
	private static final long serialVersionUID = -1673001723834684628L;

	private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

	private PaymentOrdersDao _paymentOrdersDao = new PaymentOrdersDao();

	private CyclesDao _cyclesDao = new CyclesDao();
	
	private PmoTemplate _activeTemplate;
	private PmoTemplate newTemplate;
	
	private PmoTemplate templateFilter;
	private List<Filter> templateFilters;

	private boolean selectMode;
	private boolean addSchedule;
	
	private List<SelectItem> eventTypes;
	
	private final DaoDataModel<PmoTemplate> _templatesSource;

	private final TableRowSelection<PmoTemplate> _templateSelection;
	
	private static String COMPONENT_ID = "templatesTable";
	private String tabName;
	private String parentSectionId;
	private String privilege;
	
	public MbPmoTemplates() {
		_templatesSource = new DaoDataModel<PmoTemplate>() {
			private static final long serialVersionUID = -4575425512518823699L;

			@Override
			protected PmoTemplate[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new PmoTemplate[0];
				try {
					setTemplatesFilters();
					params.setFilters(templateFilters.toArray(new Filter[templateFilters.size()]));
					params.setPrivilege(getPrivilege());
					return _paymentOrdersDao.getTemplates(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PmoTemplate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setTemplatesFilters();
					params.setFilters(templateFilters.toArray(new Filter[templateFilters.size()]));
					params.setPrivilege(getPrivilege());
					return _paymentOrdersDao.getTemplatesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_templateSelection = new TableRowSelection<PmoTemplate>(null, _templatesSource);
	}

	public DaoDataModel<PmoTemplate> getTemplates() {
		return _templatesSource;
	}

	public PmoTemplate getActiveTemplate() {
		return _activeTemplate;
	}

	public void setActiveTemplate(PmoTemplate activeTemplate) {
		this._activeTemplate = activeTemplate;
	}

	public SimpleSelection getTemplateSelection() {
		if (_activeTemplate == null && _templatesSource.getRowCount() > 0) {
			setFirstRowActive();
		}
		else if (_activeTemplate != null && _templatesSource.getRowCount() > 0)
		{
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTemplate.getModelId());
			_templateSelection.setWrappedSelection(selection);
			_activeTemplate = _templateSelection.getSingleSelection();			
		}
		return _templateSelection.getWrappedSelection();
	}
	
	public void setFirstRowActive() {
		_templatesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTemplate = (PmoTemplate) _templatesSource.getRowData();
		selection.addKey(_activeTemplate.getModelId());
		_templateSelection.setWrappedSelection(selection);
		if (_activeTemplate != null) {
			setInfo();
		}
	}

	public void setInfo() {
		
	}

	
	public void setTemplateSelection(SimpleSelection selection) {
		_templateSelection.setWrappedSelection(selection);
		_activeTemplate = _templateSelection.getSingleSelection();
	}

	public void search() {
		clearBean();
		boolean found = false;
		if (getTemplateFilter().getCustomerId() != null || getTemplateFilter().getObjectId() != null) {
			found = true;
		}
		// if no selected customers found then we must not search for payment orders at all
		if (found) {
			searching = true;
		}
	}

	public void clearFilter() {
		templateFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_templatesSource.flushCache();
		if (_templateSelection != null) {
			_templateSelection.clearSelection();
		}
		_activeTemplate = null;
	}

	public void changeSheduleState(ValueChangeEvent event) {
		Boolean state = (Boolean) event.getNewValue();
		if (state.booleanValue() && newTemplate.getSchedule() == null) {
			newTemplate.setSchedule(new PmoSchedule());
		}
		else if(!state.booleanValue()) newTemplate.setSchedule(null);
	}
	
	public void add() {
		newTemplate = new PmoTemplate();
		newTemplate.setInstId(getTemplateFilter().getInstId());
		newTemplate.setInstName(getTemplateFilter().getInstName());
		newTemplate.setLang(userLang);
		addSchedule = false;
		curMode = NEW_MODE;
	}
	
	public void edit() {
		try {
			newTemplate = (PmoTemplate) _activeTemplate.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newTemplate = _activeTemplate;
		}
		if (newTemplate.getSchedule() != null) {
			addSchedule = true;
			newTemplate.setScheduleAction(PmoTemplate.EDIT_SCHEDULE);
		} else {
			addSchedule = false;
			newTemplate.setScheduleAction(PmoTemplate.ADD_SCHEDULE);
		}
		curMode = EDIT_MODE;
	}

	public void view() {
		newTemplate = _activeTemplate;
	}
	
	public void save() {
		if (newTemplate.getSchedule() != null && !addSchedule) {
			if (newTemplate.isAddSchedule()) {
				newTemplate.setSchedule(null);
			} else {
				newTemplate.setScheduleAction(PmoTemplate.DELETE_SCHEDULE);
			}
		}
		try {
			newTemplate.setCustomerId(getTemplateFilter().getCustomerId());
			if (StringUtils.isEmpty(newTemplate.getEntityType()) || newTemplate.getObjectId() == null) {
				newTemplate.setEntityType(getTemplateFilter().getEntityType());
				newTemplate.setObjectId(getTemplateFilter().getObjectId());
			}
			if (newTemplate.getSchedule() != null) {
				newTemplate.getSchedule().setObjectId(newTemplate.getObjectId());
				newTemplate.getSchedule().setEntityType(newTemplate.getEntityType());
			}
			if (isEditMode()) {
				newTemplate = _paymentOrdersDao.editTemplate(userSessionId, newTemplate);
				_templatesSource.replaceObject(_activeTemplate, newTemplate);
			} else {
				newTemplate = _paymentOrdersDao.addTemplate(userSessionId, newTemplate);
				_templateSelection.addNewObjectToList(newTemplate);
			}
			_activeTemplate = newTemplate;

			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);

		}
	}

	public void delete() {
		try {
			_paymentOrdersDao.removeTemplate(userSessionId, _activeTemplate);
			FacesUtils.addMessageInfo("Template (id = " + _activeTemplate.getId()
					+ ") has been deleted.");

			_activeTemplate = _templateSelection.removeObjectFromList(_activeTemplate);
			if (_activeTemplate == null) {
				clearBean();
			} 
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		
	}
	
	
	
	public void setTemplatesFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		if (getTemplateFilter().getCustomerId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("customerId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getTemplateFilter().getCustomerId());
			filtersList.add(paramFilter);
		} else {
			if (StringUtils.isNotEmpty(getTemplateFilter().getEntityType())) {
				filtersList.add(Filter.create("entityType", getTemplateFilter().getEntityType()));
			}
			if (getTemplateFilter().getObjectId() != null) {
				filtersList.add(Filter.create("objectId", getTemplateFilter().getObjectId()));
			}

		}
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
		templateFilters = filtersList;
	}

	public PmoTemplate getTemplateFilter() {
		if (templateFilter == null)
			templateFilter = new PmoTemplate();
		return templateFilter;
	}

	public void setTemplateFilter(PmoTemplate templateFilter) {
		this.templateFilter = templateFilter;
	}

	public List<Filter> getTemplateFilters() {
		return templateFilters;
	}

	public void setTemplateFilters(List<Filter> templateFilters) {
		this.templateFilters = templateFilters;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public PmoTemplate getNewTemplate() {
		return newTemplate;
	}

	public void setNewTemplate(PmoTemplate newTemplate) {
		this.newTemplate = newTemplate;
	}
	
	public ArrayList<SelectItem> getPaymentStatuses() {
		return getDictUtils().getArticles(DictNames.PAYMENT_TEMPLATE_STATUS, false, false);
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activeTemplate.getId() + "");
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			PmoTemplate[] templates = _paymentOrdersDao.getTemplates(userSessionId, params);
			if (templates != null && templates.length > 0) {
				_activeTemplate = templates[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newTemplate.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newTemplate.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			PmoTemplate[] templates = _paymentOrdersDao.getTemplates(userSessionId, params);
			if (templates != null && templates.length > 0) {
				newTemplate = templates[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public List<SelectItem> getPurposesForCombo() {
		return getDictUtils().getLov(LovConstants.PAYMENT_PURPOSE);
	}
	
	public void showTemplateParameters() {
		MbPmoTemplateParameters beanSearch = (MbPmoTemplateParameters) ManagedBeanWrapper
				.getManagedBean("MbPmoTemplateParameters");
		PmoTemplateParameter paramFilter = new PmoTemplateParameter();
		paramFilter.setTemplateId(_activeTemplate.getId());
		beanSearch.setFilter(paramFilter);
		beanSearch.search();
	}
	
	public List<SelectItem> getEventTypes() {
		return getDictUtils().getLov(LovConstants.EVENT_TYPES);
	}
	
	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.PMO_TEMPLATE_ENTITIES);
	}
	
	public List<SelectItem> getAmountAlgorithms() {
		return getDictUtils().getArticles(DictNames.PAYMENT_AMOUNT_ALGORITHMS, false);
	}
	
	public List<SelectItem> getCycles() {
		if (newTemplate != null
				&& newTemplate.getSchedule() != null
				&& ApplicationConstants.PERIODIC_PAYMENT_CYCLE.equals(newTemplate.getSchedule()
						.getEventType())) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(userLang);
			filters[1] = new Filter();
			filters[1].setElement("cycleType");
			filters[1].setValue(ApplicationConstants.PERIODIC_PAYMENT_CYCLE);
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			try {
				Cycle[] cycles = _cyclesDao.getCycles(userSessionId, params);
				List<SelectItem> items = new ArrayList<SelectItem>(cycles.length);
				
				for (Cycle cycle: cycles) {
					items.add(new SelectItem(cycle.getId(), cycle.getDescription()));
				}
				return items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			}
		}
		return new ArrayList<SelectItem>(0);
	}

	public boolean isAddSchedule() {
		return addSchedule;
	}

	public void setAddSchedule(boolean addSchedule) {
		this.addSchedule = addSchedule;
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

	public String getPrivilege() {
		return privilege;
	}

	public void setPrivilege(String privilege) {
		this.privilege = privilege;
	}
	
	public boolean isCustomer(){
		return getNewTemplate() != null && EntityNames.CUSTOMER.equalsIgnoreCase(getNewTemplate().getEntityType());
	}
	
	public void prepareObject(){
		if (EntityNames.CUSTOMER.equalsIgnoreCase(getNewTemplate().getEntityType())){
			getNewTemplate().setObjectId(getTemplateFilter().getCustomerId());
			getNewTemplate().setObjectNumber(getTemplateFilter().getCustomerNumber());
		} else {
			getNewTemplate().setObjectId(null);
			getNewTemplate().setObjectNumber(null);
		}
	}
	
	public void prepareObjectId(){
		MbObjectIdModalPanel modalPanel = (MbObjectIdModalPanel)ManagedBeanWrapper
				.getManagedBean(MbObjectIdModalPanel.class);
		modalPanel.clearFilter();
		modalPanel.clearState();
		if (isEditMode()){
			modalPanel.getFilter().setNumber(
					getNewTemplate().getObjectNumber());
		}
		modalPanel.setEntityType(getNewTemplate().getEntityType());
		modalPanel.setInstId(getNewTemplate().getInstId());
		modalPanel.setCustomerId(getTemplateFilter().getCustomerId());
		modalPanel.setCustomerNumber(getTemplateFilter().getCustomerNumber());
		modalPanel.setSearching(false);
	}
	
	public void selectObject(){
		MbObjectIdModalPanel modalPanel = (MbObjectIdModalPanel)ManagedBeanWrapper
				.getManagedBean(MbObjectIdModalPanel.class);
		if (modalPanel.isAccount()){
			getNewTemplate().setObjectId(modalPanel.getActiveAccount().getId());
			getNewTemplate().setObjectNumber(modalPanel.getActiveAccount().getAccountNumber());
		} else if (modalPanel.isCard()){
			getNewTemplate().setObjectId(modalPanel.getActiveCard().getId());
			getNewTemplate().setObjectNumber(modalPanel.getActiveCard().getMask());
		} else if (modalPanel.isCustomer()){
			getNewTemplate().setObjectId(modalPanel.getActiveCustomer().getId());
			getNewTemplate().setObjectNumber(modalPanel.getActiveCustomer().getCustomerNumber());
		} else if (modalPanel.isTerminal()){
			getNewTemplate().setObjectId(modalPanel.getActiveTerminal().getId().longValue());
			getNewTemplate().setObjectNumber(modalPanel.getActiveTerminal().getTerminalNumber());
		} else if (modalPanel.isMerchant()){
			getNewTemplate().setObjectId(modalPanel.getActiveMerchant().getId());
			getNewTemplate().setObjectNumber(modalPanel.getActiveMerchant().getMerchantNumber());
		}
		
	}

	public boolean isInstitutionTemplate() {
		return EntityNames.INSTITUTION.equals(getTemplateFilter().getEntityType());
	}
}
