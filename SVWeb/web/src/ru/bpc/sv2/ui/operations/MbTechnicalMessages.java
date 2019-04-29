package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.operations.TechnicalMessage;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "mbTechnicalMessages")
public class MbTechnicalMessages extends AbstractBean {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private OperationDao _oprDao = new OperationDao();

	private TechnicalMessage filter;
	private TechnicalMessage newMsg;

	private final DaoDataModel<TechnicalMessage> _msgSource;
	private final TableRowSelection<TechnicalMessage> _itemSelection;
	private TechnicalMessage _activeMsg;

	public MbTechnicalMessages() {
		
		
		_msgSource = new DaoDataModel<TechnicalMessage>() {
			@Override
			protected TechnicalMessage[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new TechnicalMessage[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _oprDao.getTechnicalMessages(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new TechnicalMessage[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _oprDao.getTechnicalMessagesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<TechnicalMessage>(null, _msgSource);
	}

	public DaoDataModel<TechnicalMessage> getMsgs() {
		return _msgSource;
	}

	public TechnicalMessage getActiveMsg() {
		return _activeMsg;
	}

	public void setActiveMsg(TechnicalMessage activeMsg) {
		_activeMsg = activeMsg;
	}

	public SimpleSelection getItemSelection() {
		if (_activeMsg == null && _msgSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeMsg != null && _msgSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeMsg.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeMsg = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeMsg = _itemSelection.getSingleSelection();

		if (_activeMsg != null) {
			setBeans();
		}
	}

	public void setFirstRowActive() {
		_msgSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeMsg = (TechnicalMessage) _msgSource.getRowData();
		selection.addKey(_activeMsg.getModelId());
		_itemSelection.setWrappedSelection(selection);

		if (_activeMsg != null) {
			setBeans();
		}
	}

	public void setBeans() {
		MbTechnicalMessageDetails techMessages = (MbTechnicalMessageDetails) ManagedBeanWrapper.getManagedBean("mbTechnicalMessageDetails");
		techMessages.clearFilter();
		techMessages.setFilter(_activeMsg);
		techMessages.search();
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		filter = new TechnicalMessage();
		clearBean();
		searching = false;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;

		paramFilter = new Filter("lang", userLang);
		filters.add(paramFilter);

		if (filter.getOperId() != null) {
			paramFilter = new Filter("operId", filter.getOperId());
			filters.add(paramFilter);
		}
		
	}

	public void add() {
		curMode = NEW_MODE;
	}

	public void edit() {
		curMode = EDIT_MODE;
	}

	public void delete() {
	}

	public void save() {
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public TechnicalMessage getFilter() {
		if (filter == null) {
			filter = new TechnicalMessage();
		}
		return filter;
	}

	public void setFilter(TechnicalMessage filter) {
		this.filter = filter;
	}

	public void clearBean() {
		_msgSource.flushCache();
		_itemSelection.clearSelection();
		_activeMsg = null;
		
		MbTechnicalMessageDetails techMessages = (MbTechnicalMessageDetails) ManagedBeanWrapper.getManagedBean("mbTechnicalMessageDetails");
		techMessages.clearFilter();
	}

	public Logger getLogger() {
		return logger;
	}

}
