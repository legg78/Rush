package ru.bpc.sv2.ui.operations;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.IssuingPrivConstants;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.operations.Participant;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

@ViewScoped
@ManagedBean (name = "MbParticipants")
public class MbParticipants extends AbstractBean {
	private static final Logger logger = Logger.getLogger("OPER_PROCESSING");
	private boolean disabledViewCardNumber = true;
	private boolean disabledViewCardToken = true;

	private OperationDao operationDao = new OperationDao();
	private IssuingDao issuingDao = new IssuingDao();

	private Participant filter;
	private List<Participant> participantsList;

	public Participant getFilter() {
		if (filter == null) {
			filter = new Participant();
		}
		return filter;
	}

	public void setFilter(Participant filter) {
		this.filter = filter;
	}

	public List<Participant> getParticipantsList() {
		if (participantsList == null) {
			participantsList = new ArrayList<Participant>(1);
			participantsList.add(new Participant());    // to show one column group
		}
		return participantsList;
	}

	public void setParticipants(List<Participant> participantsList) {
		this.participantsList = participantsList;
	}

	public void loadParticipantsForOperation(Long operId) {
		Filter[] filters = new Filter[2];
		filters[0] = new Filter("lang", curLang);
		filters[1] = new Filter("operId", operId);

		SelectionParams params = new SelectionParams(filters);
		params.setRowIndexEnd(Integer.MAX_VALUE);
		try {
			Participant[] participants = operationDao.getParticipants(userSessionId, params);
			if (participants.length > 0) {
				participantsList = Arrays.asList(participants);
			} else {
				participantsList = null;
			}
			checkSourceList();
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	@Override
	public void clearFilter() {
		filter = null;
		clearBean();
	}

	public void clearBean() {
		participantsList = null;
		disabledViewCardNumber = true;
		disabledViewCardToken = true;
	}

	public boolean isDisabledViewCardNumber() {
		return disabledViewCardNumber;
	}

	public boolean isDisabledViewCardToken() {
		return disabledViewCardToken;
	}

	public boolean isDisabledViewCardObjects() {
		return isDisabledViewCardNumber() && isDisabledViewCardToken();
	}

	private void checkSourceList() {
		disabledViewCardNumber = true;
		disabledViewCardToken = true;
		if (participantsList == null) {
			return;
		}
		for (Participant participant : participantsList) {
			if (participant.getCardNumber() != null) {
				disabledViewCardNumber = false;
			}
			if (participant.getCardToken() != null) {
				disabledViewCardToken = false;
			}
		}
	}

	public void viewCardNumber() {
		try {
			// Audit record...
			issuingDao.viewCardNumber(userSessionId, 0L);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void viewCardToken() {
		try {
			// Audit record...
			issuingDao.viewCardToken(userSessionId, 0L);
		} catch (Exception e) {
			logger.error("", e);
			FacesUtils.addMessageError(e);
		}
	}

	public void viewCardObjects() {
		viewCardNumber();
		viewCardToken();
	}

	private boolean hasPrivilege(String privilege) {
		try {
			Boolean out = ((UserSession)ManagedBeanWrapper.getManagedBean("usession")).getInRole().get(privilege);
			return (out != null) ? out : false;
		} catch (Exception e) {
			logger.error("", e);
		}
		return false;
	}
	private boolean isTokenRequest(String privilege) {
		return IssuingPrivConstants.VIEW_CARD_TOKEN.equals(privilege);
	}
	private boolean isNumberRequest(String privilege) {
		return IssuingPrivConstants.VIEW_CARD_NUMBER.equals(privilege);
	}

	public boolean showItem(Participant item, String privilege) {
		if (item != null && hasPrivilege(privilege) && item.getParticipantType() != null) {
			if (isNumberRequest(privilege) && StringUtils.isNotEmpty(item.getCardNumber())) {
				return true;
			} else if (isTokenRequest(privilege) && StringUtils.isNotEmpty(item.getCardToken())) {
				if (!Participant.ACQ_PARTICIPANT.equals(item.getParticipantType())) {
					return true;
				}
			}
		}
		return false;
	}
}
