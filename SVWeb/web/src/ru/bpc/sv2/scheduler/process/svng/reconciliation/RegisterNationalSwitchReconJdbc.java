package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import ru.bpc.sv.svxp.reconciliation.SettleOperationType;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.reconciliation.RcnConstants;
import ru.bpc.sv2.scheduler.process.svng.RegisterLoadJdbc;
import ru.bpc.sv2.utils.AuthOracleTypeNames;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.utils.SystemException;

import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class RegisterNationalSwitchReconJdbc extends RegisterLoadJdbc {
    public static final String OPERATION = "operation";
    public static final String SETTLEMENT = "settlement";

    public static final String SQL_REGISTER_OPERATION = "{call rcn_prc_import_pkg.process_host_batch(" +
                                                        "      i_oper_tab   => ? " +
                                                        "    , i_param_tab  => ? )}";

    private List<NationalSwitchReconRec> operations;
    private List<CommonParamRec> options;

    public RegisterNationalSwitchReconJdbc(Map<String, Object> params, Connection connect) throws SystemException {
        super(params, connect);
        operations = new ArrayList<NationalSwitchReconRec>();
        options = new ArrayList<CommonParamRec>();
    }

    public void insert(List<Filter> opts, List<SettleOperationType> rows) throws Exception {
        Integer l_file_inst_id = (Integer) null;
        for (Filter opt : opts) {
            options.add(new CommonParamRec(opt.getElement(), getConvertedValue(opt.getValue()), opt.getConditionRealValue()));
            if (opt.getElement() == "inst_id")
                l_file_inst_id = (Integer) getConvertedValue(opt.getValue());
        }
        options.add(new CommonParamRec("recon_type", RcnConstants.NATIONAL_SWITCH_RECON_TYPE, null));
        options.add(new CommonParamRec("msg_source", RcnConstants.MSG_SRC_NTSW_RECONCILIATION, null));

        for (SettleOperationType row : rows) {
            operations.add(new NationalSwitchReconRec(row, connect, l_file_inst_id));
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

    private NationalSwitchReconRec[] getHostReconciliationArray() {
        return operations.toArray(new NationalSwitchReconRec[operations.size()]);
    }

    private CommonParamRec[] getParamsRecs() {
        return options.toArray(new CommonParamRec[options.size()]);
    }
}
