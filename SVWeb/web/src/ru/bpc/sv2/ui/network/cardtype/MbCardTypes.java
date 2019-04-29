package ru.bpc.sv2.ui.network.cardtype;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.net.CardTypeFeature;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbCardTypes")
public class MbCardTypes extends AbstractTreeBean<CardType> {
	private static final long serialVersionUID = -2197972132322287097L;

	private static final Logger logger = Logger.getLogger("NET");

	private NetworkDao _networkDao = new NetworkDao();

	private MbCardTypeFeatures mbCardTypeFeatures;

	private CardType newNode;
	private ArrayList<SelectItem> networks;
	private HashMap<Integer, String> networksNames;

	private static String DETAILS_TAB = "detailsTab";
	private static String FEATURES_TAB = "featuresTab";

	private String tabName = DETAILS_TAB;

	private CardType filter;

	public MbCardTypes() {
		pageLink = "net|cardTypes";
		mbCardTypeFeatures = (MbCardTypeFeatures) ManagedBeanWrapper.getManagedBean("MbCardTypeFeatures");
	}

	public CardType getNode() {
		if (currentNode == null) {
			currentNode = new CardType();
		}
		return currentNode;
	}

	public void itemSelection() {
		if (filter == null) {
			filter = null;
		}
	}

	public void setItemSelection() {
		if (filter == null) {
			filter = null;
		}
	}

