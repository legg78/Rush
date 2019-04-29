package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import ru.bpc.sv.svxp.reconciliation.HostOperationType;
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

public class RegisterHostReconciliationJdbc extends RegisterLoadJdbc {
    public static final String OPERATION = "operation";
    public static final String RECONCILIATION = "reconciliation";

    public static final String SQL_REGISTER_OPERATION = "{call rcn_prc_import_pkg.process_host_batch(" +
                                                        "      i_oper_tab   => ? " +
                                                        "    , i_param_tab  => ? )}";

    private List<HostReconciliationRec> operations;
    private List<CommonParamRec> options;

    public RegisterHostReconciliationJdbc(Map<String, Object> params, Connection connect) throws SystemException {
        super(params, connect);
        operations = new ArrayList<HostReconciliationRec>();
        options = new ArrayList<CommonParamRec>();
    }

    public void insert(List<Filter> opts, List<HostOperationType> rows) throws Exception {
        for (Filter opt : opts) {
            options.add(new CommonParamRec(opt.getElement(), getConvertedValue(opt.getValue()), opt.getConditionRealValue()));
        }
        for (HostOperationType row : rows) {
            operations.add(new HostReconciliationRec(row, connect));
        }
        execute();
    }

    @Override
    public void flush() throws Exception {
        if (operations.size() > 0) {
            execute();
        }
    }

    @Override
    public void execute() throws Exception {
        CallableStatement cstmt = null;
        try {
            ArrayDescriptor oper_tab = ArrayDescriptor.createDescriptor(AuthOracleTypeNames.RCN_HOST_RECON_MSG_TAB, connect);
            ArrayDescriptor param_tab = ArrayDescriptor.createDescriptor(AuthOracleTypeNames.COM_PARAM_MAP_TAB, connect);

            cstmt = connect.prepareCall(SQL_REGISTER_OPERATION);
            cstmt.setArray(1, new ARRAY(oper_tab, connect, getHostReconciliationArray()));
            cstmt.setObject(2, new ARRAY(param_tab, connect, getParamsRecs()));
            cstmt.execute();

            operations.clear();
        } finally {
            DBUtils.close(cstmt);
        }
    }

    private HostReconciliationRec[] getHostReconciliationArray() {
        return operations.toArray(new HostReconciliationRec[operations.size()]);
    }

    private CommonParamRec[] getParamsRecs() {
        return options.toArray(new CommonParamRec[options.size()]);
    }
}
