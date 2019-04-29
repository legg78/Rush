package ru.bpc.sv2.ui.acquiring;

import java.util.ArrayList;
import java.util.LinkedHashSet;
import java.util.Map;
import java.util.Set;


import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.acquiring.MerchantType;
import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean (name = "MbMerchantType")
public class MbMerchantType extends AbstractBean {
	private static final Logger logger = Logger.getLogger("ACQUIRING");

	private AcquiringDao _acquireDao = new AcquiringDao();

	private CommonDao _commonDao = new CommonDao();

	private ArrayList<MerchantType> coreItems;
	private boolean treeLoaded;

	private ArrayList<MerchantType> merchantTypes;
	private MerchantType currentNode;
	private MerchantType newNode;
	private Integer instId;
	private ArrayList<SelectItem> institutions;
	

	private TreePath nodePath;

	private MerchantType filter;

	public MbMerchantType() {
		pageLink = "acquiring|merchantTypes";
	}

	private int addNodes(int startIndex, ArrayList<MerchantType> branches, MerchantType[] types) {
		int i;
		int level = types[startIndex].getLevel();

		for (i = startIndex; i < types.length; i++) {
			if (types[i].getLevel() != level) {
				break;
			}
			merchantTypes.add(types[i]);
			branches.add(types[i]);
			if ((i + 1) != types.length && types[i + 1].getLevel() > level) {
				types[i].setChildren(new ArrayList<MerchantType>());
				i = addNodes(i + 1, types[i].getChildren(), types);
			}
		}
		return i - 1;
	}

	private void loadTree() {
		try {
			coreItems = new ArrayList<MerchantType>();
			merchantTypes = new ArrayList<MerchantType>();
			if (!searching)
				return;

			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			params.setRowIndexEnd(-1);

			MerchantType[] types = _acquireDao.getMerchantTypes(userSessionId, params);

			if (types != null && types.length > 0) {
				addNodes(0, coreItems, types);
				if (nodePath == null) {
					currentNode = coreItems.get(0);
					setNodePath(new TreePath(currentNode, null));
				}
			}
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public ArrayList<MerchantType> getNodeChildren() {
		MerchantType type = getMerchantType();
		if (type == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return type.getChildren();
		}
	}

	public void setFilters() {
		filters = new ArrayList<Filter>();
		filter = getFilter();

		Filter paramFilter = new Filter();

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
	}

	public MerchantType getFilter() {
		if (filter == null) {
			filter = new MerchantType();
			filter.setInstId(userInstId);
		}
		return filter;
	}

	public void setFilter(MerchantType filter) {
		this.filter = filter;
	}

	private MerchantType getMerchantType() {
		return (MerchantType) Faces.var("merchantType");
	}

	public MerchantType getNode() {
		return currentNode;
	}

	public void setNode(MerchantType node) {
		this.currentNode = node;
	}

	public void add() {
		newNode = new MerchantType();
		newNode.setInstId(getFilter().getInstId());
	}

	public void delete() {
		try {
			_acquireDao.deleteMerchantTypesBranch(userSessionId, currentNode.getBranchId());
			currentNode = null;
			loadTree();
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			_acquireDao.addMerchantTypesBranch(userSessionId, newNode);

			loadTree();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
	}

	public ArrayList<SelectItem> getUsedNodes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		Set<String> vals = new LinkedHashSet<String>();

		for (MerchantType type : merchantTypes) {
			if (!type.getType().equals("MRCTTRMN")) {
				vals.add(type.getType());
			}
		}

		Map<String, Dictionary> dict = getDictUtils().getAllArticles();
		for (String name : vals) {
			items.add(new SelectItem(name, dict.get(name) != null ? dict.get(name).getName() : name));
		}

		return items;
	}

	public ArrayList<SelectItem> getFreeNodes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		Dictionary[] allTypes;
		try {
			allTypes = _commonDao.getArticlesByDict(userSessionId, DictNames.MERCHANT_TYPE);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return items;
		}

		// boolean used;
		for (Dictionary type : allTypes) {
			// used = false;
			// for (MerchantType branch: merchantTypes) {
			// if (type.getFullCode().equals(branch.getType())) {
			// used = true;
			// break;
			// }
			// }
			// if (!used) {
			items.add(new SelectItem(type.getFullCode(), type.getName()));
			// }
		}

		return items;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getDictMerchantType() {
		return DictNames.MERCHANT_TYPE;
	}

	public MerchantType getNewNode() {
		if (newNode == null) {
			newNode = new MerchantType();
		}
		return newNode;
	}

	// public void setNewNodeType(MerchantType newNode) {
	// this.newNode = newNode;
	// }

	public boolean getNodeHasChildren() {
		MerchantType message = getMerchantType();
		return (message != null) && message.hasChildren();
	}

	public void search() {
		curMode = VIEW_MODE;
		nodePath = null;
		currentNode = null;
		setSearching(true);
		// clearBeansStates();
		loadTree();
	}

	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	@Override
	public void clearFilter() {
		curMode = VIEW_MODE;
		filter = null;
		searching = false;
		clearBean();
	}
	
	public void clearBean() {
		nodePath = null;
		currentNode = null;
		coreItems = null;
		treeLoaded = false;
	}

}
