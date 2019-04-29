package ru.bpc.sv2.ui.accounts.details;

import java.math.BigDecimal;
import java.util.Date;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.RequestScoped;

import org.apache.log4j.Logger;

import org.ajax4jsf.model.KeepAlive;
import ru.bpc.sv2.accounts.Transaction;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.SessionWrapper;

@RequestScoped
@KeepAlive
@ManagedBean (name = "MbTransactionDetails")
public class MbTransactionDetails {

	private static final Logger logger = Logger.getLogger("ACCOUNTING");
	
	public static final String OBJECT_ID = "objectId";
	private static final String CTX_MENU_PARAMS = "CTX_MENU_PARAMS";
	
	private Long objectId;
	private Transaction transaction;
	private String language;
	private long userSessionId;
	private OperationDao operationDao = new OperationDao();
	public MbTransactionDetails(){
		language = SessionWrapper.getField("language");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
	}
	
	public boolean initializeModalPanel() {
		logger.debug("MbTransactionDetails initializing...");
		if (FacesUtils.getSessionMapValue(OBJECT_ID) != null) {
			objectId = (Long) FacesUtils.getSessionMapValue(OBJECT_ID);
		}
		if (objectId == null){
			objectIdIsNotSet();
		}
		return true;
	}
	
	private boolean objectIdIsNotSet(){
		String message = "Object ID is not set";
		logger.error(message);
		FacesUtils.addErrorExceptionMessage(message);
		return false;
	}
	
	public Transaction getTransaction(){
		if (transaction == null && objectId != null){
			Filter[] filters = new Filter[] { new Filter("id", objectId),
					new Filter("lang", language) };
			Transaction[] transactions = {new Transaction(){
				{
					setDebitAccountType("ACTP1401");
					setDebitAccountNumber("123123");
					setDebitBalanceType("ACTP1401");
					setDebitBalance(new BigDecimal(123));
					setDebitPostingDate(new Date());
					setDebitSttlDay(123);
					setDebitSttlDate(new Date());
					setEntityType(EntityNames.TRANSACTION);
					setId(1);setDebitStatus("ENTRCNCL");
					setCreditStatus("ENTRCNCL");
					setTransactionId(1l);setDescription(objectId.toString());
				}
			}};//operationDao.getEntries(userSessionId, new SelectionParams(filters));
			if (transactions.length > 0){
				transaction = transactions[0];
			}			
		}
		return transaction;
	}
}
