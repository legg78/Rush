package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;


import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.hsm.HsmConnection;
import ru.bpc.sv2.hsm.HsmDevice;
import ru.bpc.sv2.hsm.HsmDynamicConnection;
import ru.bpc.sv2.hsm.HsmLMK;
import ru.bpc.sv2.hsm.HsmPrivConstants;
import ru.bpc.sv2.hsm.HsmSelection;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class HsmDao
 */
public class HsmDao extends IbatisAware {

	@SuppressWarnings("unchecked")
	public HsmDevice[] getDevices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_DEVICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, HsmPrivConstants.VIEW_HSM_DEVICE);
			List<HsmDevice> devices = ssn.queryForList("hsm.get-devices",
			        convertQueryParams(params, limitation));
			return devices.toArray(new HsmDevice[devices.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDevicesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_DEVICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, HsmPrivConstants.VIEW_HSM_DEVICE);
			return (Integer) ssn.queryForObject("hsm.get-devices-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HsmDevice addDevice(Long userSessionId, HsmDevice device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.ADD_HSM_DEVICE, paramArr);
			ssn.insert("hsm.add-device", device);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(device.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(device.getId().toString());
			HsmConnection tcpConn = device.getHsmTcp();
			tcpConn.setDeviceId(device.getId());
			ssn.insert("hsm.add-tcpip", tcpConn);
			
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HsmDevice) ssn.queryForObject("hsm.get-devices",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HsmDevice editDeviceAndConnection(Long userSessionId, HsmDevice device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.MODIFY_HSM_DEVICE, paramArr);
			
			ssn.update("hsm.edit-tcpip", device.getHsmTcp());
			ssn.update("hsm.edit-device", device);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(device.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(device.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HsmDevice) ssn.queryForObject("hsm.get-devices",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HsmDevice editDevice(Long userSessionId, HsmDevice device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.MODIFY_HSM_DEVICE, paramArr);
			
			ssn.update("hsm.edit-device", device);
			
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(device.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(device.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HsmDevice) ssn.queryForObject("hsm.get-devices",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void deleteDevice(Long userSessionId, HsmDevice device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.REMOVE_HSM_DEVICE, paramArr);

			ssn.delete("hsm.delete-device", device);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public HsmDynamicConnection[] getDynamicConnections(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_TCP_IP, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, HsmPrivConstants.VIEW_HSM_TCP_IP);
			List<HsmDynamicConnection> conns = ssn.queryForList("hsm.get-hsm-dynamic-connections",
			        convertQueryParams(params, limitation));
			return conns.toArray(new HsmDynamicConnection[conns.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDynamicConnectionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_TCP_IP, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, HsmPrivConstants.VIEW_HSM_TCP_IP);
			return (Integer) ssn.queryForObject("hsm.get-hsm-dynamic-connections-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void addTCP(Long userSessionId, HsmConnection conn) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(conn.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.ADD_HSM_TCP_IP, paramArr);

			ssn.insert("hsm.add-tcpip", conn);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void editTCP(Long userSessionId, HsmConnection conn) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(conn.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.MODIFY_HSM_TCP_IPE, paramArr);

			ssn.update("hsm.edit-tcpip", conn);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteTCP(Long userSessionId, HsmConnection conn) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(conn.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.REMOVE_HSM_TCP_IP, paramArr);

			ssn.delete("hsm.delete-tcpip", conn);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public HsmSelection[] getHsmSelections(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_SELECTIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, HsmPrivConstants.VIEW_HSM_SELECTIONS);
			List<HsmSelection> selections = ssn.queryForList("hsm.get-hsm-selections",
			        convertQueryParams(params, limitation));
			return selections.toArray(new HsmSelection[selections.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getHsmSelectionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_SELECTIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, HsmPrivConstants.VIEW_HSM_SELECTIONS);
			return (Integer) ssn.queryForObject("hsm.get-hsm-selections-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HsmSelection addHsmSelection(Long userSessionId, HsmSelection selection) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(selection.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.ADD_HSM_SELECTION, paramArr);

			ssn.insert("hsm.add-hsm-selection", selection);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(selection.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(selection.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HsmSelection) ssn.queryForObject("hsm.get-hsm-selections",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HsmSelection modifyHsmSelection(Long userSessionId, HsmSelection selection) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(selection.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.MODIFY_HSM_SELECTION, paramArr);

			ssn.update("hsm.modify-hsm-selection", selection);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(selection.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(selection.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HsmSelection) ssn.queryForObject("hsm.get-hsm-selections",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeHsmSelection(Long userSessionId, HsmSelection selection) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(selection.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.REMOVE_HSM_SELECTION, paramArr);

			ssn.delete("hsm.remove-hsm-selection", selection);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public HsmLMK[] getHsmLMKs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_LMK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, HsmPrivConstants.VIEW_HSM_LMK);
			List<HsmLMK> lmks = ssn.queryForList("hsm.get-hsm-lmks",
			        convertQueryParams(params, limitation));
			return lmks.toArray(new HsmLMK[lmks.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getHsmLMKsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_LMK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, HsmPrivConstants.VIEW_HSM_LMK);
			return (Integer) ssn.queryForObject("hsm.get-hsm-lmks-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HsmLMK addHsmLMK(Long userSessionId, HsmLMK lmk) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(lmk.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.ADD_HSM_LMK, paramArr);

			ssn.insert("hsm.add-hsm-lmk", lmk);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(lmk.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(lmk.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HsmLMK) ssn.queryForObject("hsm.get-hsm-lmks",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HsmLMK modifyHsmLMK(Long userSessionId, HsmLMK lmk) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(lmk.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.MODIFY_HSM_LMK, paramArr);

			ssn.update("hsm.modify-hsm-lmk", lmk);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(lmk.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(lmk.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HsmLMK) ssn.queryForObject("hsm.get-hsm-lmks",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeHsmLMK(Long userSessionId, HsmLMK lmk) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(lmk.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.REMOVE_HSM_LMK, paramArr);

			ssn.delete("hsm.remove-hsm-lmk", lmk);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public HsmDevice[] getHsmLov(Long userSessionId, Integer instId, Integer agentId,
			String action) {
		SqlMapSession ssn = null;
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("instId", instId);
			map.put("agentId", agentId);
			map.put("action", action);
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, HsmPrivConstants.VIEW_HSM_LOV, paramArr);
			ssn.insert("hsm.get-hsm-lov", map);
			List<HsmDevice> hsms = (List<HsmDevice>) map.get("lov");
			if (hsms == null) {
				return new HsmDevice[0];
			}
			return hsms.toArray(new HsmDevice[hsms.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public HsmDevice[] getDevices(Long userSEssionId, String lang){
		SelectionParams params = new SelectionParams();
		params.setRowIndexEnd(-1);

		List<Filter> filtersList = new ArrayList<Filter>();
		Filter paramFilter = new Filter();
		paramFilter.setElement("lang");
		paramFilter.setValue(lang);
		filtersList.add(paramFilter);

		params.setFilters(filtersList.toArray(new Filter[filtersList.size()]));

		HsmDevice[] result = getDevices(userSEssionId, params);
		return result;
	}
}
