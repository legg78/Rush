package ru.bpc.sv2.ui.orgstruct;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.common.Dictionary;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.orgstruct.AgentType;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean(name = "MbAgentType")
public class MbAgentType extends AbstractBean {
	private static final long serialVersionUID = 3471273573613625453L;

	private CommonDao _commonDao = new CommonDao();

	private OrgStructDao _orgStructDao = new OrgStructDao();

	private ArrayList<AgentType> agentTypes;
	private ArrayList<AgentType> coreItems;
	private AgentType currentNode;
	private AgentType newNode;
	private Integer instId;
	private List<SelectItem> institutions;
	private boolean treeLoaded = false;
	
	private TreePath nodePath;

	private static final Logger logger = Logger.getLogger("ORG_STRUCTURE");

	public MbAgentType() {
		pageLink = "orgStruct|agentTypes";
		instId = userInstId;
		
		setDefaultValues();
	}

	private int addNodes(int startIndex, ArrayList<AgentType> branches, AgentType[] types) {
		int i;
		int level = types[startIndex].getLevel();

		for (i = startIndex; i < types.length; i++) {
			if (types[i].getLevel() != level) {
				break;
			}
			agentTypes.add(types[i]);
			branches.add(types[i]);
			if ((i + 1) != types.length && types[i + 1].getLevel() > level) {
				types[i].setChildren(new ArrayList<AgentType>());
				i = addNodes(i + 1, types[i].getChildren(), types);
			}
		}
		return i - 1;
	}

	public void clearFilter() {
		currentNode = null;
		treeLoaded = false;
		searching = false;
		setDefaultValues();
	}
	
	private void setDefaultValues() {
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			instId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		} else {
			instId = userInstId;
		}
	}

	private void loadTree() {
		try {
//			if (instId == null) {
//				loadInstitutions();
//			}
			coreItems = new ArrayList<AgentType>();
			agentTypes = new ArrayList<AgentType>();
	
			if (instId == null || !searching)
				return;
	
			AgentType[] types = _orgStructDao.getAgentTypes(userSessionId, instId);
			if (types != null && types.length > 0) {
				addNodes(0, coreItems, types);
			}
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public ArrayList<AgentType> getNodeChildren() {
		AgentType type = getAgentType();
		if (type == null) {
			if (!treeLoaded || coreItems == null) {
				loadTree();
			}
			return coreItems;
		} else {
			return type.getChildren();
		}
	}

	private AgentType getAgentType() {
		return (AgentType) Faces.var("agentType");
	}

	public AgentType getNode() {
		return currentNode;
	}

	public void setNode(AgentType node) {
		this.currentNode = node;
	}

	public void addBranch() {
		newNode = new AgentType();
		newNode.setInstId(instId);
		// return "";
	}

	public void deleteBranch() {
		try {
			_orgStructDao.removeAgentTypeBranch(userSessionId, currentNode.getBranchId());
			currentNode = new AgentType();
			loadTree();
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void save() {
		try {
			_orgStructDao.addAgentTypeBranch(userSessionId, newNode);

			loadTree();
			FacesUtils.addMessageInfo("Saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void close() {
	}

	public void changeInstitution(ValueChangeEvent event) {
		instId = (Integer) event.getNewValue();

		loadTree();
	}

//	private void loadInstitutions() {
//		try {
//			institutions = _orgStructDao.getInstitutionsForDropdown(userSessionId, null, curLang,
//					false);
//		} catch (Exception e) {
//			FacesUtils.addMessageError(e);
//			logger.error("", e);
//		}
//	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public ArrayList<SelectItem> getUsedNodes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		for (AgentType type: agentTypes) {
			if (getDictUtils().getArticles().get(type.getType()) != null) {
				items.add(new SelectItem(type.getType(), getDictUtils().getArticles().get(type.getType())));
			} else {
				items.add(new SelectItem(type.getType(), type.getType()));
			}
		}
		return items;
	}

	public ArrayList<SelectItem> getFreeNodes() {
		if (instId == null) {
			return new ArrayList<SelectItem>(0);
		}
		
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		Dictionary[] allTypes;
		Filter[] filters = new Filter[3];
		filters[0] = new Filter();
		filters[0].setElement("lang");
		filters[0].setValue(curLang);
		filters[1] = new Filter();
		filters[1].setElement("dict");
		filters[1].setValue(DictNames.AGENT_TYPE);
		filters[2] = new Filter();
		filters[2].setElement("instId");
		filters[2].setValue(instId.toString());

		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(Integer.MAX_VALUE);
		params.setFilters(filters);
		try {
			allTypes = _commonDao.getArticles(userSessionId, params);
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return items;
		}

		boolean used;
		for (Dictionary type: allTypes) {
			used = false;
			for (AgentType branch: agentTypes) {
				if (type.getFullCode().equals(branch.getType())) {
					used = true;
					break;
				}
			}
			if (!used) {
				items.add(new SelectItem(type.getFullCode(), type.getName()));
			}
		}

		return items;
	}

	public Integer getInstId() {
		return instId;
	}

	public void setInstId(Integer instId) {
		this.instId = instId;
	}

	public String getDictAgentType() {
		return DictNames.AGENT_TYPE;
	}

	public AgentType getNewNode() {
		if (newNode == null) {
			newNode = new AgentType();
		}
		return newNode;
	}

	public void setNewNodeType(AgentType newNode) {
		this.newNode = newNode;
	}

	public boolean getNodeHasChildren() {
		AgentType message = getAgentType();
		return (message != null) && message.hasChildren();
	}

	public void searchAgentTypes() {
		currentNode = null;
		searching = true;
		nodePath = null;
		loadTree();
	}
	
	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}
}
