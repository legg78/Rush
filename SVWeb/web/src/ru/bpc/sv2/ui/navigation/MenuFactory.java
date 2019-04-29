package ru.bpc.sv2.ui.navigation;

import org.apache.commons.io.IOUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.TreeNode;
import org.richfaces.model.TreeNodeImpl;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.Node;
import org.w3c.dom.NodeList;
import org.xml.sax.SAXException;
import ru.bpc.sv2.common.MenuNode;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.RequestContextHolder;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.context.FacesContext;
import javax.xml.parsers.DocumentBuilderFactory;
import javax.xml.parsers.ParserConfigurationException;
import java.io.IOException;
import java.io.InputStream;
import java.io.Serializable;
import java.util.*;
import java.util.Map.Entry;
@SessionScoped
@ManagedBean(name = "menuFactory")
public class MenuFactory implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");

	private static final String	_XML_FP_ATTR_ROLES_DELIM	= ",";
	private static final String	_XML_FP_ATTR_ROLES		= "roles";
	private static final String	_XML_FP_ATTR_ICON		= "icon";
	private static final String	_XML_FP_ATTR_NAME		= "name";
	private static final String	_XML_PAGE_ATTR_ACTION	= "action";
	private static final String	_XML_PAGE_NODE			= "page";
	private static final String	_XML_FOLDER_NODE		= "folder";
	private static final String	_XML_FILTER_NODE		= "filter";
	private static final String	_XML_GROUP_ATTR_NAME	= _XML_FP_ATTR_NAME;
	private static final String	_XML_GROUP_NODE			= "group";
	private static final String	_CONTEXT_ATTR_ID		= "ru.bpc.svwi.orig_menu";
	private static final String	_CONTEXT_ATTR_GROUPS	= "ru.bpc.svwi.menu_groups";
	private static final String _DEFAULT_PATH			= "/WEB-INF/menu.xml";
	static final String _ROOT_GROUP 			        = "root";
	static final String _FAVOR_GROUP 			        = "favourites";
	static final String _SEARCH_GROUP 			        = "search";

	private static final Object _MENU_SYNC = new Object();
	private static final Object _GROUPS_SYNC = new Object();

	private Map<String, Boolean> favouritesMap;
	private CommonDao _commonDao = new CommonDao();

	private SettingsDao _settingsDao = new SettingsDao();

	private Long userSessionId = null;

	public MenuFactory() {
		checkUserSessionId();
	}

	public static Map<String, NavigationGroup> getMenu() throws MenuCreationException {
		return getMenu(_DEFAULT_PATH);
	}

	private static Map<String, NavigationGroup> getMenu(String path) throws MenuCreationException {
		Map<String, NavigationGroup> menu;
		synchronized( _MENU_SYNC ) {
			Map<String, Object> appContext = FacesContext.getCurrentInstance().getExternalContext().getApplicationMap();
			menu = loadMenu( path );
			appContext.put( _CONTEXT_ATTR_ID, menu );
		}
		return menu;
	}

	public static List<String> getNavGroups() throws MenuCreationException {
		return getNavGroups( _DEFAULT_PATH );
	}

	@SuppressWarnings("unchecked")
	private static List<String> getNavGroups(String path) throws MenuCreationException {
		List<String> groups;
		synchronized( _GROUPS_SYNC ) {
			Map<String, Object> appContext = FacesContext.getCurrentInstance().getExternalContext().getApplicationMap();
			if ( appContext.containsKey( _CONTEXT_ATTR_GROUPS ) ) {
				groups = (List<String>)appContext.get( _CONTEXT_ATTR_GROUPS );
			} else {
				Collection<NavigationGroup> plainGroups = loadMenu( path ).values();
				groups = new LinkedList<String>();

				for( NavigationGroup navGroup: plainGroups ) {
					groups.add( navGroup.getName() );
				}

				appContext.put( _CONTEXT_ATTR_GROUPS, groups );
			}
		}

		return groups;
	}

	public static Map<String, NavigationGroup> getMenu( IInRoleCallback roleCallback ) throws MenuCreationException {
		Map<String, NavigationGroup> menu = getMenu();
		return recalcRendering( menu, roleCallback );
	}

	public static Map<String, NavigationGroup> getMenu( String path, IInRoleCallback roleCallback ) throws MenuCreationException {
		Map<String, NavigationGroup> menu = getMenu( path );
		return recalcRendering( menu, roleCallback );
	}

