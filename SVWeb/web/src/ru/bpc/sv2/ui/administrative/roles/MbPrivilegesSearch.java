package ru.bpc.sv2.ui.administrative.roles;

import java.io.BufferedInputStream;
import java.io.BufferedWriter;
import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import javax.servlet.ServletOutputStream;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.apache.log4j.Logger;
import org.openfaces.util.Faces;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.roles.Privilege;
import ru.bpc.sv2.administrative.roles.PrivilegeGroupNode;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.invocation.SortElement.Direction;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.administrative.users.MbUsersSearch;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;
import util.servlet.FileServlet;


@ViewScoped
@ManagedBean(name = "MbPrivilegesSearch")
public class MbPrivilegesSearch extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACCESS_MANAGEMENT");

	private static String COMPONENT_ID = "1078:mainTable";


	private RolesDao _rolesDao = new RolesDao();

	private Privilege _activePriv;
	private Privilege newPrivilege;

	
	private Privilege privFilter;
	private List<Filter> privFilters;

	private String backLink;
	private boolean selectMode;
	private Integer roleId;
	private boolean addPrivToRole;
	private final DaoDataModel<Privilege> _privsSource;

	private final TableRowSelection<Privilege> _privSelection;

	private boolean _managingNew;
	private MbPrivileges privBean;
	private Integer objectId;
	
	private String fileLink = null;
	
	private String tabName;

	public MbPrivilegesSearch() {
		pageLink = "admin|manage_privileges|list_privileges";
		tabName = "detailsTab";
		privBean = (MbPrivileges) ManagedBeanWrapper.getManagedBean("MbPrivileges");

		_privsSource = new DaoDataModel<Privilege>() {
			@Override
			protected Privilege[] loadDaoData(SelectionParams params) {
				if (!isSearching())
					return new Privilege[0];
				try {
					setPrivsFilters();
					params.setFilters(privFilters.toArray(new Filter[privFilters.size()]));
					return _rolesDao.getPrivs(userSessionId, params, addPrivToRole);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new Privilege[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!isSearching())
					return 0;
				try {
					setPrivsFilters();
					params.setFilters(privFilters.toArray(new Filter[privFilters.size()]));
					return _rolesDao.getPrivsCount(userSessionId, params, addPrivToRole);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		_privSelection = new TableRowSelection<Privilege>(null, _privsSource);
		restoreFilter();
	}
	
	private void restoreFilter(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbPrivilegesSearch");
		clearFilter();
		if (queueFilter==null)
			return;
		if (queueFilter.containsKey("selectMode")){
			setSelectMode(((String)queueFilter.get("selectMode")).equals("true"));
		}
		if (queueFilter.containsKey("objectId")){
			setObjectId((Integer)queueFilter.get("objectId"));
		}
		if (queueFilter.containsKey("addPrivToRole")){
			setAddPrivToRole(((String)queueFilter.get("addPrivToRole")).equals("true"));
		}
		if (queueFilter.containsKey("backLink")){
			setBackLink((String)queueFilter.get("backLink"));
		}
		search();
	}

	public DaoDataModel<Privilege> getPrivs() {
		return _privsSource;
	}

	public Privilege getActivePriv() {
		return _activePriv;
	}

	public void setActivePriv(Privilege activePriv) {
		this._activePriv = activePriv;
	}

	public SimpleSelection getPrivSelection() {
		if (_activePriv == null && _privsSource.getRowCount() > 0) {
			_privsSource.setRowIndex(0);
			SimpleSelection selection = new SimpleSelection();
			_activePriv = (Privilege) _privsSource.getRowData();
			selection.addKey(_activePriv.getModelId());
			_privSelection.setWrappedSelection(selection);
			setInfo();
		}
		return _privSelection.getWrappedSelection();
	}

	public void setPrivSelection(SimpleSelection selection) {
		_privSelection.setWrappedSelection(selection);
		_activePriv = _privSelection.getSingleSelection();
		setInfo();
	}

	public void setInfo() {
		if (_activePriv != null) {
			MbUsersSearch usersBean = (MbUsersSearch) ManagedBeanWrapper
					.getManagedBean("MbUsersSearch");
			usersBean.setSearchByPriv(true);
			usersBean.setPrivId(_activePriv.getId());
			usersBean.search();

			NRolesBottom rolesBean = (NRolesBottom) ManagedBeanWrapper
					.getManagedBean("bottomRoles");
			rolesBean.setSlaveMode(true);
			rolesBean.getRoleFilter().setPrivilege(_activePriv.getId());
			rolesBean.search();
			
			MbPrivLimitation mbPrivLimitation = (MbPrivLimitation)ManagedBeanWrapper
					.getManagedBean("MbPrivLimitation");
			mbPrivLimitation.setPrivId(_activePriv.getId());
			mbPrivLimitation.search();
		}
	}

	private void clearBeans() {
		MbUsersSearch usersBean = (MbUsersSearch) ManagedBeanWrapper
				.getManagedBean("MbUsersSearch");
		usersBean.clearFilter();

		NRolesBottom rolesBean = (NRolesBottom) ManagedBeanWrapper
				.getManagedBean("bottomRoles");
		rolesBean.clearFilter();
		
		MbPrivLimitation mbPrivLimitation = (MbPrivLimitation)ManagedBeanWrapper
				.getManagedBean("MbPrivLimitation");
		mbPrivLimitation.setPrivId(null);
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		privFilter = null;
		clearBean();
	}

	public void clearBean() {
		searching = false;
		curLang = userLang;
		_privsSource.flushCache();
		if (_privSelection != null) {
			_privSelection.clearSelection();
		}
		_activePriv = null;
		
		clearBeans();
	}

	public void add() {
        curMode = NEW_MODE;
		newPrivilege = new Privilege();
		newPrivilege.setIsActive(Boolean.TRUE);
		newPrivilege.setLang(userLang);
        _managingNew = true;
	}

    public void edit() {
        curMode = EDIT_MODE;
        privBean.setSearching(isSearching());
        try {
            newPrivilege = _activePriv.clone();
        }catch(CloneNotSupportedException e) {
            newPrivilege = _activePriv;
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        _managingNew = false;
    }





	public void save() {
		try {

            if(isNewMode()) {
                newPrivilege.setModuleCode(newPrivilege.getModuleCode().toUpperCase());
                newPrivilege = _rolesDao.addPrivilege(userSessionId, newPrivilege);
                _activePriv = newPrivilege.clone();
                _privSelection.addNewObjectToList(newPrivilege);

            }else {
                //addPrivilege must be used for update also.
                newPrivilege = _rolesDao.addPrivilege(userSessionId, newPrivilege);
                _activePriv =  newPrivilege.clone();
                if (!userLang.equals(newPrivilege.getLang())) {
                    newPrivilege = getNodeByLang(newPrivilege.getId(), userLang);
                }
                _privsSource.replaceObject(_activePriv, newPrivilege);
            }
			_activePriv = newPrivilege;
			setInfo();
            curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void delete() {
		try {
			_rolesDao.removePrivilege(userSessionId, _activePriv.getId());
			FacesUtils.addMessageInfo("Privilege (id = " + _activePriv.getId()
					+ ") has been deleted.");

			_activePriv = _privSelection.removeObjectFromList(_activePriv);
			if (_activePriv == null) {
				clearBean();
			} else {
				setInfo();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {

	}

	public void createRole() {
		privBean.setManagingNew(true);
		privBean.setPriv(new Privilege());
		privBean.setSearching(isSearching());
		setActivePriv(new Privilege());
		_managingNew = true;

		// _rolesTree = _rolesDao.getRoleSections( userSessionId);

		// return "open_details";
	}

	public void editExistingRole() {
		privBean.setManagingNew(false);
		privBean.setSearching(isSearching());
		privBean.setPriv(_activePriv);
		_managingNew = false;
		// _rolesTree = _rolesDao.getRoleSections( userSessionId,
		// _activeRole.getId() );

		// return "open_details";
	}

	public boolean isManagingNew() {
		return _managingNew;
	}

	public void setManagingNew(boolean managingNew) {
		_managingNew = managingNew;
	}

	private PrivilegeGroupNode getPriv() {
		return (PrivilegeGroupNode) Faces.var("priv");
	}

	public boolean getNodeHasChildren() {
		PrivilegeGroupNode privNode = getPriv();
		return (privNode != null) && privNode.getChilds().size() > 0;
	}

	public void setPrivsFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
        Filter[] filters = new Filter[1];
        filters[0] = new Filter();
        filters[0].setElement("lang");
        filters[0].setValue(curLang);
        filtersList.add(filters[0]);

		if (getPrivFilter().getShortDesc() != null && !getPrivFilter().getShortDesc().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("shortDesc");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(getPrivFilter().getShortDesc().toUpperCase()
					.replaceAll("[*]", "%").replaceAll("[?]", "_"));
			filtersList.add(paramFilter);
		}
		if (getPrivFilter().getName() != null && !getPrivFilter().getName().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getPrivFilter().getName().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			filtersList.add(paramFilter);
		}
		if (getPrivFilter().getModuleCode() != null && !getPrivFilter().getModuleCode().equals("")) {
			Filter paramFilter = new Filter();
			paramFilter.setElement("moduleCode");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(getPrivFilter().getModuleCode().replaceAll("[*]", "%").replaceAll(
					"[?]", "_").toUpperCase());
			filtersList.add(paramFilter);
		}
		if (addPrivToRole) {
			// When adding priv to role we should find only
			// those privs which are not added to active role
			MbRoles roleBean = (MbRoles) ManagedBeanWrapper.getManagedBean("MbRoles");
			ComplexRole role = roleBean.getRole();
			if (role != null) {
				Filter paramFilter = new Filter();
				paramFilter.setElement("roleId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(Integer.toString(role.getId()));
				filtersList.add(paramFilter);
			}
		}
		privFilters = filtersList;
	}

	public Privilege getPrivFilter() {
		if (privFilter == null)
			privFilter = new Privilege();
		return privFilter;
	}

	public void setPrivFilter(Privilege privFilter) {
		this.privFilter = privFilter;
	}

	public List<Filter> getPrivFilters() {
		return privFilters;
	}

	public void setPrivFilters(List<Filter> privFilters) {
		this.privFilters = privFilters;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public boolean isSelectMode() {
		return selectMode;
	}

	public void setSelectMode(boolean selectMode) {
		this.selectMode = selectMode;
	}

	public String select() {
		privBean.setPriv(_activePriv);
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public String cancelSelect() {
		if ("acm_widgets".equals(backLink)) {
			privBean.setPriv(new Privilege());
		} else {
			privBean.setPriv(null);
			
			Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			mbMenu.externalSelect(backLink);
			
			MbRoles roleBean = (MbRoles) ManagedBeanWrapper.getManagedBean("MbRoles");
			ComplexRole role = roleBean.getRole();
			MbRolePrivilegesSearch rolePrivBean = (MbRolePrivilegesSearch) ManagedBeanWrapper.getManagedBean("MbRolePrivilegesSearch");
			rolePrivBean.setRoleId(role.getId());
			rolePrivBean.search();
		}
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		
		return backLink;
	}

	public String addSelectedPrivsToRole() {

		List<Privilege> privsToAdd = _privSelection.getMultiSelection();
		NRolesBottom rolesBean = (NRolesBottom) ManagedBeanWrapper.getManagedBean("bottomRoles");
		rolesBean.setSlaveMode(false);
		if (objectId != null) {
			try {
				_rolesDao.addPrivsToRole(userSessionId, objectId, privsToAdd
						.toArray(new Privilege[privsToAdd.size()]));
			} catch (DataAccessException ee) {
				FacesUtils.addMessageError(ee);
				logger.error("", ee);
			}
		}
		
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect(backLink);
		
		FacesUtils.setSessionMapValue(backLink, Boolean.TRUE);
		return backLink;
	}

	public void setSearching(boolean searching) {
		this.searching = searching;
		privBean.setSearching(searching);
	}

	public Integer getRoleId() {
		return roleId;
	}

	public void setRoleId(Integer roleId) {
		this.roleId = roleId;
	}

	public boolean isAddPrivToRole() {
		return addPrivToRole;
	}

	public void setAddPrivToRole(boolean addPrivToRole) {
		this.addPrivToRole = addPrivToRole;
	}

    public List<SelectItem> getSections() {
        return getDictUtils().getLov(LovConstants.SECTIONS_PAGE);
    }

	public void exportWebXml() {
		BufferedWriter out = null;
		BufferedInputStream in = null;
		ServletOutputStream outStream = null;
		String moduleCode = "";
		fileLink = "privs.xml";
		try {
			SelectionParams params = new SelectionParams();

			// set sorting by label name so that it would be easier to read them
			SortElement[] sorts = new SortElement[1];
			sorts[0] = new SortElement("moduleCode", Direction.ASC);

			params.setSortElement(sorts);
			params.setRowIndexEnd(-1);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("lang");
            filters[0].setValue(curLang);
            params.setFilters(filters);

			Privilege[] privs = _rolesDao.getPrivs(userSessionId, params, false);
			
			HttpServletRequest req = RequestContextHolder.getRequest();
			HttpSession session = req.getSession();

			ByteArrayOutputStream byteout = new ByteArrayOutputStream();
			PrintWriter printW = new PrintWriter(byteout);
			out = new BufferedWriter(printW);

			for (Privilege priv : privs) {
				if (priv.getModuleCode() != null && !moduleCode.equals(priv.getModuleCode())) {
					moduleCode = priv.getModuleCode();
					out.write("<!-- " + moduleCode + " --> \r\n\r\n");
				}
				String xmlPriv = "<security-role>\r\n " + "<role-name>" + priv.getName()
						+ "</role-name>\r\n" + "</security-role>";

				out.write(xmlPriv + "\r\n\r\n");
			}
			out.flush();
			session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
			session.setAttribute(FileServlet.FILE_SERVLET_FILE_CONTENT, byteout.toByteArray());
			out.close();

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			closeStream(in);
			closeStream(outStream);
		}
	}

	public void exportWeblogicXml() {
		BufferedWriter out = null;
		BufferedInputStream in = null;
		ServletOutputStream outStream = null;
		String moduleCode = "";
		fileLink = "privsWeblogic.xml";
		try {
			SelectionParams params = new SelectionParams();

			// set sorting by label name so that it would be easier to read them
			SortElement[] sorts = new SortElement[1];
			sorts[0] = new SortElement("moduleCode", Direction.ASC);

			params.setSortElement(sorts);
			params.setRowIndexEnd(-1);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("lang");
            filters[0].setValue(curLang);
            params.setFilters(filters);

			Privilege[] privs = _rolesDao.getPrivs(userSessionId, params, false);
			
			HttpServletRequest req = RequestContextHolder.getRequest();
			HttpSession session = req.getSession();

			ByteArrayOutputStream byteout = new ByteArrayOutputStream();
			PrintWriter printW = new PrintWriter(byteout);
			out = new BufferedWriter(printW);

			for (Privilege priv : privs) {
				if (priv.getModuleCode() != null && !moduleCode.equals(priv.getModuleCode())) {
					moduleCode = priv.getModuleCode();
					out.write("<!-- " + moduleCode + " --> \r\n\r\n");
				}
				String xmlPriv = "<wls:security-role-assignment>\r\n" + "  <wls:role-name>"
						+ priv.getName() + "</wls:role-name>\r\n" + "  <wls:principal-name>"
						+ priv.getName() + "</wls:principal-name>\r\n"
						+ "</wls:security-role-assignment>";

				out.write(xmlPriv + "\r\n\r\n");
			}
			
			out.flush();
			session.setAttribute(FileServlet.FILE_SERVLET_CONTENT_TYPE, "application/x-download");
			session.setAttribute(FileServlet.FILE_SERVLET_FILE_CONTENT, byteout.toByteArray());
			
			out.close();

		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		} finally {
			closeStream(in);
			closeStream(outStream);
		}
	}

	public void closeStream(Closeable stream) {
		if (stream != null) {
			try {
				stream.close();
			} catch (IOException e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}

	public Privilege getNewPrivilege() {
		return newPrivilege;
	}

	public void setNewPrivilege(Privilege newPrivilege) {
		this.newPrivilege = newPrivilege;
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(_activePriv.getId() + "");
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			Privilege[] privs = _rolesDao.getPrivs(userSessionId, params, false);
			if (privs != null && privs.length > 0) {
				_activePriv = privs[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		if (tabName.equalsIgnoreCase("ROLESTAB")) {
			NRolesBottom roleBottomBean = (NRolesBottom) ManagedBeanWrapper.getManagedBean("bottomRoles");
			roleBottomBean.setTabName(tabName);
			roleBottomBean.setParentSectionId(getSectionId());
			roleBottomBean.setTableState(getSateFromDB(roleBottomBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("USERSTAB")) {
			MbUsersSearch roleBottomBean = (MbUsersSearch) ManagedBeanWrapper.getManagedBean("MbUsersSearch");
			roleBottomBean.keepTabName(tabName);
			roleBottomBean.setParentSectionId(getSectionId());
			roleBottomBean.setTableState(getSateFromDB(roleBottomBean.getComponentId()));
		} else if (tabName.equalsIgnoreCase("LIMITATIONSTAB")) {
			MbPrivLimitation roleBottomBean = (MbPrivLimitation) ManagedBeanWrapper.getManagedBean("MbPrivLimitation");
			roleBottomBean.setTabName(tabName);
			roleBottomBean.setParentSectionId(getSectionId());
			roleBottomBean.setTableState(getSateFromDB(roleBottomBean.getComponentId()));
		}
	}

    public void confirmEditLanguage() {
        curLang = newPrivilege.getLang();
        Privilege tmp = getNodeByLang(newPrivilege.getId(), newPrivilege.getLang());
//                getNodeByLang(newPrivilege.getId(), newPrivilege.getLang());
        if (tmp != null) {
            newPrivilege.setName(tmp.getName());
            newPrivilege.setFullDesc(tmp.getFullDesc());
            newPrivilege.setShortDesc(tmp.getShortDesc());
        }
    }

    public Privilege getNodeByLang(Integer id, String lang) {
        if (_activePriv != null) {
            List<Filter> filtersList = new ArrayList<Filter>();
            Filter paramFilter = new Filter();
            paramFilter.setElement("id");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(String.valueOf(id));
            filtersList.add(paramFilter);

            paramFilter = new Filter();
            paramFilter.setElement("lang");
            paramFilter.setOp(Operator.eq);
            paramFilter.setValue(lang);
            filtersList.add(paramFilter);

            SelectionParams params = new SelectionParams();
            params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
            try {
                Privilege[] privileges = _rolesDao.getPrivs(userSessionId, params, false);
                if (privileges != null && privileges.length > 0) {
                    return privileges[0];
                }
            } catch (Exception e) {
                FacesUtils.addMessageError(e);
                logger.error("", e);
            }
        }
        return null;
    }

	public String getSectionId() {
		return SectionIdConstants.ADMIN_PERMISSION_PRIVILEGE;
	}
	
	public void setObjectId(Integer objectId) {
		this.objectId = objectId;
	}

	public String getFileLink() {
		return fileLink;
	}
}
