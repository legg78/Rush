package ru.bpc.sv2.ui.hsm;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.hsm.HsmDevice;
import ru.bpc.sv2.hsm.HsmLMK;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.HsmDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbHsmLMKsSearch")
public class MbHsmLMKsSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("COMMUNICATION");

	private static String COMPONENT_ID = "1533:lmksTable";

	private HsmDao _hsmDao = new HsmDao();

	

	private HsmLMK hsmLMKFilter;
	private HsmLMK newLmk;
	private HsmLMK detailLmk;

	private final DaoDataModel<HsmLMK> _hsmLMKSource;
	private final TableRowSelection<HsmLMK> _itemSelection;
	private HsmLMK _activeLmk;
	private String tabName;

	private ArrayList<SelectItem> hsms;

	public MbHsmLMKsSearch() {
		
		pageLink = "hsm|lmks";
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");

		_hsmLMKSource = new DaoDataModel<HsmLMK>() {
			@Override
			protected HsmLMK[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new HsmLMK[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _hsmDao.getHsmLMKs(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new HsmLMK[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _hsmDao.getHsmLMKsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<HsmLMK>(null, _hsmLMKSource);

		if (!menu.isKeepState()) {
			// if user came here from menu, we don't need to select previously
			// selected tab
			clearFilter();
		}
	}

	public DaoDataModel<HsmLMK> getHsmLMKs() {
		return _hsmLMKSource;
	}

	public HsmLMK getActiveLmk() {
		return _activeLmk;
	}

	public void setActiveLmk(HsmLMK activeLmk) {
		_activeLmk = activeLmk;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeLmk == null && _hsmLMKSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeLmk != null && _hsmLMKSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeLmk.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeLmk = _itemSelection.getSingleSelection();
				setInfoDepenedOnSeqNum();
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
					&& !_itemSelection.getSingleSelection().getId().equals(_activeLmk.getId())) {
				changeSelect = true;
			}
			_activeLmk = _itemSelection.getSingleSelection();
	
			if (_activeLmk != null) {
				setBeans();
				if (changeSelect) {
					detailLmk = (HsmLMK) _activeLmk.clone();
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}	
	}

	public void setFirstRowActive() throws CloneNotSupportedException {
		_hsmLMKSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeLmk = (HsmLMK) _hsmLMKSource.getRowData();
		selection.addKey(_activeLmk.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeLmk != null) {
			setBeans();
			detailLmk = (HsmLMK) _activeLmk.clone();
		}
	}

	/**
	 * Sets data for backing beans used by dependent pages
	 */
	public void setInfoDepenedOnSeqNum() {

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
		hsmLMKFilter = new HsmLMK();
		clearBean();
		searching = false;
	}

	public void setFilters() {
		hsmLMKFilter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (hsmLMKFilter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(hsmLMKFilter.getId().toString());
			filters.add(paramFilter);
		}

		if (hsmLMKFilter.getDescription() != null
				&& hsmLMKFilter.getDescription().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("description");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(hsmLMKFilter.getDescription().trim().replaceAll("[*]",
					"%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (hsmLMKFilter.getCheckValue() != null
				&& hsmLMKFilter.getCheckValue().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("checkValue");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(hsmLMKFilter.getCheckValue());
			filters.add(paramFilter);
		}
	}

	public void add() {
		newLmk = new HsmLMK();
		newLmk.setLang(userLang);
		curLang = newLmk.getLang();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newLmk = (HsmLMK) detailLmk.clone();
		} catch (CloneNotSupportedException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		curMode = EDIT_MODE;
	}

	public void delete() {
		try {
			_hsmDao.removeHsmLMK(userSessionId, _activeLmk);

			if (searching) {
				// refresh page if search is on
				clearBean();
			} else {
				// delete object from active page if search is off
				int index = _hsmLMKSource.getActivePage().indexOf(_activeLmk);
				_hsmLMKSource.getActivePage().remove(_activeLmk);
				_itemSelection.clearSelection();
				
				// if something's left on the page, select item of same index
				if (_hsmLMKSource.getActivePage().size() > 0) {
					SimpleSelection selection = new SimpleSelection();
					if (_hsmLMKSource.getActivePage().size() > index) {
						_activeLmk = _hsmLMKSource.getActivePage().get(index);
					} else {
						_activeLmk = _hsmLMKSource.getActivePage().get(index - 1);
					}
					detailLmk = (HsmLMK) _activeLmk.clone();
					selection.addKey(_activeLmk.getModelId());
					_itemSelection.setWrappedSelection(selection);
					
					setBeans();
				} else {
					clearBean();
				}
			}

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newLmk = _hsmDao.addHsmLMK(userSessionId, newLmk);
				detailLmk = (HsmLMK) newLmk.clone();
				_itemSelection.addNewObjectToList(newLmk);
			} else {
				newLmk = _hsmDao.modifyHsmLMK(userSessionId, newLmk);
				detailLmk = (HsmLMK) newLmk.clone();
				if (!userLang.equals(newLmk.getLang())) {
					newLmk = getNodeByLang(_activeLmk.getId(), userLang);
				}
				_hsmLMKSource.replaceObject(_activeLmk, newLmk);
			}
			_activeLmk = newLmk;
			curMode = VIEW_MODE;

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	
	public void cancel() {
		curMode = VIEW_MODE;
	}

	public HsmLMK getFilter() {
		if (hsmLMKFilter == null) {
			hsmLMKFilter = new HsmLMK();
		}
		return hsmLMKFilter;
	}

	public void setFilter(HsmLMK hsmLMKFilter) {
		this.hsmLMKFilter = hsmLMKFilter;
	}

	public HsmLMK getNewLmk() {
		if (newLmk == null) {
			newLmk = new HsmLMK();
		}
		return newLmk;
	}

	public void setNewLmk(HsmLMK newLmk) {
		this.newLmk = newLmk;
	}

	public List<SelectItem> getActions() {
		return getDictUtils().getLov(LovConstants.HSM_ACTIONS);
	}

	public void clearBean() {
		_hsmLMKSource.flushCache();
		_itemSelection.clearSelection();
		_activeLmk = null;
		detailLmk = null;
		// clear dependent bean

	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void changeLanguageTable(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		_hsmLMKSource.flushCache();
	}

	public void changeLanguage(ValueChangeEvent event) {
		if (_activeLmk != null) {
			curLang = (String) event.getNewValue();
			detailLmk = getNodeByLang(detailLmk.getId(), curLang);
		}
	}
	
	public HsmLMK getNodeByLang(Integer id, String lang) {
		if (_activeLmk != null) {
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
				HsmLMK[] hsmLMKs = _hsmDao.getHsmLMKs(userSessionId, params);
				if (hsmLMKs != null && hsmLMKs.length > 0) {
					return hsmLMKs[0];
				}
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
		return null;
	}

	public ArrayList<SelectItem> getHsms() {
		if (hsms == null) {

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

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				HsmDevice[] hsmsTmp = _hsmDao.getDevices(userSessionId, params);
				for (HsmDevice hsm : hsmsTmp) {
					items.add(new SelectItem(hsm.getId(), hsm.getDescription()));
				}
				hsms = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (hsms == null)
					hsms = new ArrayList<SelectItem>();
			}
		}
		return hsms;
	}

	public void confirmEditLanguage() {
		curLang = newLmk.getLang();
		HsmLMK tmp = getNodeByLang(newLmk.getId(), newLmk.getLang());
		if (tmp != null) {
			newLmk.setDescription(tmp.getDescription());
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

	public HsmLMK getDetailLmk() {
		return detailLmk;
	}

	public void setDetailLmk(HsmLMK detailLmk) {
		this.detailLmk = detailLmk;
	}

}
