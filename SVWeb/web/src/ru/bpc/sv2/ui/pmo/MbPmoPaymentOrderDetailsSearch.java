package ru.bpc.sv2.ui.pmo;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.PaymentOrdersDao;
import ru.bpc.sv2.pmo.PmoPaymentOrderDetail;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.List;

@ViewScoped
@ManagedBean(name = "MbPmoPaymentOrderDetailsSearch")
public class MbPmoPaymentOrderDetailsSearch extends AbstractSearchBean<PmoPaymentOrderDetail, PmoPaymentOrderDetail> {
    private static final Logger logger = Logger.getLogger("PAYMENT_ORDERS");

    private PaymentOrdersDao paymentOrdersDao = new PaymentOrdersDao();

    @Override
    protected PmoPaymentOrderDetail createFilter() {
        return new PmoPaymentOrderDetail();
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected PmoPaymentOrderDetail addItem(PmoPaymentOrderDetail item) {
        return null;
    }

    @Override
    protected PmoPaymentOrderDetail editItem(PmoPaymentOrderDetail item) {
        return null;
    }

    @Override
    protected void deleteItem(PmoPaymentOrderDetail item) {

    }

    @Override
    protected void initFilters(PmoPaymentOrderDetail filter, List<Filter> filters) {
        if (filter.getOrderId() != null) {
            filters.add(Filter.create("orderId", filter.getOrderId()));
        }
    }
    @Override
    protected List<PmoPaymentOrderDetail> getObjectList(Long userSessionId, SelectionParams params) {
        return paymentOrdersDao.getPaymentOrderDetails(userSessionId, params);
    }

    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return paymentOrdersDao.getPaymentOrderDetailsCount(userSessionId, params);
    }

}
