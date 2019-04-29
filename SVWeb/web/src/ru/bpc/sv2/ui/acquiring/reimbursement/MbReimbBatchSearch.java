package ru.bpc.sv2.ui.acquiring.reimbursement;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.acquiring.reimbursement.ReimbursementBatchEntry;
import ru.bpc.sv2.acquiring.reimbursement.ReimbursementChannel;
import ru.bpc.sv2.acquiring.reimbursement.ReimbursementOperation;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbReimbBatchSearch")
public class MbReimbBatchSearch extends AbstractBean{
	private static final long serialVersionUID = 2552521712737937362L;

	private static String COMPONENT_ID = "1114:mainTable";

	private AcquiringDao _acquiringDao = new AcquiringDao();

	private ReimbursementBatchEntry _activeBatchEntry;
	
	private ReimbursementBatchEntry filter;
	private String backLink;
	private boolean showModal;
	private boolean selectMode;
	private MbReimbBatch reimbBatchBean;
	private boolean bottomMode;
	
	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> channels;
	private ReimbursementBatchEntry newBatchEntry;
	
	private final DaoDataModel<ReimbursementBatchEntry> _batchEntriesSource;

	private final TableRowSelection<ReimbursementBatchEntry> _itemSelection;
	private static final Logger logger = Logger.getLogger("ACQUIRING");

