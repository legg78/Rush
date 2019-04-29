package ru.bpc.sv2.ui.issuing;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.event.ValueChangeEvent;
import javax.faces.model.SelectItem;

import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.Filter.Operator;
import ru.bpc.sv2.issuing.BaseCard;
import ru.bpc.sv2.issuing.CardInstance;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.net.Network;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbCardInstancesSearch")
public class MbCardInstancesSearch extends PersonalizationStateModifyBacking {
	private static final long serialVersionUID = 8191786527207473750L;

	private static final Logger logger = Logger.getLogger("ISSUING");

	private IssuingDao _issuingDao = new IssuingDao();

	private NetworkDao _networkDao = new NetworkDao();

	private CardInstance filter;
	private CardInstance _activeCardInstance;
	private CardInstance newCardInstance;

	private ArrayList<SelectItem> institutions;
	private ArrayList<SelectItem> networks;

	private final DaoDataModel<CardInstance> _cardInstancesSource;

	private final TableRowSelection<CardInstance> _itemSelection;
	
	private static String COMPONENT_ID = "mainTable";
	private String tabName;
	private String parentSectionId;



	public MbCardInstancesSearch() {
		_cardInstancesSource = new DaoDataModel<CardInstance>() {
			private static final long serialVersionUID = -7240049904405091192L;

			@Override
			protected CardInstance[] loadDaoData(SelectionParams params) {
				if (!searching || getFilter().getCardId() == null) {
					return new CardInstance[0];
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getCardInstances(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
					setDataSize(0);
				}
				return new CardInstance[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching || getFilter().getCardId() == null) {
					return 0;
				}
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return _issuingDao.getCardInstancesCount(userSessionId, params);
				} catch (Exception e) {
					FacesUtils.addMessageError(e);
				}
				return 0;
			}
		};

		_itemSelection = new TableRowSelection<CardInstance>(null, _cardInstancesSource);
	}

	public DaoDataModel<CardInstance> getCardInstances() {
		return _cardInstancesSource;
	}

	public CardInstance getActiveCardInstance() {
		return _activeCardInstance;
	}

	public void setActiveCardInstance(CardInstance activeCardInstance) {
		_activeCardInstance = activeCardInstance;
	}

	public SimpleSelection getItemSelection() {
		if (_activeCardInstance == null && _cardInstancesSource.getRowCount() > 0) {
			setFirstRowActive();
		} else if (_activeCardInstance != null && _cardInstancesSource.getRowCount() > 0) {
			SimpleSelection selection = new SimpleSelection();
			selection.addKey(_activeCardInstance.getModelId());
			_itemSelection.setWrappedSelection(selection);
			_activeCardInstance = _itemSelection.getSingleSelection();
		}
		return _itemSelection.getWrappedSelection();
	}

	public void setFirstRowActive() {
		_cardInstancesSource.setRowIndex(0);
		SimpleSelection selection = new SimpleSelection();
		_activeCardInstance = (CardInstance) _cardInstancesSource.getRowData();
		selection.addKey(_activeCardInstance.getModelId());
		_itemSelection.setWrappedSelection(selection);
		if (_activeCardInstance != null) {
			setInfo();
		}
	}

	public void setItemSelection(SimpleSelection selection) {
		_itemSelection.setWrappedSelection(selection);
		_activeCardInstance = _itemSelection.getSingleSelection();
		if (_activeCardInstance != null) {
			// setInfo();
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
		filter = new CardInstance();
		clearState();
		searching = false;
	}

	public CardInstance getFilter() {
		if (filter == null)
			filter = new CardInstance();
		return filter;
	}

	public void setFilter(CardInstance filter) {
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

		if (filter.getCardId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardId");
			paramFilter.setOp(Operator.eq);
			paramFilter.setValue(filter.getCardId().toString());
			filters.add(paramFilter);
		}

		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(curLang);
		filters.add(paramFilter);

	}

	public void view() {
		curMode = VIEW_MODE;
	}


    public void prepareNewCardInstanceData() {
        try {
            newCardInstance =  _activeCardInstance.clone();
            curMode = EDIT_MODE;
        } catch (CloneNotSupportedException e) {
            logger.error("",e);
            newCardInstance = _activeCardInstance;
        }
    }


	public void close() {
		curMode = VIEW_MODE;
	}

	public CardInstance getNewCardInstance() {
		if (newCardInstance == null) {
			newCardInstance = new CardInstance();
		}
		return newCardInstance;
	}

	public void setNewCardInstance(CardInstance newCardInstance) {
		this.newCardInstance = newCardInstance;
	}

	public void clearState() {
		_itemSelection.clearSelection();
		_activeCardInstance = null;
		_cardInstancesSource.flushCache();
		curLang = userLang;
	}

	public void clearBeansStates() {

	}

	public void changeLanguage(ValueChangeEvent event) {
		curLang = (String) event.getNewValue();

		List<Filter> filtersList = new ArrayList<Filter>();

		Filter paramFilter = new Filter();
		paramFilter.setElement("id");
		paramFilter.setOp(Operator.eq);
		paramFilter.setValue(_activeCardInstance.getId().toString());
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
			CardInstance[] cardInstances = _issuingDao.getCardInstances(userSessionId, params);
			if (cardInstances != null && cardInstances.length > 0) {
				_activeCardInstance = cardInstances[0];
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
	
	public String getComponentId() {
		return parentSectionId + ":" + tabName + ":" + COMPONENT_ID;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public void setParentSectionId(String parentSectionId) {
		this.parentSectionId = parentSectionId;
	}

    public ArrayList<SelectItem> getPersoPriorities() {
        return getDictUtils().getArticles(DictNames.PERSO_PRIORITY, true, false);
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

    @Override
    public void modify() {
        try {
            super.modify();
            if (getCardInBatchWarning()!=null && !getCardInBatchWarning()) {
                _itemSelection.addNewObjectToList(getNewCard());
                setActiveCardInstance(getNewCard());
            }
            curMode = VIEW_MODE;
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            getLogger().error("", e);
        }
    }
    
    @Override
    public void cancel() {
        super.cancel();
        curMode = VIEW_MODE;
    }


    @Override
    public String getIBatisSelectForGreed(){
        return "iss.get-card-instances";
    }

    @Override
    public CardInstance getNewCard() {
        return newCardInstance;
    }

    @Override
    public void setNewCard(BaseCard newCard) {
        this.newCardInstance = (CardInstance)newCard;
    }

	@Override
	protected Logger getLogger() {
		return logger;
	}
}
