package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.cmn.CmnParamValue;
import ru.bpc.sv2.cmn.CmnParameter;
import ru.bpc.sv2.cmn.CmnPrivConstants;
import ru.bpc.sv2.cmn.CmnStandard;
import ru.bpc.sv2.cmn.CmnVersion;
import ru.bpc.sv2.cmn.CmnVersionParameter;
import ru.bpc.sv2.cmn.Device;
import ru.bpc.sv2.cmn.ObjectStandard;
import ru.bpc.sv2.cmn.ObjectStandardVersion;
import ru.bpc.sv2.cmn.Profile;
import ru.bpc.sv2.cmn.ResponseCodeMapping;
import ru.bpc.sv2.cmn.StandardKeyTypeMap;
import ru.bpc.sv2.cmn.TcpIpDevice;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.AuditParamUtil;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.SQLException;
import java.util.List;

/**
 * Session Bean implementation class CommunicationDao
 */
public class CommunicationDao extends IbatisAware {


	@SuppressWarnings("unchecked")
	public ResponseCodeMapping[] getResponseCodesMappings(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMM_RESP_CODES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMM_RESP_CODES);
			List<ResponseCodeMapping> mappings = ssn.queryForList("cmn.get-resp-codes-mappings",
					convertQueryParams(params, limitation));
			return mappings.toArray(new ResponseCodeMapping[mappings.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getResponseCodesMappingsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMM_RESP_CODES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMM_RESP_CODES);
			return (Integer) ssn.queryForObject("cmn.get-resp-codes-mappings-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ResponseCodeMapping addResponseCodeMapping(Long userSessionId,
			ResponseCodeMapping mapping) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(mapping.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_COMM_RESP_CODES, paramArr);

			ssn.insert("cmn.add-resp-code-mapping", mapping);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(mapping.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ResponseCodeMapping) ssn.queryForObject("cmn.get-resp-codes-mappings",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ResponseCodeMapping editResponseCodeMapping(Long userSessionId,
			ResponseCodeMapping mapping) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(mapping.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_COMM_RESP_CODES, paramArr);

			ssn.update("cmn.edit-resp-code-mapping", mapping);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(mapping.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ResponseCodeMapping) ssn.queryForObject("cmn.get-resp-codes-mappings",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteResponseCodeMapping(Long userSessionId, ResponseCodeMapping mapping) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(mapping.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_COMM_RESP_CODES, paramArr);

			ssn.delete("cmn.delete-resp-code-mapping", mapping);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnStandard[] getCommStandards(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_STANDARD, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_STANDARD);
			List<CmnStandard> stds = ssn.queryForList("cmn.get-standards",
					convertQueryParams(params, limitation));
			return stds.toArray(new CmnStandard[stds.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCommStandardsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_STANDARD, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_STANDARD);
			return (Integer) ssn.queryForObject("cmn.get-standards-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnStandard[] getStandardsTree(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<CmnStandard> stds = ssn.queryForList("cmn.get-standards-tree", convertQueryParams(
					params, null, lang));
			return stds.toArray(new CmnStandard[stds.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CmnStandard addCommStandard(Long userSessionId, CmnStandard standard) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(standard.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_COMMUNIC_STANDARD, paramArr);

			ssn.insert("cmn.add-standard", standard);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(standard.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(standard.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CmnStandard) ssn
					.queryForObject("cmn.get-standards", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CmnStandard editCommStandard(Long userSessionId, CmnStandard standard) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(standard.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_COMMUNIC_STANDARD, paramArr);

			ssn.update("cmn.edit-standard", standard);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(standard.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(standard.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CmnStandard) ssn
					.queryForObject("cmn.get-standards", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCommStandard(Long userSessionId, CmnStandard standard) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(standard.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_COMMUNIC_STANDARD, paramArr);

			ssn.delete("cmn.delete-standard", standard);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnParameter[] getCmnParameters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER);
			List<CmnParameter> list = ssn.queryForList("cmn.get-cmn-parameters",
					convertQueryParams(params, limitation));
			return list.toArray(new CmnParameter[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCmnParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER);
			return (Integer) ssn.queryForObject("cmn.get-cmn-parameters-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CmnParameter addCmnParameter(Long userSessionId, CmnParameter parameter) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_COMMUNIC_PARAMETER, paramArr);

			ssn.insert("cmn.add-parameter", parameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(parameter.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(parameter.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CmnParameter) ssn.queryForObject("cmn.get-cmn-parameters",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CmnParameter editCmnParameter(Long userSessionId, CmnParameter parameter) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_COMMUNIC_PARAMETER, paramArr);

			ssn.update("cmn.edit-parameter", parameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(parameter.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(parameter.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CmnParameter) ssn.queryForObject("cmn.get-cmn-parameters",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCmnParameter(Long userSessionId, Integer parameterId) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(null);
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_COMMUNIC_PARAMETER, paramArr);

			ssn.delete("cmn.delete-parameter", parameterId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnVersion[] getCmnVersions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_CMN_STANDARD_VERSION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_CMN_STANDARD_VERSION);
			List<CmnVersion> list = ssn.queryForList("cmn.get-cmn-versions",
					convertQueryParams(params, limitation));
			return list.toArray(new CmnVersion[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCmnVersionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_CMN_STANDARD_VERSION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_CMN_STANDARD_VERSION);
			return (Integer) ssn.queryForObject("cmn.get-cmn-versions-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CmnVersion addCmnVersion(Long userSessionId, CmnVersion version) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(version.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_CMN_STANDARD_VERSION, paramArr);
			ssn.insert("cmn.add-version", version);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(version.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(version.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CmnVersion) ssn.queryForObject("cmn.get-cmn-versions",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CmnVersion editCmnVersion(Long userSessionId, CmnVersion version) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(version.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_CMN_STANDARD_VERSION, paramArr);
			ssn.update("cmn.edit-version", version);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(version.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(version.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CmnVersion) ssn.queryForObject("cmn.get-cmn-versions",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCmnVersion(Long userSessionId, CmnVersion version) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(version.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_CMN_STANDARD_VERSION, paramArr);
			ssn.delete("cmn.delete-version", version);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnVersionParameter[] getCmnVersionParameters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_CMN_VERSION_PARAMETER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_CMN_VERSION_PARAMETER);
			List<CmnVersion> list = ssn.queryForList("cmn.get-cmn-version-parameters",
					convertQueryParams(params, limitation));
			return list.toArray(new CmnVersionParameter[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCmnVersionParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_CMN_VERSION_PARAMETER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_CMN_VERSION_PARAMETER);
			return (Integer) ssn.queryForObject("cmn.get-cmn-version-parameters-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CmnVersionParameter addCmnVersionParameter(Long userSessionId,
			CmnVersionParameter parameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_CMN_VERSION_PARAMETER, paramArr);
			ssn.insert("cmn.add-version-parameter", parameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(parameter.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(parameter.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CmnVersionParameter) ssn.queryForObject("cmn.get-cmn-version-parameters",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCmnVersionParameter(Long userSessionId, CmnVersionParameter parameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(parameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_CMN_VERSION_PARAMETER, paramArr);
			ssn.delete("cmn.delete-version-parameter", parameter);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnParamValue[] getCmnParamValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			List<CmnParamValue> list = ssn.queryForList("cmn.get-cmn-param-values",
					convertQueryParams(params, limitation));
			return list.toArray(new CmnParamValue[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCmnParamValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			return (Integer) ssn.queryForObject("cmn.get-cmn-param-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setCmnParamValue(Long userSessionId, CmnParamValue value) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(value.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.SET_COMMUNIC_PARAMETER, paramArr);

			if (DataTypes.CHAR.equals(value.getDataType())) {
				ssn.update("cmn.set-param-char-value", value);
			} else if (DataTypes.NUMBER.equals(value.getDataType())) {
				ssn.update("cmn.set-param-num-value", value);
			} else if (DataTypes.DATE.equals(value.getDataType())) {
				ssn.update("cmn.set-param-date-value", value);
			} else if (DataTypes.CLOB.equals(value.getDataType())) {
				ssn.update("cmn.set-param-clob-value", value);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeParamValue(Long userSessionId, Integer id) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("cmn.remove-param-value", id);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnParamValue[] getVersionParamValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<CmnParamValue> list = ssn.queryForList("cmn.get-version-param-values",
					convertQueryParams(params));
			return list.toArray(new CmnParamValue[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getVersionParamValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (Integer) ssn.queryForObject("cmn.get-version-param-values-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public TcpIpDevice[] getTcpDevices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_DEVICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);
			List<TcpIpDevice> devices = ssn.queryForList("cmn.get-tcp-devices",
					convertQueryParams(params, limitation));
			return devices.toArray(new TcpIpDevice[devices.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getTcpDevicesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_DEVICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);
			return (Integer) ssn.queryForObject("cmn.get-tcp-devices-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public TcpIpDevice addTcpIpDevice(Long userSessionId, TcpIpDevice device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_COMMUNIC_DEVICE, paramArr);

			ssn.insert("cmn.add-device", device);
			ssn.insert("cmn.add-tcp-ip", device);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(device.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(device.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (TcpIpDevice) ssn.queryForObject("cmn.get-tcp-devices",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public TcpIpDevice editTcpIpDevice(Long userSessionId, TcpIpDevice device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_COMMUNIC_DEVICE, paramArr);

			ssn.update("cmn.edit-device", device);
			ssn.update("cmn.edit-tcp-ip", device);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(device.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(device.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (TcpIpDevice) ssn.queryForObject("cmn.get-tcp-devices",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteTcpIpDevice(Long userSessionId, TcpIpDevice device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_COMMUNIC_DEVICE, paramArr);

			ssn.delete("cmn.delete-tcp-ip", device);
			ssn.delete("cmn.delete-device", device);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void enableTcpIpDevice(Long userSessionId, TcpIpDevice device) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("cmn.enable-tcp-ip", device);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void enableDevice(Long userSessionId, Device device) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSession(userSessionId);

			ssn.delete("cmn.enable-device", device);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Profile[] getProfiles(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PROFILE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PROFILE);
			List<Profile> profiles = ssn.queryForList("cmn.get-profiles",
					convertQueryParams(params, limitation));
			return profiles.toArray(new Profile[profiles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getProfilesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PROFILE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PROFILE);
			return (Integer) ssn.queryForObject("cmn.get-profiles-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Profile addProfile(Long userSessionId, Profile profile) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(profile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_COMMUNIC_PROFILE, paramArr);

			ssn.insert("cmn.add-profile", profile);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(profile.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(profile.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Profile) ssn.queryForObject("cmn.get-profiles", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Profile addProfileExt(Long userSessionId, Profile profile, Terminal template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(profile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_COMMUNIC_PROFILE, paramArr);

			ssn.insert("cmn.add-profile", profile);

			template.setProfileId(profile.getId());
			ssn.insert("acquiring.add-terminal-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(profile.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(profile.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Profile) ssn.queryForObject("cmn.get-profiles", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Profile editProfile(Long userSessionId, Profile profile) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(profile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_COMMUNIC_PROFILE, paramArr);

			ssn.update("cmn.edit-profile", profile);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(profile.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(profile.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Profile) ssn.queryForObject("cmn.get-profiles", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Profile editProfileExt(Long userSessionId, Profile profile, Terminal template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(profile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_COMMUNIC_PROFILE, paramArr);

			ssn.update("cmn.edit-profile", profile);

			ssn.update("acquiring.modify-terminal-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(profile.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(profile.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Profile) ssn.queryForObject("cmn.get-profiles", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProfile(Long userSessionId, Profile profile) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(profile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_COMMUNIC_PROFILE, paramArr);

			ssn.delete("cmn.delete-profile", profile);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProfileExt(Long userSessionId, Profile profile, Terminal template) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(profile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_COMMUNIC_PROFILE, paramArr);

			ssn.delete("cmn.delete-profile", profile);

			ssn.delete("acquiring.remove-terminal-template", template.getId());
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public StandardKeyTypeMap addStandardKeyTypeMap(Long userSessionId,
			StandardKeyTypeMap standardKeyTypeMap) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(standardKeyTypeMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_CMN_KEY_TYPE, paramArr);

			ssn.insert("cmn.add-standard-key-type-map", standardKeyTypeMap);
			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(standardKeyTypeMap.getId().toString());

			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(standardKeyTypeMap.getLang().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (StandardKeyTypeMap) ssn.queryForObject("cmn.get-standard-key-type-maps",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public StandardKeyTypeMap editStandardKeyTypeMap(Long userSessionId,
			StandardKeyTypeMap standardKeyTypeMap) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(standardKeyTypeMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_CMN_KEY_TYPE, paramArr);

			ssn.update("cmn.modify-standard-key-type-map", standardKeyTypeMap);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(standardKeyTypeMap.getId().toString());

			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(standardKeyTypeMap.getLang().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (StandardKeyTypeMap) ssn.queryForObject("cmn.get-standard-key-type-maps",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public StandardKeyTypeMap[] getStandardKeyTypeMaps(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_CMN_KEY_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_CMN_KEY_TYPE);
			List<StandardKeyTypeMap> standardKeyTypeMaps = ssn.queryForList(
					"cmn.get-standard-key-type-maps", convertQueryParams(params, limitation));
			return standardKeyTypeMaps.toArray(new StandardKeyTypeMap[standardKeyTypeMaps.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getStandardKeyTypeMapsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_CMN_KEY_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_CMN_KEY_TYPE);
			return (Integer) ssn.queryForObject("cmn.get-standard-key-type-maps-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeStandardKeyTypeMap(Long userSessionId, StandardKeyTypeMap standardKeyTypeMap) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(standardKeyTypeMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_CMN_KEY_TYPE, paramArr);
			ssn.update("cmn.remove-standard-key-type-map", standardKeyTypeMap);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public Integer getStandardByNetworkId(Long userSessionId, Integer networkId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (Integer) ssn.queryForObject("cmn.get-standard-by-network", networkId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getStandardByDeviceId(Long userSessionId, Integer deviceId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (Integer) ssn.queryForObject("cmn.get-standard-by-device", deviceId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ObjectStandard[] getObjectStandards(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<ObjectStandard> stds = ssn.queryForList("cmn.get-object-standards",
					convertQueryParams(params));
			return stds.toArray(new ObjectStandard[stds.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getObjectStandardsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (Integer) ssn.queryForObject("cmn.get-object-standards-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    /**
     * Needs for adding standard to HSM Device
     * @param userSessionId
     * @param objectStandard
     * @return ObjectStandard
     */

    public ObjectStandard addObjectStandard(Long userSessionId, ObjectStandard objectStandard) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(objectStandard.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_CMN_STANDARD_VERSION, paramArr);
            ssn.insert("cmn.add-standard-object", objectStandard);

            Filter[] filters = new Filter[3];
            filters[0] = new Filter("standardId", objectStandard.getStandardId());
            filters[1] = new Filter("entityType", objectStandard.getEntityType());
            filters[2] = new Filter("objectId", objectStandard.getObjectId());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (ObjectStandard) ssn.queryForObject("cmn.get-standard-objects", convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void deleteObjectStandard(Long userSessionId, Integer id) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(null);
            ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_CMN_STANDARD_VERSION, paramArr);
            ssn.delete("cmn.remove-standard-object", id);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

	@SuppressWarnings("unchecked")
	public ObjectStandardVersion[] getObjectStandardVersions(Long userSessionId,
			SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_CMN_STANDARD_VERSION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_CMN_STANDARD_VERSION);
			List<ObjectStandardVersion> stds = ssn.queryForList("cmn.get-object-standard-versions",
					convertQueryParams(params, limitation, lang));
			return stds.toArray(new ObjectStandardVersion[stds.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getObjectStandardVersionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_CMN_STANDARD_VERSION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_CMN_STANDARD_VERSION);
			return (Integer) ssn.queryForObject("cmn.get-object-standard-versions-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ObjectStandardVersion[] getObjectStandardVersionsTree(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<ObjectStandardVersion> stds = ssn.queryForList(
					"cmn.get-object-standard-versions-tree", convertQueryParams(params));
			return stds.toArray(new ObjectStandardVersion[stds.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ObjectStandardVersion addObjectStandardVersion(Long userSessionId,
			ObjectStandardVersion standardObj) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(standardObj.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_CMN_STANDARD_VERSION, paramArr);
			ssn.insert("cmn.add-object-standard-version", standardObj);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(standardObj.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ObjectStandardVersion) ssn.queryForObject("cmn.get-object-standard-versions",
					convertQueryParams(params, null, standardObj.getLang()));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ObjectStandardVersion editObjectStandardVersion(Long userSessionId,
			ObjectStandardVersion standardObj) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(standardObj.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_CMN_STANDARD_VERSION, paramArr);
			ssn.update("cmn.modify-object-standard-version", standardObj);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(standardObj.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ObjectStandardVersion) ssn.queryForObject("cmn.get-object-standard-versions",
					convertQueryParams(params, null, standardObj.getLang()));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteObjectStandardVersion(Long userSessionId, Long id) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(null);
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_CMN_STANDARD_VERSION, paramArr);
			ssn.delete("cmn.remove-object-standard-version", id);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnParamValue[] getInterfaceVersionParamValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			List<CmnParamValue> list = ssn.queryForList("cmn.get-interface-version-param-values",
					convertQueryParams(params, limitation));
			return list.toArray(new CmnParamValue[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getInterfaceVersionParamValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			return (Integer) ssn.queryForObject("cmn.get-interface-version-param-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnParamValue[] getNetDeviceVersionParamValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			List<CmnParamValue> list = ssn.queryForList("cmn.get-net-device-version-param-values",
					convertQueryParams(params, limitation));
			return list.toArray(new CmnParamValue[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getNetDeviceVersionParamValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			return (Integer) ssn.queryForObject("cmn.get-net-device-version-param-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    @SuppressWarnings("unchecked")
    public CmnParamValue[] getHsmDeviceVersionParamValues(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
            List<CmnParamValue> list = ssn.queryForList("cmn.get-hsm-device-version-param-values",
                    convertQueryParams(params, limitation));
            return list.toArray(new CmnParamValue[list.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getHsmDeviceVersionParamValuesCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
            return (Integer) ssn.queryForObject("cmn.get-hsm-device-version-param-values-count",
                    convertQueryParams(params, limitation));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

	@SuppressWarnings("unchecked")
	public Device[] getDevices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_DEVICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);
			List<Device> devices = ssn.queryForList("cmn.get-devices", convertQueryParams(params, limitation));
			return devices.toArray(new Device[devices.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getDevicesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_DEVICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);
			return (Integer) ssn
					.queryForObject("cmn.get-devices-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Device addDevice(Long userSessionId, Device device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.ADD_COMMUNIC_DEVICE, paramArr);

			ssn.insert("cmn.add-device", device);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(device.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(device.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Device) ssn.queryForObject("cmn.get-all-devices", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Device editDevice(Long userSessionId, Device device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.MODIFY_COMMUNIC_DEVICE, paramArr);

			ssn.update("cmn.edit-device", device);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(device.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(device.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Device) ssn.queryForObject("cmn.get-devices", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteDevice(Long userSessionId, Device device) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.REMOVE_COMMUNIC_DEVICE, paramArr);

			ssn.delete("cmn.delete-device", device);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Device[] getAllDevices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_DEVICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);
			List<Device> devices = ssn.queryForList("cmn.get-all-devices",
					convertQueryParams(params, limitation));
			return devices.toArray(new Device[devices.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getAllDevicesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_DEVICE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_DEVICE);
			return (Integer) ssn.queryForObject("cmn.get-all-devices-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnParamValue[] getTerminalVersionParamValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			List<CmnParamValue> list = ssn.queryForList("cmn.get-terminal-version-param-values",
					convertQueryParams(params, limitation));
			return list.toArray(new CmnParamValue[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTerminalVersionParamValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			return (Integer) ssn.queryForObject("cmn.get-terminal-version-param-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CmnParamValue[] getAcqDeviceVersionParamValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			List<CmnParamValue> list = ssn.queryForList("cmn.get-acq-device-version-param-values",
					convertQueryParams(params, limitation));
			return list.toArray(new CmnParamValue[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAcqDeviceVersionParamValuesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CmnPrivConstants.VIEW_COMMUNIC_PARAMETER_VALUE);
			return (Integer) ssn.queryForObject("cmn.get-acq-device-version-param-values-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void moveVersionUp(Long userSessionId, CmnVersion version) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.delete("cmn.move-version-up", version);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
	

	public void moveVersionDown(Long userSessionId, CmnVersion version) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.delete("cmn.move-version-down", version);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}
}
