package ru.bpc.sv2.ui.products;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.products.AttrScale;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbAttrScales")
public class MbAttrScales extends AbstractBean {
	private static final long serialVersionUID = 4325390666521979463L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");

	private RulesDao _rulesDao = new RulesDao();

	private ProductsDao _productsDao = new ProductsDao();
	
    private AttrScale filter;
    private AttrScale _activeAttrScale;
	private Integer attrId;
	private String attrName;
	private AttrScale newAttrScale;
	private ArrayList<SelectItem> institutions;
	
	private final DaoDataModel<AttrScale> _attrScaleSource;
	private final TableRowSelection<AttrScale> _itemSelection;
	
	private static String COMPONENT_ID = "attrScalesTable";
	private String tabName;
	private String parentSectionId;

	public MbAttrScales() {
		_attrScaleSource = new DaoDataModel<AttrScale>() {
			private static final long serialVersionUID = -1674701069129453763L;

			@Override
			protected AttrScale[] loadDaoData(SelectionParams params) {
				if (attrId == null)
					return new AttrScale[0];
				
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));						
					return _productsDao.getAttrScales( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);					
				}
				return new AttrScale[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (attrId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _productsDao.getAttrScalesCount( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<AttrScale>(null, _attrScaleSource);
    }

    public DaoDataModel<AttrScale> getAttrScales() {
		return _attrScaleSource;
	}

	public AttrScale getActiveAttrScale() {
		return _activeAttrScale;
	}

	public void setActiveAttrScale(AttrScale activeEntryTemplate) {
		_activeAttrScale = activeEntryTemplate;
	}

	public SimpleSelection getItemSelection() {
		if (_activeAttrScale == null && _attrScaleSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeAttrScale != null && _attrScaleSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeAttrScale.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeAttrScale = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activeAttrScale = _itemSelection.getSingleSelection();
		
		if (_activeAttrScale != null) {
		}
	}
	
	public void setFirstRowActive() {
		_attrScaleSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeAttrScale = (AttrScale) _attrScaleSource.getRowData();
		selection.addKey(_activeAttrScale.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter  = new Filter();
		paramFilter.setElement("attrId");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(attrId.toString());
		filters.add(paramFilter);
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
	}
	
	public AttrScale getFilter() {
		if (filter == null)
			filter = new AttrScale();
		return filter;
	}

	public void setFilter(AttrScale filter) {
		this.filter = filter;
	}

	public void add() {
		newAttrScale = new AttrScale();
		newAttrScale.setAttrId(attrId);
		newAttrScale.setLang(userLang);
		
		curMode = NEW_MODE;
	}

	public void edit() {
//		try {
//			newAttrScale = _activeAttrScale.clone();
//		} catch (CloneNotSupportedException e) {
//			newAttrScale = _activeAttrScale; 
//		}
//		curMode = EDIT_MODE;
	}

	public void save() {
		try {
			if (isEditMode()) {
				newAttrScale = _productsDao.editAttrScale(userSessionId, newAttrScale);
				_attrScaleSource.replaceObject(_activeAttrScale, newAttrScale);
			} else {
				newAttrScale = _productsDao.addAttrScale(userSessionId, newAttrScale);
				_itemSelection.addNewObjectToList(newAttrScale);
			}
			_activeAttrScale = newAttrScale;
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(
					FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul", "attr_scale_saved"));
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public void delete() {
		try {
			_productsDao.removeAttrScale(userSessionId, _activeAttrScale);
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo(
					FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Rul", "attr_scale_removed"));
			
			_activeAttrScale = _itemSelection.removeObjectFromList(_activeAttrScale);
			if (_activeAttrScale == null) {
				clearBean();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error(e.getMessage(), e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void setCurMode(int mode) {
		curMode = mode;
	}

	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}

	public boolean isTranslMode() {
		return curMode == TRANSL_MODE;
	}

	public AttrScale getNewAttrScale() {
		if (newAttrScale == null) {
			newAttrScale = new AttrScale();
		}
		return newAttrScale;
	}

	public void setNewAttrScale(AttrScale newAttrScale) {
		this.newAttrScale = newAttrScale;
	}

	public String getCurLang() {
		return curLang;
	}

	public void setCurLang(String curLang) {
		this.curLang = curLang;
	}

	public Integer getEntrySetId() {
		return attrId;
	}

	public void setEntrySetId(Integer attrId) {
		this.attrId = attrId;
	}

	public String getEntrySetName() {
		return attrName;
	}

	public void setEntrySetName(String attrName) {
		this.attrName = attrName;
	}

	public ArrayList<SelectItem> getBalanceTypes() {
		return getDictUtils().getArticles(DictNames.BALANCE_TYPE, true, false);
	}

	public void clearBean() {
		_itemSelection.clearSelection();
		_activeAttrScale = null;
		_attrScaleSource.flushCache();
	}
	
	public void fullCleanBean() {
		attrId = null;
		attrName = null;
		clearBean();
	}
	
	public boolean isSearching() {
		return searching;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
	}
	
	public void search() {
		_itemSelection.clearSelection();
		_activeAttrScale = null;
		_attrScaleSource.flushCache();
		setSearching(true);
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getScales() {
		if (newAttrScale == null || newAttrScale.getInstId() == null) {
			return new ArrayList<SelectItem>(0);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		
		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("instId");
		filters[0].setValue(newAttrScale.getInstId().toString());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);
		filters[2] = new Filter();
		filters[2].setElement("scaleType");
		filters[2].setValue("SCTPPROD");	// TODO: set as constant?
		params.setFilters(filters);
		
		ModScale[] scales;
		try {
			scales = _rulesDao.getModScales( userSessionId, params);
		} catch (Exception e) {
			logger.error("",e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}

		ArrayList<SelectItem> items = new ArrayList<SelectItem>(scales.length);
		for (ModScale scale: scales) {
			items.add(new SelectItem(scale.getId(), scale.getName()));
		}
		return items;
	}

	public Integer getAttrId() {
		return attrId;
	}

	public void setAttrId(Integer attrId) {
		this.attrId = attrId;
	}

	public String getAttrName() {
		return attrName;
	}

	public void setAttrName(String attrName) {
		this.attrName = attrName;
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
}
