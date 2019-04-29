package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.IssuingDao;
import ru.bpc.sv2.logic.NetworkDao;
import ru.bpc.sv2.logic.OperationDao;
import ru.bpc.sv2.net.CardType;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.math.BigDecimal;
import java.util.*;

/**
 * Created by Gasanov on 10.08.2015.
 */
@ViewScoped
@ManagedBean(name = "MbFeeCollectionDS")
public class MbFeeCollectionDS implements CommonWizardStep {
    private static final Logger classLogger = Logger.getLogger(MbFeeCollectionDS.class);
    private static final String PAGE = "/pages/common/wizard/callcenter/cardFeeCollectionDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String  INST_ID = "INST_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";

    private Map<String, Object> context;

    private Long cardId;
    private Integer instId;
    private Integer networkId;
    private long userSessionId;
    private String curLang;
    private String entityType;
    private Map<Integer,Map<String,Object>> envMap;
    private List<SelectItem> reasons;
    private String reason;
    private BigDecimal amount;
    private String currency;
    private Date dateOper;

    private transient DictUtils dictUtils;

    private Card card;

    private IssuingDao issuingDao = new IssuingDao();

    private NetworkDao _networkDao = new NetworkDao();

    private OperationDao operationDao = new OperationDao();

    public MbFeeCollectionDS(){
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        curLang = SessionWrapper.getField("language");
    }

    @Override
    public void init(Map<String, Object> context) {
        this.context = context;
        entityType = (String) context.get(ENTITY_TYPE);
        context.put(MbCommonWizard.PAGE, PAGE);
        if (context.containsKey(OBJECT_ID)){
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID +" is not defined in wizard context");
        }
        if (EntityNames.CARD.equals(entityType)){
            card = retriveCard(cardId);
            networkId = getNetWorkId(card.getCardTypeId());
        }

        if (context.containsKey(INST_ID)){
            instId = (Integer) context.get(INST_ID);
        }
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        classLogger.trace("MbFeeCollectionDS release...");
        if (direction == Direction.FORWARD){
            feeGenerate();
//            context.put(CURRENT_STATUS, newStatus);
        }
        return context;
    }

    @Override
    public boolean validate() {
        return false;
    }

    private void feeGenerate(){
        Map<String, Object> params = new HashMap<String, Object>();
        params.put("card_number", card.getCardNumber());
        params.put("reason_code", reason);
        params.put("amount", amount);
        params.put("currency", currency);
        params.put("oper_date", dateOper);
        operationDao.feeGenerate(userSessionId, (String) getEnvMap(networkId).get("procedure"), params);
    }

    private Card retriveCard(Long cardId){
        classLogger.trace("retriveCard...");
        Card result;
        SelectionParams sp = SelectionParams.build("CARD_ID", cardId);
        Map<String, Object> paramMap = new HashMap<String, Object>();
        paramMap.put("tab_name", "CARD");
        paramMap.put("param_tab", sp.getFilters());
        Card[] cards = issuingDao.getCardsCur(userSessionId, sp, paramMap);
        if (cards.length > 0){
            result = cards[0];
        } else {
            throw new IllegalStateException("Card with ID:" + cardId + " is not found!");
        }
        return result;
    }

    public Integer getNetWorkId(Integer id) {
        try {
            SelectionParams params = SelectionParams.build("id", id, "lang", curLang);
            CardType[] types = _networkDao.getCardTypesList(userSessionId, params);
             if (types != null && types.length > 0){
                 return types[0].getNetworkId();
             }
        } catch (Exception e) {
            classLogger.error("", e);
            if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
                FacesUtils.addMessageError(e);
            }
        }
        return null;
    }

    private Map getEnvMap(Integer networkID){
        if(envMap == null){
            Map<String, Object> mscard = new HashMap<String, Object>();
            mscard.put("lov", LovConstants.REASON_MASTER_CARD);
            mscard.put("procedure", "mcw_api_fee_generate");

            Map<String, Object> visacard = new HashMap<String, Object>();
            visacard.put("lov", LovConstants.REASON_VISA);
            visacard.put("procedure", "vis_api_fee_generate");

            envMap = new HashMap<Integer,Map<String,Object>>();
            envMap.put(1002, mscard);
            envMap.put(1003, visacard);
        }
        return (networkID != null) ? envMap.get(networkID) : null;
    }

    public List<SelectItem> getReasons(){
        if(reasons == null && getEnvMap(networkId) != null && getEnvMap(networkId).get("lov") != null){
            reasons = getDictUtils().getLov((Integer)getEnvMap(networkId).get("lov"));
        }
        return reasons;
    }

    public DictUtils getDictUtils() {
        if (dictUtils == null) {
            dictUtils = (DictUtils) ManagedBeanWrapper.getManagedBean("DictUtils");
        }
        return dictUtils;
    }

    public String getReason() {
        return reason;
    }

    public void setReason(String reason) {
        this.reason = reason;
    }

    public BigDecimal getAmount() {
        return amount;
    }

    public void setAmount(BigDecimal amount) {
        this.amount = amount;
    }

    public List<SelectItem> getCurrencies() {
        return CurrencyCache.getInstance().getAllCurrencies(curLang);
    }

    public String getCurrency() {
        return currency;
    }

    public void setCurrency(String currency) {
        this.currency = currency;
    }

    public Date getDateOper() {
        return dateOper;
    }

    public void setDateOper(Date dateOper) {
        this.dateOper = dateOper;
    }
}
