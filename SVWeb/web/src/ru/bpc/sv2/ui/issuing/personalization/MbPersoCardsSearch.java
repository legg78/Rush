package ru.bpc.sv2.ui.issuing.personalization;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.BaseCard;
import ru.bpc.sv2.issuing.personalization.BlankType;
import ru.bpc.sv2.issuing.personalization.PersoCard;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.PersonalizationDao;
import ru.bpc.sv2.logic.ProductsDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.ui.issuing.PersonalizationStateModifyBacking;
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
@ManagedBean (name = "MbPersoCardsSearch")
public class MbPersoCardsSearch extends PersonalizationStateModifyBacking {
	private static final long serialVersionUID = 1L;
	
	private static final Logger logger = Logger.getLogger("PERSONALIZATION");
	
	private PersonalizationDao _personalizationDao = new PersonalizationDao();

    private IssuingDao _issuingDao = new IssuingDao();

	private NetworkDao _networkDao = new NetworkDao();
	
	private ProductsDao _productsDao = new ProductsDao();
	
    private PersoCard filter;
    private PersoCard _activePersoCard;
    private PersoCard newPersoCard;
    
    private ArrayList<SelectItem> institutions;
    private ArrayList<SelectItem> products;
    
	private final DaoDataModel<PersoCard> _persoCardsSource;

	private final TableRowSelection<PersoCard> _itemSelection;

    private boolean showWarning;

    
    private static String COMPONENT_ID = "batchCardsTable";
    private String tabName;
    private String parentSectionId;


    private String warningMsg;
    
