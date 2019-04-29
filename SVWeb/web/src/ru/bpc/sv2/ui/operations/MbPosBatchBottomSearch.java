package ru.bpc.sv2.ui.operations;

/**
 * Created by Gasanov on 21.07.2016.
 */


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;

import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PosBatchDao;
import ru.bpc.sv2.operations.PosBatch;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;

/**
 * Manage Bean for List Payment Orders tab.
 */
@ViewScoped
@ManagedBean (name = "MbPosBatchBottomSearch")
public class MbPosBatchBottomSearch extends AbstractBean {
    private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

    PosBatchDao _posBatch = new PosBatchDao();

    private PosBatch _activePosBatch;

    public MbPosBatchBottomSearch() {
    }

    public PosBatch getActivePosBatch() {
        return _activePosBatch;
    }

    public void setActivePosBatch(PosBatch activePosBatch) {
        this._activePosBatch = activePosBatch;
    }

    public void clearFilter() {
        clearBean();
    }

    public void clearBean() {
        searching = false;
        curLang = userLang;
        _activePosBatch = null;
    }

    public PosBatch getOrder(Long operId) {
        _activePosBatch = null;
        if (operId != null) {
            SelectionParams params = new SelectionParams();
            Filter[] filters = new Filter[2];
            filters[0] = new Filter("lang", curLang);
            filters[1] = new Filter("operId", operId);

            params.setFilters(filters);
            try {
                PosBatch[] customers = _posBatch.getPosBatches(userSessionId, params);
                if (customers != null && customers.length > 0) {
                    _activePosBatch = customers[0];
                }
            } catch (Exception e) {
                logger.error("", e);
                FacesUtils.addMessageError(e);
                _activePosBatch = null;
            }
        }
        return _activePosBatch;
    }
}
