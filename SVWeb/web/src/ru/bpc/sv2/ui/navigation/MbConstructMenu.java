package ru.bpc.sv2.ui.navigation;

import org.openfaces.util.Faces;
import ru.bpc.sv2.common.MenuNode;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbConstructMenu")
public class MbConstructMenu extends AbstractBean {
	private static final long serialVersionUID = 1L;
	
	private CommonDao _commonDao = new CommonDao();

	private ArrayList<MenuNode> menuNodes;
	private MenuNode currentNode;
	private MenuNode newNode;
	private ArrayList<MenuNode> coreNodes;
	private boolean treeLoaded;

	public static final int VIEW_MODE = 1;
	public static final int EDIT_MODE = 2;
	public static final int NEW_MODE = 4;
	public static final int TRANSL_MODE = 8;
	private int curMode;

	private UserSession us;
	private String userLang;
	private String curLang;
	private transient DictUtils dictUtils;
	private Menu menuBean;

	private Long userSessionId = null;
	
	protected List<SelectItem> languages = null;

	public MbConstructMenu() {
		pageLink = "menu|builder";
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		menuBean = (Menu) ManagedBeanWrapper.getManagedBean("menu");

		us = (UserSession) ManagedBeanWrapper.getManagedBean("usession");
		userLang = us.getUserLanguage();
		curMode = VIEW_MODE;

		curLang = userLang;
	}

	private int addNodes(int startIndex, List<MenuNode> branches, MenuNode[] types) {
		int i;
		int level = types[startIndex].getLevel();

		for (i = startIndex; i < types.length; i++) {
			if (types[i].getLevel() != level) {
				break;
			}
			menuNodes.add(types[i]);
			branches.add(types[i]);
			if ((i + 1) != types.length && types[i + 1].getLevel() > level) {
				types[i].setChildren(new ArrayList<MenuNode>());
				i = addNodes(i + 1, types[i].getChildren(), types);
			}
		}
		return i - 1;
	}

	private void loadTree() {
		MenuNode[] nodes = _commonDao.getMenuAll(userSessionId);
		menuNodes = new ArrayList<MenuNode>();
		coreNodes = new ArrayList<MenuNode>();

		if (nodes != null && nodes.length > 0) {
			addNodes(0, coreNodes, nodes);
		}
		treeLoaded = true;
	}

	public List<MenuNode> getNodeChildren() {
		MenuNode type = getMenuNode();
		if (type == null) {
			if (!treeLoaded || coreNodes == null) {
				loadTree();
			}
			return coreNodes;
		} else {
			return type.getChildren();
		}
	}

	private MenuNode getMenuNode() {
		return (MenuNode) Faces.var("menuNode");
	}

	public MenuNode getNode() {
		return currentNode;
	}

	public void setNode(MenuNode node) {
		this.currentNode = node;
	}

	public void addBranch() {
		curMode = NEW_MODE;
		newNode = new MenuNode();
		newNode.setLang(curLang);
		if (currentNode != null) {
			newNode.setParentId(currentNode.getId());
		}
		// return "";
	}

	public void editBranch() {
		curMode = EDIT_MODE;
		try {
			newNode = (MenuNode) currentNode.clone();
			newNode.setLang(curLang);
		} catch (CloneNotSupportedException e) {
			newNode = currentNode;
		}
		// return "";
	}

	public void deleteBranch() {
		try {
			_commonDao.deleteMenuNode(userSessionId, currentNode.getId());
			currentNode = null;
			curMode = VIEW_MODE;
			menuBean.reloadMenu();
			loadTree();
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public void save() {
		try {
			if (isNewMode()) {
				_commonDao.addMenuNode(userSessionId, newNode);
			} else {
				_commonDao.modifyMenuNode(userSessionId, newNode);
			}
			curMode = VIEW_MODE;
			menuBean.reloadMenu();
			loadTree();
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public MenuNode getNewNode() {
		if (newNode == null) {
			newNode = new MenuNode();
		}
		return newNode;
	}

	// public void setNewNodeType(MenuNode newNode) {
	// this.newNode = newNode;
	// }

	public boolean getNodeHasChildren() {
		MenuNode message = getMenuNode();
		return (message != null) && message.hasChildren();
	}

	public void searchMenuNodes() {
		currentNode = null;
		loadTree();
	}

	public boolean isViewMode() {
		return curMode == VIEW_MODE;
	}

	public boolean isEditMode() {
		return curMode == EDIT_MODE;
	}

	public boolean isNewMode() {
		return curMode == NEW_MODE;
	}

	public boolean isTranslMode() {
		return curMode == TRANSL_MODE;
	}

    @Override
    public void clearFilter() {
        // do nothing
    }

    public ArrayList<SelectItem> getMenuNodes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>(menuNodes.size());
		try {
			MenuNode[] nodes = _commonDao.getMenuLight(userSessionId);
			String tmp;
			for (MenuNode node: nodes) {

				// don't know how to make jsf show &nbsp; in <f:selectItems>
				// element, so let him show dashes
				tmp = node.getName().replaceAll("^\\s*", "");
				int diff = node.getName().length() - tmp.length();
				for (int i = 0; i < diff; i++) {
					tmp = "-" + tmp;
				}
				items.add(new SelectItem(node.getId(), tmp));
			}
		} catch (Exception e) {
			for (MenuNode node: menuNodes) {
				items.add(new SelectItem(node.getId(), node.getName()));
			}
		}
		return items;
	}

	public void confirmEditLanguage() {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(newNode.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(newNode.getLang());

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		try {
			MenuNode[] menus = _commonDao.getMenus(userSessionId, params);
			if (menus != null && menus.length > 0) {
				newNode = menus[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
		}
	}

	public DictUtils getDictUtils() {
		if (dictUtils == null) {
			dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
		}
		return dictUtils;
	}
}
