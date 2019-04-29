package ru.bpc.sv2.ui.aup;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.aup.AuthScheme;
import ru.bpc.sv2.aup.AuthTemplate;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAupSchemeTemplates")
public class MbAupSchemeTemplates extends AbstractBean {

	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");

	private AuthProcessingDao _aupDao = new AuthProcessingDao();

	

	private List<Filter> filters;

	private AuthTemplate templateFilter;
	private AuthTemplate _activeTemplate;
	private AuthTemplate newTemplate;
	private int selectedTemplate;
	private String templType;

	private AuthScheme scheme;

	private final DaoDataModel<AuthTemplate> _templateSource;

	private final TableRowSelection<AuthTemplate> _itemSelection;
	
	private static String COMPONENT_ID = "templatesTable";
	private String tabName;
	private String parentSectionId;
	
	public MbAupSchemeTemplates() {
		
		filters = new ArrayList<Filter>();

		_templateSource = new DaoDataModel<AuthTemplate>() {
			@Override
			protected AuthTemplate[] loadDaoData(SelectionParams params) {
				if (scheme == null) {
					return new AuthTemplate[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _aupDao.getTemplateForScheme(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new AuthTemplate[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (scheme == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					int result = _aupDao.getTemplatesForSchemeCount(userSessionId, params);
					logger.debug("MbAupSchemeTemplates: Number of retrieved records: " + result);
					return result;
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AuthTemplate>(null, _templateSource);
	}

	public DaoDataModel<AuthTemplate> getTemplates() {
		return _templateSource;
	}

	public List<SelectItem> getAllTemplates() {
		List<SelectItem> allTemplates = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			List<Filter> filters = new ArrayList<Filter>();
			Filter paramFilter;
			paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filters.add(paramFilter);
			if (getTemplType() != null){
				filters.add(new Filter("templType", getTemplType()));
			}	

			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(-1);
			AuthTemplate[] templates = _aupDao.getTemplates(userSessionId, params);
			for (AuthTemplate template : templates) {
				allTemplates.add(new SelectItem(template.getId(), template.getId() + " - " + template.getName()));
			}
			
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}
		return allTemplates;
	}

	public AuthTemplate getActiveTemplate() {
		return _activeTemplate;
	}
	
	public AuthTemplate getDetailTemplate() {
		return _activeTemplate;
	}

	public void setActiveTemplate(AuthTemplate activeTemplate) {
		_activeTemplate = activeTemplate;
	}

	public int getSelectedTemplate() {
		return selectedTemplate;
	}

	public void setSelectedTemplate(int selectedTemplate) {
		this.selectedTemplate = selectedTemplate;
	}

	public SimpleSelection getItemSelection() {
		if (_activeTemplate == null && _templateSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeTemplate != null && _templateSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeTemplate.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeTemplate = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeTemplate = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_templateSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeTemplate = (AuthTemplate) _templateSource.getRowData();
		selection.addKey(_activeTemplate.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeTemplate != null) {
			// setInfo();
		}
	}

	public void search() {
		clearState();
		setSearching(true);
	}

	public AuthTemplate getFilter() {
		if (templateFilter == null)
			templateFilter = new AuthTemplate();
		return templateFilter;
	}

	public void setFilter(AuthTemplate filter) {
		this.templateFilter = filter;
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		Filter f = new Filter("schemeId", scheme.getId());
		filters.add(f);
		if (getFilter().getName() != null && !getFilter().getName().isEmpty()){
			f = new Filter("name", 
					getFilter().getName().trim().replaceAll("[*]", "%").replaceAll("[?]",
							"_").toUpperCase());
			filters.add(f);
		}
		if (getFilter().getCondition() != null && !getFilter().getCondition().isEmpty()){
			f = new Filter("condition", 
					getFilter().getCondition().trim().replaceAll("[*]", "%").replaceAll("[?]",
							"_").toUpperCase());
			filters.add(f);
		}
		if (getFilter().getDescription() != null && !getFilter().getDescription().isEmpty()){
			f = new Filter("description", 
					getFilter().getDescription().trim().replaceAll("[*]", "%").replaceAll("[?]",
							"_").toUpperCase());
			filters.add(f);
		}
	}

	public void add() {
		curMode = NEW_MODE;

		newTemplate = new AuthTemplate();
		newTemplate.setLang(userLang);
	}

	public void save() {
		try {
			if ((scheme != null) && (selectedTemplate > 0)) {
				newTemplate = _aupDao.addTemplateToScheme(userSessionId, scheme.getId(), selectedTemplate);
				_itemSelection.addNewObjectToList(newTemplate);
				curMode = VIEW_MODE;

				FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Aup",
				        "template_saved"));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			if ((scheme != null) && (_activeTemplate != null)) {
				_aupDao.removeTemplateFromScheme(userSessionId, scheme.getId(), _activeTemplate.getId());

				_activeTemplate = _itemSelection.removeObjectFromList(_activeTemplate);
				if (_activeTemplate == null) {
					clearState();
				}
				curMode = VIEW_MODE;

				FacesUtils.addMessageInfo(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Aup",
				        "template_deleted"));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public AuthTemplate getNewTemplate() {
		if (newTemplate == null) {
			newTemplate = new AuthTemplate();
		}
		return newTemplate;
	}

	public void setNewTemplate(AuthTemplate newTemplate) {
		this.newTemplate = newTemplate;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeTemplate = null;
		_templateSource.flushCache();
		curLang = userLang;
	}

	public void fullCleanBean() {
		clearState();
	}

	public AuthScheme getScheme() {
		return scheme;
	}

	public void setScheme(AuthScheme scheme) {
		this.scheme = scheme;
	}

	public void changeLang(ValueChangeEvent event) {

	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeTemplate.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			AuthTemplate[] templates = _aupDao.getTemplates(userSessionId, params);
			if (templates != null && templates.length > 0) {
				_activeTemplate = templates[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
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

	public String getTemplType() {
		return templType;
	}

	public void setTemplType(String templType) {
		this.templType = templType;
	}

}