	public MbPersoCardsSearch() {
		filters = new ArrayList<Filter>();

		_persoCardsSource = new DaoDataModel<PersoCard>() {
			private static final long serialVersionUID = 1L;

			@Override
			protected PersoCard[] loadDaoData(SelectionParams params) {
				if (!searching && getFilter().getBatchId() == null) {
					return new PersoCard[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _personalizationDao.getPersoCards( userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new PersoCard[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching && getFilter().getBatchId() == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));				
					return _personalizationDao.getPersoCardsCount( userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<PersoCard>( null, _persoCardsSource);
    }

    public DaoDataModel<PersoCard> getPersoCards() {
		return _persoCardsSource;
	}

	public PersoCard getActivePersoCard() {
		return _activePersoCard;
	}

	public void setActivePersoCard(PersoCard activePersoCard) {
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
		_activePersoCard = (PersoCard) _persoCardsSource.getRowData();
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
		filter = new PersoCard();		
		clearState();
		searching = false;		
	}
	
	public PersoCard getFilter() {
		if (filter == null)
			filter = new PersoCard();
		return filter;
	}

	public void setFilter(PersoCard filter) {
		this.filter = filter;
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
		
		if (filter.getAgentId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("agentId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getAgentId().toString());
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
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCardUid().toString());
			filters.add(paramFilter);
		}

		if (filter.getPinRequest() != null && filter.getPinRequest().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("pinRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPinRequest());
			filters.add(paramFilter);
		}
		if (filter.getPinMailerRequest() != null && filter.getPinMailerRequest().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("pinMailerRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getPinMailerRequest());
			filters.add(paramFilter);
		}
		
		if (filter.getEmbossingRequest() != null && filter.getEmbossingRequest().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("embossingRequest");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getEmbossingRequest());
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

	public void add() {
		newPersoCard = new PersoCard();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newPersoCard = (PersoCard) _activePersoCard.clone();
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
		showWarning = false;
		warningMsg = null;
		boolean activeSet = false;
		for (PersoCard card : _itemSelection.getMultiSelection()) {
			if (!card.isIncluded()) {
				try {
					newPersoCard = card.clone();
				} catch (CloneNotSupportedException cnse) {
					newPersoCard = card;
				}
				newPersoCard.setBatchId(getFilter().getBatchId());
				try {
					_personalizationDao.addBatchCard(userSessionId, newPersoCard);
					newPersoCard = getPersoCard(newPersoCard);
					_persoCardsSource.replaceObject(card, newPersoCard);
					if(!activeSet){
						_activePersoCard = newPersoCard;
						activeSet = true;
					}
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					logger.error("",e);
				}
				if (newPersoCard.getWarningMsg() != null) {
                        warningMsg = newPersoCard.getWarningMsg();
                        showWarning = true;
				}
			}
		}
		curMode = VIEW_MODE;
	}

	private PersoCard getPersoCard(PersoCard persoCard){
		PersoCard[] persoCards = _personalizationDao.getPersoCards(userSessionId, SelectionParams.build("id", persoCard.getId(), "lang", curLang));
		if(persoCards != null && persoCards.length > 0){
			return persoCards[0];
		}
		return persoCard;
	}
	
	public void selectByFilter() {
		try {
			if (getFilter().getInstId() == null) {
				throw new Exception(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Prs", "you_must_define_institution_in_filter"));
			}
			_personalizationDao.markBatchCard(userSessionId, getFilter());
			if (getFilter().getWarningMsg() != null) {
				warningMsg = getFilter().getWarningMsg();
				showWarning = true;
				getFilter().setWarningMsg(null);
			}
			
			_itemSelection.clearSelection();
			_persoCardsSource.flushCache();
			_activePersoCard = null;			
			curMode = VIEW_MODE;			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}
	
	public void unselect() {
		boolean activeSet = false;
		try {
			for (PersoCard card : _itemSelection.getMultiSelection()) {
				if (card.isIncluded()) {
					try {
						_personalizationDao.removeBatchCard( userSessionId, card);
						newPersoCard = getPersoCard(card);
						_persoCardsSource.replaceObject(card, newPersoCard);
						if(!activeSet){
							_activePersoCard = newPersoCard;
							activeSet = true;
						}
					} catch (Exception e) {
						//continue deselecting
						FacesUtils.addMessageError(e);
						logger.error("",e);
					}
				} 
			}
			curMode = VIEW_MODE;
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}
	
	public void unselectAll() {		
		try {
			_personalizationDao.unmarkBatchCard( userSessionId, getFilter());
			_itemSelection.clearSelection();
			_persoCardsSource.flushCache();
			_activePersoCard = null;			
			curMode = VIEW_MODE;			
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("",e);
		}		
	}

    public void prepareNewPersoCardData() {
        try {
            newPersoCard = (PersoCard) _activePersoCard.clone();
        } catch (CloneNotSupportedException e) {
            logger.error("",e);
            newPersoCard = _activePersoCard;
        }
    }

	
	public void close() {
		curMode = VIEW_MODE;
		showWarning = false;
	}

	public PersoCard getNewPersoCard() {
		if (newPersoCard == null) {
			newPersoCard = new PersoCard();		
		}
		return newPersoCard;
	}

	public void setNewPersoCard(PersoCard newPersoCard) {
		this.newPersoCard = newPersoCard;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activePersoCard = null;			
		_persoCardsSource.flushCache();
		showWarning = false;
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
			PersoCard[] schemas = _personalizationDao.getPersoCards( userSessionId, params);
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
		if (products == null) {
			products = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS);
		}
		if (products == null)
			products = new ArrayList<SelectItem>();
		return products;
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

	public boolean isShowWarning() {
		return showWarning;
	}

	public String getWarningMsg() {
		return warningMsg;
	}

    public void setWarningMsg(String warningMsg) {
        this.warningMsg = warningMsg;
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



    public void modify() {
        try {
            super.modify();
            if(getCardInBatchWarning()!=null && !getCardInBatchWarning()) {
                _itemSelection.addNewObjectToList(getNewCard());
                setActivePersoCard(getNewCard());
            }
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            getLogger().error("", e);
        }
    }

    @Override
    public String getIBatisSelectForGreed(){
        return "prs.get-perso-cards";
    }

    @Override
    public PersoCard getNewCard() {
        return newPersoCard;
    }

    @Override
    public void setNewCard(BaseCard newCard) {
        this.newPersoCard = (PersoCard)newCard;
    }

	@Override
	protected Logger getLogger() {
		return logger;
	}
}
