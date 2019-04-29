package ru.bpc.sv2.ui.process.monitoring;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean (name = "MbProcessHierarchy")
public class MbProcessHierarchy extends AbstractTreeBean<ProcessSession>{
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	private ProcessDao processDao = new ProcessDao();
	
	private TreePath nodePath;
	private ProcessSession activeProcessSession;
	private Long sessionId;
	private List<ProcessSession> rootNodes;
	
	public MbProcessHierarchy(){		
	}
	
	public List<ProcessSession> getNodeChildren(){
		if (!searching){
			return new ArrayList<ProcessSession>();
		}
		ProcessSession currentNode = getCurrentNode();
		if (currentNode == null){
			if (rootNodes == null){
				loadTree();
			}
			return rootNodes;
		} else {
			return currentNode.getChildren();
		}
		
	}
	
	protected void loadTree() {
		rootNodes = new ArrayList<ProcessSession>();
		setFilters();
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		ProcessSession[] processSessions = null;
		try {
			processSessions = processDao.getProcessSessionHierarchy(
					userSessionId, params);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		if (processSessions != null && processSessions.length > 0) {
			addNodes(0, rootNodes, processSessions);			
		}
	}	

	private void setFilters() {
		filters = new ArrayList<Filter>();
		
		Filter filter = new Filter();
		filter.setElement("sessionId");
		filter.setValue(sessionId);
		filters.add(filter);
		
		filter = new Filter();
		filter.setElement("lang");
		filter.setValue(userLang);
		filters.add(filter);
	}

	public boolean getNodeHasChildren() {
		return (getCurrentNode() != null) && getCurrentNode().hasChildren();
	}
	
	public ProcessSession getCurrentNode(){
		return (ProcessSession) Faces.var("item");
	}

	public void clear(){
		rootNodes = null;
		searching = false;
	}
	
	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}
	
	public ProcessSession getNodeData() {
		if (activeProcessSession == null) {
			activeProcessSession = new ProcessSession();
		}
		return activeProcessSession;
	}

	public void setNodeData(ProcessSession node) {		
		if (node == null)
			return;

		activeProcessSession = node;		
	}

	public Long getSessionId() {		
		return sessionId;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
		clear();
		searching = true;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}	
}
