package ru.bpc.sv2.ui.vch;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.VchDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import ru.bpc.sv2.vch.Voucher;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbVouchers")
public class MbVouchers extends AbstractBean {
	private static final Logger logger = Logger.getLogger("VCH");

	private VchDao vchDao = new VchDao();

	

	private Voucher filter;

	private Voucher activeItem;

	private final DaoDataModel<Voucher> dataModel;
	private final TableRowSelection<Voucher> tableRowSelection;

	private Voucher editingItem;
	
	private static String COMPONENT_ID = "VoucherTable";
	private String tabName;
	private String parentSectionId;

	public MbVouchers() {
		
		dataModel = new DaoDataModel<Voucher>() {
			@Override
			protected Voucher[] loadDaoData(SelectionParams params) {
				Voucher[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = vchDao.getVouchers(userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new Voucher[0];
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
						result = vchDao
								.getVouchersCount(userSessionId, params);
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
		tableRowSelection = new TableRowSelection<Voucher>(null, dataModel);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);
		
		if (filter.getBatchId() != null){
			f = new Filter();
			f.setElement("batchId");
			f.setValue(filter.getBatchId());
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

	}

	public void clearFilter() {
		filter = null;
		clearState();
		clearBeansStates();
		searching = false;
	}

	public void createNewVoucher() {
		editingItem = new Voucher();
		editingItem.setBatchId(filter.getBatchId());
		curMode = AbstractBean.NEW_MODE;
	}

	public void editActiveVoucher() {
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}

	public void saveEditingVoucher() {
		try {
			if (isNewMode()) {
				editingItem = vchDao.createVoucher(userSessionId, editingItem);
			} else if (isEditMode()) {
				editingItem = vchDao.modifyVoucher(userSessionId, editingItem);
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
		resetEditingVoucher();
	}

	public void resetEditingVoucher() {
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}

	public void deleteActiveVoucher() {
		try {
			vchDao.removeVoucher(userSessionId, activeItem);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		activeItem = tableRowSelection.removeObjectFromList(activeItem);
		if (activeItem == null) {
			clearState();
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
		activeItem = (Voucher) dataModel.getRowData();
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

	}

	public Voucher getFilter() {
		if (filter == null) {
			filter = new Voucher();
		}
		return filter;
	}

	public DaoDataModel<Voucher> getDataModel() {
		return dataModel;
	}

	public Voucher getActiveItem() {
		return activeItem;
	}

	public Voucher getEditingItem() {
		return editingItem;
	}
	
	public List<SelectItem> getOperTypes(){
		List<SelectItem> result = getDictUtils().getArticles(DictNames.OPER_TYPE, true);
		return result;
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
