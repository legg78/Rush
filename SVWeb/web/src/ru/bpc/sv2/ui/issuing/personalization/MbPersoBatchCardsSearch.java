package ru.bpc.sv2.ui.issuing.personalization;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.issuing.personalization.BlankType;
import ru.bpc.sv2.issuing.personalization.PersoBatchCard;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbPersoBatchCardsSearch")
public class MbPersoBatchCardsSearch extends AbstractBean{
	private static final long serialVersionUID = 3137973238611529527L;

	private static final Logger logger = Logger.getLogger("PERSONALIZATION");
	
	private PersonalizationDao _personalizationDao = new PersonalizationDao();

	private NetworkDao _networkDao = new NetworkDao();
	
    private PersoBatchCard filter;
    private PersoBatchCard _activePersoCard;
    private PersoBatchCard newPersoCard;

    private ArrayList<SelectItem> institutions;
    
	private final DaoDataModel<PersoBatchCard> _persoCardsSource;

	private final TableRowSelection<PersoBatchCard> _itemSelection;

	private String sortCondition;
	
	private static String COMPONENT_ID = "batchCardsTable";
	private String tabName;
	private String parentSectionId;

	public MbPersoBatchCardsSearch() {

		_persoCardsSource = new DaoDataModel<PersoBatchCard>() {
			private static final long serialVersionUID = -4398037387925304240L;

			@Override
			protected PersoBatchCard[] loadDaoData(SelectionParams params) {
				if (!searching && getFilter().getBatchId() == null) {
					return new PersoBatchCard[0];
				}
				try {
					setFilters();
					params.setSortElement(getSorting());
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getPersoBatchCards( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PersoBatchCard[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching && getFilter().getBatchId() == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));				
					return _personalizationDao.getPersoBatchCardsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PersoBatchCard>( null, _persoCardsSource);
    }

    public DaoDataModel<PersoBatchCard> getPersoCards() {
		return _persoCardsSource;
	}

	public PersoBatchCard getActivePersoCard() {
		return _activePersoCard;
	}

	public void setActivePersoCard(PersoBatchCard activePersoCard) {
		_activePersoCard = activePersoCard;
	}

	public SimpleSelection getItemSelection() {
		if (_activePersoCard == null && _persoCardsSource.getRowCount() > 0) {
//			setFirstRowActive();
		} else if (_activePersoCard != null && _persoCardsSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activePersoCard.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activePersoCard = _itemSelection.getSingleSelection();			
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_persoCardsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activePersoCard = (PersoBatchCard) _persoCardsSource.getRowData();
		selection.addKey(_activePersoCard.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activePersoCard != null) {
			setInfo();
		}
	}
	
	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection( selection );
		_activePersoCard = _itemSelection.getSingleSelection();
		if (_activePersoCard != null) {
			setInfo();
		}
	}

	public void setInfo() {
		
	}
	
	public void search() {
		clearState();
		clearBeansStates();
		searching = true;		
	}
	
	public void clearFilter() {
		filter = new PersoBatchCard();		
		clearState();
		searching = false;		
	}
	
	public PersoBatchCard getFilter() {
		if (filter == null)
			filter = new PersoBatchCard();
		return filter;
	}

	public void setFilter(PersoBatchCard filter) {
		this.filter = filter;
	}

	public String getSortCondition() {
		return sortCondition;
	}

	public void setSortCondition(String sortCondition) {
		this.sortCondition = sortCondition;
	}

	private void setFilters() {
		filter = getFilter();
		filters = new ArrayList<Filter>();

		Filter paramFilter;
		if (filter.getId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("id");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getId() + "%");
			filters.add(paramFilter);
		}
		
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);
		
		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getInstId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getProductId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("productId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getProductId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getBatchId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("batchId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getBatchId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getBlankTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("blankTypeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getBlankTypeId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardTypeId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCardTypeId().toString());
			filters.add(paramFilter);
		}
		
		if (filter.getCardholderName() != null && filter.getCardholderName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardholderName");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getCardholderName().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}
		
		if (filter.getMask() != null && filter.getMask().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardMask");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getMask().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getCardUid() != null && filter.getCardUid().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("cardUid");
			paramFilter.setOp(Operator.like);
			paramFilter.setValue(filter.getCardUid().trim().replaceAll("[*]", "%").replaceAll("[?]", "_").toUpperCase());
			filters.add(paramFilter);
		}

		if (filter.getPinRequest() != null && filter.getPinRequest().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("pinRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPinRequest());
			filters.add(paramFilter);
		}
		
		if (filter.getPinGenerated() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("pinGenerated");
			paramFilter.setOp(Operator.eq);
			String str = filter.getPinGenerated().booleanValue()?"1":"0";
			paramFilter.setValue(str);
			filters.add(paramFilter);
		}
		
		if (filter.getPinMailerRequest() != null && filter.getPinMailerRequest().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("pinMailerRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPinMailerRequest());
			filters.add(paramFilter);
		}
		
		if (filter.getPinMailerPrinted() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("pinMailerPrinted");
			paramFilter.setOp(Operator.eq);
			String str = filter.getPinMailerPrinted().booleanValue()?"1":"0";
			paramFilter.setValue(str);
			filters.add(paramFilter);
		}
		
		if (filter.getEmbossingRequest() != null && filter.getEmbossingRequest().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("embossingRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEmbossingRequest());
			filters.add(paramFilter);
		}
		
		if (filter.getEmbossingDone() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("embossingDone");
			paramFilter.setOp(Operator.eq);
			String str = filter.getEmbossingDone().booleanValue()?"1":"0";
			paramFilter.setValue(str);
			filters.add(paramFilter);
		}
		
		if (filter.getPersoPriority() != null && filter.getPersoPriority().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("persoPriority");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPersoPriority());
			filters.add(paramFilter);
		}
		
	}

	private SortElement[] getSorting() {
		List<SortElement> elements = new ArrayList<SortElement>();
		SortElement sort = new SortElement("sorting");
		sort.setCondition(sortCondition);
		elements.add(sort);
		/*
		String[] conditions = sortCondition.split(",");
		for (String cond : conditions) {
			String[] s = cond.split(" ");
			Direction direction;
			if (s.length < 2) {
				direction = Direction.AUTO;
			} else if ("DESC".equals(s[1])) {
				direction = Direction.DESC;
			} else {
				direction = Direction.ASC;
			}
			SortElement ele = new SortElement(s[0], direction);
			elements.add(ele);
		}
		*/
		return elements.toArray(new SortElement[elements.size()]);
	}

	public void add() {
		newPersoCard = new PersoBatchCard();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newPersoCard = (PersoBatchCard) _activePersoCard.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("",e);
			newPersoCard = _activePersoCard;
		}
		curMode = EDIT_MODE;
	}

	public void view() {
		
	}
	
	public void save() {
		/*
		try {
			if (isNewMode()) {
				_personalizationDao.addPersoCard( userSessionId, newPersoCard);
			} else if (isEditMode()) {
				_personalizationDao.modifyPersoCard( userSessionId, newPersoCard);
			}
						
			curMode = VIEW_MODE;
			_persoCardsSource.flushCache();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
		*/
	}

	public void delete() {
		/*
		try {
			_personalizationDao.deletePersoCard( userSessionId, _activePersoCard);
			_itemSelection.clearSelection();
			_persoCardsSource.flushCache();
			_activePersoCard = null;
			clearBeansStates();
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}
		*/
	}
	
	public void select() {		
		try {
			for (PersoBatchCard card : _itemSelection.getMultiSelection()) {
				if (!card.isIncluded()) {
					try {
						newPersoCard = card.clone();
					} catch (CloneNotSupportedException cnse) {
						newPersoCard = card;
					}
					newPersoCard.setBatchId(getFilter().getBatchId());
					try {
						_personalizationDao.addBatchCard( userSessionId, newPersoCard);
					} catch (Exception e) {
						//continue selecting
						FacesUtils.addMessageError(e);
						logger.error("",e);
					}
				}
			}
			_itemSelection.clearSelection();
			_persoCardsSource.flushCache();
			curMode = VIEW_MODE;			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}
	
	public void selectByFilter() {
		try {
			if (getFilter().getInstId() == null) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prs", "you_must_define_institution_in_filter"));
			}
			_personalizationDao.markBatchCard( userSessionId, getFilter());
			_itemSelection.clearSelection();
			_persoCardsSource.flushCache();
			_activePersoCard = null;			
			curMode = VIEW_MODE;			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}
			
	public void close() {
		curMode = VIEW_MODE;
	}

	public PersoBatchCard getNewPersoCard() {
		if (newPersoCard == null) {
			newPersoCard = new PersoBatchCard();		
		}
		return newPersoCard;
	}

	public void setNewPersoCard(PersoBatchCard newPersoCard) {
		this.newPersoCard = newPersoCard;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activePersoCard = null;			
		_persoCardsSource.flushCache();
		curLang = userLang;
	}
	
	public void clearBeansStates() {
		
	}
	
	public ArrayList<SelectItem> getPinRequests() {
		return getDictUtils().getArticles(DictNames.PIN_REQUEST, true, false);		
	}
	
	public ArrayList<SelectItem> getPinMailerRequests() {
		return getDictUtils().getArticles(DictNames.PIN_MAILER_REQUEST, true, false);		
	}
	
	public ArrayList<SelectItem> getEmbossingRequests() {
		return getDictUtils().getArticles(DictNames.EMBOSSING_REQUEST, true, false);		
	}
	
	public ArrayList<SelectItem> getPersoPriorities() {
		return getDictUtils().getArticles(DictNames.PERSO_PRIORITY, true, false);		
	}
		
	public void changeLanguage(ValueChangeEvent event) {	
		curLang = (String)event.getNewValue();
		
		List<Filter> filtersList = new ArrayList<Filter>();
		
		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activePersoCard.getId().toString());
		filtersList.add(paramFilter);

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filtersList.add(paramFilter);
			
		filters = filtersList;		
		SelectionParams params = new SelectionParams();
		params.setFilters(filters.toArray(new Filter[filters.size()]));
		try {
			PersoBatchCard[] schemas = _personalizationDao.getPersoBatchCards( userSessionId, params);
			if (schemas != null && schemas.length > 0) {
				_activePersoCard = schemas[0];				
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}
	
	public ArrayList<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS_SYS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}
	
	public List<SelectItem> getProducts(){
		try {
			Map<String, Object> paramMap = new HashMap<String, Object>();
			if (getFilter().getInstId() != null) {
				paramMap.put("INSTITUTION_ID", getFilter().getInstId());
			}		
			return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, paramMap);
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
		return new ArrayList<SelectItem>();
	}
	
	public ArrayList<SelectItem> getCardTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			if (getFilter().getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getFilter().getInstId().toString());
				filtersList.add(paramFilter);
			}
			
			paramFilter = new Filter();
			paramFilter.setElement("isVirtual");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue("0");
			filtersList.add(paramFilter);
			
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

			CardType[] types = _networkDao.getCardTypesList(userSessionId, params);
			for (CardType type : types) {
				items.add(new SelectItem(type.getId(), type.getId() + " - " + type.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		return items;
	}
	
	public ArrayList<SelectItem> getBlankTypes() {
		ArrayList<SelectItem> items = new ArrayList<SelectItem>();
		try {
			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filtersList = new ArrayList<Filter>();
			Filter paramFilter = new Filter();
			paramFilter.setElement("lang");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(userLang);
			filtersList.add(paramFilter);

			if (getFilter().getInstId() != null) {
				paramFilter = new Filter();
				paramFilter.setElement("instId");
				paramFilter.setOp(Operator.eq);
				paramFilter.setValue(getFilter().getInstId().toString());
				filtersList.add(paramFilter);
			}
			
			params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

			BlankType[] types = _personalizationDao.getBlankTypes(userSessionId, params);
			for (BlankType type : types) {
				items.add(new SelectItem(type.getId(),type.getId() + " - " + type.getName()));
			}
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
		} finally {
			if (items == null)
				items = new ArrayList<SelectItem>();
		}
		return items;
	}
	
	public List<SelectItem> getAgents() {
		if (getFilter().getInstId() == null)
			return new ArrayList<SelectItem>();
		Map<String, Object> paramMap = new HashMap<String, Object>();
		paramMap.put("INSTITUTION_ID", getFilter().getInstId());
		return getDictUtils().getLov(LovConstants.AGENTS, paramMap);
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
