package ru.bpc.sv2.ui.application;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.application.ApplicationFlowFilterStruct;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbApplicationFilters")
public class MbApplicationFilters extends AbstractTreeBean<ApplicationFlowFilterStruct> {
	private static final long serialVersionUID = 7457844112714550742L;

	private static final Logger logger = Logger.getLogger("APPLICATION");

	private ApplicationDao _applicationDao = new ApplicationDao();

	private ApplicationFlowFilter flowFilter;
	

	private ArrayList<SelectItem> institutions;
	private ApplicationFlowFilter filter;
	private String tabName;
	
	private List<ApplicationFlowFilterStruct> clipboard = new ArrayList<ApplicationFlowFilterStruct>();

	public MbApplicationFilters() {
		pageLink = "applications|filters";
		setDefaultValues();
	}

	public ApplicationFlowFilterStruct getNode() {
		if (currentNode == null) {
			currentNode = new ApplicationFlowFilterStruct();
		}
		return currentNode;
	}

	public void setNode(ApplicationFlowFilterStruct node) {
		if (node == null)
			return;

		this.currentNode = node;
	}

	public TreePath getNodePath() {
		return nodePath;
	}

	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	private ApplicationFlowFilterStruct getApplicationFlowFilterStruct() {
		return (ApplicationFlowFilterStruct) Faces.var("item");
	}

	protected void loadTree() {
		coreItems = new ArrayList<ApplicationFlowFilterStruct>();

		if (!searching)
			return;

		try {

			setFilters();

			SelectionParams params = new SelectionParams();
			params.setFilters(filters.toArray(new Filter[filters.size()]));
			ApplicationFlowFilterStruct[] types = _applicationDao.getApplicationFiltersTree(userSessionId, params);

			if (types != null && types.length > 0) {
				addNodes(0, coreItems, types);
				if (currentNode != null) {
					currentNode = findInCoreItemsIfPossible(currentNode);
				}
				if (nodePath == null) {
					if (currentNode != null) {
						if (currentNode.getParentId() != null) {
							setNodePath(formNodePath(types));
						} else {
							setNodePath(new TreePath(currentNode, null));
						}
					}
				}
			}
			treeLoaded = true;
		} catch (DataAccessException ee) {
			FacesUtils.addMessageError(ee);
			logger.error("", ee);
		}
	}

