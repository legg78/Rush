package ru.bpc.sv2.ui.navigation;

import java.io.Serializable;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

import org.apache.log4j.Logger;

import ru.bpc.sv2.logic.CommonDao;

import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;
@SessionScoped
@ManagedBean(name = "favs")
public class MbFavourites implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");
	
	private HashMap<String, String> favourites;
	private String currentPageName;
	private String selectedPage;
	
	private CommonDao _commonDao = new CommonDao();
	
	private Long userSessionId = null;
	
	public MbFavourites() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}
	
	public void saveToFavourites() {
//		FacesContext ctx = FacesContext.getCurrentInstance();
//		String url = ctx.getExternalContext().getRequestContextPath() + ctx.getExternalContext().getRequestServletPath();
//		String viewId = ctx.getViewRoot().getViewId();
		
		try {
			Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			if (menu.getCurrentNode() == null) return;
//		if (menu.getCurrentNode() != null && currentPageName == null) {
//			System.out.println(menu.getCurrentNode().getName());
//		}
//		System.out.println(url);
			
			currentPageName = menu.getCurrentNode().getName();
			String outcome = menu.getCurrentNode().getAction();
			Long sectionId = menu.getCurrentNode().getId();
			
			if (favourites == null) {
				favourites = new HashMap<String, String>();
			}
			favourites.put(outcome, currentPageName);
			
			_commonDao.addToFavourites(userSessionId, sectionId);
//			menu.reloadFavourites();
		} catch (Exception e) {
			logger.error("", e);
		}
//		System.out.println(viewId);
	}
	
	public void removeFromFavourites() {
		
		try {
			Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
			if (menu.getCurrentNode() == null) return;
			
			currentPageName = menu.getCurrentNode().getName();
			Long sectionId = menu.getCurrentNode().getId();
			
			if (favourites == null) {
				favourites = new HashMap<String, String>();
			}
			favourites.remove(currentPageName);
			
			_commonDao.removeFromFavourites(userSessionId, sectionId);
//			menu.reloadFavourites();
		} catch (Exception e) {
			logger.error("", e);
		}
//		System.out.println(viewId);
	}

	public String getCurrentPageName() {
		return currentPageName;
	}

	public void setCurrentPageName(String currentPageName) {
		this.currentPageName = currentPageName;
	}
	
	public Set<String> getFavKeys() {
		if (favourites == null) 
			return new HashSet<String>(0);
		
		return favourites.keySet();
	}

	public HashMap<String, String> getFavourites() {
		return favourites;
	}
	
	public String gotoPage() {
//		try {
//			FacesContext.getCurrentInstance().getExternalContext().redirect(selectedPage);
//		} catch (IOException e) {
//			logger.error("", e);
//		}
		return selectedPage;
	}

	public String getSelectedPage() {
		return selectedPage;
	}

	public void setSelectedPage(String selectedPage) {
		this.selectedPage = selectedPage;
	}
	
}
