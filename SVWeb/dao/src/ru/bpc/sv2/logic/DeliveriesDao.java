package ru.bpc.sv2.logic;

/**
 * Created by Viktorov on 21.02.2017.
 */


import java.sql.SQLException;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.logic.utility.db.DataAccessException;


import org.apache.log4j.Logger;

import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.deliveries.Delivery;
import ru.bpc.sv2.deliveries.DeliveryAmount;
import ru.bpc.sv2.deliveries.DeliveryPrivConstants;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

@SuppressWarnings("unchecked")
public class DeliveriesDao extends IbatisAware {
    private static final Logger logger = Logger.getLogger("ISSUING");

    @SuppressWarnings("unchecked")
    public Delivery[] getDeliveries(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : DeliveryPrivConstants.VIEW_DELIVERY, paramArr);

            String limitation = CommonController.getLimitationByPriv(ssn,
                    params.getPrivilege()!=null ? params.getPrivilege(): DeliveryPrivConstants.VIEW_DELIVERY);
            List<Delivery> accs = ssn.queryForList("deliveries.get-deliveries", convertQueryParams(
                    params, limitation));
            return accs.toArray(new Delivery[accs.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    public int getDeliveriesCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : DeliveryPrivConstants.VIEW_DELIVERY, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                    params.getPrivilege()!=null ? params.getPrivilege() : DeliveryPrivConstants.VIEW_DELIVERY);
            return (Integer) ssn.queryForObject("deliveries.get-deliveries-count",
                    convertQueryParams(params, limitation));
        } catch (SQLException e) {
            logger.error("", e);
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public List<DeliveryAmount> getStatistics(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, params.getPrivilege()!=null ? params.getPrivilege() : DeliveryPrivConstants.VIEW_DELIVERY_STATISTICS, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                    params.getPrivilege()!=null ? params.getPrivilege() : DeliveryPrivConstants.VIEW_DELIVERY_STATISTICS);
            List<DeliveryAmount> amounts = ssn.queryForList("deliveries.get-statistics",
                    convertQueryParams(params, limitation));
            return amounts;
        } catch (SQLException e) {
            logger.error("", e);
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public void modifyDeliveryStatus(Long userSessionId, Long[] instanceIds, String deliveryStatus){
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("instanceIdList", instanceIds);
        map.put("deliveryStatus", deliveryStatus);
        map.put("eventDate", new Date());
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSession(userSessionId);
            ssn.update("deliveries.modify-delivery-status", map);
        } catch (SQLException e) {
            logger.error("", e);
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }

    }


    public void modifyDeliveryRefNum(Long userSessionId, Long[] instanceIds, String deliveryRefNum, Integer instId, Integer agentId, Integer cardTypeId){
        Map<String, Object> map = new HashMap<String, Object>();
        map.put("instId", instId);
        map.put("agentId", agentId);
        map.put("cardTypeId", cardTypeId);
        map.put("instanceIdList", instanceIds);
        map.put("deliveryRefNum", deliveryRefNum);
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSession(userSessionId);
            ssn.update("deliveries.update-delivery-ref-number", map);
        } catch (SQLException e) {
            logger.error("", e);
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }

    }
}