	public List<ApplicationFlowFilterStruct> getNodeChildren() {
		ApplicationFlowFilterStruct type = getApplicationFlowFilterStruct();
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
		Filter paramFilter;
		filter = getFilter();

		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getId());
			filters.add(paramFilter);
		}
		
		if (filter.getStageId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("stageId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getStageId());
			filters.add(paramFilter);
		}
		
		if (filter.getFlowId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("flowId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getFlowId());
			filters.add(paramFilter);
		}

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
	
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(userLang);
		filters.add(paramFilter);
	}

	public boolean getNodeHasChildren() {
		return (getApplicationFlowFilterStruct() != null) && getApplicationFlowFilterStruct().isHasChildren();
	}
	
	public void set() {
		Integer flowFilterId = currentNode.getFlowFilterId();
		if (flowFilterId == null) {
			curMode = NEW_MODE;			
		} else {
			curMode = EDIT_MODE;			
		}
		flowFilter = getFlowFilterFromNode(currentNode);
	}

	public void save() {
		try {
			currentNode.setVisible(flowFilter.getVisible());
			currentNode.setUpdatable(flowFilter.getUpdatable());
			currentNode.setInsertable(flowFilter.getInsertable());
			currentNode.setMinCount(flowFilter.getMinCount());
			currentNode.setMaxCount(flowFilter.getMaxCount());
			currentNode.setValueV(flowFilter.getValueV());
			currentNode.setValueN(flowFilter.getValueN());
			currentNode.setValueD(flowFilter.getValueD());
			if (flowFilter.getLovId() != null) {
				flowFilter.setValue(flowFilter.isChar() ? flowFilter.getValueV() : flowFilter.getValueN());
				currentNode.setLovValue(getDictUtils().getLovMap(flowFilter.getLovId()).get(String.valueOf(flowFilter.getValue())));
			}
			curMode = VIEW_MODE;
			FacesUtils.addMessageInfo("ApplicationFlowFilterStruct has been saved!");
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
	}
	
	private ApplicationFlowFilter getFlowFilterFromNode(ApplicationFlowFilterStruct node) {
		ApplicationFlowFilter flowFilter = new ApplicationFlowFilter();
		if (node != null && node.getId() != null) {
			flowFilter.setDefaultValue(node.getDefaultValue());
			flowFilter.setId(node.getFlowFilterId());
			flowFilter.setSeqNum(node.getFlowFilterSeqnum());
			flowFilter.setMaxCount(node.getMaxCount());
			flowFilter.setMinCount(node.getMinCount());
			flowFilter.setInsertable(node.getInsertable());
			flowFilter.setUpdatable(node.getUpdatable());
			flowFilter.setVisible(node.getVisible());
			flowFilter.setValueV(node.getValueV());
			flowFilter.setValueN(node.getValueN());
			if (node.getValueD() !=  null) {
				flowFilter.setValueD(new Date(node.getValueD().getTime()));
			}
			flowFilter.setStructId(node.getStId());
			flowFilter.setStageId(getFilter().getStageId());
			flowFilter.setDataType(node.getDataType());
			flowFilter.setLovId(node.getLovId());
		}
		return flowFilter;
	}

	public void delete() {
		try {
			flowFilter = getFlowFilterFromNode(currentNode);
			_applicationDao.deleteApplicationFlowFilter(userSessionId, flowFilter);
			curMode = VIEW_MODE;

			search();
			currentNode = null;
			clearBeansStates();

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
		setDefaultValues();
	}

	private void setDefaultValues() {
		Integer defaultInstId = userInstId;
		List<SelectItem> instList = getInstitutions();
		if (userInstId == ApplicationConstants.DEFAULT_INSTITUTION && !instList.isEmpty()) {
			// instId from LOV is for some reason String 
			defaultInstId = Integer.valueOf((String) getInstitutions().get(0).getValue());
		}
		getFilter().setInstId(defaultInstId);
	}

	public ApplicationFlowFilter getFlowFilter() {
		if (flowFilter == null) {
			flowFilter = new ApplicationFlowFilter();
		}
		return flowFilter;
	}

	public void setFlowFilter(ApplicationFlowFilter flowFilter) {
		this.flowFilter = flowFilter;
	}

	public void clearBeansStates() {

	}

	public ApplicationFlowFilter getFilter() {
		if (filter == null) {
			filter = new ApplicationFlowFilter();
		}
		return filter;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	
	public List<SelectItem> getFlows() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (getFilter().getInstId() != null) {
			paramMap.put("INSTITUTION_ID", getFilter().getInstId());
		} else {
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(LovConstants.APP_FLOWS, paramMap);
	}
	
	public List<SelectItem> getStages() {
		Map<String, Object> paramMap = new HashMap<String, Object>();
		if (getFilter().getFlowId() != null) {
			paramMap.put("FLOW_ID", getFilter().getFlowId());
		} else {
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(LovConstants.APP_STAGES, paramMap);
	}

	public void copy(){
		clipboard.clear();
		for (ApplicationFlowFilterStruct item : coreItems){
			clipboard.add(item);
		}
	}
	
	public void paste(){
		String cbApplType = clipboard.get(0).getAppType();
		if (!cbApplType.equals(coreItems.get(0).getAppType())){
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Error", "past_from_clipboard_error");
			FacesUtils.addErrorExceptionMessage(msg);
			return;
		}
		copyFiltersLists(clipboard, coreItems);
	}
	
	private void copyFiltersLists(List<ApplicationFlowFilterStruct>source, List<ApplicationFlowFilterStruct> target) {
		if (source != null && target != null) {
			int size = (source.size() > target.size()) ? target.size() : source.size();
			ApplicationFlowFilterStruct buf = new ApplicationFlowFilterStruct();
			for (int i = 0; i < size; i++) {
				ApplicationFlowFilterStruct targetFilter = target.get(i);
				ApplicationFlowFilterStruct sourceFilter = source.get(i);
				targetFilter.copyTo(buf);
				sourceFilter.copyTo(targetFilter);
				targetFilter.setId(buf.getId());
				targetFilter.setParentId(buf.getParentId());
				targetFilter.setStageId(buf.getStageId());
				if (sourceFilter.getFlowFilterId() != null) {
					targetFilter.setFlowFilterId(buf.getFlowFilterId());
					targetFilter.setFlowFilterSeqnum(buf.getFlowFilterSeqnum());
				} else {
					targetFilter.setFlowFilterId(null);
					targetFilter.setFlowFilterSeqnum(null);
				}
				targetFilter.setStId(buf.getStId());
				if (targetFilter.getChildren() != null && targetFilter.getChildren().size() > 0) {
					copyFiltersLists(sourceFilter.getChildren(), targetFilter.getChildren());
				}
			}
		}
	}

	public boolean isClipboardIsEmpty(){
		return clipboard.isEmpty();
	}
	
	public void saveAll(){
		List<ApplicationFlowFilterStruct> sample = new ArrayList<ApplicationFlowFilterStruct>();
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		ApplicationFlowFilterStruct[] types = _applicationDao.getApplicationFiltersTree(userSessionId, params);
		if (types != null && types.length > 0) {
			addNodes(0, sample, types);
		}				
		
		int targetSize = coreItems.size();
		boolean itemHasMinMaxError = false;
		for (ApplicationFlowFilterStruct coreItem : coreItems) {
			itemHasMinMaxError = itemHasMinMaxError || checkForMinMaxError(coreItem);
		}
		if (itemHasMinMaxError){
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Error", "errors_have_been_detected");
			FacesUtils.addErrorExceptionMessage(msg);
			return;
		}
		for (int i=0; i<targetSize; i++){		
			compareAndSave(coreItems.get(i), sample.get(i));
		}
		loadTree();
	}
	
	private boolean checkForMinMaxError(ApplicationFlowFilterStruct target){
		boolean result = false;
		if (target.getMaxCount() < target.getMinCount()){
			target.setMinMaxError(true);
			result = true;
		} else if (target.isMinMaxError()){
			target.setMinMaxError(false);
		}
		if (target.getChildren() != null && !target.getChildren().isEmpty()){
			boolean childResult;
			for (ApplicationFlowFilterStruct item : target.getChildren()){
				childResult = checkForMinMaxError(item);
				result = result || childResult;
			}
		}
		return result;
	}
	
	private void compareAndSave(ApplicationFlowFilterStruct target, ApplicationFlowFilterStruct sample){
		boolean objEq;
		
		boolean condition = (sample.getVisible() != null && !sample.getVisible().equals(target.getVisible()));
		condition = condition || (sample.getUpdatable() != null && !sample.getUpdatable().equals(target.getUpdatable()));
		condition = condition || (sample.getInsertable() != null && !sample.getInsertable().equals(target.getInsertable()));
		condition = condition || (sample.getMinCount() != null && !sample.getMinCount().equals(target.getMinCount()));
		condition = condition || (sample.getMaxCount() != null && !sample.getMaxCount().equals(target.getMaxCount()));

		condition = condition
				|| ((sample.getValueV() != null && (target.getValueV() == null || !sample.getValueV().equals(
						target.getValueV()))) || (target.getValueV() != null && (sample.getValueV() == null || !target
						.getValueV().equals(sample.getValueV()))));
		condition = condition
				|| ((sample.getValueN() != null && (target.getValueN() == null || !sample.getValueN().equals(
						target.getValueN()))) || (target.getValueN() != null && (sample.getValueN() == null || !target
						.getValueN().equals(sample.getValueN()))));
		condition = condition
				|| ((sample.getValueD() != null && (target.getValueD() == null || !sample.getValueD().equals(
						target.getValueD()))) || (target.getValueD() != null && (sample.getValueD() == null || !target
						.getValueD().equals(sample.getValueD()))));
		
		objEq = !condition;
		
		if (target.getFlowFilterId() == null && sample.getFlowFilterId() != null){
			ApplicationFlowFilter targetFlowFilter = getFlowFilterFromNode(sample);
			_applicationDao.deleteApplicationFlowFilter(userSessionId, targetFlowFilter);
			target.setFlowFilterId(null);			
		} else if (!objEq) {
			ApplicationFlowFilter targetFlowFilter = getFlowFilterFromNode(target);
			if (target.getFlowFilterId() != null){
				_applicationDao.editApplicationFlowFilter(userSessionId, targetFlowFilter);
			} else {
				_applicationDao.addApplicationFlowFilter(userSessionId, targetFlowFilter);
				target.setFlowFilterId(targetFlowFilter.getId());
			}
		}

		if (target.getChildren() != null && !target.getChildren().isEmpty()){
			List<ApplicationFlowFilterStruct> targetChildren = target.getChildren();
			List<ApplicationFlowFilterStruct> sampleChildren = sample.getChildren();
			int childrenSize = targetChildren.size();
			for (int i=0;i<childrenSize; i++){
				compareAndSave(targetChildren.get(i), sampleChildren.get(i));
			}
		}
	}
	
	public List<SelectItem> getFilterLov() {
		if (flowFilter == null || flowFilter.getLovId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		return getDictUtils().getLov(flowFilter.getLovId());
	}
}
