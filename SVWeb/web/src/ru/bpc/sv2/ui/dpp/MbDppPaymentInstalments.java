package ru.bpc.sv2.ui.dpp;

import java.util.ArrayList;


import ru.bpc.sv2.logic.utility.db.DataAccessException;
import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.dpp.DppInstalment;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.DppDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbDppPaymentInstalments")
public class MbDppPaymentInstalments extends AbstractBean{
	private static final Logger logger = Logger.getLogger("DPP");
	
	private DppDao dppDao = new DppDao();
	
	private final DaoDataModel<DppInstalment> dataModel;
	private DppInstalment filter = null;
	
	private static String COMPONENT_ID = "instalmentTable";
	private String tabName;
	private String parentSectionId;
	
	public MbDppPaymentInstalments(){
		dataModel = new DaoDataModel<DppInstalment>() {
			@Override
			protected DppInstalment[] loadDaoData(SelectionParams params) {
				if (getFilter() != null){
					setFilters();
					try{
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						DppInstalment[] data = dppDao.getDppInstalments(userSessionId, params);
						return data;
					}catch (DataAccessException e){
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return new DppInstalment[0];
			}
			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (getFilter() != null){
					setFilters();
					try{
						params.setFilters(filters.toArray(new Filter[filters.size()]));
						int dataSize = dppDao.getDppInstalmentsCount(userSessionId, params);
						return dataSize;
					}catch (DataAccessException e){
						FacesUtils.addMessageError(e);
						logger.error("", e);
					}
				}
				return 0;
			}
		};
	}
	
	private void clearData(){
		dataModel.flushCache();
	}
	
	private void setFilters(){
		filters = new ArrayList<Filter>();
		if (getFilter().getDppId() != null){
			Filter f = new Filter();
			f.setElement("dppId");
			f.setValue(getFilter().getDppId());
			filters.add(f);
		}
		
	}

	public DppInstalment getFilter() {
		return filter;
	}

	public void setFilter(DppInstalment filter) {
		this.filter = filter;
		clearData();
	}

	public DaoDataModel<DppInstalment> getDataModel() {
		return dataModel;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}
	
}