//***************************************************************

	Map<String, NavigationGroup> getMenuFromDB() throws MenuCreationException {
		HashMap<String, NavigationGroup> menu;
		synchronized(_MENU_SYNC) {
			menu = loadTree();
		}
		return menu;
	}

	void getFavouritesFromDB(Map<String, NavigationGroup> menu) throws MenuCreationException {
		synchronized(_MENU_SYNC) {
			loadFavouritesTree(menu);
		}
	}

	boolean getMenuCollapsedDefault() {
		try {
			Double value = _settingsDao.getParameterValueN(getUserSessionId(), SettingsConstants.MENU_COLLAPSED, LevelNames.USER, null);
			return value.intValue() == 1;
		} catch (Exception e) {
			logger.error("", e);
		}
		return false;
	}

	private boolean getMenuFavouritesPlain() {
		try {
			Double value = _settingsDao.getParameterValueN(getUserSessionId(), SettingsConstants.MENU_BOOKMARKS_PLAIN, LevelNames.USER, null);
			return value.intValue() == 1;
		} catch (Exception e) {
			logger.error("", e);
		}
		return false;
	}

	private int addNodes(int startIndex, TreeNode<NavTreeElement> rootNode,
						 TreeNode<NavTreeElement> node, MenuNode[] nodes,
						 List<String> parentPath, boolean showLeafsOnly) {
		int i;
		int level = nodes[startIndex].getLevel();

		NavTreeElement lastElement = null;

		for (i = startIndex; i < nodes.length; i++) {
			if (nodes[i].getLevel() != level) {
				break;
			}
			TreeNodeImpl<NavTreeElement> nodeImpl = new TreeNodeImpl<NavTreeElement>();
			NavTreeElement treeElem = getNavTreeElement(nodes[i]);
			treeElem.setAncestorPath(parentPath);

			lastElement = treeElem;		// remember this element to check if it was last

			nodeImpl.setData(treeElem);
			if (!showLeafsOnly) {
				node.addChild(i, nodeImpl);
			} else if (_XML_PAGE_NODE.equals(treeElem.getType()) || _XML_FILTER_NODE.equals(treeElem.getType())) {
				rootNode.addChild(treeElem.getId(), nodeImpl);
				String path = "";
				for (int k = 0; k < treeElem.getAncestorPath().size(); k++) {
					path += treeElem.getAncestorPath().get(k) + " - ";
				}
				treeElem.setTitle(path + treeElem.getName());
			}

			List<String> ancestorPath = new LinkedList<String>(parentPath);
			ancestorPath.add(nodes[i].getName());

			if ((i + 1) != nodes.length && nodes[i + 1].getLevel() > level) {
				if (_XML_PAGE_NODE.equals(treeElem.getType())) {
					i = addNodes(i + 1, nodeImpl, nodeImpl, nodes, ancestorPath, showLeafsOnly);
				} else {
					i = addNodes(i + 1, rootNode, nodeImpl, nodes, ancestorPath, showLeafsOnly);
				}
			}
		}
		if (lastElement != null) {
			lastElement.setLast(true);
		}

		return i - 1;
	}

	Map<String, Boolean> getFavouritesMap() {
		return favouritesMap;
	}
	private HashMap<String, NavigationGroup> loadTree() throws MenuCreationException {
		HashMap<String, NavigationGroup> groupTrees = new HashMap<String, NavigationGroup>();
		try {
			MenuNode[] nodes = _commonDao.getMenu(getUserSessionId());

			TreeNode<NavTreeElement> rootNode = new TreeNodeImpl<NavTreeElement>();

			if (nodes != null && nodes.length > 0) {
				addNodes(0, rootNode, rootNode, nodes, new LinkedList<String>(), false);
				groupTrees.put(_ROOT_GROUP, new NavigationGroup(_ROOT_GROUP, rootNode));
			}
			boolean isPlain = getMenuFavouritesPlain();
			MenuNode[] favoriteNodes = _commonDao.getMenuFavorites(getUserSessionId());
			favouritesMap = new HashMap<String, Boolean>();
        	for (MenuNode node : favoriteNodes) {
        		favouritesMap.put(node.getId().toString(), Boolean.TRUE);
        	}
			TreeNode<NavTreeElement> favouritesNode = new TreeNodeImpl<NavTreeElement>();

			if (favoriteNodes.length > 0) {
				addNodes(0, favouritesNode, favouritesNode, favoriteNodes, new LinkedList<String>(), isPlain);
			}
			groupTrees.put(_FAVOR_GROUP, new NavigationGroup(_FAVOR_GROUP, favouritesNode));
		} catch (Exception e) {
			logger.error("Could not read menu. Request: "+ RequestContextHolder.getRequest().getRequestURI());
			throw new MenuCreationException(e);
		}
		return groupTrees;
	}

	NavigationGroup loadSearchTree(String searchTerm, List<List<Long>> searchPaths) throws MenuCreationException {
		Filter[] filters = new Filter[1];
		filters[0] = new Filter();
		filters[0].setElement("caption");
		filters[0].setValue("%" + searchTerm.trim().toUpperCase().replaceAll("[*]", "%").replaceAll("[?]", "_") + "%");

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);
		params.setRowIndexEnd(-1);
		MenuNode[] searchNodes = _commonDao.getSearchMenus( getUserSessionId(), params);

		searchNodes = removeDuplicateNode(searchNodes);
		buildSearchPath(searchNodes, searchTerm, searchPaths);

		TreeNode<NavTreeElement> searchNode = new TreeNodeImpl<NavTreeElement>();

		if (searchNodes != null && searchNodes.length > 0) {
			addNodes(0, searchNode, searchNode, searchNodes, new LinkedList<String>(), false);
			return new NavigationGroup(_SEARCH_GROUP, searchNode);
		}
		return null;
	}

	private MenuNode[] removeDuplicateNode(MenuNode[] searchNodes) {
		List<MenuNode> list = new LinkedList<MenuNode>();
		Map<Integer, MenuNode> map = new HashMap<Integer, MenuNode>();
		for (MenuNode node : searchNodes) {
			if (!map.containsKey(node.getId())) {
				map.put(node.getId(), node);
				list.add(node);
			}
		}
		return list.toArray(new MenuNode[list.size()]);
	}

	private void buildSearchPath(MenuNode[] searchNodes, String searchTerm, List<List<Long>> result) {
		MenuNode grandpa = null;
		List<Long> searchPath;
		for ( MenuNode node : searchNodes) {
			//keep grandpa node
			if (node.getParentId() == null) {
				grandpa = node;
			}
			if (node.getName() != null && node.getName().toUpperCase().contains(searchTerm.toUpperCase())) {
				searchPath = new ArrayList<Long>();
				if (grandpa != null && !node.getId().equals(grandpa.getId())) {
					searchPath.add(grandpa.getId().longValue());
				}
				if (grandpa != null && node.getParentId() != null && !node.getParentId().equals(grandpa.getId())) {
					searchPath.add(node.getParentId().longValue());
				}
				result.add(searchPath);
			}
		}
	}

	private void loadFavouritesTree(Map<String, NavigationGroup> menu) throws MenuCreationException {
		try {
			boolean isPlain = getMenuFavouritesPlain();
			MenuNode[] favoriteNodes = _commonDao.getMenuFavorites(getUserSessionId());
			favouritesMap = new HashMap<String, Boolean>();
        	for (MenuNode node : favoriteNodes) {
        		favouritesMap.put(node.getId().toString(), Boolean.TRUE);
        	}
			TreeNode<NavTreeElement> favouritesNode = new TreeNodeImpl<NavTreeElement>();

			if (favoriteNodes.length > 0) {
				addNodes(0, favouritesNode, favouritesNode, favoriteNodes, new LinkedList<String>(), isPlain);
				menu.put(_FAVOR_GROUP, new NavigationGroup(_FAVOR_GROUP, favouritesNode));
			} else {
				menu.put(_FAVOR_GROUP, new NavigationGroup(_FAVOR_GROUP, new TreeNodeImpl<NavTreeElement>()));
			}
		} catch (Exception e) {
			throw new MenuCreationException(e);
		}
	}

	/**
	 * Transforms MenuNode to NavTreeElement.<br>
	 * It is done so because NavTreeElement is from Web module
	 * which is not accessible for Dao module. Besides, it is
	 * used in so many places that replacing it everywhere could
	 * take a lot of time and lead to a lot of errors.
	 * @param node - MenuNode variable
	 * @return NavTreeElement variable
	 */
	private NavTreeElement getNavTreeElement(MenuNode node) {
		NavTreeElement elem = new NavTreeElement();
		elem.setId(node.getId().longValue());
		elem.setAction(node.getAction());
		elem.setLeaf(node.isLeaf() & !_XML_FOLDER_NODE.equals(node.getType()));
		elem.setName(node.getName());
		elem.setType(node.getType());
		elem.setManagedBeanName(node.getManagedBeanName());
		if (node.getParentId() != null) {
			elem.setParentId(node.getParentId().longValue());
		}
		return elem;
	}

	List<String> getNavGroupsDB() {
		List<String> groups = new ArrayList<String>();
		groups.add(_ROOT_GROUP);

		return groups;
	}
