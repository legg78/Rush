package ru.bpc.sv2.ui.process.monitoring;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessLaunchParameter;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean (name = "MbProcessLaunchParameters")
public class MbProcessLaunchParameters extends AbstractBean{
	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	private ProcessDao processDAO = new ProcessDao();
	
	private Long sessionId;
	
	private final DaoDataModel<ProcessLaunchParameter> daoDataModel;
	
	private static String COMPONENT_ID = "procLaunchParamsTable";
	private String tabName;
	private String parentSectionId;
	
	public MbProcessLaunchParameters() {
		daoDataModel = new DaoDataModel<ProcessLaunchParameter>() {
			@Override
			protected ProcessLaunchParameter[] loadDaoData(SelectionParams params) {
				if (sessionId == null)
					return new ProcessLaunchParameter[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					ProcessLaunchParameter[] processLaunchParameters = processDAO.getProcessLaunchParameters( userSessionId, params);
					return processLaunchParameters;
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new ProcessLaunchParameter[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (sessionId == null)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return processDAO.getProcessLaunchParametersCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
	}

	public ExtendedDataModel getDataModel(){
		return daoDataModel;
	}

	public void setFilters() {
		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter;
		if (sessionId != null) {
			paramFilter = new Filter();
			paramFilter.setElement("sessionId");
			paramFilter.setValue(sessionId.toString());
			filtersList.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filtersList.add(paramFilter);
		
		filters = filtersList;
	}

	public void setSessionId(Long sessionId) {
		this.sessionId = sessionId;
		clear();
	}
	
	private void clear(){
		daoDataModel.flushCache();
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
