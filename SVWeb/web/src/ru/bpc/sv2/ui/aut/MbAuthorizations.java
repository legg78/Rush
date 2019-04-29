package ru.bpc.sv2.ui.aut;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;

import ru.bpc.sv2.aut.Authorization;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthorizationDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

@ViewScoped
@ManagedBean (name = "MbAuthorizations")
public class MbAuthorizations extends AbstractBean {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
	
	private AuthorizationDao authDao = new AuthorizationDao();
	
	private Authorization activeAuth;
	private Authorization filter;
	
	public Authorization getActiveAuth() {
		return activeAuth;
	}
	
	public void setActiveAuth(Authorization activeAuth) {
		this.activeAuth = activeAuth;
	}
	
	public Authorization getFilter() {
		if (filter == null) {
			filter = new Authorization();
		}
		return filter;
	}

	public void setFilter(Authorization filter) {
		this.filter = filter;
	}
	
	public Authorization loadAuthorization(Long authId) {
		activeAuth = null;
		
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("id", authId);
		filters[1] = new Filter("lang", curLang);
		
		SelectionParams params = new SelectionParams(filters);

		try {
			Authorization[] auths = authDao.getAuthorizations(userSessionId, params);
			if (auths.length > 0) {
				activeAuth = auths[0];
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return activeAuth;
	}

	@Override
	public void clearFilter() {
		filter = null;
		clearBean();
	}
	
	public void clearBean() {
		activeAuth = null;
	}
}
