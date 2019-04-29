package ru.bpc.sv2.ui.application;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.constants.scale.ScaleConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.rules.Modifier;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.xml.XMLConstants;
import javax.xml.transform.TransformerConfigurationException;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.stream.StreamSource;
import javax.xml.validation.SchemaFactory;
import java.io.StringReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbApplicationFlows")
public class MbApplicationFlows extends AbstractBean {

	private static final long serialVersionUID = -4787844677085359271L;

	private static final Logger logger = Logger.getLogger("APPLICATIONS");

	private static String COMPONENT_ID = "2003:flowsTable";

	private ApplicationDao _applicationDao = new ApplicationDao();

	private RulesDao _rulesDao = new RulesDao();

	private ApplicationFlow filter;
	private ApplicationFlow newApplicationFlow;
	private ApplicationFlow detailApplicationFlow;

	private final DaoDataModel<ApplicationFlow> _flowSource;
	private final TableRowSelection<ApplicationFlow> _itemSelection;
	private ApplicationFlow _activeApplicationFlow;
	private String tabName;
	private ArrayList<SelectItem> institutions;
	private List<SelectItem> filterCustomerTypes;
	private List<SelectItem> filterContractTypes;
	private MbFlows flows;
	
	private String oldLang;

	public MbApplicationFlows() {
		pageLink = "applications|flows";
		tabName = "detailsTab";
		flows = (MbFlows)ManagedBeanWrapper.getManagedBean(MbFlows.class);
		restoreBean = (Boolean)FacesUtils.getSessionMapValue(pageLink);
		if (Boolean.TRUE.equals(restoreBean)) {
			FacesUtils.setSessionMapValue(pageLink, Boolean.FALSE);
			searching = flows.isSearching();
			_activeApplicationFlow = flows.getActiveFlow();
			tabName = flows.getActiveTab();
			filter = flows.getFilter();
			if (_activeApplicationFlow != null){
				detailApplicationFlow = _activeApplicationFlow;
				setPageNumber(flows.getPageNumber());
				setBeans();
			}
		}else if (restoreBean == null || !restoreBean) {
			restoreBean = Boolean.FALSE;
		}
		_flowSource = new DaoDataModel<ApplicationFlow>() {
			private static final long serialVersionUID = 8774910666474062629L;

			@Override
			protected ApplicationFlow[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ApplicationFlow[0];
				}
				try {
					setFilters();
					if (restoreBean){
						params.setRowIndexStart(flows.getRowIndexStart());
						params.setRowIndexEnd(flows.getRowIndexEnd());
						restoreBean = false;
					}else{
						flows.setRowIndexEnd(params.getRowIndexEnd());
						flows.setRowIndexStart(params.getRowIndexStart());
					}
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationFlows(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ApplicationFlow[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					if (restoreBean){
						params.setRowIndexStart(flows.getRowIndexStart());
						params.setRowIndexEnd(flows.getRowIndexEnd());
					}else{
						flows.setRowIndexEnd(params.getRowIndexEnd());
						flows.setRowIndexStart(params.getRowIndexStart());
					}
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _applicationDao.getApplicationFlowsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ApplicationFlow>(null, _flowSource);
	}

	public DaoDataModel<ApplicationFlow> getApplicationFlows() {
		return _flowSource;
	}

	public ApplicationFlow getActiveApplicationFlow() {
		return _activeApplicationFlow;
	}

	public void setActiveApplicationFlow(ApplicationFlow activeApplicationFlow) {
		_activeApplicationFlow = activeApplicationFlow;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeApplicationFlow == null && _flowSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeApplicationFlow != null && _flowSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeApplicationFlow.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeApplicationFlow = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeApplicationFlow.getId())) {
				changeSelect = true;
			}
			_activeApplicationFlow = _itemSelection.getSingleSelection();
	
			if (_activeApplicationFlow != null) {
				setBeans();
				if (changeSelect) {
					detailApplicationFlow = (ApplicationFlow) _activeApplicationFlow.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_flowSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeApplicationFlow = (ApplicationFlow) _flowSource.getRowData();
		selection.addKey(_activeApplicationFlow.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeApplicationFlow != null) {
			setBeans();
			detailApplicationFlow = (ApplicationFlow) _activeApplicationFlow.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
		MbAppFlowStages stages = (MbAppFlowStages) ManagedBeanWrapper
		        .getManagedBean("MbAppFlowStages");
		stages.setApplicationFlow(_activeApplicationFlow);
		stages.search();

		MbAppFlowTransitions transitions = (MbAppFlowTransitions) ManagedBeanWrapper
		        .getManagedBean("MbAppFlowTransitions");
		transitions.setApplicationFlow(_activeApplicationFlow);
		transitions.search();
		
		MbApplicationFlowSteps mbStep = (MbApplicationFlowSteps) ManagedBeanWrapper
		        .getManagedBean("MbApplicationFlowSteps");
		AppFlowStep step = new AppFlowStep();
		step.setFlowId(_activeApplicationFlow.getId());
		mbStep.setFilter(step);
		mbStep.search();

		MbFlowRoles rolesBean = (MbFlowRoles)ManagedBeanWrapper.getManagedBean(MbFlowRoles.class);
		rolesBean.setFlowId(_activeApplicationFlow.getId());
		rolesBean.setBackLink(pageLink);
		flows.setActiveFlow(_activeApplicationFlow);
		flows.setPageNumber(getPageNumber());
		rolesBean.search();
	}

	public void search() {
		clearBean();
		searching = true;
		curLang = userLang;
		flows.setSearching(searching);
		flows.setFilter(filter);
	}

	public void clearFilter() {
		curLang = userLang;
		filter = null;
		searching = false;
		clearBean();
		flows.setSearching(searching);
		flows.setFilter(filter);

		MbAppFlowStages stages = (MbAppFlowStages) ManagedBeanWrapper
		        .getManagedBean("MbAppFlowStages");
		stages.fullCleanBean();
		MbAppFlowTransitions transitions = (MbAppFlowTransitions) ManagedBeanWrapper
		        .getManagedBean("MbAppFlowTransitions");
		transitions.fullCleanBean();
		
		MbApplicationFlowSteps mbStep = (MbApplicationFlowSteps) ManagedBeanWrapper
		        .getManagedBean("MbApplicationFlowSteps");
		mbStep.fullCleanBean();

		MbFlowRoles rolesBean = (MbFlowRoles)ManagedBeanWrapper.getManagedBean(MbFlowRoles.class);
		rolesBean.clearBean();
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		if (filter.getAppType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("type");
			paramFilter.setValue(filter.getAppType());
			filters.add(paramFilter);
		}
		if (filter.getContractType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("contractType");
			paramFilter.setValue(filter.getContractType());
			filters.add(paramFilter);
		}
		if (filter.getCustomerType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("customerType");
			paramFilter.setValue(filter.getCustomerType());
			filters.add(paramFilter);
		}
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll(
			        "[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newApplicationFlow = new ApplicationFlow();
		newApplicationFlow.setLang(userLang);
		curLang = newApplicationFlow.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newApplicationFlow = (ApplicationFlow) detailApplicationFlow.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_applicationDao.deleteApplicationFlow(userSessionId, _activeApplicationFlow);

			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App", "flow_deleted",
			        "(id = " + _activeApplicationFlow.getId() + ")");

			_activeApplicationFlow = _itemSelection.removeObjectFromList(_activeApplicationFlow);
			if (_activeApplicationFlow == null) {
				clearBean();
			} else {
				setBeans();
				detailApplicationFlow = (ApplicationFlow) _activeApplicationFlow.clone();
			}

			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		if (!checkXsdAndXslt()) {
			return;
		}
		try {
			if (isNewMode()) {
				newApplicationFlow = _applicationDao.addApplicationFlow(userSessionId, newApplicationFlow);
				detailApplicationFlow = (ApplicationFlow) newApplicationFlow.clone();
				_itemSelection.addNewObjectToList(newApplicationFlow);
			} else {
				newApplicationFlow = _applicationDao.editApplicationFlow(userSessionId, newApplicationFlow);
				detailApplicationFlow = (ApplicationFlow) newApplicationFlow.clone();
				//adjust newProvider according userLang
				if (!userLang.equals(newApplicationFlow.getLang())) {
					newApplicationFlow = getNodeByLang(_activeApplicationFlow.getId(), userLang);
				}
				_flowSource.replaceObject(_activeApplicationFlow, newApplicationFlow);
			}
			_activeApplicationFlow = newApplicationFlow;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.App",
			        "flow_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public ApplicationFlow getFilter() {
		if (filter == null) {
			filter = new ApplicationFlow();
		}
		return filter;
	}

	public void setFilter(ApplicationFlow filter) {
		this.filter = filter;
	}

	public ApplicationFlow getNewApplicationFlow() {
		if (newApplicationFlow == null) {
			newApplicationFlow = new ApplicationFlow();
		}
		return newApplicationFlow;
	}

	public void setNewApplicationFlow(ApplicationFlow newApplicationFlow) {
		this.newApplicationFlow = newApplicationFlow;
	}

	public void clearBean() {
		_flowSource.flushCache();
		_itemSelection.clearSelection();
		_activeApplicationFlow = null;
		detailApplicationFlow = null;
		// clear dependent bean
		MbAppFlowStages stages = (MbAppFlowStages) ManagedBeanWrapper.getManagedBean("MbAppFlowStages");
		stages.clearBean();
		MbAppFlowTransitions transitions = (MbAppFlowTransitions) ManagedBeanWrapper
		        .getManagedBean("MbAppFlowTransitions");
		transitions.clearBean();
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		flows.setActiveTab(tabName);
		
		if (tabName.equalsIgnoreCase("stagesTab")) {
			MbAppFlowStages bean = (MbAppFlowStages) ManagedBeanWrapper
					.getManagedBean("MbAppFlowStages");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("transitionsTab")) {
			MbAppFlowTransitions bean = (MbAppFlowTransitions) ManagedBeanWrapper
					.getManagedBean("MbAppFlowTransitions");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("stepsTab")) {
			MbApplicationFlowSteps bean = (MbApplicationFlowSteps) ManagedBeanWrapper
					.getManagedBean("MbApplicationFlowSteps");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("rolesTab")){
			MbFlowRoles bean = (MbFlowRoles)ManagedBeanWrapper.getManagedBean(MbFlowRoles.class);
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_APP_FLOW;
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getFilterCustomerTypes() {
		if (filterCustomerTypes == null){
			filterCustomerTypes = getDictUtils().getLov(LovConstants.LIST_CUSTOMER_TYPES);
		}
		return filterCustomerTypes;
	}
	
	public List<SelectItem> getDialogCustomerTypes(){
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (isAcquiringType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		} else if (isIssuingType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		} else {
            return getDictUtils().getLov(LovConstants.CUSTOMER_TYPES_WITHOUT_PROD_TYPE);
		}
		return getDictUtils().getLov(LovConstants.CUSTOMER_TYPES_COND, paramMap);
	}
	
	public List<SelectItem> getDialogContractTypes() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (isAcquiringType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ACQUIRING_PRODUCT);
		} else if (isIssuingType()) {
			paramMap.put("PRODUCT_TYPE", ProductConstants.ISSUING_PRODUCT);
		}
		if (getNewApplicationFlow().getCustomerType() != null && !getNewApplicationFlow().getCustomerType().trim().equals("")) {
			paramMap.put("CUSTOMER_ENTITY_TYPE", getNewApplicationFlow().getCustomerType());
		}
		return getDictUtils().getLov(LovConstants.CONTRACT_TYPES, paramMap);
	}
	
	public List<SelectItem> getFilterContractTypes() {
		if (filterContractTypes == null){
			filterContractTypes = getDictUtils().getLov(LovConstants.LIST_CONTRACT_TYPES); 
		}
		return filterContractTypes;
	}

	public boolean isIssuingType() {
		return (ApplicationConstants.TYPE_ISSUING).equals(getNewApplicationFlow().getAppType());
	}

	public boolean isAcquiringType() {
		return (ApplicationConstants.TYPE_ACQUIRING).equals(getNewApplicationFlow().getAppType());
	}
	
	public List<SelectItem> getApplicationTypes() {
		return getDictUtils().getArticles(DictNames.AP_TYPES, false, true);
	}
	
	public ArrayList<SelectItem> getModifiers() {
		ArrayList<SelectItem> items;
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			if (getNewApplicationFlow().getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setValue(getNewApplicationFlow().getInstId() + ", "
						+ ApplicationConstants.DEFAULT_INSTITUTION);
				filtersList.add(paramFilter);
			} else {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setValue(ApplicationConstants.DEFAULT_INSTITUTION);
				filtersList.add(paramFilter);
			}
			filtersList.add(new Filter("scaleType", ScaleConstants.SCALE_FOR_FLOWS));
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
			Modifier[] mods = _rulesDao.getModifiers(userSessionId, params);

			items = new ArrayList<SelectItem>();
			for (Modifier mod: mods) {
				items.add(new SelectItem(mod.getId(), mod.getId() + " - " + mod.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			items = new ArrayList<SelectItem>(0);
		}
		return items;
	}
	
	public ApplicationFlow getNodeByLang(Integer id, String lang) {
		if (_activeApplicationFlow != null) {
			List<Filter> filtersList = new ArrayList<Filter>();

			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(id);
			filtersList.add(paramFilter);

			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(lang);
			filtersList.add(paramFilter);

			filters = filtersList;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			try {
				ApplicationFlow[] appFlows = _applicationDao.getApplicationFlows(userSessionId, params);
				if (appFlows != null && appFlows.length > 0) {
					return appFlows[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeApplicationFlow != null) {
			curLang = (String) event.getNewValue();
			detailApplicationFlow = getNodeByLang(detailApplicationFlow.getId(), curLang);
		}
	}

	public void editLanguage(ValueChangeEvent event) {
		oldLang = (String) event.getOldValue();
	}

	public void confirmEditLanguage() {
		curLang = newApplicationFlow.getLang();
		ApplicationFlow tmp = getNodeByLang(newApplicationFlow.getId(), newApplicationFlow.getLang());
		if (tmp != null) {
			newApplicationFlow.setName(tmp.getName());
			newApplicationFlow.setDescription(tmp.getDescription());
		}
	}

	public void cancelEditLanguage() {
		newApplicationFlow.setLang(oldLang);
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public void reloadCache() {
		try {
			AppElementsCache.getInstance().reload();
		} catch (Exception e) {
			logger.error("", e);
		}
	}
	
	public List<SelectItem> getBooleans() {
		return getDictUtils().getLov(LovConstants.BOOLEAN);
	}
	
	private boolean checkXsdAndXslt() {
		boolean result = true;
		if (newApplicationFlow.getXsltSource() != null) {
			newApplicationFlow.setXsltSource(newApplicationFlow.getXsltSource().trim());
			if (newApplicationFlow.getXsltSource().length() > 0) {
				try {
					TransformerFactory tFactory = TransformerFactory.newInstance();
					tFactory.newTransformer(new StreamSource(new StringReader(newApplicationFlow
							.getXsltSource())));
				} catch (TransformerConfigurationException e) {
					result = false;
					logger.error("", e);
					FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
							"malformed_xslt") + ". " + e.getMessage());
				}
			} else {
				newApplicationFlow.setXsltSource(null);
			}
		}

		if (newApplicationFlow.getXsdSource() != null) {
			newApplicationFlow.setXsdSource(newApplicationFlow.getXsdSource().trim());
			if (newApplicationFlow.getXsdSource().length() > 0) {
				try {
					SchemaFactory schemaFactory = SchemaFactory
							.newInstance(XMLConstants.W3C_XML_SCHEMA_NS_URI);
					schemaFactory.newSchema(new StreamSource(new StringReader(newApplicationFlow
							.getXsdSource())));
				} catch (Exception e) {
					result = false;
					logger.error("", e);
					FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Msg",
							"malformed_xsd") + ". " + e.getMessage());
				}
			} else {
				newApplicationFlow.setXsdSource(null);
			}
		}
		return result;
	}

	public ApplicationFlow getDetailApplicationFlow() {
		return detailApplicationFlow;
	}

	public void setDetailApplicationFlow(ApplicationFlow detailApplicationFlow) {
		this.detailApplicationFlow = detailApplicationFlow;
	}
	
}
