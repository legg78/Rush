package ru.bpc.sv2.ui.rules.naming;

import java.io.Serializable;

import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.rules.naming.NameIndexRange;
import ru.bpc.sv2.ui.utils.AbstractBean;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbNameIndexRanges")
public class MbNameIndexRanges extends AbstractBean implements Serializable {
	
	private static final long serialVersionUID = 1L;
	
	private NameIndexRange paramsFilter;
	private NameIndexRange activeIndexRange;	
	private String tabName;
	

	public NameIndexRange getParamsFilter() {
		return paramsFilter;
	}

	public void setParamsFilter(NameIndexRange paramsFilter) {
		this.paramsFilter = paramsFilter;
	}

	public NameIndexRange getActiveIndexRange() {
		return activeIndexRange;
	}

	public void setActiveIndexRange(NameIndexRange activeIndexRange) {
		this.activeIndexRange = activeIndexRange;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
		
		if (tabName.equalsIgnoreCase("poolsTab")) {
			MbNameIndexPools bean = (MbNameIndexPools) ManagedBeanWrapper
					.getManagedBean("MbNameIndexPools");
			bean.setTabName(tabName);
			bean.setParentSectionId(getSectionId());
			bean.setTableState(getSateFromDB(bean.getComponentId()));
		}	
	}
	
	public String getSectionId() {
		return SectionIdConstants.OPERATION_NAMING_RANGE;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
	
}
