package ru.bpc.sv2.ui.aup;

import java.util.ArrayList;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;

import org.ajax4jsf.model.ExtendedDataModel;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;

import ru.bpc.sv2.aup.CardStatResp;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AuthProcessingDao;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DaoDataModel;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.ui.utils.TableRowSelection;

@ViewScoped
@ManagedBean (name = "MbAupCardStatResp")
public class MbAupCardStatResp extends AbstractBean {

	private static final Logger logger = Logger.getLogger("AUTH_PROCESSING");

	private static String COMPONENT_ID = "2202:cardStatRespTable";

	private AuthProcessingDao aupDao = new AuthProcessingDao();


	private List<SelectItem> institutions;

	private List<SelectItem> participantTypes;
	private List<SelectItem> msgTypes;

	private CardStatResp filter;
	private transient DaoDataModel<CardStatResp> cardStatRespSource;
	private final TableRowSelection<CardStatResp> itemSelection;
	private CardStatResp activeCardStatResp;
	private CardStatResp newCardStatResp;

	public MbAupCardStatResp() {
		pageLink = "aup|cardStatResp";
		cardStatRespSource = new DaoDataModel<CardStatResp>() {
			@Override
			protected CardStatResp[] loadDaoData(SelectionParams params) {
				if (!searching)
					return new CardStatResp[0];
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return aupDao.getCardStatResps(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return new CardStatResp[0];
			}

			@Override
			protected int loadDaoDataSize(SelectionParams params) {
				if (!searching)
					return 0;
				try {
					setFilters();
					params.setFilters(filters.toArray(new Filter[filters.size()]));
					return aupDao.getCardStatRespsCount(userSessionId, params);
				} catch (Exception e) {
					setDataSize(0);
					FacesUtils.addMessageError(e);
					logger.error("", e);
				}
				return 0;
			}
		};
		itemSelection = new TableRowSelection<CardStatResp>(null, cardStatRespSource);
	}

	public void search() {
		clearBean();
		searching = true;
	}

	public void clearFilter() {
		clearBean();
		filter = null;
		searching = false;
	}

	public void clearBean() {
		cardStatRespSource.flushCache();
		activeCardStatResp = null;
	}

	public void setFilters() {
		filter = getFilter();

		filters = new ArrayList<Filter>();

		Filter paramFilter;
		paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(userLang);
		filters.add(paramFilter);

		if (filter.getInstId() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("instId");
			paramFilter.setValue(filter.getInstId());
			filters.add(paramFilter);
		}
		if (filter.getOperType() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("operType");
			paramFilter.setValue(filter.getOperType());
			filters.add(paramFilter);
		}
		if (filter.getCardState() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardState");
			paramFilter.setValue(filter.getCardState());
			filters.add(paramFilter);
		}
		if (filter.getCardStatus() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("cardStatus");
			paramFilter.setValue(filter.getCardStatus());
			filters.add(paramFilter);
		}
		if (filter.getPinPresence() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("pinPresence");
			paramFilter.setValue(filter.getPinPresence());
			filters.add(paramFilter);
		}
		if (filter.getRespCode() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("respCode");
			paramFilter.setValue(filter.getRespCode());
			filters.add(paramFilter);
		}
		if (filter.getPriority() != null) {
			paramFilter = new Filter();
			paramFilter.setElement("priority");
			paramFilter.setValue(filter.getPriority());
			filters.add(paramFilter);
		}
	}

	private void prepareSelection() {
		if (cardStatRespSource.getRowCount() > 0) {
			if (activeCardStatResp == null) {
				setFirstRowActive();
			} else {
				setRowActive();
			}
		}
	}

	private void setFirstRowActive() {
		cardStatRespSource.setRowIndex(0);
		activeCardStatResp = (CardStatResp) cardStatRespSource.getRowData();

		SimpleSelection selection = new SimpleSelection();
		selection.addKey(activeCardStatResp.getModelId());
		itemSelection.setWrappedSelection(selection);

		setDependentBeans();
	}

	private void setRowActive() {
		SimpleSelection selection = new SimpleSelection();
		selection.addKey(activeCardStatResp.getModelId());
		itemSelection.setWrappedSelection(selection);
		activeCardStatResp = itemSelection.getSingleSelection();
	}

	private void setDependentBeans() {
	}

	public void add() {
		curMode = NEW_MODE;
		newCardStatResp = new CardStatResp();
	}

	public void edit() {
		curMode = EDIT_MODE;
		newCardStatResp = activeCardStatResp;
	}

	public void save() {
		if (this.isNewMode()) {
			newCardStatResp = aupDao.addCardStatResp(userSessionId, newCardStatResp);

		} else if (this.isEditMode()) {
			newCardStatResp = aupDao.editCardStatResp(userSessionId, newCardStatResp);
		}
		clearBean();
		activeCardStatResp = newCardStatResp;

		cancel();
	}

	public void delete() {
		try {
			aupDao.removeCardStatRespLong(userSessionId, activeCardStatResp);
			activeCardStatResp = itemSelection.removeObjectFromList(activeCardStatResp);
			clearBean();
		} catch (Exception e) {
			FacesUtils.addMessageError(e);
			logger.error("", e);
		}
	}

	public void cancel() {
		curMode = VIEW_MODE;
		newCardStatResp = null;
	}

	public CardStatResp getNewCardStatResp() {
		return newCardStatResp;
	}

	public CardStatResp getActiveCardStatResp() {
		return activeCardStatResp;
	}

	public void setItemSelection(SimpleSelection selection) {
		itemSelection.setWrappedSelection(selection);
		activeCardStatResp = itemSelection.getSingleSelection();
		setDependentBeans();
	}

	public SimpleSelection getItemSelection() {
		prepareSelection();
		return itemSelection.getWrappedSelection();
	}

	public ExtendedDataModel getCardStatResps() {
		return cardStatRespSource;
	}

	public List<SelectItem> getRespCodes() {
		return getDictUtils().getArticles(DictNames.RESPONSE_CODE, false, true);
	}

	public List<SelectItem> getPinPresences() {
		return getDictUtils().getArticles(DictNames.PIN_PRESENCE, false, true);
	}

	public List<SelectItem> getCardStatuses() {
		return getDictUtils().getArticles(DictNames.CARD_STATUS, false, true);
	}

	public List<SelectItem> getCardStates() {
		return getDictUtils().getArticles(DictNames.CARD_STATE, false, true);
	}

	public List<SelectItem> getOperTypes() {
		return getDictUtils().getArticles(DictNames.OPER_TYPE, false, true);
	}

	public List<SelectItem> getInstitutions() {
		if (institutions == null) {
			institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
		}
		if (institutions == null)
			institutions = new ArrayList<SelectItem>();
		return institutions;
	}

	public List<SelectItem> getMsgTypes() {
		if (msgTypes == null) {
			msgTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.MESSAGE_TYPES);
		}
		if (msgTypes == null)
			msgTypes = new ArrayList<SelectItem>();
		return msgTypes;
	}

	public List<SelectItem> getParticipantTypes() {
		if (participantTypes == null) {
			participantTypes = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.PARTICIPANT_TYPES);
		}
		if (participantTypes == null)
			participantTypes = new ArrayList<SelectItem>();
		return participantTypes;
	}

	public CardStatResp getFilter() {
		if (filter == null) {
			filter = new CardStatResp();
		}
		return filter;
	}

	public void setFilter(CardStatResp filter) {
		this.filter = filter;
	}

	public String getComponentId() {
		return COMPONENT_ID;
	}

	public Logger getLogger() {
		return logger;
	}

}
