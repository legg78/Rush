package ru.bpc.sv2.ui.fraud;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.fraud.Suite;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.FraudDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbSuites")
public class MbSuites extends AbstractBean {
	private static final Logger logger = Logger.getLogger("FRAUD_PREVENTION");

	private static String COMPONENT_ID = "1802:suitesTable";

	private FraudDao _fraudDao = new FraudDao();

	

	private Suite filter;
	private Suite _activeSuite;
	private Suite newSuite;
	private Suite detailSuite;

	private ArrayList<SelectItem> institutions;

	private final DaoDataModel<Suite> _suitesSource;
	private final TableRowSelection<Suite> _itemSelection;
	
	private String tabName;
	
	public MbSuites() {
		
		pageLink = "fraud|suites";
		tabName = "detailsTab";
		_suitesSource = new DaoDataModel<Suite>() {
			@Override
			protected Suite[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Suite[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getSuites(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Suite[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _fraudDao.getSuitesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Suite>(null, _suitesSource);
	}

	public DaoDataModel<Suite> getSuites() {
		return _suitesSource;
	}

	public Suite getActiveSuite() {
		return _activeSuite;
	}

	public void setActiveSuite(Suite activeSuite) {
		_activeSuite = activeSuite;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeSuite == null && _suitesSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeSuite != null && _suitesSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeSuite.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeSuite = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_suitesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeSuite = (Suite) _suitesSource.getRowData();
		detailSuite = (Suite) _activeSuite.clone();
		selection.addKey(_activeSuite.getModelId());
		_itemSelection.setWrappedSelection(selection);

		setBeans();
	}

	public void setItemSelection(SimpleSelection selection) {
		try {
			_itemSelection.setWrappedSelection(selection);
			boolean changeSelect = false;
			if (_itemSelection.getSingleSelection() != null 
					&& !_itemSelection.getSingleSelection().getId().equals(_activeSuite.getId())) {
				changeSelect = true;
			}
			_activeSuite = _itemSelection.getSingleSelection();
			if (_activeSuite != null) {
				setBeans();
				if (changeSelect) {
					detailSuite = (Suite) _activeSuite.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void search() {
		clearState();
		searching = true;
	}

	public void setBeans() {
		MbSuiteCases suiteCases = (MbSuiteCases) ManagedBeanWrapper.getManagedBean("MbSuiteCases");
		suiteCases.fullCleanBean();
		suiteCases.getFilter().setSuiteId(_activeSuite.getId());
		suiteCases.getFilter().setSuiteName(_activeSuite.getLabel());
		suiteCases.setBlockSuite(true);
		suiteCases.search();
	}

	public void clearBeansStates() {
		MbSuiteCases suiteCases = (MbSuiteCases) ManagedBeanWrapper.getManagedBean("MbSuiteCases");
		suiteCases.fullCleanBean();
	}

	public void clearFilter() {
		filter = null;

		clearState();
		searching = false;
	}

	public Suite getFilter() {
		if (filter == null) {
			filter = new Suite();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(Suite filter) {
		this.filter = filter;
	}

	private void setFilters() {
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
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getEntityType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("entityType");
			paramFilter.setValue(filter.getEntityType());
			filters.add(paramFilter);
		}
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setValue(filter.getId());
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

	public void add() {
		newSuite = new Suite();
		newSuite.setLang(userLang);
		curLang = newSuite.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newSuite = (Suite) detailSuite.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isNewMode()) {
				newSuite = _fraudDao.addSuite(userSessionId, newSuite);
				detailSuite = (Suite) newSuite.clone();
				_itemSelection.addNewObjectToList(newSuite);
			} else if (isEditMode()) {
				newSuite = _fraudDao.modifySuite(userSessionId, newSuite);
				detailSuite = (Suite) newSuite.clone();
				if (!userLang.equals(newSuite.getLang())) {
					newSuite = getNodeByLang(_activeSuite.getId(), userLang);
				}
				_suitesSource.replaceObject(_activeSuite, newSuite);
			}
			_activeSuite = newSuite;
			setBeans();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_fraudDao.removeSuite(userSessionId, _activeSuite);
			_activeSuite = _itemSelection.removeObjectFromList(_activeSuite);

			if (_activeSuite == null) {
				clearState();
			} else {
				setBeans();
				detailSuite = (Suite) _activeSuite.clone();
			}

			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public Suite getNewSuite() {
		if (newSuite == null) {
			newSuite = new Suite();
		}
		return newSuite;
	}

	public void setNewSuite(Suite newSuite) {
		this.newSuite = newSuite;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeSuite = null;
		detailSuite = null;
		_suitesSource.flushCache();

		clearBeansStates();
	}

	public void changeLanguage(ValueChangeEvent checkGroup) {
		curLang = (String) checkGroup.getNewValue();
		detailSuite = getNodeByLang(detailSuite.getId(), curLang);
	}
	
	public Suite getNodeByLang(Integer id, String lang) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(id.toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(lang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Suite[] checkGroups = _fraudDao.getSuites(userSessionId, params);
			if (checkGroups != null && checkGroups.length > 0) {
				return checkGroups[0];
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

	public List<SelectItem> getEntityTypes() {
		return getDictUtils().getLov(LovConstants.FRAUD_ENTITY_TYPES);
	}
	
	public void confirmEditLanguage() {
		curLang = newSuite.getLang();
		Suite tmp = getNodeByLang(newSuite.getId(), newSuite.getLang());
		if (tmp != null) {
			newSuite.setLabel(tmp.getLabel());
			newSuite.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public Suite getDetailSuite() {
		return detailSuite;
	}

	public void setDetailSuite(Suite detailSuite) {
		this.detailSuite = detailSuite;
	}
	
	public String getTabName() {
		return tabName;
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
}