//******************************************************************


	private static Map<String, NavigationGroup> loadMenu( String path ) throws MenuCreationException {
		Document doc;
		InputStream is = null;
		Map<String, NavigationGroup> menu = null;
		try {
			is = FacesContext.getCurrentInstance().getExternalContext().getResourceAsStream( path );
			doc = DocumentBuilderFactory.newInstance().newDocumentBuilder().parse( is );
			menu  = processMenu( doc );
		} catch( SAXException saxe ) {
			throw new MenuCreationException( saxe );
		} catch( IOException ioe ) {
			throw new MenuCreationException( ioe );
		} catch( ParserConfigurationException pce ) {
			throw new MenuCreationException( pce );
		} finally {
			IOUtils.closeQuietly(is);
		}

		return menu;
	}

	private static Map<String, NavigationGroup> recalcRendering( Map<String, NavigationGroup> menu, IInRoleCallback roleCallback ) {
		Map<String, NavigationGroup> finalMenu = new HashMap<String, NavigationGroup>();
		for( NavigationGroup group : menu.values() ) {
			if( availableToRoles( group, roleCallback ) ) {
				TreeNodeImpl<NavTreeElement> acceptor = new TreeNodeImpl<NavTreeElement>();
				recalcNode( group.getBranch(), acceptor, roleCallback, 0 );

				NavigationGroup acceptorGroup = new NavigationGroup( group.getName(), acceptor );
				acceptorGroup.setVisibleToAny( group.isVisibleToAny() );
				acceptorGroup.addRoles( group.getRoles() );

				finalMenu.put( group.getName(), acceptorGroup );
			}
		}
		return finalMenu;
	}

	private static int recalcNode( TreeNode<NavTreeElement> src, TreeNode<NavTreeElement> trg, IInRoleCallback rolesCallback, int nodeCounter ) {
		trg.setData( src.getData() );
		if( !src.isLeaf() ) {
			Iterator<Entry<Object, TreeNode<NavTreeElement>>> it = src.getChildren();
			while( it.hasNext() ) {
				TreeNode<NavTreeElement> childNode = it.next().getValue();
				if( availableToRoles( childNode.getData(), rolesCallback ) ) {
					TreeNode<NavTreeElement> tRecip = new TreeNodeImpl<NavTreeElement>();
					trg.addChild( nodeCounter++, tRecip );

					nodeCounter = recalcNode( childNode, tRecip, rolesCallback, nodeCounter );
				}
			}
		}
		return nodeCounter;
	}

	private static boolean availableToRoles( RoleVisibility rv, IInRoleCallback roleCallback ) {
		if( rv.isVisibleToAny() ) {
			return true;
		}

		for( String aElem : rv.getRoles() ) {
			if( roleCallback.inRole( aElem ) ) {
				return true;
			}
		}
		return false;
	}

	private static Map<String, NavigationGroup> processMenu( Document doc ) throws MenuCreationException {
		Map<String, NavigationGroup> menu = loadNavigation( doc );
		propogateRolesOnGroups( menu );
		return menu;
	}

	private static void propogateRolesOnGroups( Map<String, NavigationGroup> menu ) {
		for( NavigationGroup navGroup: menu.values() ) {
			TreeNode<NavTreeElement> branch = navGroup.getBranch();

			propagateRoles( branch );

			Iterator<Entry<Object, TreeNode<NavTreeElement>>> it;
			it = branch.getChildren();
			while( it.hasNext() ) {
				TreeNode<NavTreeElement> childNode = it.next().getValue();

				if( childNode.getData().isVisibleToAny() ) {
					navGroup.setVisibleToAny( true );
					break;
				}
			}

			it = branch.getChildren();
			while( it.hasNext() ) {
				TreeNode<NavTreeElement> childNode = it.next().getValue();
				navGroup.getRoles().addAll( propagateRoles( childNode ) );
			}
		}
	}

	private static Set<String> propagateRoles( TreeNode<NavTreeElement> node ) {
		NavTreeElement data = node.getData();
		if( !node.isLeaf() && !data.isRolesPropagated() ) {
			Iterator<Entry<Object, TreeNode<NavTreeElement>>> it;

			it = node.getChildren();
			while( it.hasNext() ) {
				TreeNode<NavTreeElement> childNode = it.next().getValue();
				propagateRoles( childNode );
			}

			it = node.getChildren();
			while( it.hasNext() ) {
				TreeNode<NavTreeElement> childNode = it.next().getValue();

				if( childNode.getData().isVisibleToAny() ) {
					data.setVisibleToAny( true );
					data.setRolesPropagated( true );
					return null;
				}
			}

			it = node.getChildren();
			while( it.hasNext() ) {
				TreeNode<NavTreeElement> childNode = it.next().getValue();
				data.getRoles().addAll( propagateRoles( childNode ) );
			}
			data.setRolesPropagated( true );
		}
		return data.getRoles();
	}

	private static Map<String, NavigationGroup> loadNavigation( Document doc ) throws MenuCreationException {
		NodeList groups = doc.getDocumentElement().getElementsByTagName( _XML_GROUP_NODE );

		Map<String, NavigationGroup> groupTrees = new HashMap<String, NavigationGroup>();
		for( int i = 0; i < groups.getLength(); i++ ) {
			if( groups.item( i ) instanceof Element ) {
				Element group = (Element)groups.item( i );

				String groupName = group.getAttribute( _XML_GROUP_ATTR_NAME );

				TreeNode<NavTreeElement> root = new TreeNodeImpl<NavTreeElement>();
				root.setData( new NavTreeElement() );

				int counter = 0;
				NavTreeElement lastElement = null;
				for( Node groupChild = group.getFirstChild(); (groupChild = groupChild.getNextSibling()) != null; ) {
					if( groupChild instanceof Element ) {
						IterationResult itRes = loadNode( Collections.singletonList( groupName ), (Element)groupChild, counter);
						counter = itRes.getCounter();

						lastElement = itRes.getNavNode().getData();
						root.addChild( counter++, itRes.getNavNode() );
					}
				}
				if (lastElement != null) {
					lastElement.setLast(true);
				}
				groupTrees.put( groupName, new NavigationGroup( groupName, root ) );
			}
		}
		return groupTrees;
	}

	private static IterationResult loadNode( List<String> parentPath,  Element node, int nodeCounter) throws MenuCreationException {
		String nodeName = node.getNodeName();
		if( _XML_FOLDER_NODE.equals( nodeName ) || _XML_PAGE_NODE.equals( nodeName ) ) {
			NavTreeElement navElem = new NavTreeElement();

			navElem.setName( node.getAttribute( _XML_FP_ATTR_NAME ) );
			navElem.setIcon( node.hasAttribute( _XML_FP_ATTR_ICON ) ? node.getAttribute( _XML_FP_ATTR_ICON ) : null );

			if( _XML_PAGE_NODE.equals( nodeName ) ) {
				if( node.hasAttribute( _XML_FP_ATTR_ROLES ) ) {
					String roles = node.getAttribute( _XML_FP_ATTR_ROLES );
					StringTokenizer rolesTokens = new StringTokenizer( roles, _XML_FP_ATTR_ROLES_DELIM );
					while( rolesTokens.hasMoreTokens() ) {
						navElem.getRoles().add( rolesTokens.nextToken().trim() );
					}
					navElem.setVisibleToAny( false );
				} else {
					navElem.setVisibleToAny( true );
				}
			} else {
				navElem.setVisibleToAny( false );
			}

			navElem.setAncestorPath( parentPath );

			TreeNode<NavTreeElement> tn =  new TreeNodeImpl<NavTreeElement>();

			if( _XML_PAGE_NODE.equals( nodeName ) ) {
				navElem.setAction( node.getAttribute( _XML_PAGE_ATTR_ACTION ) );
				navElem.setLeaf( true );
			} else {
				navElem.setLeaf( false );

				List<String> ancestorPath = new LinkedList<String>( parentPath );
				ancestorPath.add( navElem.getName() );

				NavTreeElement lastElement = null;
				for( Node sibling = node.getFirstChild(); ( sibling = sibling.getNextSibling() ) != null; ) {
					if( sibling instanceof Element ) {
						int reserved = nodeCounter++;
						IterationResult nextit = loadNode( ancestorPath, (Element)sibling, nodeCounter);

						nodeCounter = nextit.getCounter();

						lastElement = nextit.getNavNode().getData();
						tn.addChild( reserved, nextit.getNavNode() );
					}
				}
				if (lastElement != null) {
					lastElement.setLast(true);
				}
			}

			tn.setData( navElem );

			return new IterationResult( tn, nodeCounter );
		} else {
			throw new MenuCreationException( "Invalid menu configuration: unexcepted node '" + nodeName + "'" );
		}
	}

	private static class IterationResult {
		private final TreeNode<NavTreeElement> _navNode;
		private final int	_counter;

		IterationResult(TreeNode<NavTreeElement> navNode, int counter) {
			_navNode = navNode;
			_counter = counter;
		}

		TreeNode<NavTreeElement> getNavNode()
		{
			return _navNode;
		}

		public int getCounter()
		{
			return _counter;
		}
	}

	private void checkUserSessionId() {
		if (userSessionId == null) {
			String sessionId = SessionWrapper.getUserSessionIdStr();
			userSessionId = sessionId != null ? Long.parseLong(sessionId) : null;
		}
	}

	public Long getUserSessionId() {
		checkUserSessionId();
		return userSessionId;
	}
}
