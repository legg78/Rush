package ru.bpc.sv2.ui.utils;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;
import javax.servlet.http.HttpServletRequest;

import org.apache.log4j.Logger;

import ru.bpc.sv2.filters.SectionFilter;
import ru.bpc.sv2.logic.SettingsDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.utils.KeyLabelItem;
import util.auxil.SessionWrapper;
@SessionScoped
@ManagedBean (name = "filterFactory")
public class FilterFactory implements Serializable {
	private static final long serialVersionUID = 1L;

	private static final Logger logger = Logger.getLogger("COMMON");
		
	private UsersDao _usersDao = new UsersDao();
	
	private SettingsDao _settingsDao = new SettingsDao();
	
	private Long userSessionId = null;
	
	public FilterFactory() {
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}
	
	public Map<String, String> getSectionFilterRecs(Integer filterId) {
		Map<String, String> filterRec = null;
		try {
			filterRec = new HashMap<String, String>();
			KeyLabelItem[] recs = _usersDao.getSectionFilterRecords(userSessionId, filterId);
			for (KeyLabelItem rec : recs) {
				filterRec.put((String)rec.getValue(), rec.getLabel());
			}
			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return filterRec;
	}
	
	public void saveSectionFilter(SectionFilter filter, boolean sectionFilterModeEdit) {
		try {
			if (sectionFilterModeEdit) {
				_usersDao.modifySectionFilterRecs(userSessionId, filter);
			} else {
				_usersDao.addSectionFilter(userSessionId, filter);
				flushSectionFilters();
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}		
	}
	
	public void removeSectionFilter(Integer filterId) {
		if (filterId != null) {
			try {
				SectionFilter sf = new SectionFilter();
				sf.setId(filterId);
				_usersDao.removeSectionFilter(userSessionId, sf);
				flushSectionFilters();
			} catch (Exception e) {
				FacesUtils.addMessageError(e);
				logger.error("", e);
			}
		}
	}
	
	public List<SelectItem> getSectionFilters(Integer sectionId) {
		List<SelectItem> items = null;
		try {
			SectionFilter[] recs = _usersDao.getSectionFilters(userSessionId, sectionId);

			SelectItem si;
			items = new ArrayList<SelectItem>();
			for (SectionFilter rec: recs) {
				si = new SelectItem(rec.getId(),rec.getName(), rec.getName());
				items.add(si);
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>(0);
		}
		return items;
	}
	
	private Map<Integer,List<SelectItem>> userSectionFilters = null;
	private Map<Integer,SectionFilter> userSectionFiltersObjects = null;
	
	private void flushSectionFilters() {
		sectionFilters = null;
		if (userSectionFilters != null) {
			userSectionFilters.clear();
			userSectionFilters = null;	
		}
		if (userSectionFiltersObjects != null) {
			userSectionFiltersObjects.clear();		
			userSectionFiltersObjects = null;	
		}
	}
	
	public Map<Integer,List<SelectItem>> getUserSectionFilters() {		
		if (userSectionFilters == null) {
			loadUserSectionFilters();
		}
		return userSectionFilters;
	}
	
	public Map<Integer,SectionFilter> getUserSectionFiltersObjects() {		
		if (userSectionFiltersObjects == null) {
			loadUserSectionFilters();
		}
		return userSectionFiltersObjects;
	}
	
	private void loadUserSectionFilters() {		
		try {
			if (userSectionFilters == null) {
				SectionFilter[] recs = _usersDao.getUserSectionsFilters(userSessionId);
				userSectionFilters = new HashMap<Integer, List<SelectItem>>();
				userSectionFiltersObjects = new HashMap<Integer, SectionFilter>();
				SelectItem si;
				List<SelectItem> items = null;
				Integer sectionId = null;
				for (SectionFilter rec: recs) {
					if (rec.getSectionId() == null) {
						continue;
					}
					try {
						userSectionFiltersObjects.put(rec.getId(), rec);
						if (sectionId == null || !sectionId.equals(rec.getSectionId())) {
							if (sectionId != null) {								
								userSectionFilters.put(sectionId, items);								
							}
							sectionId = rec.getSectionId();
							items = userSectionFilters.get(sectionId);
							if (items == null) {
								items = new ArrayList<SelectItem>();
							}							
						}
						si = new SelectItem(rec.getId(),rec.getName(), rec.getName());
						items.add(si); 
					} catch (Exception e) {
						sectionId = null;
						logger.error("", e);
					}
				}
				if (sectionId != null) {					
					userSectionFilters.put(sectionId, items);
				}
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		} finally {
			if (userSectionFilters == null)
				userSectionFilters = new HashMap<Integer,List<SelectItem>>(0);			
		}		
	}
	
	public void reloadFilters() {
		userSectionFilters = null;
	}
	
	List<SelectItem> sectionFilters = null;
	public List<SelectItem> getSectionFilters() {
//		if (sectionFilters == null) {
			try {
				HttpServletRequest req = RequestContextHolder.getRequest();
				String sectionId = req.getParameter("sectionId");
				if (sectionId != null) {
					sectionFilters = getUserSectionFilters().get(Integer.parseInt(sectionId));
				}
			} catch (Exception e) {
				logger.error("", e);
				return new ArrayList<SelectItem>(0);
			}
//		}
		if (sectionFilters == null) {
			return new ArrayList<SelectItem>(0);
		}
		return sectionFilters;
	}

}
