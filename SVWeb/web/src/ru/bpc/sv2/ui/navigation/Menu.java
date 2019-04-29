package ru.bpc.sv2.ui.navigation;

import org.apache.log4j.Logger;
import org.richfaces.component.UITree;
import org.richfaces.component.html.HtmlTree;
import org.richfaces.component.state.TreeState;
import org.richfaces.event.NodeSelectedEvent;
import org.richfaces.model.TreeNode;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.settings.SettingParam;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.session.StoreFilter;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import util.auxil.ManagedBeanWrapper;

import javax.faces.FacesException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.faces.event.ActionEvent;
import javax.servlet.http.HttpServletRequest;
import java.io.Serializable;
import java.math.BigDecimal;
import java.util.*;
import java.util.Map.Entry;

@SessionScoped
@ManagedBean(name = "menu")
public class Menu implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");
	
	private SettingParam collapsedParam; 
	private boolean collapsed = false;
	private boolean clicked;
	private Map<String, NavigationGroup> menu;
	private final List<String> groups;
	private UITree node;
	private UITree favoritesNode;
	private UITree searchNode;
	private TreeState treeState;
	private TreeState favoritesTreeState;
	private TreeState searchTreeState;
	private Object currentRowKey;
	private Object currentRowKeyFavorites;
	private Object currentRowKeySearch;
	private List<Object> rowKeys;
	private List<Object> rowKeysFavorites;
	private NavTreeElement currentNode;
	private NavTreeElement currentNodeFavorites;
	private NavTreeElement currentNodeSearch;
	private boolean keepState;
	private Stack<NavLinkElement> currentRoute;
	private String currentPageName;
	private String nextPageAction;

	private ArrayList<Long> nodePath;
	private ArrayList<Long> nodePathFavorites;

	private List<List<Long>> searchPaths;

	private Long currentSectionId;
	
	private String tabName;
	
	private Map<String, Boolean> favourites;
	
	private String searchTerm;
	
	private boolean search = false;
		
	public Menu() {
		rowKeys = new ArrayList<Object>();
		rowKeysFavorites = new ArrayList<Object>();
		try {
			collapsedParam = new SettingParam();
			collapsedParam.setParamLevel(LevelNames.USER);
			collapsedParam.setLevelValue(null);
			collapsedParam.setName(SettingsConstants.MENU_COLLAPSED);
			collapsedParam.setDataType(DataTypes.NUMBER);

			MenuFactory factory = (MenuFactory) ManagedBeanWrapper.getManagedBean("menuFactory");
			menu = factory.getMenuFromDB();
			groups = factory.getNavGroupsDB();
			favourites = factory.getFavouritesMap();
			collapsed = factory.getMenuCollapsedDefault();
		} catch (MenuCreationException mce) {
			throw new FacesException(mce);
		}
	}

	public Map<String, NavigationGroup> getMenu() {
		return menu;
	}

	public NavigationGroup getMenuGroup() {
		return menu.get(MenuFactory._ROOT_GROUP);
	}
	
	public NavigationGroup getFavouritesGroup() {
		return menu.get(MenuFactory._FAVOR_GROUP);
	}
	
	public NavigationGroup getSearchGroup() {
		return menu.get(MenuFactory._SEARCH_GROUP);
	}
	
	public List<String> getGroups() {
		return groups;
	}

	public UITree getNode() {
		return node;
	}

	public void setNode(UITree node) {
		this.node = node;
	}
	
	public UITree getSearchNode() {
		return searchNode;
	}

	public void setSearchNode(UITree searchNode) {
		this.searchNode = searchNode;
	}

	public UITree getFavoritesNode() {
		return favoritesNode;
	}

	public void setFavoritesNode(UITree favoritesNode) {
		this.favoritesNode = favoritesNode;
	}

	public Boolean autoExpand(UITree node) {
		NavTreeElement el = (NavTreeElement) node.getRowData();
		if (nodePath != null) {
			for (Long nodeId: nodePath) {
				if (nodeId.equals(el.getId())) {
					return true;
				}
			}
		}
		return null;
	}
	
	public Boolean autoExpandFavorites(UITree node) {
		NavTreeElement el = (NavTreeElement) node.getRowData();
		if (nodePathFavorites != null) {
			for (Long nodeId: nodePathFavorites) {
				if (nodeId.equals(el.getId())) {
					return true;
				}
			}
		}
		return null;
	}
	
	public Boolean autoExpandSearch(UITree node) {
		NavTreeElement el = (NavTreeElement) node.getRowData();
		if (searchPaths != null) {
			for (List<Long> subList : searchPaths) {
				for (Long nodeId: subList) {
					if (nodeId.equals(el.getId())) {
						return true;
					}
				}
			}
		}
		if (search) return false;
		else return null;
	}

	public Boolean autoSelectFavorites(UITree node) {
		return rowKeysFavorites.contains(node.getRowKey());
	}

	public TreeState getTreeState() {
		return treeState;
	}

	public void setTreeState(TreeState treeState) {
		this.treeState = treeState;
	}
	
	public TreeState getSearchTreeState() {
		return searchTreeState;
	}

	public void setSearchTreeState(TreeState searchTreeState) {
		this.searchTreeState = searchTreeState;
	}

	public TreeState getFavoritesTreeState() {
		return favoritesTreeState;
	}

	public void setFavoritesTreeState(TreeState favoritesTreeState) {
		this.favoritesTreeState = favoritesTreeState;
	}

    protected void log(Object object) {
        String methodName = Thread.currentThread().getStackTrace()[2].getMethodName();
        System.out.println("Menu " + methodName + ": " + object);
    }
	public void processSelection(NodeSelectedEvent event) {
		try {
			log("Pressed menu");
			rowKeys = new ArrayList<Object>();
			HtmlTree tree = (HtmlTree) event.getComponent();
			currentRowKey = tree.getRowKey();
			rowKeys.add(currentRowKey);
			while (currentRowKey != null) {
				rowKeys.add(tree.getParentRowKey(currentRowKey));
				currentRowKey = tree.getParentRowKey(currentRowKey);
			}
	
			// reset route to show only path that corresponds to menu tree
			resetRoute();
			resetRouteFavorites();
			resetRouteSearch();
			searchTreeState.setSelected(null);
			// reset all selections in case several windows were opened
			// with different menu items selected
			resetSelection(menu.get(MenuFactory._ROOT_GROUP).getBranch());
			resetSelection(menu.get(MenuFactory._FAVOR_GROUP).getBranch());
			if (menu.get(MenuFactory._SEARCH_GROUP) != null) {
				resetSelection(menu.get(MenuFactory._SEARCH_GROUP).getBranch());
			}
			currentNode = null;
			try {
				currentNode = (NavTreeElement) tree.getRowData();
				currentNode.setSelected(true);
				clicked = true;
			} catch (IllegalStateException ignored) {
				logger.error("", ignored);
			}
		} catch (Exception e){
			logger.error("", e);
		}
	}
	
	public void externalSelect(String key){
		TreeNode<NavTreeElement> root = menu.get(MenuFactory._ROOT_GROUP).getBranch();
		LinkedList<Entry<Object, TreeNode<NavTreeElement>>> route = new LinkedList<Entry<Object, TreeNode<NavTreeElement>>>();
		fillRoute(root, key, route);
		rowKeys = prepareRowKeys(route);
		prepareNodePath(route);
		resetRoute();
		resetRouteFavorites();
		resetRouteSearch();
		resetSelection(menu.get(MenuFactory._ROOT_GROUP).getBranch());
		resetSelection(menu.get(MenuFactory._FAVOR_GROUP).getBranch());
		treeState.setSelected(null);
		
		if (menu.get(MenuFactory._SEARCH_GROUP) != null){
			resetSelection(menu.get(MenuFactory._SEARCH_GROUP).getBranch());
		}
		
		currentNode = null;
		try {
			currentNode = prepareCurrentNode(route);
			if (currentNode != null) {
				currentNode.setSelected(true);
				clicked = true;
			}
		} catch (IllegalStateException ignored) {
			logger.error("", ignored);
		}
	}
	
	private void prepareNodePath(LinkedList<Entry<Object, TreeNode<NavTreeElement>>> route){
		if (nodePath == null){
			nodePath = new ArrayList<Long>();
		}
		for (Entry<Object, TreeNode<NavTreeElement>> entry : route){
			nodePath.add(entry.getValue().getData().getId());
		}
	}
	
	private ArrayList<Object> prepareRowKeys(LinkedList<Entry<Object, TreeNode<NavTreeElement>>> route){
		ArrayList<Object> result = new ArrayList<Object>();
		for (Entry<Object, TreeNode<NavTreeElement>> entry : route){
			result.add(entry.getKey());
		}
		return result;
	}
	
	private NavTreeElement prepareCurrentNode(LinkedList<Entry<Object, TreeNode<NavTreeElement>>> route){
		if (route.size() > 0) {
			return route.getFirst().getValue().getData();
		} else {
			return null;
		}
	}
	
	private boolean fillRoute(TreeNode<NavTreeElement> root, String key, LinkedList<Entry<Object, TreeNode<NavTreeElement>>> route){
		boolean result = false; //found
		Iterator<Entry<Object, TreeNode<NavTreeElement>>> i = root.getChildren();
		while (i.hasNext()){
			Entry<Object, TreeNode<NavTreeElement>> entry = i.next();
			TreeNode<NavTreeElement> value = entry.getValue();
			NavTreeElement data = value.getData();
			if (key.equals(data.getAction())){
				result = true;
				route.add(entry);
				break;
			}
			if (value.getChildren().hasNext()){
				result = fillRoute(value, key, route);
				if (result){
					route.add(entry);
					break;
				}
			}
		}
		return result;
	}
	
	public void processSelectionFavorites(NodeSelectedEvent event) {
		try {
			log("Pressed menu");
			rowKeysFavorites = new ArrayList<Object>();
			HtmlTree tree = (HtmlTree) event.getComponent();
			currentRowKeyFavorites = tree.getRowKey();
			rowKeysFavorites.add(currentRowKeyFavorites);
			while (currentRowKeyFavorites != null) {
				rowKeysFavorites.add(tree.getParentRowKey(currentRowKeyFavorites));
				currentRowKeyFavorites = tree.getParentRowKey(currentRowKeyFavorites);
			}
	
			// reset route to show only path that corresponds to menu tree
			resetRouteFavorites();
			// reset all selections in case several windows were opened
			// with different menu items selected
			resetSelection(menu.get("favourites").getBranch());
			if (currentNode != null) {
				currentNode.setSelected(false);
			}
			
			currentNode = null;
			rowKeys = new ArrayList<Object>();
			currentRowKey = null;
			treeState.setSelected(null);
			searchTreeState.setSelected(null);
			try {
				currentNodeFavorites = (NavTreeElement) tree.getRowData();
				currentNodeFavorites.setSelected(true);
				selectNode(currentNodeFavorites.getId());
			} catch (IllegalStateException ignored) {
	
			}
		} catch (Exception ignored) {

		}
	}
	
	public void processSelectionSearch(NodeSelectedEvent event) {
		try {
			log("Pressed menu");
			HtmlTree tree = (HtmlTree) event.getComponent();
			currentRowKeySearch = tree.getRowKey();
			while (currentRowKeySearch != null) {
				currentRowKeySearch = tree.getParentRowKey(currentRowKeySearch);
			}
	
			// reset route to show only path that corresponds to menu tree
			resetRouteSearch();
			// reset all selections in case several windows were opened
			// with different menu items selected
			resetSelection(menu.get(MenuFactory._SEARCH_GROUP).getBranch());
			if (currentNode != null) {
				currentNode.setSelected(false);
			}
			
			currentNode = null;
			rowKeys = new ArrayList<Object>();
			currentRowKey = null;
			treeState.setSelected(null);
			favoritesTreeState.setSelected(null);
			search = false;
			try {
				currentNodeSearch = (NavTreeElement) tree.getRowData();
				currentNodeSearch.setSelected(true);
				selectNode(currentNodeSearch.getId());
			} catch (IllegalStateException ignored) {
	
			}
		} catch (Exception ignored) {

		}
	}

	private void resetSelection(TreeNode<NavTreeElement> node) {
		Iterator<Entry<Object, TreeNode<NavTreeElement>>> iter = node.getChildren();
		while (iter.hasNext()) {
			TreeNode<NavTreeElement> value = iter.next().getValue();
			value.getData().setSelected(false);
			if (value.getChildren().hasNext()) {
				resetSelection(value);
			}
		}
	}
	
	private void resetRoute() {
		currentRoute = null;
	}
	
	@SuppressWarnings("UnusedParameters")
	public void resetCurrentRoute(ActionEvent e) {
		resetRoute();
	}
	
	private void resetRouteFavorites() {
		
	}
	
	private void resetRouteSearch() {
		
	}

	public NavTreeElement getCurrentNode() {
		return currentNode;
	}
	
	public NavTreeElement getCurrentNodeSearch() {
		return currentNodeSearch;
	}

	public NavTreeElement getCurrentNodeFavorites() {
		return currentNodeFavorites;
	}

	public Object getCurrentRowKey() {
		return currentRowKey;
	}

	public void setCurrentRowKey(Object currentRowKey) {
		this.currentRowKey = currentRowKey;
	}
	
	public Object getCurrentRowKeySearch() {
		return currentRowKeySearch;
	}

	public void setCurrentRowKeySearch(Object currentRowKeySearch) {
		this.currentRowKeySearch = currentRowKeySearch;
	}

	public Object getCurrentRowKeyFavorites() {
		return currentRowKeyFavorites;
	}

	public void setCurrentRowKeyFavorites(Object currentRowKeyFavorites) {
		this.currentRowKeyFavorites = currentRowKeyFavorites;
	}

	public boolean isKeepState() {
		return keepState;
	}

	public void setKeepState(boolean keepState) {
		this.keepState = keepState;
	}

	public boolean isFalseKeepState() {
		return false;
	}

	@SuppressWarnings("UnusedParameters")
	public void setFalseKeepState(boolean falseKeepState) {
		// this is kinda a constant
	}

	public boolean isTrueKeepState() {
		return true;
	}

	@SuppressWarnings("UnusedParameters")
	public void setTrueKeepState(boolean trueKeepState) {
		// this is kinda a constant
	}

	public void setCurrentRoute(Stack<NavLinkElement> currentRoute) {
		this.currentRoute = currentRoute;
	}

	public Stack<NavLinkElement> getCurrentRoute() {
		if (currentRoute == null) {
			currentRoute = new Stack<NavLinkElement>();
		}
		return currentRoute;
	}

	/**
	 * <p>
	 * Adds page to bread crumbs.
	 * </p>
	 * 
	 * @param pageName - page name.
	 */
	public void addPageToRoute(String pageName) {
		NavLinkElement el = new NavLinkElement();
		el.setPageName(pageName);
		getCurrentRoute().push(el);
	}

	/**
	 * <p>
	 * Removes last page from bread crumbs.
	 * </p>
	 */
	public int removeLastPageFromRoute() {
		if (getCurrentRoute().size() > 0) {
			currentRoute.pop();
		}
		return currentRoute.size();
	}
	
	public String processNextPage() {
		FacesContext ctx = FacesContext.getCurrentInstance();
		String url = ctx.getExternalContext().getRequestContextPath()
				+ ctx.getExternalContext().getRequestServletPath();

		NavLinkElement link = new NavLinkElement();
		link.setPageUrl(url);
		link.setPageName(currentPageName);
		getCurrentRoute().push(link);

		return nextPageAction;
	}

	public void setNextPageAction(String nextPageAction) {
		this.nextPageAction = nextPageAction;
	}

	public void setCurrentPageName(String currentPageName) {
		this.currentPageName = currentPageName;
	}

	public void popLinks() {
		String pageUrl = FacesContext.getCurrentInstance().getExternalContext()
				.getRequestParameterMap().get("pageUrl");
		while (true) {
			if (getCurrentRoute().peek().getPageUrl().equals(pageUrl)) {
				getCurrentRoute().pop();
				break;
			}
			getCurrentRoute().pop();
		}
	}

	/**
	 * Reloads menu (e.g. when user language is changed)
	 */
	public void reloadMenu() {
		try {
			MenuFactory factory = (MenuFactory) ManagedBeanWrapper.getManagedBean("menuFactory");
			menu = factory.getMenuFromDB();
			favourites = factory.getFavouritesMap();
			NavigationGroup rootGroup = menu.get(MenuFactory._ROOT_GROUP);
			if (rootGroup != null) {
				// select node if menu is not empty
				TreeNode<NavTreeElement> rootBranch = rootGroup.getBranch();
				if (currentNode != null) {
					selectNode(rootBranch);
				}
			}
		} catch (MenuCreationException e) {
			throw new FacesException(e);
		}
	}

	/**
	 * Reloads favourites menu (e.g. when user language is changed, added new section to favourites, etc.)
	 */
	private void reloadFavourites() {
		try {
			MenuFactory factory = (MenuFactory) ManagedBeanWrapper.getManagedBean("menuFactory");
			factory.getFavouritesFromDB(menu);
			favourites = factory.getFavouritesMap();
		} catch (MenuCreationException e) {
			throw new FacesException(e);
		}
	}
	
	public void reloadFavouritesFromPage() {
		try {
			reloadFavourites();
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	/**
	 * Looks for the node with same id as the current node to set it selected.
	 * 
	 * @param node
	 *            - node which is checked
	 * @return - <i>true</i> if node was found, <i>false</i> - otherwise
	 */
	private boolean selectNode(TreeNode<NavTreeElement> node) {
		Iterator<Entry<Object, TreeNode<NavTreeElement>>> it = node.getChildren();
		while (it.hasNext()) {
			Entry<Object, TreeNode<NavTreeElement>> entry = it.next();
			TreeNode<NavTreeElement> elem = entry.getValue();
			if (currentNode.getId().equals(elem.getData().getId())) {
				currentNode = elem.getData();
				currentNode.setSelected(true);
				return true;
			}
			if (elem.getChildren() != null) {
				if (selectNode(elem)) {
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	 * <p>
	 * Selects node by JSF's navigation case.
	 * <p>
	 * 
	 * @param pageAction
	 *            - <code>from-outcome</code> value of jsf's faces-config.xml
	 *            <code>navigation-case</code> element.
	 * @return - name of the selected node.
	 */
	public String selectNode(String pageAction) {
		resetRoute();
		nodePath = new ArrayList<Long>();
		resetSelection(menu.get(MenuFactory._ROOT_GROUP).getBranch());
		if (setSelection(menu.get(MenuFactory._ROOT_GROUP).getBranch(), pageAction)) {
			return currentNode.getName();
		}
		return null;
	}
	
	private String selectNode(Long id) {
		resetRoute();
		nodePath = new ArrayList<Long>();
		resetSelection(menu.get(MenuFactory._ROOT_GROUP).getBranch());
		if (setSelection(menu.get(MenuFactory._ROOT_GROUP).getBranch(), id)) {
			return currentNode.getName();
		}
		return null;
	}
	
	public String selectNodeFavorites(String pageAction) {
		resetRoute();
		nodePathFavorites = new ArrayList<Long>();
		resetSelection(menu.get(MenuFactory._FAVOR_GROUP).getBranch());
		if (setSelectionFavorites(menu.get(MenuFactory._FAVOR_GROUP).getBranch(), pageAction)) {
			return currentNodeFavorites.getName();
		}
		return null;
	}
	
	public String selectNodeSearch(String pageAction) {
		resetRoute();
		resetSelection(menu.get(MenuFactory._SEARCH_GROUP).getBranch());
		if (setSelectionSearch(menu.get(MenuFactory._SEARCH_GROUP).getBranch(), pageAction)) {
			return currentNodeSearch.getName();
		}
		return null;
	}

	/**
	 * <p>
	 * Sets menu node selection by <code>pageAction</code>.
	 * </p>
	 * 
	 * @param node
	 *            - menu node
	 * @param pageAction
	 *            - <code>from-outcome</code> value of jsf's faces-config.xml
	 *            <code>navigation-case</code> element.
	 */
	private boolean setSelection(TreeNode<NavTreeElement> node, String pageAction) {
		Iterator<Entry<Object, TreeNode<NavTreeElement>>> iter = node.getChildren();
		while (iter.hasNext()) {
			TreeNode<NavTreeElement> value = iter.next().getValue();
			if (pageAction.equals(value.getData().getAction())) {
				currentNode = value.getData();
				currentNode.setSelected(true);
				nodePath.add(currentNode.getId());
				// needed node is found, no more actions are required
				return true;
			}
			if (value.getChildren().hasNext()) {
				if (setSelection(value, pageAction)) {
					nodePath.add(value.getData().getId()); // add parents to path
					// needed node is found, no more actions are required
					return true;
				}
			}
		}
		return false;
	}
	
	/**
	 * <p>
	 * Sets menu node selection by <code>pageAction</code>.
	 * </p>
	 * 
	 * @param node - menu node
	 * @param sectionId - setcion id
	 */
	private boolean setSelection(TreeNode<NavTreeElement> node, Long sectionId) {
		Iterator<Entry<Object, TreeNode<NavTreeElement>>> iter = node.getChildren();
		while (iter.hasNext()) {
			TreeNode<NavTreeElement> value = iter.next().getValue();
			if (sectionId.equals(value.getData().getId())) {
				currentNode = value.getData();
				currentNode.setSelected(true);
				nodePath.add(currentNode.getId());
				// needed node is found, no more actions are required
				return true;
			}
			if (value.getChildren().hasNext()) {
				if (setSelection(value, sectionId)) {
					nodePath.add(value.getData().getId()); // add parents to path
					// needed node is found, no more actions are required
					return true;
				}
			}
		}
		return false;
	}
	
	private boolean setSelectionFavorites(TreeNode<NavTreeElement> node, String pageAction) {
		Iterator<Entry<Object, TreeNode<NavTreeElement>>> iter = node.getChildren();
		while (iter.hasNext()) {
			TreeNode<NavTreeElement> value = iter.next().getValue();
			if (pageAction.equals(value.getData().getAction())) {
				currentNodeFavorites = value.getData();
				currentNodeFavorites.setSelected(true);
				nodePathFavorites.add(currentNodeFavorites.getId());
				// needed node is found, no more actions are required
				return true;
			}
			if (value.getChildren().hasNext()) {
				if (setSelectionFavorites(value, pageAction)) {
					nodePathFavorites.add(value.getData().getId()); // add parents to path
					// needed node is found, no more actions are required
					return true;
				}
			}
		}
		return false;
	}
	
	private boolean setSelectionSearch(TreeNode<NavTreeElement> node, String pageAction) {
		Iterator<Entry<Object, TreeNode<NavTreeElement>>> iter = node.getChildren();
		while (iter.hasNext()) {
			TreeNode<NavTreeElement> value = iter.next().getValue();
			if (pageAction.equals(value.getData().getAction())) {
				currentNodeSearch = value.getData();
				currentNodeSearch.setSelected(true);
				// needed node is found, no more actions are required
				return true;
			}
			if (value.getChildren().hasNext()) {
				if (setSelectionSearch(value, pageAction)) {
					// needed node is found, no more actions are required
					return true;
				}
			}
		}
		return false;
	}
	
	public void changeMenuState() {
		collapsed = !collapsed;
		try {
			Long value = collapsed? 1L : 0L;
			collapsedParam.setValueN(BigDecimal.valueOf(value));
		} catch (Exception e) {
			logger.error("", e);
		}
	}

	public boolean isCollapsed() {
		return collapsed;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public boolean isRenderAddToFavourites() {
		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionIdStr = req.getParameter("sectionId");
		try {
			Long sectionId;
			if (sectionIdStr == null) {				
				sectionId = currentSectionId;
			} else {
				sectionId = Long.parseLong(sectionIdStr);
			}
			if (!menu.get(MenuFactory._FAVOR_GROUP).contain(sectionId)) {
				return true;	
			}
		} catch (Exception e) {
			logger.error("", e);
		} 
		return false;
	}
	
	public boolean isRenderRemoveFromFavourites() {
		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		try {
			if (sectionId != null && menu.get(MenuFactory._FAVOR_GROUP).contain(Long.parseLong(sectionId))) {
				return true;
			}
		} catch (Exception e) {
			logger.error("", e);
		} 
		return false;
	}
	
	public void search() {
		try {
			if(searchTerm == null || searchTerm.trim().length() == 0){
				return;
			}
			MenuFactory factory = (MenuFactory) ManagedBeanWrapper.getManagedBean("menuFactory");
			searchPaths = new ArrayList<List<Long>>();
			menu.put(MenuFactory._SEARCH_GROUP, factory.loadSearchTree(searchTerm, searchPaths));
			search = true;
		} catch (MenuCreationException mce) {
			throw new FacesException(mce);
		}
	}

	public Long getCurrentSectionId() {
		return currentSectionId;
	}

	public void setCurrentSectionId(Long currentSectionId) {
		this.currentSectionId = currentSectionId;
	}

	public Map<String, Boolean> getFavourites() {
		return favourites;
	}

	public boolean isClicked() {
		if (clicked) {
			clicked = false;
			return true;
		}
		return false;
	}

	public void setClicked(boolean clicked) {
		this.clicked = clicked;
	}

	public String getSearchTerm() {
		return searchTerm;
	}

	public void setSearchTerm(String searchTerm) {
		this.searchTerm = searchTerm;
	}
	
	public void setActivate(String bean){
		if (bean == null)
			return;
        StoreFilter storeFilter = (StoreFilter) ManagedBeanWrapper.getManagedBean("StoreFilter");
        storeFilter.clearqueue(bean);
        storeFilter.addFilter(bean, bean, null);
	}
}
