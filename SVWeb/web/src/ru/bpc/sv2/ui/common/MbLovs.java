package ru.bpc.sv2.ui.common;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.common.Lov;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbLovs")
public class MbLovs extends AbstractBean{
	private static final Logger logger = Logger.getLogger("COMMON");

	private static String COMPONENT_ID = "2062:lovsTable";

	private CommonDao _commonDao = new CommonDao();

	

	private Lov lovFilter;
	private Lov newLov;
	private Lov detailLov;

	private final DaoDataModel<Lov> _lovsSource;
	private final TableRowSelection<Lov> _itemSelection;
	private Lov _activeLov;
	private String tabName;
	private ArrayList<SelectItem> dataTypes;
		

	public MbLovs() {
		
		pageLink = "common|lovs";
		_lovsSource = new DaoDataModel<Lov>() {
			@Override
			protected Lov[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Lov[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getLovs(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Lov[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _commonDao.getLovsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Lov>(null, _lovsSource);
	}

	public DaoDataModel<Lov> getLovs() {
		return _lovsSource;
	}

	public Lov getActiveLov() {
		return _activeLov;
	}

	public void setActiveLov(Lov activeLov) {
		_activeLov = activeLov;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeLov == null && _lovsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeLov != null && _lovsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeLov.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeLov = _itemSelection.getSingleSelection();
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
					&& !_itemSelection.getSingleSelection().getId().equals(_activeLov.getId())) {
				changeSelect = true;
			}
			_activeLov = _itemSelection.getSingleSelection();
	
			if (_activeLov != null) {
				setBeans();
				if (changeSelect) {
					detailLov = (Lov) _activeLov.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_lovsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeLov = (Lov) _lovsSource.getRowData();
		selection.addKey(_activeLov.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeLov != null) {
			setBeans();
			detailLov = (Lov) _activeLov.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setBeans() {
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		curLang = userLang;
		clearBean();
		lovFilter = new Lov();
		searching = false;
	}

	public void setFilters() {
		lovFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (lovFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(lovFilter.getId().toString());
			filters.add(paramFilter);
		}
		if (lovFilter.getName() != null && lovFilter.getName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setValue(lovFilter.getName().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (lovFilter.getModuleCode() != null 
				&& lovFilter.getModuleCode().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("moduleCode");
			paramFilter.setValue(lovFilter.getModuleCode().trim().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}

	public void add() {
		newLov = new Lov();
		newLov.setLang(userLang);
		curLang = newLov.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newLov = (Lov) detailLov.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		
		if (newLov.getDict() != null) {
			newLov.setDict(DictNames.MAIN_DICTIONARY + newLov.getDict());
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
//		try {
//			_commonDao.deleteLov(userSessionId, _activeLov);
//
//			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common",
//					"lov_deleted", "(id = " + _activeLov.getId() + ")");
//
//			if (searching) {
//				// refresh page if search is on
//				clearBean();
//			} else {
//				// delete object from active page if search is off
//				int index = _lovsSource.getActivePage().indexOf(_activeLov);
//				_lovsSource.getActivePage().remove(_activeLov);
//				_itemSelection.clearSelection();
//				
//				// if something's left on the page, select item of same index
//				if (_lovsSource.getActivePage().size() > 0) {
//					SimpleSelection selection = new SimpleSelection();
//					if (_lovsSource.getActivePage().size() > index) {
//						_activeLov = _lovsSource.getActivePage().get(index);
//					} else {
//						_activeLov = _lovsSource.getActivePage().get(index - 1);
//					}
//					selection.addKey(_activeLov.getModelId());
//					_itemSelection.setWrappedSelection(selection);
//					
//					setBeans();
//				} else {
//					clearBean();
//				}
//			}
//
//			FacesUtils.addMessageInfo(msg);
//		} catch (Exception e) {
//			FacesUtils.addMessageError(e);
//			logger.error("", e);
//		}
	}

	public void save() {
		try {
			if (newLov.getDict() != null && newLov.getLovQuery() != null
					&& newLov.getLovQuery().trim().length() > 0) {
				// TODO: i18n
				throw new Exception("Define only one source: either 'Dictionary' OR 'LOV query'.");
			}
			newLov.setModuleCode(newLov.getModuleCode().toUpperCase());
			
			// if dictionary is set then take article code only (without 'DICT' prefix)
			if (newLov.getDict() != null) {
				newLov.setDict(newLov.getDict().substring(4));
			}
			
			if (isNewMode()) {
				newLov = _commonDao.addLov(userSessionId, newLov);
				detailLov = (Lov) newLov.clone();
				_itemSelection.addNewObjectToList(newLov);
			} else {
				newLov = _commonDao.editLov(userSessionId, newLov);
				detailLov = (Lov) newLov.clone();
				if (!userLang.equals(newLov.getLang())) {
					newLov = getNodeByLang(_activeLov.getId(), userLang);
				}
				_lovsSource.replaceObject(_activeLov, newLov);				
			}
			_activeLov = newLov;
			setBeans();
			curMode = VIEW_MODE;

			FacesUtils.addMessageInfo(FacesUtils.getMessage(
					"ru.bpc.sv2.ui.bundles.Common", "lov_saved"));

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Lov getFilter() {
		if (lovFilter == null) {
			lovFilter = new Lov();
		}
		return lovFilter;
	}

	public void setFilter(Lov lovFilter) {
		this.lovFilter = lovFilter;
	}

	public Lov getNewLov() {
		if (newLov == null) {
			newLov = new Lov();
		}
		return newLov;
	}

	public void setNewLov(Lov newLov) {
		this.newLov = newLov;
	}

	public ArrayList<SelectItem> getDictionaries() {
		return getDictUtils().getArticles(DictNames.MAIN_DICTIONARY, false);
	}

	public ArrayList<SelectItem> getSortModes() {
		return getDictUtils().getArticles(DictNames.LOV_SORT_MODE, false);
	}

	public ArrayList<SelectItem> getAppearances() {
		return getDictUtils().getArticles(DictNames.LOV_APPEARANCE, false);
	}

	public void clearBean() {
		_lovsSource.flushCache();
		_itemSelection.clearSelection();
		_activeLov = null;
		detailLov = null;
		// clear dependent beans
		clearBeans();
	}

	private void clearBeans() {
		
	}
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeLov != null) {
			curLang = (String) event.getNewValue();
			detailLov = getNodeByLang(detailLov.getId(), curLang);
		}
	}
	
	public void confirmEditLanguage() {
		curLang = newLov.getLang();
		Lov tmp = getNodeByLang(newLov.getId(), newLov.getLang());
		if (tmp != null) {
			newLov.setName(tmp.getName());
		}
	}
	
	public Lov getNodeByLang(Integer id, String lang) {
		if (_activeLov != null) {
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
				Lov[] lovs = _commonDao.getLovs(userSessionId, params);
				if (lovs != null && lovs.length > 0) {
					return lovs[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}
	
	public ArrayList<SelectItem> getDataTypes() {
		if (dataTypes == null){
			dataTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.DATA_TYPES);
		}
		return dataTypes;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Lov getDetailLov() {
		return detailLov;
	}

	public void setDetailLov(Lov detailLov) {
		this.detailLov = detailLov;
	}
	

}
