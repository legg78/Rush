package ru.bpc.sv2.ui.acquiring;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.acquiring.MccSelectionTpl;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import java.util.ArrayList;

@ViewScoped
@ManagedBean (name = "MbMccSelectionTpl")
public class MbMccSelectionTpl extends AbstractBean {
	private static final long serialVersionUID = 676448833153787077L;

	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private AcquiringDao acquiringDao = new AcquiringDao();

	private MccSelectionTpl filter;

	private MccSelectionTpl activeItem;

	private final DaoDataModel<MccSelectionTpl> dataModel;
	private final TableRowSelection<MccSelectionTpl> tableRowSelection;

	private MccSelectionTpl editingItem;

	private MbMccSelection mbMccSelection;
	
	private String tabName;
	
	public MbMccSelectionTpl() {
		pageLink = "acquiring|mccRedefinitionGroups";
		tabName = "detailsTab";
		mbMccSelection = ManagedBeanWrapper.getManagedBean(MbMccSelection.class);
		
		dataModel = new DaoDataModel<MccSelectionTpl>() {
			private static final long serialVersionUID = -3746239695930674150L;

			@Override
			protected MccSelectionTpl[] loadDaoData(SelectionParams params) {
				MccSelectionTpl[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = acquiringDao.getMccSelectionTpls(
								userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new MccSelectionTpl[0];
				}
				return result;
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				int result = 0;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = acquiringDao.getMccSelectionTplsCount(
								userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = 0;
				}
				return result;
			}
		};
		tableRowSelection = new TableRowSelection<MccSelectionTpl>(null,
				dataModel);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		getFilter();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getName() != null && filter.getName().trim().length() > 0) {
			f = new Filter();
			f.setElement("name");
			f.setValue(filter.getName().trim().replaceAll("[*]", "%")
					.replaceAll("[?]", "_").toUpperCase());
			filters.add(f);
		}
	}

	public void search() {
		clearState();
		clearBeansStates();
		searching = true;
	}

	public void clearState() {
		tableRowSelection.clearSelection();
		activeItem = null;
		dataModel.flushCache();
		curLang = userLang;
	}

	public void clearBeansStates() {
		mbMccSelection.clearFilter();
	}

	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public void createNewMccSelectionTpl() {
		editingItem = new MccSelectionTpl();
		curMode = AbstractBean.NEW_MODE;
	}

	public void editActiveMccSelectionTpl() {
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}

	public void saveEditingMccSelectionTpl() {
		try {
			if (isNewMode()) {
				editingItem = acquiringDao.createMccSelectionTpl(
						userSessionId, editingItem);
			} else if (isEditMode()) {
				editingItem = acquiringDao.modifyMccSelectionTpl(
						userSessionId, editingItem);
			}
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		if (isNewMode()) {
			tableRowSelection.addNewObjectToList(editingItem);
		} else {
			try {
				dataModel.replaceObject(activeItem, editingItem);
			} catch (Exception e) {
				e.printStackTrace();
			}
		}
		activeItem = editingItem;
		setBeansState();
		resetEditingMccSelectionTpl();
	}

	public void resetEditingMccSelectionTpl() {
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}

	public void deleteActiveMccSelectionTpl() {
		try {
			acquiringDao.removeMccSelectionTpl(userSessionId, activeItem);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
		if (activeItem == null) {
			clearState();
			clearBeansStates();
		} else {
			setBeansState();
		}
	}

	public SimpleSelection getItemSelection() {
		if (activeItem == null && dataModel.getRowCount() > 0) {
			prepareItemSelection();
		}
		return tableRowSelection.getWrappedSelection();
	}

	public void prepareItemSelection() {
		dataModel.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		activeItem = (MccSelectionTpl) dataModel.getRowData();
		selection.addKey(activeItem.getModelId());
		tableRowSelection.setWrappedSelection(selection);
		if (activeItem != null) {
			setBeansState();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		tableRowSelection.setWrappedSelection(selection);
		activeItem = tableRowSelection.getSingleSelection();
		if (activeItem != null) {
			setBeansState();
		}
	}

	private void setBeansState() {
		mbMccSelection.clearFilter();
		mbMccSelection.getFilter().setMccTemplateId(activeItem.getId());
		mbMccSelection.search();
	}

	public MccSelectionTpl getFilter() {
		if (filter == null) {
			filter = new MccSelectionTpl();
		}
		return filter;
	}

	public DaoDataModel<MccSelectionTpl> getDataModel() {
		return dataModel;
	}

	public MccSelectionTpl getActiveItem() {
		return activeItem;
	}

	public MccSelectionTpl getEditingItem() {
		return editingItem;
	}
	
	public void confirmEditLanguage() {
		curLang = editingItem.getLang();
		editingItem = itemByLang(editingItem.getId(), editingItem.getLang());
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();
		activeItem = itemByLang(activeItem.getId(), curLang);
	}	
	
	public MccSelectionTpl itemByLang(Long id, String lang) {
		SelectionParams params = new SelectionParams(
			new Filter[] {
				new Filter("id", id), 
				new Filter("lang", lang)					
		});
		try {
			MccSelectionTpl[] mccSelectionTpls = acquiringDao.getMccSelectionTpls(userSessionId, params);
			if (mccSelectionTpls != null && mccSelectionTpls.length > 0) {
				return mccSelectionTpls[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return null;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("mccRedefinitionsTab")) {
			MbMccSelection bean = (MbMccSelection) ManagedBeanWrapper
					.getManagedBean("MbMccSelection");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}
	}
	
	public String getSectionId() {
		return SectionIdConstants.ACQUIRING_MCC_REF_GROUP;
	}
}
