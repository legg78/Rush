package ru.bpc.sv2.ui.audit;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbInfoUserSession")
public class MbInfoUserSession extends AbstractBean{

	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("AUDIT");

	private ProcessSession filter;
	private ProcessSession _activeInfo;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> networks;

	private final DaoDataModel<ProcessSession> _InfoSource;

	private final TableRowSelection<ProcessSession> _itemSelection;
	
	private static String COMPONENT_ID = "bottomTable";
	private String tabName;
	private String parentSectionId;
	
	private CommonDao _commonDao = new CommonDao();

	public MbInfoUserSession() {
		_InfoSource = new DaoDataModel<ProcessSession>() {
			private static final long serialVersionUID = -7240049904405091192L;

			@Override
			protected ProcessSession[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new ProcessSession[0];
				}
				try {
					return new ProcessSession[0];
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
				}
				return new ProcessSession[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					return 0;
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<ProcessSession>(null, _InfoSource);
	}

	public DaoDataModel<ProcessSession> getCardInstances() {
		return _InfoSource;
	}

	public ProcessSession getActiveInfo() {
		return _activeInfo;
	}

	public void setActiveCardInstance(ProcessSession activeInfo) {
		_activeInfo = activeInfo;
	}

	public SimpleSelection getItemSelection() {
		if (_activeInfo == null && _InfoSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeInfo != null && _InfoSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeInfo.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeInfo = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_InfoSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeInfo = (ProcessSession) _InfoSource.getRowData();
		selection.addKey(_activeInfo.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeInfo = _itemSelection.getSingleSelection();
	}
	
	public ProcessSession initializeInfo(Long sessionId) {
		ProcessSession[] result = new ProcessSession[0];
		result = _commonDao.getUserSessionInfo(userSessionId, new SelectionParams(new Filter("sessionId", sessionId)));
		if (result != null && result.length > 0) {
			_activeInfo = result[0];
		} else {
			_activeInfo = null;
		}
		return _activeInfo;
	}


	public void search() {
		clearState();
		searching = true;
	}

	public void clearFilter() {
		filter = new ProcessSession();
		clearState();
		searching = false;
	}

	public ProcessSession getFilter() {
		if (filter == null)
			filter = new ProcessSession();
		return filter;
	}

	public void setFilter(ProcessSession filter) {
		this.filter = filter;
	}

	private void setFilters() {
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeInfo = null;
		_InfoSource.flushCache();
		curLang = userLang;
	}

	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
}
