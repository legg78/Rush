package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import ru.bpc.sv.svxp.reconciliation.PaymentOrderType;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.scheduler.process.svng.RegisterLoadJdbc;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.SystemException;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class RegisterSrvpReconciliationJdbc extends RegisterLoadJdbc {
    public static final String ORDER = "payment_order";
    public static final String RECONCILIATION = "reconciliation";

    private static final String SQL_REGISTER_ORDERS = "{call rcn_prc_import_pkg.process_srvp_batch(" +
                                                      "      i_order_tab  => ? " +
                                                      "    , i_param_tab  => ? )}";

    private List<ReconciliationSrvpRec> orders;
    private List<CommonParamRec> options;

    public RegisterSrvpReconciliationJdbc(Map<String, Object> params, Connection connect) throws SystemException {
        super(params, connect);
        orders = new ArrayList<ReconciliationSrvpRec>();
        options = new ArrayList<CommonParamRec>();
    }

    public void insert(List<Filter> opts, List<PaymentOrderType> rows) throws Exception {
        for (Filter opt : opts) {
            options.add(new CommonParamRec(opt.getElement(), getConvertedValue(opt.getValue()), opt.getConditionRealValue()));
        }
        for (PaymentOrderType row : rows) {
            orders.add(new ReconciliationSrvpRec(row, connect));
        }
        execute();
    }

    @Override
    public void flush() throws Exception {
        if (orders.size() > 0) {
            execute();
        }
    }

    @Override
    public void execute() throws Exception {
        CallableStatement cstmt = null;
        try {
            ArrayDescriptor order_tab = ArrayDescriptor.createDescriptor(AuthOracleTypeNames.RCN_SRVP_RECON_MSG_TAB, connect);
            ArrayDescriptor param_tab = ArrayDescriptor.createDescriptor(AuthOracleTypeNames.COM_PARAM_MAP_TAB, connect);

            cstmt = connect.prepareCall(SQL_REGISTER_ORDERS);
            cstmt.setArray(1, new ARRAY(order_tab, connect, getSrvpReconciliationArray()));
            cstmt.setObject(2, new ARRAY(param_tab, connect, getParamsRecs()));
            cstmt.execute();

            orders.clear();
        } catch (Exception e) {
            logger.debug("", e);
            throw e;
        } finally {
            DBUtils.close(cstmt);
        }
    }

    private ReconciliationSrvpRec[] getSrvpReconciliationArray() {
        return orders.toArray(new ReconciliationSrvpRec[orders.size()]);
    }

    private CommonParamRec[] getParamsRecs() {
        return options.toArray(new CommonParamRec[options.size()]);
    }
}