	public void setNode(CardType node) {
		if (node == null) {
			return;
		}

		this.currentNode = node;
		loadCurrentTab();
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	private CardType getCardType() {
		return (CardType) Faces.var("item");
	}

	protected void loadTree() {
		coreItems = new ArrayList<CardType>();
		if (!searching) {
			return;
		}
		try {
			setFilters();
			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			CardType[] types = _networkDao.getCardTypes(userSessionId, params);

			if (types != null && types.length > 0) {
				addNodes(0, coreItems, types);
				if (nodePath == null) {
					if (currentNode == null) {
						setNode(coreItems.get(0));
						setNodePath(new TreePath(currentNode, null));
					} else {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(types));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
					loadCurrentTab();
				}
			}
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public List<CardType> getNodeChildren() {
		CardType type = getCardType();
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

		// main filters, used in any product search
		Filter paramFilter = null;
		filter = getFilter();

		if (filter.getName() != null && !filter.getName().trim().equals("")) {
			paramFilter = new Filter();
			paramFilter.setElement("name");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getName().trim().toUpperCase().replaceAll("[*]", "%")
					.replaceAll("[?]", "_"));
			filters.add(paramFilter);
		}

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		if (filter.getNetworkId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("networkId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getNetworkId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public boolean getNodeHasChildren() {
		return (getCardType() != null) && getCardType().isHasChildren();
	}

	public void add() {
		curMode = NEW_MODE;
		newNode = new CardType();
		newNode.setParentId(currentNode.getParentId());
		newNode.setLang(userLang);
	}

	public void edit() {
		curMode = EDIT_MODE;
		newNode = new CardType();
		copyCardType(currentNode, newNode);
	}

	/**
	 * Copies properties that are changed during cardType edit
	 *
	 * @param from - cardType which properties are copied
	 * @param to   - cardType where properties are copied to
	 */
	private void copyCardType(CardType from, CardType to) {
		to.setId(from.getId());
		to.setParentId(from.getParentId());
		to.setNetworkId(from.getNetworkId());
		to.setName(from.getName());
		to.setLang(from.getLang());
		to.setSeqNum(from.getSeqNum());
		to.setChildren(from.getChildren());
		to.setLeaf(from.isLeaf());
		to.setVirtual(from.getVirtual());
//    	to.setLevel(from.getLevel());
	}

	public void save() {
		try {
			if (isNewMode()) {
				newNode = _networkDao.addCardType(userSessionId, newNode);
				addElementToTree(newNode);
			} else {
				newNode = _networkDao.modifyCardType(userSessionId, newNode);
				replaceCurrentNode(newNode);
			}

			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("CardType has been saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		loadCurrentTab();
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}

	public void delete() {
		try {
			_networkDao.deleteCardType(userSessionId, currentNode);
			curMode = VIEW_MODE;

			deleteNodeFromTree(currentNode, coreItems);
			currentNode = null;
			clearBeansStates();
			if (coreItems.size() > 0) {
				currentNode = coreItems.get(0);
				setNodePath(new TreePath(currentNode, null));
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void search() {
		curMode = VIEW_MODE;
		clearBean();
		searching = true;
		loadTree();
	}

	public void clearBean() {
		currentNode = null;
		nodePath = null;
		coreItems = null;
		treeLoaded = false;
		curLang = userLang;
	}

	public void clearFilter() {
		curMode = VIEW_MODE;
		clearBean();
		filter = null;
		searching = false;
	}

	public ArrayList<SelectItem> getParentCardTypes() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);

		if (getNewNode().getNetworkId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("networkId");
			paramFilter.setValue(getNewNode().getNetworkId());
			filtersList.add(paramFilter);
		}

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);
		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));
		try {
			CardType[] types = _networkDao.getCardTypes(userSessionId, params);
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(types.length);

			ArrayList<Long> excludeNodeIds = new ArrayList<Long>();
			if (isEditMode()) {
				excludeNodeIds.add(currentNode.getId());
			}
			for (CardType type : types) {
				if (isEditMode()) {
					boolean excludeNode = false;
					for (Long excludeNodeId : excludeNodeIds) {
						// check if it's the same node as current or if it's one of current node's children
						if (excludeNodeId.equals(type.getId())
								|| excludeNodeId.equals(type.getParentId())) {
							excludeNodeIds.add(type.getId());
							excludeNode = true;
							break;
						}
					}
					if (excludeNode) {
						continue;
					}
				}

				String name = "";
				for (int i = 1; i < type.getLevel(); i++) {
					name = "--" + name;
				}
				if (type.getLevel() > 1) {
					name = " " + name + " " + type.getName();
				} else {
					name = type.getName();
				}

				items.add(new SelectItem(type.getId(), name));
			}

			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		}

		return new ArrayList<SelectItem>(0);
	}

	public ArrayList<SelectItem> getNetworks() {
		if (networks == null) {
			getNetworksNames().clear();
			ArrayList<SelectItem> items = new ArrayList<SelectItem>();
			try {
				SelectionParams params = new SelectionParams();
				params.setRowIndexEnd(-1);

				List<Filter> filtersList = new ArrayList<Filter>();
				Filter paramFilter = new Filter();
				paramFilter.setElement("lang");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(userLang);
				filtersList.add(paramFilter);

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				Network[] nets = _networkDao.getNetworks(userSessionId, params);
				for (Network net : nets) {
					getNetworksNames().put(net.getId(), net.getName());
					items.add(new SelectItem(net.getId(), net.getName(), net.getDescription()));
				}
				networks = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (networks == null) {
					networks = new ArrayList<SelectItem>();
				}
			}
		}
		return networks;
	}

	public CardType getNewNode() {
		if (newNode == null) {
			newNode = new CardType();
		}
		return newNode;
	}

	public void setNewNode(CardType newNode) {
		this.newNode = newNode;
	}

	public void clearBeansStates() {

	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(currentNode.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);

		filters = filtersList;
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			CardType[] cardTypes = _networkDao.getCardTypesList(userSessionId, params);
			if (cardTypes != null && cardTypes.length > 0) {
				cardTypes[0].copy(currentNode);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public CardType getFilter() {
		if (filter == null) {
			filter = new CardType();
		}
		return filter;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		loadCurrentTab();

		if (tabName.equalsIgnoreCase(FEATURES_TAB)) {
			mbCardTypeFeatures.setTabName(tabName);
			mbCardTypeFeatures.setParentSectionId(getSectionId());
			mbCardTypeFeatures.setTableState(getSateFromDB(mbCardTypeFeatures.getComponentId()));
		}
	}

	public String getSectionId() {
		return SectionIdConstants.CONFIGURATION_CARD_TYPE;
	}

	private void loadCurrentTab() {

		if (tabName.equalsIgnoreCase(FEATURES_TAB)) {
			Long cardTypeId = currentNode != null ? currentNode.getId() : null;
			if (cardTypeId != null) {
				CardTypeFeature feature = new CardTypeFeature();
				feature.setCardTypeId(cardTypeId.intValue());  // cardTypeId is actually integer			
				mbCardTypeFeatures.setFilter(feature);
				mbCardTypeFeatures.search();
			}
		} else {
			mbCardTypeFeatures.setFilter(null);

		}
	}


	public HashMap<Integer, String> getNetworksNames() {
		if (networksNames == null) {
			networksNames = new HashMap<Integer, String>();
		}
		return networksNames;
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
			CardType[] cardTypes = _networkDao.getCardTypesList(userSessionId, params);
			if (cardTypes != null && cardTypes.length > 0) {
				newNode = cardTypes[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
