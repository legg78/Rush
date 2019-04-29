package ru.bpc.sv2.scheduler.process.svng.reconciliation;

import oracle.sql.ARRAY;
import oracle.sql.ArrayDescriptor;
import oracle.sql.CLOB;
import oracle.sql.OracleSQLOutput;
import oracle.xdb.XMLType;
import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv.svxp.reconciliation.ParameterType;
import ru.bpc.sv.svxp.reconciliation.PaymentOrderType;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.common.SQLDataRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.utils.AuthOracleTypeNames;

import javax.sql.rowset.serial.SerialArray;
import javax.xml.bind.DatatypeConverter;
import javax.xml.datatype.XMLGregorianCalendar;
import java.io.IOException;
import java.io.Writer;
import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.GregorianCalendar;
import java.util.List;

public class ReconciliationSrvpRec extends SQLDataRec {
    private PaymentOrderType paymentOrder;

    public ReconciliationSrvpRec(PaymentOrderType paymentOrder, Connection con) {
        this.paymentOrder = paymentOrder;
        setConnection(con);
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return AuthOracleTypeNames.RCN_SRVP_RECON_MSG_REC;
    }

    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        // id                      number(16)           01
        writeValueNull(stream);
        // recon_type              varchar2(8)          02
        writeValueNull(stream);
        // msg_source              varchar2(8)          03
        writeValueNull(stream);
        // recon_status            varchar2(8)          04
        writeValueNull(stream);
        // msg_date                date                 05
        writeValueNull(stream);
        // recon_date              date                 06
        writeValueNull(stream);
        // inst_id                 number(4)            07
        writeValueNull(stream);
        // split_hash              number(4)            08
        writeValueNull(stream);
        // order_id                number(16)           09
        writeValueN(stream, paymentOrder.getOrderId());
        // recon_msg_id            number(16)           10
        writeValueNull(stream);
        // payment_order_number    varchar2(200)        11
        writeValueV(stream, paymentOrder.getPaymentOrderNumber());
        // order_date              date                 12
        writeValueT(stream, paymentOrder.getOrderDate());
        // order_amount            number(22)           13
        writeValueN(stream, (paymentOrder.getOrderAmount() != null) ? paymentOrder.getOrderAmount().getAmountValue() : null);
        // order_currency          varchar2(3)          14
        writeValueV(stream, (paymentOrder.getOrderAmount() != null) ? paymentOrder.getOrderAmount().getCurrency() : null);
        // customer_id             number(12)           15
        writeValueNull(stream);
        // customer_number         varchar2(200)        16
        writeValueV(stream, paymentOrder.getCustomerNumber());
        // purpose_id              number(8)            17
        writeValueN(stream, paymentOrder.getPurposeId());
        // purpose_number          varchar2(200)        18
        writeValueV(stream, paymentOrder.getPurposeNumber());
        // provider_id             number(8)            19
        writeValueNull(stream);
        // provider_number         varchar2(200)        20
        writeValueV(stream, paymentOrder.getProviderNumber());
        // order_status            varchar2(8)          21
        writeValueV(stream, paymentOrder.getOrderStatus());
        // params                  com_param_map_tpt    22
        writeValueA(stream, paymentOrder.getParameter());
    }

    private void writeValueA(SQLOutput stream, List<ParameterType> table) throws SQLException {
        if (table == null || table.size() == 0) {
            stream.writeObject(null);
        } else {
            List<CommonParamRec> list = new ArrayList<CommonParamRec>(table.size());
            for (ParameterType param : table) {
                list.add(new CommonParamRec(param.getParamName(), getConvertedValue(param.getParamValue())));
            }
            ArrayDescriptor tab = ArrayDescriptor.createDescriptor(AuthOracleTypeNames.COM_PARAM_MAP_TAB, connection);
            stream.writeArray(new ARRAY(tab, connection, list.toArray(new CommonParamRec[list.size()])));
        }
    }
}
