package ru.bpc.sv2.ui.crp;

import java.util.ArrayList;
import java.util.List;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;
import org.openfaces.component.table.TreePath;
import org.openfaces.util.Faces;

import ru.bpc.sv2.crp.CrpDepartment;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CrpDao;
import ru.bpc.sv2.ui.utils.AbstractTreeBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbCrpDepartment")
public class MbCrpDepartment extends AbstractTreeBean<CrpDepartment> {

	private static final Logger logger = Logger.getLogger("EMV");
	
	private CrpDao crpDao = new CrpDao();

	private MbCrpEmployee mbCrpEmployee;

	private CrpDepartment activeItem;
	private Long contractId;

	public MbCrpDepartment() {
		mbCrpEmployee = (MbCrpEmployee) ManagedBeanWrapper.getManagedBean("MbCrpEmployee");
	}

	public List<CrpDepartment> getNodeChildren() {
		CrpDepartment node = getNode();
		if (node == null) {
			if (coreItems == null && contractId != null){
				loadTree();
			}
			return coreItems;
		} else {
			return node.getChildren();
		}
	}
	
	private CrpDepartment getNode() {
		return (CrpDepartment) Faces.var("item");
	}
	
	public boolean getNodeHasChildren() {
		return (getNode() != null) && getNode().isHasChildren();
	}
	
	@Override
	protected void loadTree() {
		Filter[] filters = new Filter[2];
		Filter f = new Filter();
		f.setElement("corpContractId");
		f.setValue(contractId);
		filters[0] = f;
		f = new Filter();
		f.setElement("lang");
		f.setValue(curLang);
		filters[1] = f;
		SelectionParams sp = new SelectionParams();
		sp.setFilters(filters);
		CrpDepartment[] dataList = null;
		try {
			dataList = crpDao.getDepartments(userSessionId, sp);
		} catch (DataAccessException e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
			return;
		}
		coreItems = new ArrayList<CrpDepartment>(0);
		if (dataList.length > 0) {
			addNodes(0, coreItems, dataList);
		}
	}

	@Override
	public TreePath getNodePath() {
		return this.nodePath;
	}

	@Override
	public void setNodePath(TreePath nodePath) {
		this.nodePath = nodePath;
	}

	public Long getContractId() {
		return contractId;
	}

	public void setContractId(Long contractId) {
		this.contractId = contractId;
		coreItems = null;
		clearBeansState();
	}

	public CrpDepartment getActiveItem() {
		return activeItem;
	}

	public void setActiveItem(CrpDepartment activeItem) {
		this.activeItem = activeItem;
		setBeansState();
	}
	
	private void setBeansState(){
		mbCrpEmployee.setDepartamentId(activeItem.getId().intValue()); // CmnDepartment's ID is actually an integer
	}
	
	private void clearBeansState(){
		mbCrpEmployee.setDepartamentId(null);
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

}
