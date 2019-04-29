package ru.bpc.sv2.ui.acm;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acm.SectionParameter;
import ru.bpc.sv2.common.Lov;
import ru.bpc.sv2.common.MenuNode;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AccessManagementDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean (name = "MbSectionParameters")
public class MbSectionParameters extends AbstractBean {
	private static final long serialVersionUID = -6266510750658704358L;

	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private static String COMPONENT_ID = "2024:sectionParamsTable";

	private AccessManagementDao _acmDao = new AccessManagementDao();

	private CommonDao _commonDao = new CommonDao();

	private SectionParameter filter;
	private SectionParameter newSectionParameter;
	private SectionParameter detailSectionParameter;

	private final DaoDataModel<SectionParameter> _sectionParamsSource;
	private final TableRowSelection<SectionParameter> _itemSelection;
	private SectionParameter _activeSectionParameter;
	private List<SelectItem> dataTypes;

	public MbSectionParameters() {
		pageLink = "acm|sectionParams";
		_sectionParamsSource = new DaoDataModel<SectionParameter>() {
			private static final long serialVersionUID = 4037918444632337511L;

			@Override
			protected SectionParameter[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new SectionParameter[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acmDao.getSectionParameters(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new SectionParameter[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _acmDao.getSectionParametersCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<SectionParameter>(null, _sectionParamsSource);
	}

	public DaoDataModel<SectionParameter> getSectionParameters() {
		return _sectionParamsSource;
	}

	public SectionParameter getActiveSectionParameter() {
		return _activeSectionParameter;
	}

	public void setActiveSectionParameter(SectionParameter activeSectionParameter) {
		_activeSectionParameter = activeSectionParameter;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeSectionParameter == null && _sectionParamsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeSectionParameter != null && _sectionParamsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeSectionParameter.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeSectionParameter = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeSectionParameter.getId())) {
				changeSelect = true;
			}
			_activeSectionParameter = _itemSelection.getSingleSelection();
	
			if (_activeSectionParameter != null) {
				setBeans();
				if (changeSelect) {
					detailSectionParameter = (SectionParameter) _activeSectionParameter.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_sectionParamsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSectionParameter = (SectionParameter) _sectionParamsSource.getRowData();
		selection.addKey(_activeSectionParameter.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
		detailSectionParameter = (SectionParameter) _activeSectionParameter.clone();
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		if (filter.getDataType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("dataType");
			paramFilter.setValue(filter.getDataType());
			filters.add(paramFilter);
		}
		if (filter.getSystemName() != null && filter.getSystemName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getSystemName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (filter.getSectionId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sectionId");
			paramFilter.setValue(filter.getSectionId());
			filters.add(paramFilter);
		}
		if (filter.getLabel() != null && filter.getLabel().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("label");
			paramFilter.setValue(filter.getLabel().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public SectionParameter getFilter() {
		if (filter == null) {
			filter = new SectionParameter();
		}
		return filter;
	}

	public void setFilter(SectionParameter filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();

		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void add() {
		newSectionParameter = new SectionParameter();
		newSectionParameter.setLang(userLang);
		curLang = newSectionParameter.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newSectionParameter = (SectionParameter) detailSectionParameter.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_acmDao.removeSectionParameter(userSessionId, _activeSectionParameter);

			_activeSectionParameter = _itemSelection.removeObjectFromList(_activeSectionParameter);
			if (_activeSectionParameter == null) {
				clearBean();
			} else {
				setBeans();
				detailSectionParameter = (SectionParameter) _activeSectionParameter.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newSectionParameter = _acmDao.addSectionParameter(userSessionId, newSectionParameter);
				detailSectionParameter = (SectionParameter) newSectionParameter.clone();
				_itemSelection.addNewObjectToList(newSectionParameter);
			} else {
				newSectionParameter = _acmDao.modifySectionParameter(userSessionId, newSectionParameter);
				detailSectionParameter = (SectionParameter) newSectionParameter.clone();
				if (!userLang.equals(newSectionParameter.getLang())) {
					newSectionParameter = getNodeByLang(_activeSectionParameter.getId(), userLang);
				}
				_sectionParamsSource.replaceObject(_activeSectionParameter, newSectionParameter);
			}
			_activeSectionParameter = newSectionParameter;
			curMode = VIEW_MODE;
			setBeans();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public SectionParameter getNewSectionParameter() {
		if (newSectionParameter == null) {
			newSectionParameter = new SectionParameter();
		}
		return newSectionParameter;
	}

	public void setNewSectionParameter(SectionParameter newSectionParameter) {
		this.newSectionParameter = newSectionParameter;
	}

	public void clearBean() {
		curLang = userLang;
		_sectionParamsSource.flushCache();
		_itemSelection.clearSelection();
		_activeSectionParameter = null;
		detailSectionParameter = null;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailSectionParameter = getNodeByLang(detailSectionParameter.getId(), curLang);
	}
	
	public SectionParameter getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id);
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			SectionParameter[] types = _acmDao.getSectionParameters(userSessionId, params);
			if (types != null && types.length > 0) {
				return types[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public List<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public List<SelectItem> getSections() {
		try {
			MenuNode[] sections = _commonDao.getMenuLight(userSessionId);
			List<SelectItem> items = new ArrayList<SelectItem>(sections.length);
			for (MenuNode section: sections) {
				items.add(new SelectItem(section.getId(), section.getName()));
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return new ArrayList<SelectItem>(0);
	}

	public List<SelectItem> getLovs() {
		if (newSectionParameter != null && newSectionParameter.getDataType() != null) {
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("dataType");
			filters[0].setValue(newSectionParameter.getDataType());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(curLang);
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);
			try {
				Lov[] lovs = _commonDao.getLovs(userSessionId, params);
				List<SelectItem> items = new ArrayList<SelectItem>(lovs.length);
				for (Lov lov: lovs) {
					items.add(new SelectItem(lov.getId(), lov.getName()));
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
	
	public void confirmEditLanguage() {
		curLang = newSectionParameter.getLang();
		SectionParameter tmp = getNodeByLang(newSectionParameter.getId(), newSectionParameter.getLang());
		if (tmp != null) {
			newSectionParameter.setLabel(tmp.getLabel());
			newSectionParameter.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public SectionParameter getDetailSectionParameter() {
		return detailSectionParameter;
	}

	public void setDetailSectionParameter(SectionParameter detailSectionParameter) {
		this.detailSectionParameter = detailSectionParameter;
	}

}
