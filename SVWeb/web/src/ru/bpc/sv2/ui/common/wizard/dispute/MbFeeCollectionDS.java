package ru.bpc.sv2.ui.common.wizard.dispute;

import org.apache.log4j.Logger;
import ru.bpc.sv2.accounts.Account;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.dsp.DisputeParameter;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.operations.Operation;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.common.wizard.application.ApplicationBuilder;
import ru.bpc.sv2.ui.utils.CurrencyCache;
import ru.bpc.sv2.ui.utils.FacesUtils;
import ru.bpc.sv2.utils.UserException;
import util.auxil.SessionWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbFeeCollectionDS")
public class MbFeeCollectionDS extends AbstractWizardStep {
    private static final Logger logger = Logger.getLogger("COMMON");

    private static final String PAGE = "/pages/common/wizard/callcenter/dualCardFeeCollectionDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String INST_ID = "INST_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";
    private static final String STATUS = "STATUS";
    private static final String CARD = "CARD";
    private static final String ACCOUNT = "ACCOUNT";
    private static final String OPERATION = "OPERATION";
    private static final String APPLICATION_ID = "APPLICATION_ID";

    private List<SelectItem> networks;
    private List<DisputeParameter> parameters;
    private Map<Integer, Integer> ids;

    private Integer institution;
    private Integer institutionCard;
    private Integer network;

    private IssuingDao issuingDao = new IssuingDao();
    private OperationDao operationDao = new OperationDao();
    private DisputesDao disputeDao = new DisputesDao();
    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);

        ids = new HashMap<Integer, Integer>(4);
        ids.put(1003, 1544);    // network ID -> procedure ID (vis_api_dsp_init_pkg.init_fee_collection) for VISA
        ids.put(1002, 1486);    // network ID -> procedure ID (mcw_api_dsp_init_pkg.init_member_fee) for MC
        ids.put(1544, 1545);    // procedure ID -> rule ID (vis_api_dsp_generate_pkg.gen_fee_collection) for VISA
        ids.put(1486, 1502);    // procedure ID -> rule ID (mcw_api_dsp_generate_pkg.gen_member_fee) for MC

        if (context.containsKey(CARD)){
            institution = ((Card) context.get(CARD)).getInstId();
        } else if (context.containsKey(ACCOUNT)) {
            institution = ((Account) context.get(ACCOUNT)).getInstId();
        } else if (context.containsKey(OPERATION)){
            institution = ((Operation) context.get(OPERATION)).getIssInstId();
            if (institution == null) {
                institution = ((Operation) context.get(OPERATION)).getAcqInstId();
            }
        }  else if (context.containsKey(INST_ID)) {
            institution = (Integer) context.get(INST_ID);
        }
        networks = getNetworks();
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        logger.trace("MbFeeCollectionDS release...");
        if (direction == Direction.FORWARD) {
            try {
                getContext().put(STATUS, feeGenerate());
            } catch (UserException e) {
                FacesUtils.addMessageError(e.getMessage());
                logger.error("", e);
            } finally {
                parameters.clear();
                parameters = null;
                network = null;
                institution = null;
            }
        }
        return getContext();
    }

    @Override
    public boolean validate() {
        if (parameters != null) {
            for (DisputeParameter parameter : parameters) {
                if (parameter.getMandatory()) {
                    if (parameter.getValue() == null) {
                        FacesUtils.addMessageError("Mandatory parameter '" + parameter.getName() + "' isn't filled");
                        return false;
                    }
                }
            }
        }
        return true;
    }

    private Integer getInstIdByCard(String cardNumber) {
        List<Filter> filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", curLang));
        filters.add(Filter.create("cardNumber", "=", cardNumber));
        Card[] cards = issuingDao.getCards(userSessionId, new SelectionParams(filters));
        if (cards != null && cards.length > 0) {
            return cards[0].getInstId();
        }
        return null;
    }

    private String feeGenerate() throws UserException {
        if (isMaker()) {
            if (institution == null && parameters != null) {
                for (DisputeParameter param : parameters) {
                    if (AppElements.CARD_NUMBER.equals(param.getSystemName())
                            || AppElements.DE_002.equals(param.getSystemName()))
                        if (param.getValueV() != null){
                            institutionCard = getInstIdByCard(param.getValueV().trim().toUpperCase());
                            if (institutionCard != null)
                                break;
                        }
                    if (AppElements.INST_ID.equals(param.getSystemName()))
                        institution = param.getValueN().intValue();
                }
            }
            if (institutionCard != null)
                institution = institutionCard;
            if (institution == null)
                institution = (Integer) SessionWrapper.getObjectField("defaultInst");

            ApplicationBuilder builder = new ApplicationBuilder(applicationDao, userSessionId, institution, getFlowId());
            if (getContext().containsKey(OPERATION)) {
                builder.buildFromDispute(network, parameters, (Operation) getContext().get(OPERATION), true);
            } else {
                builder.buildFromDispute(network, parameters);
            }
            builder.createApplicationInDB();
            getContext().put(APPLICATION_ID, builder.getApplication().getId());
            return builder.getApplication().getStatus();
        } else {
            Map<String, Object> params = new HashMap<String, Object>();
            if (getContext().containsKey(OPERATION)) {
                params.put("operId", ((Operation) getContext().get(OPERATION)).getId());
            } else {
                params.put("operId", null);
            }
            params.put("initRule", ids.get(network));
            params.put("genRule", ids.get(ids.get(network)));
            if (parameters != null) {
                Map<String, Object> disputeParams = new HashMap<String, Object>(parameters.size());
                for (DisputeParameter param : parameters) {
                    disputeParams.put(param.getSystemName(), param.getValue());
                }
                params.put("params", disputeParams);
            }
            params.put("isEdit", false);
            disputeDao.execDispute(userSessionId, params);
        }
        return null;
    }

    public void initParameters() {
        try {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("operId", null);
            params.put("procId", ids.get(getNetwork()));
            params.put("lang", curLang);
            parameters = disputeDao.prepareDispute(userSessionId, params);

            //Dispute parameter initialisation (if disabled on UI)
            for (DisputeParameter parameter : parameters) {
                if (!parameter.getEditable()){
                    parameter.setValueV(parameter.getValueV());
                    parameter.setValueN(parameter.getValueN());
                    parameter.setValueD(parameter.getValueD());
                }
            }
        } catch (Exception e) {
            parameters = null;
            FacesUtils.addMessageError(e.getMessage());
            logger.error("", e);
        }
    }

    public List<SelectItem> getNetworks(){
        return getDictUtils().getLov(LovConstants.VISA_OR_MASTERCARD);
    }
    public List<SelectItem> getCurrencies() {
        return CurrencyCache.getInstance().getAllCurrencies(curLang);
    }
    public List<DisputeParameter> getParameters() {
        if (parameters == null) {
            parameters = new ArrayList<DisputeParameter>();
        }
        return parameters;
    }

    public Integer getInstitution() {
        return institution;
    }
    public void setInstitution(Integer institution) {
        this.institution = institution;
    }

    public Integer getNetwork() {
        return network;
    }
    public void setNetwork(Integer network) {
        this.network = network;
    }
}
