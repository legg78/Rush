package ru.bpc.sv2.ui.operations;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.accounts.Transaction;
import ru.bpc.sv2.acm.AcmAction;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.reports.ReportParameter;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbEntriesForOperation")
public class MbEntriesForOperation extends AbstractTreeBean<Transaction> {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");

	private OperationDao _operationsDao = new OperationDao();

	private Transaction filter;

	private Transaction _activeEntry;
	private Long operationId;
	private String entityType;

	private final DaoDataModel<Transaction> _entrySource;
	private final TableRowSelection<Transaction> _itemSelection;

	private boolean tableView = false;
	private String backLink;

	private AcmAction selectedCtxItem;
	
	private static String COMPONENT_ID = "operEntriesTable";
	private boolean credit;
	private String tabName;
	private String parentSectionId;
	private boolean errorSearch;

	public MbEntriesForOperation() {
		_entrySource = new DaoDataModel<Transaction>() {
			@Override
			protected Transaction[] loadDaoData(SelectionParams params) {
				if (!searching || operationId == null) {
					return new Transaction[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getEntries(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return new Transaction[0];
				}
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || operationId == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _operationsDao.getEntriesCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<Transaction>(null, _entrySource);
	}

	public DaoDataModel<Transaction> getEntries() {
		return _entrySource;
	}

	public Transaction getActiveEntry() {
		return _activeEntry;
	}

	public void setActiveEntry(Transaction activeEntry) {
		_activeEntry = activeEntry;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeEntry == null && _entrySource.getRowCount() > 0) {
				setFirstRowActive();
			}
		} catch (Exception ignored) {
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeEntry = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_entrySource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeEntry = (Transaction) _entrySource.getRowData();
		selection.addKey(_activeEntry.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	public void clearFilter() {
		filter = null;
		curMode = VIEW_MODE;
		operationId = null;
		entityType = null;
		clearBean();
		searching = false;
		errorSearch = false;
	}

	public void setFilters() {
		getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		// paramFilter = new Filter();
		// paramFilter.setElement("lang");
		// paramFilter.setValue(curLang);
		// filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("objectId");
		paramFilter.setValue(operationId);
		filters.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("entityType");
		paramFilter.setValue(entityType);
		filters.add(paramFilter);

		if (filter.getTransactionId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("transactionId");
			paramFilter.setValue(filter.getTransactionId());
			filters.add(paramFilter);
		}
	}

	public Long getOperationId() {
		return operationId;
	}

	public void setOperationId(Long operationId) {
		this.operationId = operationId;
	}

	public String getEntityType() {
		return entityType;
	}

	public void setEntityType(String entityType) {
		this.entityType = entityType;
	}

	public Transaction getNode() {
		if (currentNode == null) {
			currentNode = new Transaction();
		}
		return currentNode;
	}

	public void setNode(Transaction node) {
		if (node == null)
			return;
		_activeEntry = node;
		this.currentNode = node;
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	private Transaction getTransaction() {
		return (Transaction) Faces.var("item");
	}

	protected void loadTree() {
		coreItems = new ArrayList<Transaction>();

		if (!searching || operationId == null) {
			return;
		}

		try {

			setFilters();

			SelectionParams params = new SelectionParams();
			SortElement[] sortElements = new SortElement[3];
			sortElements[0] = new SortElement("macrosId", Direction.ASC);
			sortElements[1] = new SortElement("bunchId", Direction.ASC);
			sortElements[2] = new SortElement("transactionId", Direction.ASC);
			params.setSortElement(sortElements);
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			Transaction[] trans = _operationsDao.getEntriesForOperation(userSessionId, params);

			if (trans != null && trans.length > 0) {
				addNodes1(0, coreItems, trans, 1);
			}
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
			errorSearch = true;
		}
	}
	
	public void view(){
		if (_activeEntry == null){
			if (currentNode != null){
				_activeEntry = currentNode;
			}
		}
		if (_activeEntry.getCreditAccountNumber() != null && 
				_activeEntry.getCreditAccountNumber().length() > 0){
			setCredit(true);
		}else{
			setCredit(false);
		}
	}

	public List<Transaction> getNodeChildren() {
		Transaction type = getTransaction();
		if (type == null) {
			if ((!treeLoaded || coreItems == null) && !errorSearch) {
				loadTree();
			}
			return coreItems;
		} else {
			return type.getChildren();
		}
	}

	public boolean getNodeHasChildren() {
		return (getTransaction() != null ) && getTransaction().isHasChildren();
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
		errorSearch = false;
		loadTree();
	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;

		_entrySource.flushCache();
		_itemSelection.clearSelection();
		_activeEntry = null;

		curLang = userLang;
	}

	public void saveState() {
		FacesUtils.setSessionMapValue("viewTypeEntryForOperation", tableView);
		FacesUtils.setSessionMapValue("activeEntryForOperation", _activeEntry);
		FacesUtils.setSessionMapValue("currentNodeEntryForOperation", currentNode);
	}

	public void restoreState() {
		tableView = (Boolean) FacesUtils.getSessionMapValue("viewTypeEntryForOperation");
		_activeEntry = (Transaction) FacesUtils.getSessionMapValue("activeEntryForOperation");
		currentNode = (Transaction) FacesUtils.getSessionMapValue("currentNodeEntryForOperation");
	}

	@Override
	protected int addNodes(int startIndex, List<Transaction> branches, Transaction[] items) {
		// int counter = 1;
		int i;
		int level = items[startIndex].getLevel();

		for (i = startIndex; i < items.length; i++) {
			if (items[i].getLevel() != level) {
				break;
			}
			branches.add(items[i]);
			if ((i + 1) != items.length && items[i + 1].getLevel() > level) {
				items[i].setChildren(new ArrayList<Transaction>());
				i = addNodes(i + 1, items[i].getChildren(), items);
			}
			// counter++;
		}
		return i - 1;
	}

	protected int addNodes1(int startIndex, List<Transaction> branches, Transaction[] items,
			int level) {
		// int counter = 1;
		int i;
		long macrosId = 0;
		long bunchId = 0;
		long transId = 0;
		String entityType = null;

		if (level == 1) {
			entityType = EntityNames.MACROS;
		} else if (level == 2) {
			entityType = EntityNames.BUNCH;
			macrosId = items[startIndex].getMacrosId();
		} else if (level == 3) {
			entityType = EntityNames.TRANSACTION;
			macrosId = items[startIndex].getMacrosId();
			bunchId = items[startIndex].getBunchId();
		}

		boolean checkParent = false;

		for (i = startIndex; i < items.length; i++) {

			if (level == 1) {
				checkParent = items[i].getMacrosId() != macrosId;
			} else if (level == 2) {
				checkParent = items[i].getMacrosId() == macrosId &&
						items[i].getBunchId() != bunchId;
			} else if (level == 3) {
				checkParent = items[i].getMacrosId() == macrosId &&
						items[i].getBunchId() == bunchId && items[i].getTransactionId() != transId;
			}

			if (checkParent) {
				Transaction tr = null;
				try {
					tr = items[i].clone();
				} catch (CloneNotSupportedException e) {
					tr = new Transaction();
				}
				tr.setEntityType(entityType);
				tr.setLevel(level);
				branches.add(tr);
				tr.setChildren(new ArrayList<Transaction>());
				if (level < 3) {
					i = addNodes1(i, tr.getChildren(), items, level + 1);
				}
			} else {
				break;
			}

			// counter++;
		}
		return i - 1;
	}

	public Transaction getFilter() {
		if (filter == null) {
			filter = new Transaction();
		}
		return filter;
	}

	public void setFilter(Transaction filter) {
		this.filter = filter;
	}

	public boolean isTableView() {
		return tableView;
	}

	public void setTableView(boolean tableView) {
		logger.debug("ViewMode has been changed. Actual value tableView=" + tableView);
		this.tableView = tableView;
	}

	public void initCtxParams() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");

		selectedCtxItem = ctxBean.getSelectedCtxItem();
		Map<String, ReportParameter> params = new HashMap<String, ReportParameter>();

		FacesUtils.setSessionMapValue("entityType", EntityNames.TRANSACTION);
		if (tableView) {
			ctxBean.initCtxParams(EntityNames.TRANSACTION, _activeEntry.getTransactionId(), true);
			FacesUtils.setSessionMapValue("objectId", _activeEntry.getTransactionId());
			params.put("I_OBJECT_ID", new ReportParameter("I_OBJECT_ID", DataTypes.NUMBER,
					new BigDecimal(_activeEntry.getTransactionId())));
			params.put("I_TRANSACTION_ID", new ReportParameter("I_TRANSACTION_ID",
					DataTypes.NUMBER, new BigDecimal(_activeEntry.getTransactionId())));

		} else {
			ctxBean.initCtxParams(EntityNames.TRANSACTION, currentNode.getLongId(), true);
			FacesUtils.setSessionMapValue("objectId", currentNode.getLongId());
			params.put("I_OBJECT_ID", new ReportParameter("I_OBJECT_ID", DataTypes.NUMBER,
					new BigDecimal(currentNode.getLongId())));
			params.put("I_TRANSACTION_ID", new ReportParameter("I_TRANSACTION_ID",
					DataTypes.NUMBER, new BigDecimal(currentNode.getLongId())));
		}

		FacesUtils.setSessionMapValue("reportParams", params);
	}

	public String ctxPageForward() {
		initCtxParams();
		FacesUtils.setSessionMapValue("initFromContext", Boolean.TRUE);
		FacesUtils.setSessionMapValue("backLink", backLink);
		saveState();

		return selectedCtxItem.getAction();
	}

	public void initCtxMenu() {
		if (tableView && _activeEntry == null) {
			return;
		} else if (!tableView && currentNode == null) {
			return;
		}
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		ctxBean.setEntityType(EntityNames.TRANSACTION);
		if (tableView) {
			ctxBean.setObjectType(_activeEntry.getTransType());
		} else {
			ctxBean.setObjectType(currentNode.getTransType());
		}
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
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

	public boolean isCredit() {
		return credit;
	}

	public void setCredit(boolean credit) {
		this.credit = credit;
	}
}
