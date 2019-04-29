package ru.bpc.sv2.ui.acquiring;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.model.selection.SimpleSelection;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.issuing.Card;
import ru.bpc.sv2.logic.AcquiringDao;
import ru.bpc.sv2.ui.acm.MbContextMenu;
import ru.bpc.sv2.ui.context.ContextType;
import ru.bpc.sv2.ui.context.ContextTypeFactory;
import ru.bpc.sv2.ui.utils.*;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbMerchantCards")
public class MbMerchantCards extends AbstractBean {
    private static final long serialVersionUID = 1L;
    private static final Logger logger = Logger.getLogger("ACQUIRING");

    private final DaoDataListModel<Card> source;
    private final TableRowSelection<Card> selection;
    private Card activeCard;
    private Card filter;
    private ContextType ctxType;
    private String ctxItemEntityType;

    private AcquiringDao acquringDao = new AcquiringDao();

    public MbMerchantCards() {
        source = new DaoDataListModel<Card>(logger) {
            private static final long serialVersionUID = 1L;

            @Override
            protected List<Card> loadDaoListData(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return acquringDao.getMerchantCards(userSessionId, params);
                }
                return new ArrayList<Card>();
            }

            @Override
            protected int loadDaoDataSize(SelectionParams params) {
                if (searching) {
                    setFilters();
                    params.setFilters(filters);
                    return acquringDao.getMerchantCardsCount(userSessionId, params);
                }
                return 0;
            }
        };
        selection = new TableRowSelection<Card>(null, source);
    }

    @Override
    public void clearFilter() {
        filter = null;
        searching = false;
        clearState();
    }

    public Card getFilter() {
        if (filter == null) {
            filter = new Card();
        }
        return filter;
    }
    public void setFilter(Card filter) {
        this.filter = filter;
    }

    public DaoDataListModel<Card> getCards() {
        return source;
    }

    public SimpleSelection getSelection() {
        try {
            if (activeCard == null && source.getRowCount() > 0) {
                setFirstRowActive();
            } else if (activeCard != null && source.getRowCount() > 0) {
                SimpleSelection itemSelection = new SimpleSelection();
                itemSelection.addKey(activeCard.getModelId());
                selection.setWrappedSelection(itemSelection);
                activeCard = selection.getSingleSelection();
            }
        } catch (Exception e) {
            logger.error("", e);
            FacesUtils.addMessageError(e);
        }
        return selection.getWrappedSelection();
    }
    public void setSelection(SimpleSelection itemSelection) {
        selection.setWrappedSelection(itemSelection);
        activeCard = selection.getSingleSelection();
    }

    public void setFirstRowActive() {
        source.setRowIndex(0);
        SimpleSelection itemSelection = new SimpleSelection();
        activeCard = (Card) source.getRowData();
        itemSelection.addKey(activeCard.getModelId());
        selection.setWrappedSelection(itemSelection);
    }

    public void search() {
        clearState();
        searching = true;
    }

    public String getCtxItemEntityType() {
        return ctxItemEntityType;
    }
    public void setCtxItemEntityType() {
        String ctx = ManagedBeanWrapper.getManagedBean(MbContextMenu.class).getEntityType();
        if (ctx == null || !ctx.equals(ctxItemEntityType)) {
            ctxType = ContextTypeFactory.getInstance(ctx);
        }
        ctxItemEntityType = ctx;
    }

    public ContextType getCtxType() {
        Map<String, Object> map = new HashMap<String, Object>();
        if (ctxType != null && activeCard != null) {
            if (EntityNames.CARD.equals(ctxItemEntityType)) {
                if (activeCard.getModelId() != null) {
                    map.put("id", activeCard.getModelId());
                }
            } else if (EntityNames.CARDHOLDER.equals(ctxItemEntityType)) {
                if (activeCard.getCardholderId() != null) {
                    map.put("id", activeCard.getCardholderId());
                }
                if (activeCard.getInstId() != null) {
                    map.put("instId", activeCard.getInstId());
                }
                if (StringUtils.isNotEmpty(activeCard.getCardholderName())) {
                    map.put("cardholderName", activeCard.getCardholderName());
                }
                if (StringUtils.isNotEmpty(activeCard.getCardholderNumber())) {
                    map.put("cardholderNumber", activeCard.getCardholderNumber());
                }
            } else if (EntityNames.INSTITUTION.equals(ctxItemEntityType)) {
                if (activeCard.getInstId() != null) {
                    map.put("id", activeCard.getInstId());
                    map.put("instId", activeCard.getInstId());
                }
            } else if (EntityNames.PRODUCT.equals(ctxItemEntityType)) {
                map.put("id", activeCard.getProductId());
                map.put("instId", activeCard.getInstId());
                map.put("objectType", activeCard.getProductType());
                map.put("productType", activeCard.getProductType());
                map.put("productName", activeCard.getProductName());
                map.put("productNumber", activeCard.getProductNumber());
            } if (EntityNames.ACCOUNT.equals(ctxItemEntityType)) {
                if (activeCard.getAccountId() != null) {
                    map.put("id", activeCard.getAccountId());
                }
                if (activeCard.getInstId() != null) {
                    map.put("instId", activeCard.getInstId());
                }
                if (StringUtils.isNotEmpty(activeCard.getAccountNumber())) {
                    map.put("accountNumber", activeCard.getAccountNumber());
                }
            }
        }
        ctxType.setParams(map);
        return ctxType;
    }

    public boolean isForward() {
        return !ctxItemEntityType.equals(EntityNames.MERCHANT);
    }

    private void clearState() {
        activeCard = null;
        selection.clearSelection();
        source.flushCache();
    }

    private void setFilters() {
        filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", curLang));

        if (getFilter().getMerchantId() != null) {
            filters.add(Filter.create("merchantId", getFilter().getMerchantId()));
        }
        if (getFilter().getProductId() != null) {
            filters.add(Filter.create("productId", getFilter().getProductId()));
        }
        if (StringUtils.isNotEmpty(getFilter().getCardUid())) {
            filters.add(Filter.create("cardUid", getFilter().getCardUid().trim()));
        }
        if (StringUtils.isNotEmpty(getFilter().getMask())) {
            filters.add(Filter.create("cardMask", Filter.mask(getFilter().getMask())));
        }
        if (getFilter().getInstId() != null) {
            filters.add(Filter.create("instId", getFilter().getInstId()));
        }
        if (getFilter().getCardTypeId() != null) {
            filters.add(Filter.create("cardTypeId", getFilter().getCardTypeId()));
        }
    }
}
