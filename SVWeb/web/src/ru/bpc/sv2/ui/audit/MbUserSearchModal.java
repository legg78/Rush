package ru.bpc.sv2.ui.audit;

import java.util.ArrayList;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbUserSearchModal")
public class MbUserSearchModal extends AbstractBean{
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private UsersDao _usersDao = new UsersDao();

	private User filter;

	private final DaoDataModel<User> _usersSource;
	private final TableRowSelection<User> _itemSelection;
	private User _activeUser;

	private String beanName;
	private String methodName;
	private String quickMethodName;
	private String rerenderList;
	private String modalPanel = "userSearchModalPanel";
	
	public MbUserSearchModal() {
		rowsNum = Integer.MAX_VALUE; // we don't have pages on modal panel so we need to show all entries
		
		_usersSource = new DaoDataModel<User>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected User[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new User[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _usersDao.getUsers(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					logger.error("", e);
					FacesUtils.addMessageError(e);
				}
				return new User[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _usersDao.getUsersCount(userSessionId, params);
				} catch (Exception e) {
					logger.error("", e);
					FacesUtils.addMessageError(e);
					return 0;
				}
			}
		};

		_itemSelection = new TableRowSelection<User>(null, _usersSource);
	}

	public DaoDataModel<User> getUsers() {
		return _usersSource;
	}

	public User getActiveUser() {
		return _activeUser;
	}

	public void setActiveCustomer(User activeUser) {
		_activeUser = activeUser;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeUser == null && _usersSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeUser != null && _usersSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeUser.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeUser = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeUser = _itemSelection.getSingleSelection();
	}

	public void setFirstRowActive() {
		_usersSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeUser = (User) _usersSource.getRowData();
		selection.addKey(_activeUser.getModelId());
		_itemSelection.setWrappedSelection(selection);

	}

	public void setFilters() {
		filters = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (getFilter().getStatus() != null && !getFilter().getStatus().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("status");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getFilter().getStatus());
			filters.add(paramFilter);
		}
		if (getFilter().getName() != null && !getFilter().getName().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getName().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
		if (getFilter().getPerson().getSurname() != null
				&& !getFilter().getPerson().getSurname().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("surname");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getFilter().getPerson().getSurname().toUpperCase().replaceAll(
					"[*]", "%").replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}
	}
	public User getFilter() {
		if (filter == null) {
			filter = new User();
		}
		return filter;
	}
	public void setFilter(User filter) {
		this.filter = filter;
	}

	public void clearFilter() {
		filter = null;
		clearBean();
		searching = false;
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
	}

	public void clearBean() {
		curLang = userLang;
		_usersSource.flushCache();
		_itemSelection.clearSelection();
		_activeUser = null;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}

	public String getBeanName() {
		return beanName;
	}
	public void setBeanName(String beanName) {
		this.beanName = beanName;
	}

	public String getRerenderList() {
		return rerenderList;
	}
	public void setRerenderList(String rerenderList) {
		this.rerenderList = rerenderList;
	}

	public String getMethodName() {
		if (methodName == null || "".equals(methodName)) {
			return "selectUser";
		}
		return methodName;
	}
	public void setMethodName(String methodName) {
		this.methodName = methodName;
	}

	public String getQuickMethodName() {
		if (quickMethodName == null || "".equals(quickMethodName)) {
			return "selectCurrentUser";
		}
		return quickMethodName;
	}
	public void setQuickMethodName(String quickMethodName) {
		this.quickMethodName = quickMethodName;
	}

	public String getModalPanel() {
		return modalPanel;
	}

	public ArrayList<SelectItem> getStatuses() {
		return getDictUtils().getArticles(DictNames.USER_STATUSES, true, false);
	}
}