	public MbReimbBatchSearch() {
		pageLink = "acquiring|reimbursement|list_batches";
		bottomMode = false;
		
		reimbBatchBean = (MbReimbBatch) ManagedBeanWrapper.getManagedBean("MbReimbBatch");
		Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		if (!menu.isKeepState()) {
			reimbBatchBean.setTabName("");
			reimbBatchBean.setBatchEntry(null);
		} else {
			_activeBatchEntry = reimbBatchBean.getBatchEntry();
			backLink = reimbBatchBean.getBackLink();
			searching = reimbBatchBean.isSearching();
		}

		_batchEntriesSource = new DaoDataModel<ReimbursementBatchEntry>() {
			private static final long serialVersionUID = 4315741791608926739L;

			@Override
			protected ReimbursementBatchEntry[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new ReimbursementBatchEntry[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _acquiringDao.getReimbursementBatchEntries(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ReimbursementBatchEntry[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));

					return _acquiringDao.getReimbursementBatchEntriesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		if (_activeBatchEntry != null) {

			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeBatchEntry.getModelId());
			_itemSelection = new TableRowSelection<ReimbursementBatchEntry>(selection,
					_batchEntriesSource);
			setBeans();
		} else {
			_itemSelection = new TableRowSelection<ReimbursementBatchEntry>(null,
					_batchEntriesSource);
		}
	}

	public DaoDataModel<ReimbursementBatchEntry> getBatchEntries() {
		return _batchEntriesSource;
	}

	public ReimbursementBatchEntry getActiveBatchEntry() {
		return _activeBatchEntry;
	}

	public void setActiveBatchEntry(ReimbursementBatchEntry activeBatchEntry) {
		_activeBatchEntry = activeBatchEntry;
	}

	public SimpleSelection getItemSelection() {
		setFirstRowActive();
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		if (_activeBatchEntry == null && _batchEntriesSource.getRowCount() > 0) {
			_batchEntriesSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activeBatchEntry = (ReimbursementBatchEntry) _batchEntriesSource.getRowData();
			selection.addKey(_activeBatchEntry.getModelId());
			_itemSelection.setWrappedSelection(selection);
			reimbBatchBean.setBatchEntry(_activeBatchEntry);
			setBeans();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBatchEntry = _itemSelection.getSingleSelection();
		reimbBatchBean.setBatchEntry(_activeBatchEntry);
		setBeans();
	}

	private void setBeans() {
		MbReimbOperationSearch operBean = (MbReimbOperationSearch) ManagedBeanWrapper
				.getManagedBean("MbReimbOperationSearch");
		if (_activeBatchEntry != null) {
			ReimbursementOperation filter = new ReimbursementOperation();
			filter.setBatchId(_activeBatchEntry.getId());
			operBean.setFilter(filter);

		} else {
			operBean.setFilter(null);
		}
		operBean.search();
	}

	private void clearBeans() {
		MbReimbOperationSearch operBean = (MbReimbOperationSearch) ManagedBeanWrapper
				.getManagedBean("MbReimbOperationSearch");
		operBean.setFilter(null);
		operBean.clearBean();
	}

	public void search() {
		setSearching(true);
		_batchEntriesSource.flushCache();
		_activeBatchEntry = null;
		reimbBatchBean.setFilter(filter);
	}

	public void clearBean() {
		_batchEntriesSource.flushCache();
		_itemSelection.clearSelection();
		_activeBatchEntry = null;

		clearBeans();
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		searching = false;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		String dbDateFormat = "dd.MM.yyyy";
		SimpleDateFormat df = new SimpleDateFormat(dbDateFormat);

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
		if (getFilter().getChequeNumber() != null && !getFilter().getChequeNumber().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("chequeNumber");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getChequeNumber());
			filtersList.add(paramFilter);
		}
		if (getFilter().getStatus() != null && !getFilter().getStatus().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getStatus());
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
		if (getFilter().getOperCount() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("operCount");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getOperCount().toString());
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
		if (getFilter().getSessionFileId() != null) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("sessionFileId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getSessionFileId().toString());
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

	public void create() {
		curMode = NEW_MODE;
		newBatchEntry = new ReimbursementBatchEntry();
		newBatchEntry.setInstId(filter.getInstId());
	}

	public void edit() {
		curMode = EDIT_MODE;
		try {
			newBatchEntry = _activeBatchEntry.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newBatchEntry = new ReimbursementBatchEntry();
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				newBatchEntry = _acquiringDao.modifyReimbursementBatchEntry(userSessionId,
						newBatchEntry);
				_itemSelection.addNewObjectToList(newBatchEntry);
			} else {
				newBatchEntry = _acquiringDao.modifyReimbursementBatchEntry(userSessionId,
						newBatchEntry);
				_batchEntriesSource.replaceObject(_activeBatchEntry, newBatchEntry);
			}
			setBeans();
			_activeBatchEntry = newBatchEntry;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {

	}

	public void cancel() {
	}

	public ReimbursementBatchEntry getFilter() {
		if (filter == null)
			filter = new ReimbursementBatchEntry();
		return filter;
	}

	public void setFilter(ReimbursementBatchEntry filter) {
		this.filter = filter;
	}

	public List<Filter> getFilters() {
		return filters;
	}

	public void setFilters(List<Filter> filters) {
		this.filters = filters;
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

	public ArrayList<SelectItem> getReimbursementStatuses() {
		return getDictUtils().getArticles(DictNames.REIMBURSEMENT_STATUS, false, false);
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

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
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

	/**
	 * This method return a list of reimbursement channels. During Ajax requests
	 * list is not reread from DB. New request to DB happens only if managed
	 * bean has been recreated
	 * 
	 * @return
	 */
	public ArrayList<SelectItem> getReimbursementChannels() {
		if (channels == null) {
			ArrayList<SelectItem> items = null;
			try {
				items = new ArrayList<SelectItem>();
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(curLang);
				List<Filter> filtersChannel = new ArrayList<Filter>();
				filtersChannel.add(paramFilter);
				params.setFilters(filtersChannel.toArray(new Filter[filtersChannel.size()]));
				ReimbursementChannel[] channels = _acquiringDao.getReimbursementChannels(
						userSessionId, params);
				for (ReimbursementChannel channel : channels) {
					items
							.add(new SelectItem(channel.getId(), channel.getName(), channel
									.getName()));
				}
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (items == null)
					items = new ArrayList<SelectItem>();
			}
			channels = items;
		}
		return channels;
	}

	public ReimbursementBatchEntry getNewBatchEntry() {
		return newBatchEntry;
	}

	public void setNewBatchEntry(ReimbursementBatchEntry newBatchEntry) {
		this.newBatchEntry = newBatchEntry;
	}

	public boolean isManagingNew() {
		return isNewMode();
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
