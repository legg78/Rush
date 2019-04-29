package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.ui.process.monitoring.*;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import java.util.HashMap;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbProcessSessionsContextSearch")
public class MbProcessSessionsContextSearch extends AbstractBean {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private String tabName;
	private HashMap<String, Boolean> loadedTabs = new HashMap<String, Boolean>();
	private ProcessSession sess;
	
	private ProcessDao _processDao = new ProcessDao();
	
	public ProcessSession getActiveProcessSession() {
		return getProcessSession();
	}
	
	public ProcessSession getProcessSession(){
		try {
			if (sess == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				ProcessSession[] sesss = _processDao.getProcessSessions(userSessionId, new SelectionParams(filters));
				if (sesss.length > 0) {
					sess = sesss[0];
				}
			}
			return sess;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}

	public ProcessSession getNode() {
		return getProcessSession();
	}

	public void reset(){
		sess = null;
		id = null;
	}
	
	public void initializeModalPanel(){
		logger.debug("MbCardDetails initializing...");
		reset();
		if (FacesUtils.getSessionMapValue(CTX_MENU_PARAMS) != null) {
			Map<String, Object> ctxMenuParams = (Map<String, Object>) FacesUtils.getSessionMapValue(CTX_MENU_PARAMS);
			FacesUtils.setSessionMapValue(CTX_MENU_PARAMS, null);
			if (ctxMenuParams.containsKey(OBJECT_ID)){
				id = (Long) ctxMenuParams.get(OBJECT_ID);
			} 
		} else {
			if (FacesUtils.getSessionMapValue(OBJECT_ID) != null) {
				id = (Long) FacesUtils.getSessionMapValue(OBJECT_ID);
//				FacesUtils.setSessionMapValue(OBJECT_ID, null);
			}	
		}
		getActiveProcessSession();
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public String getTabName(){
		if(tabName==null)
			tabName = "detailsContextTab";
		return tabName;
	}
	
	public void loadCurrentTab() {
		loadTab(tabName);
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (sess == null)
			return;
		try {
			if (tab.equalsIgnoreCase("traceContextTab")) {
				MbProcessTrace traceBean = (MbProcessTrace) ManagedBeanWrapper
						.getManagedBean("MbProcessTraceContext");
				traceBean.setSessionId(sess.getSessionId());
				traceBean.setThreadCount(sess.getThreadCount());
				traceBean.search();
			} else if(tab.equalsIgnoreCase("statContextTab")) {
				MbProcessStat statBean = (MbProcessStat) ManagedBeanWrapper
						.getManagedBean("MbProcessStatContext");
				statBean.setSessionId(sess.getSessionId());
				statBean.search();
			} else if(tab.equalsIgnoreCase("hierarchyContextTab")) {
				MbProcessHierarchy mbProcessHierarchy = (MbProcessHierarchy) ManagedBeanWrapper
						.getManagedBean("MbProcessHierarchyContext");
				mbProcessHierarchy.setSessionId(sess.getSessionId());
			} else if(tab.equalsIgnoreCase("processLaunchParametersContextTab")) {
				
				MbProcessLaunchParameters mbProcessLaunchParameters = (MbProcessLaunchParameters)ManagedBeanWrapper
						.getManagedBean("MbProcessLaunchParametersContext");
				mbProcessLaunchParameters.setSessionId(sess.getSessionId());
			} else if(tab.equalsIgnoreCase("sessionFilesContextTab")) {
				MbSessionFiles mbSessionFiles = (MbSessionFiles)ManagedBeanWrapper
				.getManagedBean("MbSessionFilesContext");
				mbSessionFiles.setSessionId(sess.getSessionId());
			} 
			loadedTabs.put(tab, Boolean.TRUE);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}
	
	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		Filter[] filters = new Filter[2];
		filters[0] = new Filter();
		filters[0].setElement("id");
		filters[0].setValue(sess.getId());
		filters[1] = new Filter();
		filters[1].setElement("lang");
		filters[1].setValue(curLang);

		SelectionParams params = new SelectionParams();
		params.setFilters(filters);

		try {
			ProcessSession[] items = _processDao.getProcessSessions(userSessionId, params);
			if (items != null && items.length > 0) {
				sess = items[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
}
