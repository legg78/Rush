package ru.bpc.sv2.ui.acquiring.reimbursement;

import java.text.SimpleDateFormat;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.acquiring.reimbursement.ReimbursementOperation;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbReimbOperationSearch")
public class MbReimbOperationSearch extends AbstractBean{
	private AcquiringDao _acquiringDao = new AcquiringDao();

	private ReimbursementOperation _activeOperation;
	private ReimbursementOperation newOperation;
	
	private ReimbursementOperation filter;
	private String backLink;
	private boolean showModal;
	private boolean selectMode;
	private MbReimbOperation reimbOperBean;
	private boolean bottomMode;
	private ArrayList<SelectItem> institutions;
	
	private final DaoDataModel<ReimbursementOperation> _operationsSource;

	private final TableRowSelection<ReimbursementOperation> _itemSelection;
	private static final Logger logger = Logger.getLogger("ACQUIRING");
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;

	public MbReimbOperationSearch() {
		bottomMode = false;
		
		reimbOperBean = (MbReimbOperation) ManagedBeanWrapper.getManagedBean("MbReimbOperation");

		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		if (!menu.isKeepState()) {
			reimbOperBean.setTabName("");
		} else {
			_activeOperation = reimbOperBean.getOperation();
			backLink = reimbOperBean.getBackLink();
			searching = reimbOperBean.isSearching();
		}

		_operationsSource = new DaoDataModel<ReimbursementOperation>() {
			@Override
			protected ReimbursementOperation[] loadDaoData(SelectionParams params) {
				if (!isSearching() || getFilter().getBatchId() == null)
					return new ReimbursementOperation[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _acquiringDao.getReimbursementOperations(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ReimbursementOperation[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching() || getFilter().getBatchId() == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _acquiringDao.getReimbursementOperationsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		if (_activeOperation != null) {

			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeOperation.getModelId());
			_itemSelection = new TableRowSelection<ReimbursementOperation>(selection,
					_operationsSource);
			setInfo();
		} else {
			_itemSelection = new TableRowSelection<ReimbursementOperation>(null, _operationsSource);
		}
	}

	public DaoDataModel<ReimbursementOperation> getOperations() {
		return _operationsSource;
	}

	public ReimbursementOperation getActiveOperation() {
		return _activeOperation;
	}

	public void setActiveOperation(ReimbursementOperation activeOperation) {
		_activeOperation = activeOperation;
	}

	public SimpleSelection getItemSelection() {
		setFirstRowActive();
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		if (_activeOperation == null && _operationsSource.getRowCount() > 0) {
			_operationsSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeOperation = (ReimbursementOperation) _operationsSource.getRowData();
			selection.addKey(_activeOperation.getModelId());
			_itemSelection.setWrappedSelection(selection);
			reimbOperBean.setOperation(_activeOperation);
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeOperation = _itemSelection.getSingleSelection();
		reimbOperBean.setOperation(_activeOperation);
		setInfo();
	}

	public void setInfo() {
		// MbProcessFilesSearch procFileBean =
		// (MbProcessFilesSearch)ManagedBeanWrapper.getManagedBean("MbProcessFilesSearch");
		if (_activeOperation != null) {

		}
	}

	public void search() {
		setSearching(true);
		_operationsSource.flushCache();
		_activeOperation = null;
		reimbOperBean.setFilter(filter);
	}

	public void clearBean() {
		_operationsSource.flushCache();

		if (_activeOperation != null) {
			if (_itemSelection != null) {
				_itemSelection.unselect(_activeOperation);
			}
			_activeOperation = null;
		}

		// TODO clear dependent bean
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);

		if (getFilter().getBatchId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("batchId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getBatchId().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getChannelId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("channelId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getChannelId().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getPosBatchId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("posBatchId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getPosBatchId().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getOperDateFrom() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("operDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getOperDateFrom()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getOperDateTo() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("operDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getOperDateTo()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getPostingDateFrom() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("postingDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getPostingDateFrom()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getPostingDateTo() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("postingDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getPostingDateTo()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getReimbDateFrom() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("reimbDateFrom");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getReimbDateFrom()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getReimbDateTo() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("reimbDateTo");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(df.format(getFilter().getReimbDateTo()));
			filtersList.add(paramFilter);
		}
		if (getFilter().getSttlDay() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("sttlDay");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getSttlDay().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getGrossAmount() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("grossAmount");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getGrossAmount().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getServiceCharge() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("serviceCharge");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getServiceCharge().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getTaxAmount() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("taxAmount");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getTaxAmount().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getNetAmount() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("netAmount");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getNetAmount().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getInstId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getInstId().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getSplitHash() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("splitHash");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getSplitHash().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getAccountId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("accountId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getAccountId().toString());
			filtersList.add(paramFilter);
		}
		if (getFilter().getId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getId().toString());
			filtersList.add(paramFilter);
		}

		filters = filtersList;
	}

	public ReimbursementOperation getFilter() {
		if (filter == null)
			filter = new ReimbursementOperation();
		return filter;
	}

	public void setFilter(ReimbursementOperation filter) {
		this.filter = filter;
	}

	public void delete() {

	}

	public void cancel() {
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isShowModal() {
		return showModal;
	}

	public void setShowModal(boolean showModal) {
		this.showModal = showModal;
	}

	public String cancelSelect() {
		return backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public void clearState() {
		if (_itemSelection.getWrappedSelection() != null) {
			_itemSelection.clearSelection();
		}
	}

	public ArrayList<SelectItem> getPaymentModes() {
		return getDictUtils().getArticles(DictNames.PROCESS_FILE_TYPE, false, false);
	}

	public boolean isBottomMode() {
		return bottomMode;
	}

	public void setBottomMode(boolean bottomMode) {
		this.bottomMode = bottomMode;
	}

	public String selectProcess() {

		return backLink;
	}

	/**
	 * This method return a list of institutions. During Ajax requests list is
	 * not reread from DB. New request to DB happens only if managed bean has
	 * been recreated
	 * 
	 * @return
	 */
	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public boolean isManagingNew() {
		return isNewMode();
	}

	public ReimbursementOperation getNewOperation() {
		return newOperation;
	}

	public void setNewOperation(ReimbursementOperation newOperation) {
		this.newOperation = newOperation;
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
