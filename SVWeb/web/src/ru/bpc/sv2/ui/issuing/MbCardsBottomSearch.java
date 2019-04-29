package ru.bpc.sv2.ui.issuing;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.SecurityDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.security.QuestionWord;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean(name = "MbCardsBottomSearch")
public class MbCardsBottomSearch extends AbstractBean {
	private static final long serialVersionUID = 175440235963828804L;

	private static final Logger logger = Logger.getLogger("ISSUING");

	private IssuingDao _issuingDao = new IssuingDao();

	private NetworkDao _networkDao = new NetworkDao();

	private SecurityDao _securityDao = new SecurityDao();

	private Menu mbMenu;

	private boolean secWordCorrect;
	private QuestionWord secWord;
	private String secWordEntity;
	private Long secWordObjectId;

	private Card filter;
	private Card _activeCard;
	private Card newCard;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> networks;
	private ArrayList<SelectItem> cardTypes;

	private final DaoDataModel<Card> _cardsSource;
	private final TableRowSelection<Card> _itemSelection;

	private boolean searchByHolder;
	private String backLink;
	private String ctxItemEntityType;
	private ContextType ctxType;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String searchTabName;
	private String tabNameParam;
	private String parentSectionId;
	private Map<String, Object> paramMaps;
	
	public MbCardsBottomSearch() {
		mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		_cardsSource = new DaoDataModel<Card>(true) {
			private static final long serialVersionUID = -9111805905889948423L;

			@Override
			protected Card[] loadDaoData(SelectionParams params) {
				if (!searching) {
					return new Card[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getCardsCur(userSessionId, params, paramMaps);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
				}
				return new Card[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					getParamMaps().put("param_tab", filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getCardsCurCount(userSessionId, params, paramMaps);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<Card>(null, _cardsSource);
	}

	public DaoDataModel<Card> getCards() {
		return _cardsSource;
	}

	public Card getActiveCard() {
		return _activeCard;
	}

	public void setActiveCard(Card activeCard) {
		_activeCard = activeCard;
	}

	public SimpleSelection getItemSelection() {
		try {
			if (_activeCard == null && _cardsSource.getRowCount() > 0) {
				setFirstRowActive();
			} else if (_activeCard != null && _cardsSource.getRowCount() > 0) {
				SimpleSelection selection = new SimpleSelection();
				selection.addKey(_activeCard.getModelId());
				_itemSelection.setWrappedSelection(selection);
				_activeCard = _itemSelection.getSingleSelection();
			}

		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_cardsSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCard = (Card) _cardsSource.getRowData();
		selection.addKey(_activeCard.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeCard != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCard = _itemSelection.getSingleSelection();
		if (_activeCard != null) {
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
		filter = new Card();
		paramMaps = new HashMap<String, Object>();
		clearState();
		searching = false;
	}

	public Card getFilter() {
		if (filter == null)
			filter = new Card();
		return filter;
	}

	public void setFilter(Card filter) {
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
			paramFilter.setValue(filter.getId().toString());
			filters.add(paramFilter);
		}

		if (filter.getCardholderId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CARDHOLDER_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCardholderId());
			filters.add(paramFilter);
		}

		if (filter.getCustomerId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_ID");
			paramFilter.setValue(filter.getCustomerId());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("LANG");
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("INST_ID");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}

		if (filter.getCardTypeId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_TYPE_ID");
			paramFilter.setValue(filter.getCardTypeId());
			filters.add(paramFilter);
		}

		if (filter.getAccountId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("ACCOUNT_ID");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getAccountId());
			filters.add(paramFilter);
		}

		if (filter.getCardholderName() != null && filter.getCardholderName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARDHOLDER_NAME");
			paramFilter.setValue(filter.getCardholderName());
			filters.add(paramFilter);
		}		
		
		if (filter.getCardNumber() != null && filter.getCardNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CARD_NUMBER");
			paramFilter.setCondition("=");
			paramFilter.setValue(filter.getCardNumber().trim().replaceAll("[*]", "%").replaceAll("[?]",
					"_").toUpperCase());
			if (((String)paramFilter.getValue()).indexOf("%") != -1 || filter.getCardNumber().indexOf("?") != -1) {
				paramFilter.setCondition("like");
			}
			filters.add(paramFilter);
		}

		if (getFilter().getCustomerNumber() != null &&
				getFilter().getCustomerNumber().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("CUSTOMER_NUMBER");
			filters.add(paramFilter);
		}
		
		if (getFilter().getContractId() != null){
			filters.add(new Filter("CONTRACT_ID", getFilter().getContractId()));
		}
		
		if (getFilter().getContractNumber() != null &&
				!getFilter().getContractNumber().trim().isEmpty()){
			String contractNumber = getFilter().getContractNumber().trim().toUpperCase().replaceAll("[*]",
					"%").replaceAll("[?]", "_");
			filters.add(new Filter("CONTRACT_NUMBER", contractNumber));
		}
		
		if (filter.getFirstName() != null && filter.getFirstName().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("FIRST_NAME");
			paramFilter.setValue(filter.getFirstName());
			filters.add(paramFilter);
		}
		
		if (filter.getSurname() != null && filter.getSurname().trim().length() > 0) {
			paramFilter = new Filter();
			paramFilter.setElement("SURNAME");
			paramFilter.setValue(filter.getSurname());
			filters.add(paramFilter);
		}
		if (searchTabName != null && searchTabName.trim().length() > 0){
			getParamMaps().put("tab_name", searchTabName);
		}
		
		if (filter.getAuthId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("authId");
			paramFilter.setValue(filter.getAuthId());
			filters.add(paramFilter);
		}
	}
	
	public String toCard(){
		HashMap<String,Object> queueFilter = getQueueFilter("MbCardsBottomSearch");

		if (queueFilter==null)
			return "";
		queueFilter.put("cardNumber", _activeCard.getCardNumber());
		queueFilter.put("instId", _activeCard.getInstId());
		addFilterToQueue("MbCardsSearch", queueFilter);
		Menu mbMenu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
		mbMenu.externalSelect("issuing|cards");
		return "issuing|cards";
	}

	public void add() {
		newCard = new Card();
		curMode = NEW_MODE;
	}

	public void edit() {
		try {
			newCard = (Card) _activeCard.clone();
		} catch (CloneNotSupportedException e) {
			logger.error("", e);
			newCard = _activeCard;
		}
		curMode = EDIT_MODE;
	}

	public void view() {
		MbCardsSearch cards = (MbCardsSearch) ManagedBeanWrapper.getManagedBean("MbCardsSearch");
		cards.setActiveCard(_activeCard);
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

	public void clearState() {
		_itemSelection.clearSelection();
		_activeCard = null;
		_cardsSource.flushCache();
		curLang = userLang;

		clearBeansStates();
	}

	public void clearBeansStates() {
	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeCard.getId().toString());
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
			Card[] cards = _issuingDao.getCards(userSessionId, params);
			if (cards != null && cards.length > 0) {
				_activeCard = cards[0];
			}
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
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

	public ArrayList<SelectItem> getNetworks() {
		if (networks == null) {
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

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				Network[] nets = _networkDao.getNetworks(userSessionId, params);
				for (Network net : nets) {
					items.add(new SelectItem(net.getId(), net.getName(), net.getDescription()));
				}
				networks = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (networks == null)
					networks = new ArrayList<SelectItem>();
			}
		}
		return networks;
	}

	public ArrayList<SelectItem> getCardTypes() {
		if (cardTypes == null) {
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

				params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

				CardType[] types = _networkDao.getCardTypes(userSessionId, params);
				for (CardType type : types) {
					String name = type.getName();
					for (int i = 1; i < type.getLevel(); i++) {
						name = " -- " + name;
					}
					items.add(new SelectItem(type.getId(), name));
				}
				cardTypes = items;
			} catch (Exception e) {
				logger.error("", e);
				if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
					FacesUtils.addMessageError(e);
				}
			} finally {
				if (cardTypes == null)
					cardTypes = new ArrayList<SelectItem>();
			}
		}
		return cardTypes;
	}

	public ArrayList<SelectItem> getSecurityQuestions() {
		if (_activeCard == null || _activeCard.getCardholderId() == null) {
			return new ArrayList<SelectItem>(0);
		}
		try {
			QuestionWord[] questions = _securityDao.getQuestions(userSessionId, _activeCard
					.getCardholderId(), _activeCard.getId(), _activeCard.getCustomerId());
			ArrayList<SelectItem> items = new ArrayList<SelectItem>(questions.length);
			for (QuestionWord q : questions) {
				items.add(new SelectItem(q.getQuestion(), getDictUtils().getAllArticlesDesc().get(
						q.getQuestion())));
			}
			if (questions.length > 0) {
				secWordEntity = questions[0].getEntityType();
				secWordObjectId = questions[0].getObjectId();
			}
			return items;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
				FacesUtils.addMessageError(e);
			}
			return new ArrayList<SelectItem>(0);
		}
	}

	public void checkWord() {
		secWord.setObjectId(secWordObjectId);
		secWord.setEntityType(secWordEntity);
		try {
			secWordCorrect = _securityDao.checkSecurityWord(userSessionId, secWord);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public boolean isSecWordCorrect() {
		return secWordCorrect;
	}

	public void setSecWordCorrect(boolean secWordCorrect) {
		this.secWordCorrect = secWordCorrect;
	}

	public QuestionWord getSecWord() {
		if (secWord == null) {
			secWord = new QuestionWord();
		}
		return secWord;
	}

	public void setSecWord(QuestionWord secWord) {
		this.secWord = secWord;
	}

	public void checkSecWord() {
		secWord = new QuestionWord();
	}

	public boolean isSearchByHolder() {
		return searchByHolder;
	}

	public void setSearchByHolder(boolean searchByHolder) {
		this.searchByHolder = searchByHolder;
	}

	public String gotoCards() {
		MbCardsSearch cardsBean = (MbCardsSearch) ManagedBeanWrapper
				.getManagedBean("MbCardsSearch");
		Card filter = new Card();
		filter.setMask(_activeCard.getMask());
		cardsBean.clearFilter();
		cardsBean.setFilter(filter);
		cardsBean.setSearching(true);
		cardsBean.setSaveAfterSearch(true);
		cardsBean.setBackLink(backLink);
		
		String link = "issuing|cards";
		mbMenu.externalSelect(link);
		return link;
	}
	
	public Card loadCard() {
		_activeCard = null;

		setFilters();
		SelectionParams params = new SelectionParams();
		params.setFilters((Filter[]) filters.toArray(new Filter[filters.size()]));
		
		try {
			Card[] cards = _issuingDao.getCards(userSessionId, params);
			if (cards.length > 0) {
				_activeCard = cards[0];
			}
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
		return _activeCard;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}
	
	public String getCtxItemEntityType() {
		return ctxItemEntityType;
	}

	public void setCtxItemEntityType() {
		MbContextMenu ctxBean = (MbContextMenu) ManagedBeanWrapper.getManagedBean("MbContextMenu");
		String ctx = ctxBean.getEntityType();
		if (ctx == null || !ctx.equals(this.ctxItemEntityType)){
			ctxType = ContextTypeFactory.getInstance(ctx);
		}
		this.ctxItemEntityType = ctx;
	}
	
	public ContextType getCtxType(){
		if (ctxType == null) return null;
		Map <String, Object> map = new HashMap<String, Object>();
		
		if (_activeCard != null){
			if (EntityNames.CARD.equals(ctxItemEntityType)) {
				map.put("instId", _activeCard.getInstId());
				map.put("customerNumber", _activeCard.getCustomerNumber());
				map.put("cardNumber", _activeCard.getCardNumber());
				map.put("mask", _activeCard.getMask());
				map.put("id", _activeCard.getId());
			}
			if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
				map.put("id", _activeCard.getInstId());
				map.put("instId", _activeCard.getInstId());
			}
			if (EntityNames.PRODUCT.equals(ctxItemEntityType)) {
				map.put("id", _activeCard.getProductId());
				map.put("instId", _activeCard.getInstId());
				map.put("objectType", _activeCard.getProductType());
				map.put("productType", _activeCard.getProductType());
				map.put("productName", _activeCard.getProductName());
				map.put("productNumber", _activeCard.getProductNumber());
			}
		}

		ctxType.setParams(map);
		return ctxType;
	}
	
	public boolean isForward(){
		return true;
	}
	
	public String getComponentId() {
		return parentSectionId + ":" + tabNameParam + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setTabNameParam(String tabNameParam) {
		this.tabNameParam = tabNameParam;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

	public Map<String, Object> getParamMaps() {
		if (paramMaps == null){
			paramMaps = new HashMap<String, Object>();
		}
		return paramMaps;
	}

	public void setParamMaps(Map<String, Object> paramMaps) {
		this.paramMaps = paramMaps;
	}

	public String getSearchTabName() {
		return searchTabName;
	}

	public void setSearchTabName(String searchTabName) {
		this.searchTabName = searchTabName;
	}


    public void viewCardNumber() {
        try {
            // Audit record...
            _issuingDao.viewCardNumber(userSessionId, _activeCard != null ? _activeCard.getId() : 0L);
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
    }


    public void onSortablePreRenderTable() {
        onSortablePreRenderTable(_cardsSource);
    }
}
