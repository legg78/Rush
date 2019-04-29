package ru.bpc.sv2.ui.issuing;


import ru.bpc.sv2.issuing.BaseCard;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.ui.utils.AbstractBean;




/*
If any greed with card list use personalization state modify modal window, we need to extends
that abstract class in the greed manage bean class.
 */
public abstract class PersonalizationStateModifyBacking extends AbstractBean {

    public final static String WARNING_IF_IN_BATCH_OR_SAVE = "RQTP0001";
    public final static String REMOVE_FROM_BATCH_AND_SAVE = "RQTP0002";
    public final static String LEAVE_IN_BATCH_AND_SAVE = "RQTP0003";

    private IssuingDao _issuingDao = new IssuingDao();

    private Boolean cardInBatchWarning = null;  //must be null
    private Boolean needRemoveFromBatch = null; //must be null
    private String warningMsg = null;           //must be null

    public abstract BaseCard getNewCard();
    public abstract void setNewCard(BaseCard newCard);
    public abstract String getIBatisSelectForGreed();


    public void cancel() {
        setCardInBatchWarning(false);
        setWarningMsg(null);
    }

    public void setNeedRemoveFromBatch(Boolean needRemoveFromBatch) {
        this.needRemoveFromBatch = needRemoveFromBatch;
    }

    public Boolean getNeedRemoveFromBatch() {
        return needRemoveFromBatch;
    }

    public Boolean getCardInBatchWarning() {
        return cardInBatchWarning;
    }

    public void setCardInBatchWarning(Boolean cardInBatchWarning) {
        this.cardInBatchWarning = cardInBatchWarning;
    }

    public String getWarningMsg() {
        return warningMsg;
    }

    public void setWarningMsg(String warningMsg) {
        this.warningMsg = warningMsg;
    }

    public void modify() throws Exception {

        String requestType = WARNING_IF_IN_BATCH_OR_SAVE;
        if (getNeedRemoveFromBatch() != null) {
            requestType = getNeedRemoveFromBatch() ? REMOVE_FROM_BATCH_AND_SAVE : LEAVE_IN_BATCH_AND_SAVE;
            setNeedRemoveFromBatch(null);
        }
        getNewCard().setRequestType(requestType);
        setNewCard(_issuingDao.modifyCardPersonalizationState(userSessionId, getNewCard(), curLang, getIBatisSelectForGreed()));
        if (getNewCard().getWarningMsg() != null) {
            setWarningMsg(getNewCard().getWarningMsg());
            setCardInBatchWarning(true);
        } else {
            setWarningMsg(null);
            setCardInBatchWarning(false);
        }
    }


}
