package ru.bpc.sv2.ui.rules;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.PostConstruct;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbModScales")
public class MbModScales extends AbstractBean {
	/**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("RULES");

	private static String COMPONENT_ID = "1090:modScalesTable";

	private RulesDao _rulesDao = new RulesDao();

	private String tabName;

	private ModScale filter;
	private ModScale _activeModScale;
	private ModScale newModScale;
	private ModScale detailModScale;
	private MbModsSess sessBean;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<ModScale> _modScaleSource;

	private final TableRowSelection<ModScale> _itemSelection;

	public MbModScales() {
		
		pageLink = "rules|scales";
		tabName = "detailsTab";
		sessBean = (MbModsSess) ManagedBeanWrapper.getManagedBean("MbModsSess");
		thisBackLink = "rules|scales";
		
		_modScaleSource = new DaoDataModel<ModScale>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected ModScale[] loadDaoData(SelectionParams params) {
				
				if(restoreBean!=null && restoreBean){
					restoreBean = false;
					if (sessBean.getActivePageList() != null){
						List<ModScale> modScaleList = sessBean.getActivePageList();
//						sessBean.setActivePageList(null);
						return (ModScale[]) modScaleList
								.toArray(new ModScale[modScaleList.size()]);
					}
				}
				if (!searching) {
					return new ModScale[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getModScales(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ModScale[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				
				if (restoreBean!=null && restoreBean){
					FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
					if (sessBean.getActivePageList() != null) {
						return sessBean.getActivePageList().size();
					}
				}
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _rulesDao.getModScalesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ModScale>(null, _modScaleSource);

		
	}
	
	@PostConstruct
	public void init() {
		restoreBean = (Boolean) FacesUtils.getSessionMapValue(thisBackLink);
		if (restoreBean != null && restoreBean) {
			_activeModScale = sessBean.getActiveModScale();
			if (_activeModScale != null) {
				try {
					detailModScale = (ModScale) _activeModScale.clone();
				} catch (CloneNotSupportedException e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
			}
			filter = sessBean.getScalesFilter();
			_activeModScale = sessBean.getActiveModScale();
			tabName = sessBean.getScalesTabName();
			rowsNum = sessBean.getRowsNum();
			pageNumber = sessBean.getPageNumber();
			if(_activeModScale == null){
				searching = true;
			}
			setBeans(true);
			Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			mbMenu.externalSelect(pageLink);
			FacesUtils.setSessionMapValue(thisBackLink, Boolean.FALSE);
		}
	}

	public DaoDataModel<ModScale> getModScales() {
		return _modScaleSource;
	}

	public ModScale getActiveModScale() {
		return _activeModScale;
	}

	public void setActiveModScale(ModScale activeModScale) {
		_activeModScale = activeModScale;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeModScale == null && _modScaleSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeModScale != null && _modScaleSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeModScale.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeModScale = _itemSelection.getSingleSelection();
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
					&& !_itemSelection.getSingleSelection().getId().equals(_activeModScale.getId())) {
				changeSelect = true;
			}
			_activeModScale = _itemSelection.getSingleSelection();
	
			sessBean.setActiveModScale(_activeModScale);
	
			// set entry templates
			if (_activeModScale != null) {
				setBeans(false);
				if (changeSelect) {
					detailModScale = (ModScale) _activeModScale.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_modScaleSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeModScale = (ModScale) _modScaleSource.getRowData();
		selection.addKey(_activeModScale.getModelId());
		_itemSelection.setWrappedSelection(selection);

		sessBean.setActiveModScale(_activeModScale);

		if (_activeModScale != null) {
			setBeans(false);
			detailModScale = (ModScale) _activeModScale.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans(boolean restoreState) {
		MbModScaleParams modParamsBean = (MbModScaleParams) ManagedBeanWrapper
				.getManagedBean("MbModScaleParams");
		modParamsBean.setModScale(_activeModScale);
		modParamsBean.setBackLink(thisBackLink);
		modParamsBean.search();
		if (restoreState) {
			modParamsBean.loadState();
		}
		MbModifiers modsBean = (MbModifiers) ManagedBeanWrapper
				.getManagedBean("MbModifiers");
		modsBean.setModScale(_activeModScale);
		modsBean.search();
		if (!restoreState) {
			sessBean.setActivePageList(_modScaleSource.getActivePage());
		}
	}

	public void clearFilter() {
		filter = null;
		curLang = userLang;
		clearBean();

		searching = false;

	}

	public void search() {
		curMode = VIEW_MODE;
		sessBean.setScalesFilter(getFilter());
		clearBean();
		searching = true;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter = null;
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instOnly");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}

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

		if (filter.getScaleType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("scaleType");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getScaleType());
			filters.add(paramFilter);
		}

		if (filter.getName() != null
				&& filter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getDescription() != null
				&& filter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getDescription().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public ModScale getFilter() {
		if (filter == null) {
			filter = new ModScale();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(ModScale filter) {
		this.filter = filter;
	}

	public void add() {
		newModScale = new ModScale();
		newModScale.setInstId(getFilter().getInstId());
		newModScale.setLang(userLang);
		curLang = newModScale.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newModScale = (ModScale) detailModScale.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newModScale = _rulesDao.modifyModScale(userSessionId, newModScale);
				detailModScale = (ModScale) newModScale.clone();
				if (!userLang.equals(newModScale.getLang())) {
					newModScale = getNodeByLang(_activeModScale.getId(), userLang);
				}
				_modScaleSource.replaceObject(_activeModScale, newModScale);
			} else {
				newModScale = _rulesDao.addModScale(userSessionId, newModScale);
				detailModScale = (ModScale) newModScale.clone();
				_itemSelection.addNewObjectToList(newModScale);
				sessBean.setActiveModScale(newModScale);
			}
			_activeModScale = newModScale;
			setBeans(false);
			curMode = VIEW_MODE;

			// TODO: i18n
			FacesUtils.addMessageInfo("Modscale has been saved.");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rulesDao.deleteModScale(userSessionId, _activeModScale);
			curMode = VIEW_MODE;

			_activeModScale = _itemSelection.removeObjectFromList(_activeModScale);
			if (_activeModScale == null) {
				clearBean();
			} else {
				setBeans(false);
				detailModScale = (ModScale) _activeModScale.clone();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void close() {
		curMode = VIEW_MODE;

	}

	public ModScale getNewModScale() {
		if (newModScale == null) {
			newModScale = new ModScale();
		}
		return newModScale;
	}

	public void setNewModScale(ModScale newModScale) {
		this.newModScale = newModScale;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		detailModScale = getNodeByLang(detailModScale.getId(), curLang);
	}
	
	public ModScale getNodeByLang(Integer id, String lang) {
		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(id.toString());
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
			ModScale[] scales = _rulesDao.getModScales(userSessionId, params);
			if (scales != null && scales.length > 0) {
				return scales[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeModScale = null;
		detailModScale = null;
		_modScaleSource.flushCache();

		clearBeansStates();
	}

	public void clearBeansStates() {
		// clear dependent beans
		MbModScaleParams modParamsBean = (MbModScaleParams) ManagedBeanWrapper
				.getManagedBean("MbModScaleParams");
		modParamsBean.fullCleanBean();

		MbModifiers modsBean = (MbModifiers) ManagedBeanWrapper
				.getManagedBean("MbModifiers");
		modsBean.fullCleanBean();
	}
	
	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getScaleTypes() {
		return getDictUtils().getArticles(DictNames.SCALE_TYPE, true, false);
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		sessBean.setScalesTabName(tabName);
		
		if (tabName.equalsIgnoreCase("modParamsTab")) {
			MbModScaleParams bean = (MbModScaleParams) ManagedBeanWrapper
					.getManagedBean("MbModScaleParams");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("modifiersTab")) {
			MbModifiers bean = (MbModifiers) ManagedBeanWrapper
					.getManagedBean("MbModifiers");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		} 
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_MODIFIER_SCALE;
	}

	public void regeneratePackages() {
		try {
			_rulesDao.regeneratePackages(userSessionId);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
		sessBean.setPageNumber(pageNumber);
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
		sessBean.setRowsNum(rowsNum);
	}
	
	public void confirmEditLanguage() {
		curLang = newModScale.getLang();
		ModScale tmp = getNodeByLang(newModScale.getId(), newModScale.getLang());
		if (tmp != null) {
			newModScale.setName(tmp.getName());
			newModScale.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public ModScale getDetailModScale() {
		return detailModScale;
	}

	public void setDetailModScale(ModScale detailModScale) {
		this.detailModScale = detailModScale;
	}

}
