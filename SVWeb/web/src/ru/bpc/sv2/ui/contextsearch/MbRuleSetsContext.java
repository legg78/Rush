package ru.bpc.sv2.ui.contextsearch;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.RulesDao;
import ru.bpc.sv2.rules.Rule;
import ru.bpc.sv2.rules.RuleSet;
import ru.bpc.sv2.ui.rules.MbRules;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean(name = "MbRuleSetsContext")
public class MbRuleSetsContext extends AbstractBean {
	
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("PRODUCTS");
	
	public static final String OBJECT_ID = "OBJECT_ID";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long id;
	private RuleSet ruleSet;
	protected String tabName;
	
	private RulesDao _rulesDao = new RulesDao();
	
	public RuleSet getActiveRuleSet() {
//		super.setActiveCard(getCard());
		return getRuleSet();
	}
	
	public RuleSet getRuleSet(){
		try {
			if (ruleSet == null && id != null) {
				Filter[] filters = new Filter[]{new Filter("id", id),
						new Filter("lang", curLang)};
				RuleSet[] ruleSets = _rulesDao.getRuleSets(userSessionId,
						new SelectionParams(filters));
				if (ruleSets.length > 0) {
					ruleSet = ruleSets[0];
				}
			}
			return ruleSet;
		}catch (Exception e){
			logger.error(e.getMessage(), e);
			FacesUtils.addMessageError(e);
		}
		return  null;
	}
	
	public void reset(){
		ruleSet = null;
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
		getActiveRuleSet();
	}
	
	public void setTabName(String tabName) {
		this.tabName = tabName;
	}
	
	public String getTabName(){
		return this.tabName;
	}
	
	public void loadCurrentTab() {
		loadTab(tabName);
	}
	
	private void loadTab(String tab) {
		if (tab == null)
			return;
		if (ruleSet == null)
			return;
		
		if (tabName.equalsIgnoreCase("rulesContextTab")) {
			MbRules rulesBean = (MbRules) ManagedBeanWrapper.getManagedBean("MbRulesContext");
			rulesBean.clearBean();
			Rule filter = new Rule();
			filter.setRuleSetId(ruleSet.getId());
			filter.setCategory(ruleSet.getCategory());
			rulesBean.setRuleSetName(ruleSet.getName());
			rulesBean.setFilter(filter);
			rulesBean.search();
		}
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		
	}

}
