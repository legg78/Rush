package ru.bpc.sv2.ui.issuing;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.SectionIdConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.servlet.http.HttpServletRequest;
import java.text.ParseException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbBlackListSearch")
public class MbBlackListSearch extends AbstractBean {
	private IssuingDao _issuingDao = new IssuingDao();
	
	private static final Logger logger = Logger.getLogger("ISSUING");

	private static String COMPONENT_ID = "2310:blackListTable";
	
	private final DaoDataModel<Card> _blackListSource;
	private final TableRowSelection<Card> _itemSelection;
	private Card _activeBlackCard;
	private Card newCard;
	
	private Card filter;
	
	private String tabName;
	private String needRerender;
	private List<String> rerenderList;
	
	public MbBlackListSearch() {
		
		pageLink = "issuing|black_list";
		_blackListSource = new DaoDataModel<Card>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected Card[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Card[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getBlackCards(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
					logger.error("", e);
				}
				return new Card[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				int count = 0;
				int threshold = 1000;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					params.setThreshold(threshold);
					count = _issuingDao.getBlackCardsCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				if (count >= threshold) {
					FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Common", "many_records"));
					count = 0;
				}
				return count;
			}
		};
		_itemSelection = new TableRowSelection<Card>(null, _blackListSource);
		
		HttpServletRequest req = RequestContextHolder.getRequest();
		String sectionId = req.getParameter("sectionId");
		String filterId = req.getParameter("filterId");

		if (sectionId != null && filterId != null && sectionId.equals(getSectionId())) {
			selectedSectionFilter = Integer.parseInt(filterId);
			applySectionFilter(selectedSectionFilter);
		}
	}
		
	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		if (filter.getCardNumber() != null && filter.getCardNumber().trim().length() > 0) {
			String filterValue = filter.getCardNumber();
			Filter filter = null;
			if (filterValue.indexOf("*") >= 0 || filterValue.indexOf("?") >= 0){
				String mask = filterValue.trim().replaceAll("[*]", "%").replaceAll("[?]",
						"_").toUpperCase();
				filter = new Filter("cardNumber", mask);
				filter.setCondition("like");
			} else {
				filter = new Filter("cardNumber", filterValue);
				filter.setCondition("=");
			}
			filters.add(filter);
		}

		if (filter.getId() != null) {
			filters.add(new Filter("id", filter.getId()));
		}
	}
	
	public Card getFilter() {
		if (filter == null) {
			filter = new Card();
		}
		return filter;
	}

	@Override
	public void clearFilter() {
		// TODO Auto-generated method stub
		filter = null;
		clearState();
		searching = false;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeBlackCard = null;
		_blackListSource.flushCache();
		curLang = userLang;
	}
	
	public void setFirstRowActive() {
		_blackListSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeBlackCard = (Card) _blackListSource.getRowData();
		selection.addKey(_activeBlackCard.getModelId());
		_itemSelection.setWrappedSelection(selection);
	}

	
	public SimpleSelection getItemSelection() {
		try {
			if (_activeBlackCard == null && _blackListSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeBlackCard != null && _blackListSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeBlackCard.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeBlackCard = _itemSelection.getSingleSelection();
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeBlackCard = _itemSelection.getSingleSelection();
	}
	
	public DaoDataModel<Card> getBlackList() {
		return _blackListSource;
	}

	public Card getActiveBlackCard() {
		return _activeBlackCard;
	}

	public void setActiveBlackCard(Card activeBlackCard) {
		_activeBlackCard = activeBlackCard;
	}
	
	public void search() {
		clearState();
		searching = true;
	}
	
	public void add() {
		newCard = new Card();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCard = (Card) _activeBlackCard.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCard = _activeBlackCard;
		}
		curMode = EDIT_MODE;
	}

	public void view() {
		curMode = VIEW_MODE;
	}

	public void close() {
		curMode = VIEW_MODE;
	}

	public Card getNewCard() {
		if (newCard == null) {
			newCard = new Card();
		}
		return newCard;
	}

	public void setNewCard(Card newCard) {
		this.newCard = newCard;
	}
	
	public void save() {
		try {
			newCard = _issuingDao.addBlackCard(userSessionId, newCard);
			_itemSelection.addNewObjectToList(newCard);

			_activeBlackCard = newCard;
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public void delete() {
		try {
			_issuingDao.deleteBlackCard(userSessionId, _activeBlackCard);
			String msg = FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prd", "service_deleted",
					"(id = " + _activeBlackCard.getId() + ")");

			_activeBlackCard = _itemSelection.removeObjectFromList(_activeBlackCard);
			if (_activeBlackCard == null) {
				clearState();
			} 
			FacesUtils.addMessageInfo(msg);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}
	
	public String getComponentId() {
		return COMPONENT_ID;
	}
	
	public String getSectionId() {
		return SectionIdConstants.ISSUING_BLACK_LIST;
	}
	
	@Override
	protected void applySectionFilter(Integer filterId) {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");
			Map<String, String> filterRec = factory.getSectionFilterRecs(filterId);
			sectionFilter = factory.getUserSectionFiltersObjects().get(filterId);
			if (filterRec != null) {
				filter = new Card();
				setFilterForm(filterRec);
				if (searchAutomatically)
					search();
			}
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	@Override
	public void saveSectionFilter() {
		try {
			FilterFactory factory = (FilterFactory) ManagedBeanWrapper.getManagedBean("filterFactory");

			Map<String, String> filterRec = new HashMap<String, String>();
			filter = getFilter();
			setFilterRec(filterRec);

			sectionFilter = getSectionFilter();
			sectionFilter.setRecs(filterRec);

			factory.saveSectionFilter(sectionFilter, sectionFilterModeEdit);
			selectedSectionFilter = sectionFilter.getId();
			sectionFilterModeEdit = true;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	private void setFilterForm(Map<String, String> filterRec) throws ParseException {
		getFilter();
		filters = new ArrayList<Filter>();
		if (filterRec.get("cardNumber") != null) {
			filter.setCardNumber(filterRec.get("cardNumber"));
		}
		if (filterRec.get("cardUid") != null) {
			filter.setCardUid(filterRec.get("cardUid"));
		}
	}

	private void setFilterRec(Map<String, String> filterRec) {
		if (filter.getCardNumber() != null) {
			filterRec.put("cardNumber", filter.getCardNumber().toString());
		}
		if (filter.getCardUid() != null) {
			filterRec.put("cardUid", filter.getCardUid().toString());
		}
	}
	
	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		needRerender = null;
		this.tabName = tabName;
	}

	public void loadCurrentTab() {
		loadTab(tabName);
	}

	private void loadTab(String tab) {

	}
	
	public List<String> getRerenderList() {
		rerenderList = new ArrayList<String>();
		rerenderList.clear();
		if (needRerender != null) {
			rerenderList.add(needRerender);
		}
		rerenderList.add("err_ajax");
		return rerenderList;
	}
	
}
