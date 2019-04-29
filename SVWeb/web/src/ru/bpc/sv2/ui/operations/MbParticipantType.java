package ru.bpc.sv2.ui.operations;

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
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.ParticipantType;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped @KeepAlive
@ManagedBean (name = "MbParticipantType")
public class MbParticipantType extends AbstractBean {
	private static final Logger logger = Logger.getLogger("OPERATIONS");

	private OperationDao operationDao = new OperationDao();

	private DictUtils dictUtils;

	private ParticipantType filter;

	private ParticipantType activeItem;

	private final DaoDataModel<ParticipantType> dataModel;
	private final TableRowSelection<ParticipantType> tableRowSelection;

	private List<SelectItem> participantTypes;

	private ParticipantType editingItem;

	public MbParticipantType() {
		dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		dataModel = new DaoDataModel<ParticipantType>() {
			@Override
			protected ParticipantType[] loadDaoData(SelectionParams params) {
				ParticipantType[] result = null;
				if (searching) {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					try {
						result = operationDao.getParticipantTypes(
								userSessionId, params);
					} catch (DataAccessException e) {
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				} else {
					result = new ParticipantType[0];
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
						result = operationDao.getParticipantTypesCount(
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
		tableRowSelection = new TableRowSelection<ParticipantType>(null,
				dataModel);
	}

	private void setFilters() {
		filters = new ArrayList<Filter>();

		Filter f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters.add(f);

		if (filter.getId() != null) {
			f = new Filter();
			f.setElement("id");
			f.setValue(filter.getId());
			filters.add(f);
		}

		if (filter.getOperType() != null) {
			f = new Filter();
			f.setElement("operType");
			f.setValue(filter.getOperType());
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

	public void createNewParticipantType() {
		editingItem = new ParticipantType();
		editingItem.setOperType(getFilter().getOperType());
		curMode = AbstractBean.NEW_MODE;
	}

	public void editActiveParticipantType() {
		editingItem = activeItem;
		curMode = AbstractBean.EDIT_MODE;
	}

	public void saveEditingParticipantType() {
		try {
			editingItem = operationDao.createParticipantType(userSessionId,
					editingItem);
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
		resetEditingParticipantType();
	}

	public void resetEditingParticipantType() {
		curMode = AbstractBean.VIEW_MODE;
		editingItem = null;
	}

	public void deleteActiveParticipantType() {
		try {
			operationDao.removeParticipantType(userSessionId, activeItem);
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
		activeItem = (ParticipantType) dataModel.getRowData();
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

	public ParticipantType getFilter() {
		if (filter == null) {
			filter = new ParticipantType();
		}
		return filter;
	}

	public DaoDataModel<ParticipantType> getDataModel() {
		return dataModel;
	}

	public ParticipantType getActiveItem() {
		return activeItem;
	}

	public ParticipantType getEditingItem() {
		return editingItem;
	}

	public List<SelectItem> getParticipantTypes() {
		if (participantTypes == null) {
			participantTypes = dictUtils.getArticles(DictNames.PARTY_TYPE,
					true, true);
		}
		return participantTypes;
	}

}
