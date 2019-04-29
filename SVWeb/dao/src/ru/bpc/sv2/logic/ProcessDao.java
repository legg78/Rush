package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.io.IOUtils;
import org.apache.commons.io.input.ReaderInputStream;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.constants.settings.LevelNames;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.process.*;
import ru.bpc.sv2.schedule.ScheduledTask;
import ru.bpc.sv2.security.RsaKey;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.utils.*;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.io.File;
import java.io.InputStream;
import java.io.PrintWriter;
import java.nio.charset.Charset;
import java.sql.*;
import java.util.*;
import java.util.Date;
import java.util.regex.Pattern;

/**
 * Session Bean implementation class Cycles
 */
@SuppressWarnings("unchecked")
public class ProcessDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("PROCESSES");


	public List<ProcessFileInfo> getProcessFilesInfo(Long userSessionId, Integer processId,
													 Integer containerId) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> params=new HashMap<String, Object>();
			params.put("processId", Long.valueOf(processId));
			params.put("containerId", Long.valueOf(containerId));
			List<ProcessFileInfo> files = ssn.queryForList("process.get-file-info", params);
			for( ProcessFileInfo f : files ){
				f.setDirectoryPath(resolvePath(f.getDirectoryPath(), userSessionId));
			}
			return files;
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessGroup[] getProcessGroups(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS_GROUP, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS_GROUP);
			List<ProcessGroup> roles = ssn.queryForList("process.get-process-groups", convertQueryParams(params, limitation));

			return roles.toArray(new ProcessGroup[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessGroupsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS_GROUP, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS_GROUP);
			return (Integer) ssn.queryForObject("process.get-process-groups-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessBO[] getProcesses(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS);
			List<ProcessBO> roles = ssn.queryForList("process.get-processes", convertQueryParams(params, limitation));

			return roles.toArray(new ProcessBO[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS);
			return (Integer) ssn.queryForObject("process.get-processes-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessBO[] getContainers(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_CONTAINER, paramArr);

			List<ProcessBO> roles;

			roles = ssn.queryForList("process.get-containers", convertQueryParams(params));

			return roles.toArray(new ProcessBO[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContainersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_CONTAINER, paramArr);

			return (Integer) ssn.queryForObject("process.get-containers-count",
												convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessBO[] getContainersAll(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_CONTAINER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_CONTAINER);
			List<ProcessBO> roles = ssn.queryForList("process.get-containers-all", convertQueryParams(params, limitation));

			return roles.toArray(new ProcessBO[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContainersAllCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_CONTAINER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_CONTAINER);
			return (Integer) ssn.queryForObject("process.get-containers-all-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessBO[] getProcessesByGroup(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS);
			List<ProcessBO> prcs = ssn.queryForList("process.get-processes-by-group", convertQueryParams(params, limitation));

			return prcs.toArray(new ProcessBO[prcs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessesByGroupCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS);
			return (Integer) ssn.queryForObject("process.get-processes-by-group-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessBO[] getProcessesByContainer(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS);
			List<ProcessBO> prcs = ssn.queryForList("process.get-processes-by-container",
													convertQueryParams(params, limitation));

			return prcs.toArray(new ProcessBO[prcs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessesByContainerCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS);
			return (Integer) ssn.queryForObject("process.get-processes-by-container-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessBO[] getProcessesByContainerHier(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);

			List<ProcessBO> prcs;

			prcs = ssn.queryForList("process.get-processes-by-container-hier",
									convertQueryParams(params));

			return prcs.toArray(new ProcessBO[prcs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addProcessToGroup(Long userSessionId, Integer groupId, Integer processId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			HashMap<String, Integer> map = new HashMap<String, Integer>();
			map.put("groupId", groupId);
			map.put("processId", processId);
			ssn.insert("process.add-process-to-group", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addProcessesToGroup(Long userSessionId, Integer groupId, ProcessBO[] processes) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			for (ProcessBO process : processes) {
				HashMap<String, Integer> map = new HashMap<String, Integer>();
				map.put("groupId", groupId);
				map.put("processId", process.getId());
				ssn.insert("process.add-process-to-group", map);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcessFromGroup(Long userSessionId, Integer groupBindId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.insert("process.remove-procee-from-group", groupBindId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcessesFromGroup(Long userSessionId, ProcessBO[] processes) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			for (ProcessBO process : processes) {
				ssn.delete("process.remove-process-from-group", process.getGroupBindId());
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessGroup addProcessGroup(Long userSessionId, ProcessGroup group) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(group.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.CREATE_GROUP, paramArr);
			ssn.insert("process.add-process-group", group);

			return group;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public ProcessGroup modifyProcessGroup(Long userSessionId, ProcessGroup group) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(group.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_GROUP, paramArr);
			ssn.insert("process.modify-process-group", group);

			return group;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcessGroup(Long userSessionId, ProcessGroup group) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(group.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.REMOVE_GROUP, paramArr);
			ssn.insert("process.remove-process-group", group);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessBO addProcess(Long userSessionId, ProcessBO process) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(process.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_PROCESS, paramArr);
			ssn.insert("process.add-process", process);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(process.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(process.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (process.isContainer()) {
				return (ProcessBO) ssn.queryForObject("process.get-containers-all",
													  convertQueryParams(params));
			} else {
				return (ProcessBO) ssn.queryForObject("process.get-processes",
													  convertQueryParams(params));
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessBO modifyProcess(Long userSessionId, ProcessBO process) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(process.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_PROCESS, paramArr);
			ssn.insert("process.modify-process", process);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(process.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(process.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			if (process.isContainer()) {
				return (ProcessBO) ssn.queryForObject("process.get-containers-all",
													  convertQueryParams(params));
			} else {
				return (ProcessBO) ssn.queryForObject("process.get-processes",
													  convertQueryParams(params));
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcess(Long userSessionId, ProcessBO process) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(process.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.REMOVE_PROCESS, paramArr);
			ssn.delete("process.remove-process", process);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessParameter[] getProcessParams(Long userSessionId, SelectionParams params,
											   boolean containerProcessParams) {
		SqlMapSession ssn = null;
		try {
			List<ProcessParameter> procParams;
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			if (containerProcessParams) {
				ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_CONTAINER_PROCESS, paramArr);
				String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_CONTAINER_PROCESS);
				procParams = ssn.queryForList("process.get-container-process-params",
											  convertQueryParams(params, limitation));
			} else {
				ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PARAM_PRC, paramArr);
				String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PARAM_PRC);
				procParams = ssn.queryForList("process.get-process-params",
											  convertQueryParams(params, limitation));
			}
			return procParams.toArray(new ProcessParameter[procParams.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessParameter[] getContainerLaunchParams(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_CONTAINER_PROCESS, paramArr);

			List<ProcessParameter> procParams = ssn.queryForList(
					"process.get-container-launch-params", convertQueryParams(params));

			return procParams.toArray(new ProcessParameter[procParams.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContainerLaunchParamsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_CONTAINER_PROCESS, paramArr);
			return (Integer) ssn.queryForObject("process.get-container-launch-params-count",
												convertQueryParams(params));

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessParameter[] getContainerParams(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<ProcessParameter> procParams = ssn.queryForList("process.get-container-params",
																 convertQueryParams(params));

			return procParams.toArray(new ProcessParameter[procParams.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContainerParamsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return (Integer) ssn.queryForObject("process.get-container-params-count",
												convertQueryParams(params));

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Map<String, Object> getProcessParamsMap(Long userSessionId, Integer processId,
												   Integer containerId) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}

			SelectionParams params = new SelectionParams();
			params.setRowIndexEnd(-1);

			List<Filter> filters = new ArrayList<Filter>();
			Filter filter = new Filter();
			filter.setElement("processId");
			filter.setValue(processId.toString());
			filters.add(filter);

			filter = new Filter();
			filter.setElement("containerBindId");
			filter.setValue(containerId.toString());
			filters.add(filter);

			params.setFilters(filters.toArray(new Filter[filters.size()]));

			Map<String, Object> map = new HashMap<String, Object>();
			List<ProcessParameter> procParams = ssn.queryForList(
					"process.get-container-process-params", convertQueryParams(params));

			for (ProcessParameter param : procParams) {
				map.put(param.getSystemName(), param.getValue());
			}
			return map;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessParamsCount(Long userSessionId, SelectionParams params,
									 boolean containerProcessParams) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			if (containerProcessParams) {
				ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_CONTAINER_PROCESS, paramArr);
				String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_CONTAINER_PROCESS);
				return (Integer) ssn.queryForObject("process.get-container-process-params-count",
													convertQueryParams(params, limitation));
			} else {
				ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PARAM_PRC, paramArr);
				String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PARAM_PRC);
				return (Integer) ssn.queryForObject("process.get-process-params-count",
													convertQueryParams(params, limitation));
			}

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void setProcessParam(Long userSessionId, ProcessParameter param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.SET_PARAMETER_VALUE, paramArr);
			if (!param.isFormat()) {
				param.setValueV((String) param.getValue());
				ssn.update("process.change-prc-attr_v", param);
			} else if (param.getDataType().equals(DataTypes.CHAR)) {
				ssn.update("process.change-prc-attr_v", param);
			} else if (param.getDataType().equals(DataTypes.NUMBER)) {
				ssn.update("process.change-prc-attr_n", param);
			} else if (param.getDataType().equals(DataTypes.DATE)) {
				ssn.update("process.change-prc-attr_d", param);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void removePrcAttr(Long userSessionId, ProcessParameter param) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("process.remove-prc-attr", param);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public ProcessParameter addParam(Long userSessionId, ProcessParameter param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_PARAM, paramArr);
			param.setForce(false);
			ssn.update("process.add-param", param);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(param.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(param.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessParameter) ssn.queryForObject("process.get-parameters",
														 convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public ProcessParameter modifyParam(Long userSessionId, ProcessParameter param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_PARAM, paramArr);
			param.setForce(true);
			ssn.update("process.modify-param", param);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(param.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(param.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessParameter) ssn.queryForObject("process.get-parameters",
														 convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void removeParam(Long userSessionId, ProcessParameter param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.REMOVE_PARAM, paramArr);
			if (param.getId() != null)
				ssn.update("process.remove-param", param.getId());

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public ProcessParameter addParamPrc(Long userSessionId, ProcessParameter param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_PARAM_PRC, paramArr);
			param.setForce(false);
			ssn.update("process.add-process-parameter", param);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("relationId");
			filters[0].setValue(param.getPrcParamId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(param.getLang());
			filters[2] = new Filter();
			filters[2].setElement("processId");
			filters[2].setValue(param.getProcessId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessParameter) ssn.queryForObject("process.get-process-params",
														 convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public Boolean allowProcessParameterModify(Long userSessionId, final Integer processId) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> params = new HashMap<String, Object>(2);
				params.put("processId", processId);
				ssn.update("process.allow-process-parameter-modify", params);
				return (Boolean)params.get("result");
			}
		});
	}

	public void modifyProcessParameterDesc(Long userSessionId, final ProcessParameter param) {
		executeWithSession(userSessionId, ProcessPrivConstants.MODIFY_PARAM_PRC, logger, new IbatisSessionCallback<Void>() {
			@Override
			public Void doInSession(SqlMapSession ssn) throws Exception {
				ssn.update("process.modify-process-parameter-desc", param);
				return null;
			}
		});
	}

	public ProcessParameter modifyParamPrc(Long userSessionId, ProcessParameter param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_PARAM_PRC, paramArr);
			param.setForce(true);
			ssn.update("process.modify-process-parameter", param);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("paramId");
			filters[0].setValue(param.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(param.getLang());
			filters[2] = new Filter();
			filters[2].setElement("processId");
			filters[2].setValue(param.getProcessId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessParameter) ssn.queryForObject("process.get-process-params",
														 convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public void removeParamPrc(Long userSessionId, ProcessParameter param) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(param.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.REMOVE_PARAM_PRC, paramArr);

			ssn.update("process.remove-process-parameter", param.getPrcParamId());

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessBO addProcessToContainer(Long userSessionId, ProcessBO prc) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(prc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_PRC_TO_CONTAINER, paramArr);

			ssn.insert("process.add-prc-to-container", prc);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("containerBindId");
			filters[0].setValue(prc.getContainerBindId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(prc.getLang());
			filters[2] = new Filter();
			filters[2].setElement("containerId");
			filters[2].setValue(prc.getContainerId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessBO) ssn.queryForObject("process.get-processes-by-container",
												  convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessBO modifyContainerProcess(Long userSessionId, ProcessBO prc) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(prc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_PRC_TO_CONTAINER, paramArr);
			prc.setForce(true);
			ssn.insert("process.add-prc-to-container", prc);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("containerBindId");
			filters[0].setValue(prc.getContainerBindId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(prc.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessBO) ssn.queryForObject("process.get-processes-by-container",
												  convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcessFromContainer(Long userSessionId, ProcessBO prc) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(prc.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.REMOVE_PRC_FROM_CONTAINER, paramArr);
			ssn.insert("process.remove-prc-from-container", prc.getContainerBindId());
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessParameter[] getParameters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PARAM, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PARAM);
			List<ProcessParameter> procParams = ssn.queryForList("process.get-parameters",
																 convertQueryParams(params, limitation));
			return procParams.toArray(new ProcessParameter[procParams.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PARAM, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PARAM);
			return (Integer) ssn.queryForObject("process.get-parameters-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessParameter[] getParametersNotAssignedToProcess(Long userSessionId,
																SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PARAM, paramArr);

			List<ProcessParameter> procParams = ssn.queryForList(
					"process.get-parameters-not-assigned-to-process", convertQueryParams(params));
			return procParams.toArray(new ProcessParameter[procParams.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getParametersNotAssignedToProcessCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PARAM, paramArr);
			return (Integer) ssn.queryForObject(
					"process.get-parameters-not-assigned-to-process-count",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ScheduledTask[] getSchedulerTasks(SelectionParams params) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<ScheduledTask> tasks = ssn.queryForList("process.get-tasks",
														 convertQueryParams(params));
			return tasks.toArray(new ScheduledTask[tasks.size()]);
		} catch (SQLException e) {
			if (e.getCause() != null && e.getCause().getCause() instanceof UserException){
				throw (UserException) e.getCause().getCause();
			} else {
				throw createDaoException(e);
			}
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ScheduledTask[] getTasks(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_TASK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_TASK);
			List<ScheduledTask> tasks = ssn.queryForList("process.get-tasks",
														 convertQueryParams(params, limitation));
			return tasks.toArray(new ScheduledTask[tasks.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getTasksCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_TASK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_TASK);
			return (Integer) ssn.queryForObject("process.get-tasks-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteTasks(Long userSessionId, ScheduledTask[] tasks) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			for (ScheduledTask task : tasks) {
				ssn.insert("process.remove-task", task.getId());
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteTask(Long userSessionId, Integer taskId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.insert("process.remove-task", taskId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ScheduledTask createTask(Long userSessionId, ScheduledTask task) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(task.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_TASK, paramArr);
			if (task.getPrcType() == null)
				task.setPrcType("");

			ssn.insert("process.add-task", task);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(task.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(task.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ScheduledTask) ssn.queryForObject("process.get-tasks",
													  convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ScheduledTask modifyTask(Long userSessionId, ScheduledTask task) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(task.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_TASK, paramArr);
			ssn.insert("process.modify-task", task);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(task.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(task.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ScheduledTask) ssn.queryForObject("process.get-tasks",
													  convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProgressBar[] getProgressBars(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			List<ProgressBar> bars = ssn.queryForList("process.get-progress-bars", convertQueryParams(params));

			return bars.toArray(new ProgressBar[bars.size()]);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessFileAttribute[] getFileAttributes(final Long userSessionId, final SelectionParams params, boolean isUserMode) {
		final String privilege = isUserMode ? ProcessPrivConstants.VIEW_FILE_ATTRIBUTE : null;
		return executeWithSession(userSessionId,
								  privilege,
								  params,
								  logger,
								  new IbatisSessionCallback<ProcessFileAttribute[]>() {
			@Override
			public ProcessFileAttribute[] doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, privilege);
				List<ProcessFileAttribute> fileAttrs = ssn.queryForList("process.get-file-attributes", convertQueryParams(params, limitation));
				for (ProcessFileAttribute fa : fileAttrs) {
					fa.setLocation(resolvePath(fa.getLocation(), userSessionId)); // resolve ROOT_DIR
				}
				return fileAttrs.toArray(new ProcessFileAttribute[fileAttrs.size()]);
			}
		});
	}


	public int getFileAttributesCount(Long userSessionId, final SelectionParams params, boolean isUserMode) {
		final String privilege = isUserMode ? ProcessPrivConstants.VIEW_FILE_ATTRIBUTE : null;
		return executeWithSession(userSessionId,
								  privilege,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				String limitation = CommonController.getLimitationByPriv(ssn, privilege);
				Object count = ssn.queryForObject("process.get-file-attributes-count", convertQueryParams(params, limitation));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}


	public ProcessFileAttribute addFileAttribute(Long userSessionId,
												 ProcessFileAttribute fileAttribute,
												 String lang,
												 String fileEncryptionKey) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fileAttribute.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_FILE_ATTRIBUTE, paramArr);
			ssn.insert("process.add-file-attribute", fileAttribute);

			if (fileEncryptionKey != null) {
				RsaKey rsaKey = new RsaKey();
				rsaKey.setPrivateKey(fileEncryptionKey);
				rsaKey.setEntityType(EntityNames.FILE_ATTRIBUTE);
				rsaKey.setObjectId(fileAttribute.getId());
				ssn.insert("sec.set-rsa-keypair", rsaKey);
			}

			List<Filter> filters = new ArrayList<Filter>(2);
			filters.add(Filter.create("id", fileAttribute.getId().toString()));
			filters.add(Filter.create("lang", lang));
			SelectionParams params = new SelectionParams(filters);

			return (ProcessFileAttribute) ssn.queryForObject("process.get-file-attributes", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessFileAttribute modifyFileAttribute(Long userSessionId,
													ProcessFileAttribute fileAttribute,
													String lang,
													String fileEncryptionKey) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fileAttribute.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_FILE_ATTRIBUTE, paramArr);
			ssn.insert("process.modify-file-attribute", fileAttribute);

			if (fileEncryptionKey != null) {
				RsaKey rsaKey = new RsaKey();
				rsaKey.setPrivateKey(fileEncryptionKey);
				rsaKey.setEntityType(EntityNames.FILE_ATTRIBUTE);
				rsaKey.setObjectId(fileAttribute.getId());
				if (fileAttribute.getFileEncryptionKeyExists()) {
					Filter[] filters = new Filter[2];
					filters[0] = new Filter("objectId", fileAttribute.getId());
					filters[1] = new Filter("entityType", EntityNames.FILE_ATTRIBUTE);
					SelectionParams params = new SelectionParams(filters);

					List<RsaKey> keys = ssn.queryForList("sec.get-rsa-keys", convertQueryParams(params));
					if (keys.size() > 0) {
						rsaKey.setId(keys.get(0).getId());
						rsaKey.setSeqnum(keys.get(0).getSeqnum());

						ssn.update("sec.remove-rsa-keypair", rsaKey);

						rsaKey.setId(null);
						rsaKey.setSeqnum(null);
					}
				}
				ssn.insert("sec.set-rsa-keypair", rsaKey);
			}

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(fileAttribute.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessFileAttribute) ssn.queryForObject("process.get-file-attributes",
															 convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteFileAttribute(Long userSessionId, ProcessFileAttribute fileAttribute) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(fileAttribute.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.REMOVE_FILE_ATTRIBUTE, paramArr);
			ssn.delete("process.remove-file-attribute", fileAttribute.getId());
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessSession[] getProcessSessions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_SESSION, paramArr);
			List<ProcessSession> sessions = ssn.queryForList("process.get-sessions-hier",
															 convertQueryParams(params));
			// resolve ROOT_DIR
			for (ProcessSession s : sessions) {
				s.setLocation(resolvePath(s.getLocation(), userSessionId));
			}

			return sessions.toArray(new ProcessSession[sessions.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessSession[] getProcessSessionsWithParams(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_SESSION, paramArr);
			List<ProcessSession> sessions = ssn.queryForList("process.get-sessions-hier-with-params",
															 convertQueryParams(params));
			// resolve ROOT_DIR
			for (ProcessSession s : sessions) {
				s.setLocation(resolvePath(s.getLocation(), userSessionId));
			}

			return sessions.toArray(new ProcessSession[sessions.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessSessionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_SESSION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_SESSION);
			return (Integer) ssn.queryForObject("process.get-sessions-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessStat[] getProcessStat(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS_STAT, paramArr);
			List<ProcessStat> traces = ssn.queryForList("process.get-stat",
														convertQueryParams(params));
			return traces.toArray(new ProcessStat[traces.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessStatCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS_STAT, paramArr);
			return (Integer) ssn.queryForObject("process.get-stat-count",
												convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessFile[] getProcessFiles(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS_FILE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS_FILE);
			List<ProcessFile> processFiles = ssn
					.queryForList("process.get-process-files", convertQueryParams(params, limitation));

			return processFiles.toArray(new ProcessFile[processFiles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessFilesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS_FILE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS_FILE);
			return (Integer) ssn.queryForObject("process.get-process-files-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessFile addProcessFile(Long userSessionId, ProcessFile processFile) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(processFile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_FILE, paramArr);
			ssn.insert("process.add-process-file", processFile);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(processFile.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(processFile.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessFile) ssn.queryForObject("process.get-process-files",
													convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessFile modifyProcessFile(Long userSessionId, ProcessFile processFile) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(processFile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_FILE, paramArr);
			ssn.insert("process.modify-process-file", processFile);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(processFile.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(processFile.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ProcessFile) ssn.queryForObject("process.get-process-files",
													convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteProcessFile(Long userSessionId, ProcessFile processFile) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(processFile.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.DELETE_FILE, paramArr);
			ssn.delete("process.remove-process-file", processFile.getId());
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProgressBar getProgressBar(Long userSessionId, Long sessionId, Integer threadNum) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("sessionId", sessionId);
			map.put("threadNum", threadNum);
			return (ProgressBar) ssn.queryForObject("process.get-progress-bars", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProgressBarValue(Long userSessionId, Long sessionId, Integer threadNum) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("sessionId", sessionId);
			map.put("threadNum", threadNum);
			return (Integer) ssn.queryForObject("process.get-progress-bar-value", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProgressBarMap getProgressBarValue1(Long userSessionId, Long sessionId, Integer threadNum) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("sessionId", sessionId);
			map.put("threadNum", threadNum);
			return (ProgressBarMap) ssn.queryForObject("process.get-progress-bar-value1", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getParallelDegree() {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			return (Integer) ssn.queryForObject("process.get-parallel-degree");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Long runContainer(Long userSessionId, ProcessBO container, Long parentSessionId,
							 Date effectiveDate, String userName) throws UserException {
		SqlMapSession ssn = null;
		Long result = null;
		CallableStatement cstmt = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId, userName);
			} else {
				ssn = getIbatisProcessSession(true);
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("processId", container.getId());
			map.put("containerId", parentSessionId);
			map.put("effectiveDate", effectiveDate);
			map.put("sessionId", null);

			ssn.insert("process.run-container", map);

			cstmt = ssn.getCurrentConnection().prepareCall("commit");
			cstmt.execute();
			result = (Long) map.get("sessionId");
			logger.trace("Container " + container.getId() + " started. Session ID = " + result);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}

		} finally {
			close(cstmt);
			close(ssn);
		}
		return result;
	}

	@SuppressWarnings("unchecked")
	public List<ProcessBO> getContainerHierarchy(Long userSessionId, final Integer containerId) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<ProcessBO>>() {
			@Override
			public List<ProcessBO> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("process.get-container-heirarchy", containerId);
			}
		});
	}


	public Connection preprocess(Long userSessionId, ProcessBO process,
								 int procNum, ProcessSession sess, Connection con,
								 Date processDate, String userName)
			throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				if (con != null) {
					ssn = getIbatisSessionForConnection(userSessionId, con, userName, process.getContainerBindId());
				} else {
					ssn = getIbatisSession(userSessionId, null, process.getContainerBindId());
				}
			} else {
				ssn = getIbatisSessionNoContext();
			}
			logger.trace("Preprocess started");

			Boolean respCode = Boolean.TRUE;
			long tmptime = System.currentTimeMillis();
			Map<String, Object> map = new HashMap<String, Object>();

			map.put("processId", process.getId());
			map.put("sessionId", sess.getSessionId());
			map.put("threadNum", procNum);
			map.put("upSessionId", sess.getUpSessionId());
			map.put("effectiveDate", processDate);
			map.put("respCode", respCode);
			map.put("containerId", process.getContainerBindId());
			ssn.update("process.before-process", map);

			sess.setSessionId((Long) map.get("sessionId"));

			logger.trace("Time for preprocess: " + (System.currentTimeMillis() - tmptime));
			logger.trace("Preprocess finished");

			if (!(Boolean) map.get("respCode")) {
				logger.error("Preprocess for process " + process.getId() +
									 " failed with code '" + (Boolean) map.get("respCode") +
									 "': " + (String)map.get("errorDesc"));
				throw new Exception((String)map.get("errorDesc"));
			}
			return ssn.getCurrentConnection();
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void postProcess(Long userSessionId, Long sessionId,
							String result, String userName, Integer containerId)
			throws DataAccessException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId, userName, containerId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			logger.trace("Postprocess started");

			Boolean respCode = Boolean.TRUE;
			long tmptime = System.currentTimeMillis();
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("sessionId", sessionId);
			map.put("resultCode", result);
			map.put("containerId", containerId);
			//noinspection ConstantConditions
			map.put("respCode", respCode);

			ssn.update("process.post-process", map);

			logger.trace("Session id = " + sessionId + "; Time for postprocess: "
								 + (System.currentTimeMillis() - tmptime));
			logger.trace("Postprocess finished");

			if (!(Boolean) map.get("respCode")) {
				throw new Exception("POSTPROCESS_FAILED");
			}
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void changeThreadStatus(Long userSessionId, Long sessionId, String result,
								   Integer threadNumber, String userName) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId, userName);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("sessionId", sessionId);
			map.put("resultCode", result);
			map.put("threadNumber", threadNumber);

			ssn.update("process.change-thread-status", map);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessFileAttribute[] getIncomingFilesForProcess(Long userSessionId, Long sessionId,
															 Integer containerId) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId, null, containerId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			List<ProcessFileAttribute> files = ssn.queryForList(
					"process.get-incoming-files-for-process", containerId);

			//resolve ROOT_DIR
			for (ProcessFileAttribute f : files) {
				f.setLocation(resolvePath(f.getLocation(), userSessionId));
			}

			return files.toArray(new ProcessFileAttribute[files.size()]);

		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessFileAttribute[] getOutgoingProcessFiles(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId, null, (params.get("containerId") != null ? Integer.valueOf(params.get("containerId").toString()) : null));
			} else {
				ssn = getIbatisSessionNoContext();
			}
			List<ProcessFileAttribute> files = ssn.queryForList("process.get-outgoing-process-files", params);

			// resolve ROOT_DIR
			for (ProcessFileAttribute f : files) {
				f.setLocation(resolvePath(f.getLocation(), userSessionId));
			}

			return files.toArray(new ProcessFileAttribute[files.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {

			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessFileAttribute[] getOutgoingProcessFiles(Long userSessionId, Connection connection, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				if (connection != null) {
					ssn = getIbatisSessionForConnection(userSessionId, connection, (String) params.get("USER_NAME"), (params.get("containerProcessId") != null ? Integer.valueOf(params.get("containerProcessId").toString()) : null));
				} else {
					ssn = getIbatisSessionFE(userSessionId);
				}
			} else {
				ssn = getIbatisSessionNoContext();
			}
			List<ProcessFileAttribute> files = ssn.queryForList("process.get-outgoing-process-files", params);

			// resolve ROOT_DIR
			for (ProcessFileAttribute f : files) {
				f.setLocation(resolvePath(f.getLocation(), userSessionId));
			}

			return files.toArray(new ProcessFileAttribute[files.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {

			close(ssn);
		}
	}


	public void runProcess(Long userSessionId, int threadNum, Long sessionId,
						   Integer containerId, Map<String, Object> params,
						   Date processDate, Connection connection,
						   Integer oracleTraceLevel, Integer oracleThreadNum) throws UserException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				if (connection != null) {
					ssn = getIbatisSessionForConnection(userSessionId, connection, (String) params.get("USER_NAME"), containerId);
				} else {
					ssn = getIbatisSession(userSessionId, null, containerId);
				}
			} else if(params.containsKey("USER_NAME")){
				HashMap<String, Object> mp = new HashMap<String, Object>();
				mp.put("sessionId", null);
				mp.put("user", params.get("USER_NAME"));
				ssn = getIbatisSessionInitContext(mp);
			} else{
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("sessionId", sessionId);
			map.put("containerId", containerId);
			map.put("threadNum", (Integer)threadNum);
			map.put("parameters", params);
			map.put("processDate", processDate);
			map.put("oracleTraceLevel", oracleTraceLevel);
			map.put("oracleThreadNum", oracleThreadNum);
			long tmptime = System.currentTimeMillis();
			logger.trace("Running proc: " + threadNum + ";");
			ssn.update("process.run-process", map);
			logger.trace("Call procedure: " + threadNum + ";time: "
								 + (System.currentTimeMillis() - tmptime));
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage(), e.getErrorCode(), e.getCause());
			} else {
				throw new DataAccessException(e);
			}

		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessUserSession[] getProcessUserSessions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_USER_SESSIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_USER_SESSIONS);
			List<ProcessUserSession> sessions = ssn.queryForList("process.get-user-sessions",
																 convertQueryParams(params, limitation));
			return sessions.toArray(new ProcessUserSession[sessions.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessUserSessionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_USER_SESSIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_USER_SESSIONS);
			return (Integer) ssn.queryForObject("process.get-user-sessions-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<ProcessStatSummary> getProcessStatSummary(Long userSessionId, Long sessionId) {
		List<ProcessStatSummary> result;
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			result = ssn.queryForList("process.get-stat-summary", sessionId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}

	@SuppressWarnings("unchecked")
	public ProcessBO[] getAllProcesses(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);

			List<ProcessBO> roles;

			roles = ssn.queryForList("process.get-all-processes", convertQueryParams(params));

			return roles.toArray(new ProcessBO[roles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAllProcessesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PROCESS, paramArr);

			return (Integer) ssn.queryForObject("process.get-all-processes-count",
												convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessSession[] getProcessSessionHierarchy(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_SESSION, paramArr);

			List<ProcessSession> processSessions;

			processSessions = ssn.queryForList("process.get-process-session-hierarchy",
											   convertQueryParams(params));

			// resolve ROOT_DIR
			for (ProcessSession s : processSessions) {
				s.setLocation(resolvePath(s.getLocation(), userSessionId));
			}

			return processSessions.toArray(new ProcessSession[processSessions.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessLaunchParameter[] getProcessLaunchParameters(Long userSessionId,
															   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PARAMETER_VALUE, paramArr);

			List<ProcessLaunchParameter> processLaunchParameters;

			processLaunchParameters = ssn.queryForList("process.get-process-launch-parameters",
													   convertQueryParams(params));

			return processLaunchParameters
					.toArray(new ProcessLaunchParameter[processLaunchParameters.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessLaunchParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_PARAMETER_VALUE, paramArr);

			return (Integer) ssn.queryForObject(
					"process.get-process-launch-parameters-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SessionFile[] getSessionFiles(final Long userSessionId, final SelectionParams params, boolean isUserMode) {
		final String privilege = isUserMode ? ProcessPrivConstants.VIEW_SESSION_FILE : null;
		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
		return executeWithSession(userSessionId, privilege, paramArr, logger, new IbatisSessionCallback<SessionFile[]>() {
			@Override
			public SessionFile[] doInSession(SqlMapSession ssn) throws Exception {
				List<SessionFile> files = ssn.queryForList("process.get-session-files", convertQueryParams(params));
				for (SessionFile sf : files) {
					sf.setLocation(resolvePath(sf.getLocation(), userSessionId)); // resolve ROOT_DIR
				}
				return files.toArray(new SessionFile[files.size()]);
			}
		});
	}


	public int getSessionFilesCount(Long userSessionId, final SelectionParams params, boolean isUserMode) {
		final String privilege = isUserMode ? ProcessPrivConstants.VIEW_SESSION_FILE : null;
		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
		return executeWithSession(userSessionId, privilege, paramArr, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("process.get-session-files-count", convertQueryParams(params));
			}
		});
	}


	public ProcessStatSummary getStatSummaryBySessionId(Long userSessionId, Long sessionId) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
			} else {
				ssn = getIbatisSessionFE(userSessionId);
			}

			Filter[] filters = new Filter[1];
			Filter filter = new Filter();
			filter.setElement("sessionId");
			filter.setValue(sessionId);
			filters[0] = filter;

			SelectionParams selectionParams = new SelectionParams();
			selectionParams.setFilters(filters);

			return (ProcessStatSummary) ssn.queryForObject(
					"process.get-stat-summary-by-session-id", convertQueryParams(selectionParams));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<ProcessStatSummary> getProcessThreads(Long userSessionId, Long sessionId) {
		SqlMapSession ssn = null;
		List<ProcessStatSummary> result;
		try {
			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
			} else {
				ssn = getIbatisSessionFE(userSessionId);
			}

			result = (List<ProcessStatSummary>) ssn.queryForList("process.get-process-threads",
																 sessionId);

			return result;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeContainer(Long userSessionId, ProcessBO container) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(container.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.REMOVE_CONTAINER, paramArr);
			ssn.delete("process.remove-container", container);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void prcLogStart(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("process.prc-log-start");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void prcLogEstimation(Long userSessionId, Long estimatedCount) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("process.prc-log-estimation", estimatedCount);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void prcLogCurrent(Long userSessionId, Long currentCount, Long exceptedCount) {
		SqlMapSession ssn = null;
		Map<String, Long> map = new HashMap<String, Long>(2);
		map.put("currentCount", currentCount);
		map.put("exceptedCount", exceptedCount);
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("process.prc-log-estimation", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void prcLogEnd(Long userSessionId, int processed, int failed, int rejected, String resultCode) {
		SqlMapSession ssn = null;
		Map<String, Object> map = new HashMap<String, Object>(4);
		map.put("processed", processed);
		map.put("excepted", failed);
		map.put("rejected", rejected);
		map.put("resultCode", resultCode);

		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("process.prc-log-end", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessParameter[] getContainerParamsNoContext(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();

			List<ProcessParameter> procParams = ssn.queryForList("process.get-container-params",
																 convertQueryParams(params));

			return procParams.toArray(new ProcessParameter[procParams.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void storeFileClob(Connection con, String fileName, String fileContent, String fileType) throws SystemException{
		CallableStatement cstmt = null;
		try {
			cstmt = con.prepareCall("{call prc_api_file_pkg.open_file(?,?,?,?)}");
			cstmt.registerOutParameter(1, Types.NUMERIC);
			cstmt.setString(2, fileName);
			cstmt.setString(3, fileType);
			cstmt.setString(4, ProcessConstants.FILE_PURPOSE_OUTGOING);
			cstmt.execute();
			long fileId = cstmt.getLong(1);
			cstmt.close();

			cstmt = con.prepareCall("{call prc_api_file_pkg.put_file(?,?)}");
			cstmt.setLong(1, fileId);
			cstmt.setObject(2, fileContent);
			cstmt.execute();
			cstmt.close();

			cstmt = con.prepareCall("{call prc_api_file_pkg.close_file(?,?)}");
			cstmt.setLong(1, fileId);
			cstmt.setNull(2, Types.CHAR);
			cstmt.execute();
			con.commit();
		} catch (SQLException e) {
			logger.error("", e);
			throw new SystemException(e);
		} finally {
			DBUtils.close(cstmt);
		}
	}

	@SuppressWarnings("unchecked")
	public SessionFile[] getSessionFilesByName(final Long userSessionId, final Map<String, Object> params, boolean isUserMode) {
		final String privilege = isUserMode ? ProcessPrivConstants.VIEW_SESSION_FILE : null;
		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
		return executeWithSession(userSessionId, privilege, paramArr, logger, new IbatisSessionCallback<SessionFile[]>() {
			@Override
			public SessionFile[] doInSession(SqlMapSession ssn) throws Exception {
				List<SessionFile> files = ssn.queryForList("process.get-session-files-by-name", params);
				for (SessionFile sf : files) {
					sf.setLocation(resolvePath(sf.getLocation(), userSessionId)); // resolve ROOT_DIR
				}
				return files.toArray(new SessionFile[files.size()]);
			}
		});
	}

	@SuppressWarnings("unchecked")
	public String[] getFileRawData(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_FILE, paramArr);

			List<String> data = ssn.queryForList("process.get-file-raw-data", params);

			return data.toArray(new String[data.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setStatusToFiles(Long userSessionId, List<ProcessFileAttribute> files, String status) {
		SqlMapSession ssn = null;
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("status", status);
		try {
			ssn = getIbatisSessionFE(userSessionId);

			for (ProcessFileAttribute file : files) {
				params.put("sessionFileId", file.getId());
				ssn.update("process.set-file-status", params);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setStatusToSessionFiles(Long userSessionId, List<SessionFile> files, String status){
		SqlMapSession ssn = null;
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("status", status);
		try {
			ssn = getIbatisSessionFE(userSessionId);

			for (SessionFile file : files) {
				params.put("sessionFileId", file.getId());
				ssn.update("process.set-file-status", params);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public String getDefaultFileName(Long userSessionId, String fileType, String filePurpose, Map<String, Object> params) {
		SqlMapSession ssn = null;
		Map<String, Object> p = new HashMap<String, Object>();
		p.put("result", "");
		p.put("fileType", fileType);
		p.put("filePurpose", filePurpose);
		p.put("params", params);
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.queryForObject("process.get-default-file-name", p);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		String fileName = null;
		if (p.containsKey("result")){
			fileName = (String) p.get("result");
		}
		return fileName;
	}


	@SuppressWarnings("unchecked")
	public ProcessFileDirectory[] getProcessFileDirectories(Long userSessionId,
															SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_DIRECTORY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_DIRECTORY);
			List<ProcessFileDirectory> fileDirectories = ssn.queryForList("process.get-process-files-directories",
																		  convertQueryParams(params, limitation));
			return fileDirectories.toArray(new ProcessFileDirectory[fileDirectories.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessFileDirectoriesCount(Long userSessionId,
											  SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_DIRECTORY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_DIRECTORY);
			return (Integer) ssn.queryForObject("process.get-process-files-directories-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessFileDirectory addFileDirectory(Long userSessionId,
												 ProcessFileDirectory editItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_DIRECTORY, paramArr);
			ssn.update("process.add-process-file-directory", editItem);

			Filter[] filters = new Filter[2];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editItem.getId());
			filters[0] = f;
			f = new Filter();
			f.setElement("lang");
			f.setValue(editItem.getLang());
			filters[1] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ProcessFileDirectory) ssn.
					queryForObject("process.get-process-files-directories", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ProcessFileDirectory modifyFileDirectory(Long userSessionId,
													ProcessFileDirectory editItem) {
		SqlMapSession ssn = null;
		try {

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_DIRECTORY, paramArr);
			ssn.update("process.modify-process-file-directory", editItem);

			Filter[] filters = new Filter[2];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editItem.getId());
			filters[0] = f;
			f = new Filter();
			f.setElement("lang");
			f.setValue(editItem.getLang());
			filters[1] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ProcessFileDirectory) ssn.
					queryForObject("process.get-process-files-directories", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteFileDirectory(Long userSessionId,
									ProcessFileDirectory editItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.REMOVE_DIRECTORY, paramArr);
			ssn.update("process.remove-process-file-directory", editItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public Boolean checkDirectory(Long userSessionId, Long id) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("id", id);
			params.put("value",  new Object());
			return (Boolean) ssn.queryForObject("process.check-directory", params);
		}catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    public List<ProcessFileSaver> getFileSavers(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ProcessPrivConstants.VIEW_FILE_SAVERS,
                                  params,
                                  logger,
                                  new IbatisSessionCallback<List<ProcessFileSaver>>() {
            @Override
            public List<ProcessFileSaver> doInSession(SqlMapSession ssn) throws Exception {
                String limit = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_FILE_SAVERS);
                List<ProcessFileSaver> savers = ssn.queryForList("process.get-file-savers", convertQueryParams(params, limit));
                return savers;
            }
        });
    }

    public int getFileSaversCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ProcessPrivConstants.VIEW_FILE_SAVERS,
                                  params,
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
            @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limit = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_FILE_SAVERS);
                Object count = ssn.queryForObject("process.get-file-savers-count", convertQueryParams(params, limit));
                return (count != null) ? (Integer)count : 0;
            }
        });
    }

    public ProcessFileSaver addFileSaver(Long userSessionId, final ProcessFileSaver fileSaver) {
        return executeWithSession(userSessionId,
                                  ProcessPrivConstants.ADD_FILE_SAVERS,
                                  AuditParamUtil.getCommonParamRec(fileSaver),
                                  logger,
                                  new IbatisSessionCallback<ProcessFileSaver>() {
            @Override
            public ProcessFileSaver doInSession(SqlMapSession ssn) throws Exception {
                ssn.insert("process.add-file-saver", fileSaver);
                return fileSaver;
            }
        });
    }

    public ProcessFileSaver modifyFileSaver(Long userSessionId, final ProcessFileSaver fileSaver) {
        return executeWithSession(userSessionId,
                                  ProcessPrivConstants.MODIFY_FILE_SAVERS,
                                  AuditParamUtil.getCommonParamRec(fileSaver),
                                  logger,
                                  new IbatisSessionCallback<ProcessFileSaver>() {
            @Override
            public ProcessFileSaver doInSession(SqlMapSession ssn) throws Exception {
                ssn.update("process.modify-file-saver", fileSaver);
                return fileSaver;
            }
        });
    }

    public void deleteFileSaver(Long userSessionId, final ProcessFileSaver fileSaver) {
        executeWithSession(userSessionId,
                           ProcessPrivConstants.REMOVE_FILE_SAVERS,
                           AuditParamUtil.getCommonParamRec(fileSaver),
                           logger,
                           new IbatisSessionCallback<Void>() {
            @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.delete("process.remove-file-saver", fileSaver);
                return null;
            }
        });
    }

	public Long openFile(Long userSessionId, ProcessFileAttribute attr) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attr.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_FILE, paramArr);
			ssn.update("process.set-container-id", attr.getContainerBindId());
			ssn.update("process.set-session-id", attr.getSessionId());
			ssn.update("process.open-file", attr);
			return attr.getId();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Long openFileNoSession(Long userSessionId, ProcessFileAttribute attr) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attr.getAuditParameters());
			if(userSessionId != null){
				ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_FILE, paramArr);
			}else{
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("process.set-container-id", attr.getContainerBindId());
			ssn.update("process.open-file-nosession", attr);
			return attr.getId();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void putFileClob(Long userSessionId, Map<String, Object> attr) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(attr);
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_FILE, paramArr);
			ssn.update("process.put-file-clob",attr);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setContainerId(Long userSessionId, Integer container_id) {
		SqlMapSession ssn = null;
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("id", container_id);
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.ADD_FILE, paramArr);
			ssn.update("process.set-container-id", container_id);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setContainerId(Connection mainContainerConnection, Long containerBindId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisProcessSession(mainContainerConnection, false);
			ssn.update("process.set-container-id", containerBindId.intValue());
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SessionFile[] getSessionFilesContent(final Long userSessionId, final SelectionParams params, boolean isUserMode) {
		final String privilege = isUserMode ? ProcessPrivConstants.VIEW_SESSION_FILE : null;
		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
		return executeWithSession(userSessionId, privilege, paramArr, logger, new IbatisSessionCallback<SessionFile[]>() {
			@Override
			public SessionFile[] doInSession(SqlMapSession ssn) throws Exception {
				List<SessionFile> files = ssn.queryForList("process.get-session-files-content", convertQueryParams(params));
				for (SessionFile sf : files) {
					sf.setLocation(resolvePath(sf.getLocation(), userSessionId)); // resolve ROOT_DIR
				}
				return files.toArray(new SessionFile[files.size()]);
			}
		});
	}

	@SuppressWarnings("unchecked")
	public ProcessSession[] getSessionFilesList(final Long userSessionId, final SelectionParams params, boolean isUserMode) {
		final String privilege = isUserMode ? ProcessPrivConstants.VIEW_SESSION_FILE : null;
		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
		return executeWithSession(userSessionId, privilege, paramArr, logger, new IbatisSessionCallback<ProcessSession[]>() {
			@Override
			public ProcessSession[] doInSession(SqlMapSession ssn) throws Exception {
				List<ProcessSession> files = ssn.queryForList("process.get-session-files-list", convertQueryParams(params));
				for (ProcessSession ps : files) {
					ps.setLocation(resolvePath(ps.getLocation(), userSessionId)); // resolve ROOT_DIR
				}
				return files.toArray(new ProcessSession[files.size()]);
			}
		});
	}


	public int getSessionFilesListCount(Long userSessionId, final SelectionParams params, boolean isUserMode) {
		final String privilege = isUserMode ? ProcessPrivConstants.VIEW_SESSION_FILE : null;
		CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
		return executeWithSession(userSessionId, privilege, paramArr, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("process.get-session-files-list-count", convertQueryParams(params));
			}
		});
	}


	public void runSheduler(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MANAGE_PROCESS_SCHEDULE, null);
			ssn.update("process.run-sheduler");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void stopSheduler(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MANAGE_PROCESS_SCHEDULE, null);
			ssn.update("process.stop-sheduler");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public boolean isRunning() {
		SqlMapSession ssn = null;
		try {
			Map<String, Object> params = new HashMap<String, Object>();
			ssn = getIbatisSessionNoContext();
			ssn.update("process.is-running", params);
			return (Boolean) params.get("isRunning");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeFileConfiguration(Long userSessionId,
										Long sessionId) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSession(userSessionId);
			ssn.delete("process.remove-file-configuration", sessionId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public void generateResponseFile(Connection mainProcConnection,
									 String fileType, Long fileId, String fileName, String errorCode) {
		SqlMapSession ssn = null;
		try {
			Map<String, Object> p = new HashMap<String, Object>();
			p.put("fileType", fileType);
			p.put("fileId", fileId);
			p.put("fileName", fileName);
			p.put("errorCode", errorCode);
			ssn = getIbatisProcessSession(mainProcConnection, false);
			ssn.update("process.generate-response-file", p);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setStatusToFile(Long userSessionId, Long id, String status) {
		SqlMapSession ssn = null;
		Map<String, Object> params = new HashMap<String, Object>();
		params.put("status", status);
		try {
			ssn = getIbatisSessionFE(userSessionId);
			params.put("sessionFileId", id);
			ssn.update("process.set-file-status", params);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}



	public InputStream getSessionFileContentsStream(Long userSessionId, Connection aCon, Long sessionFileId, String charSet, String lineSeparator){
		SqlMapSession ssn = null;
		String cs = (charSet != null && Charset.availableCharsets().keySet().contains(charSet))? charSet : SystemConstants.DEFAULT_CHARSET;
		try {
			PreparedStatement ps = null;
			ResultSet rs;
			InputStream result = null;
			Connection con;
			try {
				if (aCon == null) {
					ssn = getIbatisSessionFE(userSessionId);
					con = ssn.getCurrentConnection();
				} else
					con = aCon;
				ps = con.prepareStatement(
						"select case when nvl(dbms_lob.getlength(file_contents), 0)>0 then file_contents " +
								"            when nvl(vsize(file_xml_contents), 0)>0 then f.file_xml_contents.getclobval() else null end file_contents, " +
								"       case when nvl(dbms_lob.getlength(file_bcontents), 0)>0 then file_bcontents else null end file_bcontents " +
								" from PRC_SESSION_FILE_VW f where id=?");
				ps.setLong(1, sessionFileId);
				rs = ps.executeQuery();
				if (rs.next()) {
					Clob clob = rs.getClob(1);
					if (clob != null) {
						result = new ReaderInputStream(clob.getCharacterStream(), cs);
					} else {
						Blob blob = rs.getBlob(2);
						if (blob != null) {
							result = blob.getBinaryStream();
						}
					}
					if (aCon == null && result != null) {
						// We are using local connection and input stream will not be available once connection is closed
						// so we save contents as temp file and return file stream
						result = SystemUtils.recreateInputStreamAsTempFile(result);
					}
				}
			} finally {
				close(ps);
			}
			if (result == null) {
				try {
					ps = con.prepareStatement("select raw_data from prc_file_raw_data_vw where session_file_id=? order by record_number");
					ps.setLong(1, sessionFileId);
					rs = ps.executeQuery();
					if (rs.next()) {
						File file = SystemUtils.getTempFile(null);
						PrintWriter writer = new PrintWriter(file, cs);
						final int bufLines = 1000;
						StringBuilder buf = new StringBuilder();
						int index = 0;
						try {
							do {
								buf.append(rs.getString(1)).append(lineSeparator);
								if (index++ >= bufLines) {
									index = 0;
									writer.write(buf.toString());
									buf.setLength(0);
								}
							} while (rs.next());
							if (buf.length() > 0) {
								writer.write(buf.toString());
							}
						} finally {
							IOUtils.closeQuietly(writer);
						}
						result = new NamedFileInputStream(file);
					}
				} finally {
					close(ps);
				}
			}
			return result;
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public InputStream getSessionFileContentsStream(Long userSessionId, Connection aCon, Long sessionFileId) {
		return getSessionFileContentsStream(userSessionId, aCon, sessionFileId, SystemConstants.DEFAULT_CHARSET, System.lineSeparator());
	}



	// Closes PreparedStatement. Also, closing PreparedStatement autocloses produced ResultSet, if any
	private void close(PreparedStatement ps) {
		try {
			if (ps != null)
				ps.close();
		} catch (Exception ignored) {
		}
	}


	public void changeSessionFile(Long userSessionId, Map params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			if(userSessionId != null){
				ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_FILE, paramArr);
			}else{
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("process.change-session-file", params);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setSessionContext(Long sessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(sessionId);
			ssn.update("process.set-session-context", sessionId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void saveRejectedCount(Long userSessionId, Map params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params);
			if(userSessionId != null){
				ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.MODIFY_FILE, paramArr);
			}else{
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("process.save-rejected-count", params);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String resolvePath(String path, Long userSessionId) {
		if (path != null && path.contains(SystemConstants.ROOT_DIR)) {
			SqlMapSession ssn = null;
			try {
				Map<String, String> map = new HashMap<String, String>();
				map.put("systemName", SettingsConstants.INPUT_OUTPUT_HOME);
				map.put("level", LevelNames.SYSTEM);
				map.put("levelValue", null);

				if (userSessionId == null) {
					ssn = getIbatisSessionNoContext();
				} else {
					ssn = getIbatisSession(userSessionId);
				}
				ssn.insert("settings.get-system-param_v", map);
				String rootDir = map.get("value");
				if (rootDir.trim().length() > 0) {
					path = path.replaceFirst(Pattern.quote(SystemConstants.ROOT_DIR), rootDir);
				}
			} catch (SQLException e) {
				throw createDaoException(e);
			} finally {
				close(ssn);
			}
		}
		return path;
	}


	public void auditContainerRun(Long userSessionId, ProcessBO processBO) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId, null,
									   ProcessPrivConstants.RUN_CONTAINER,
									   AuditParamUtil.getCommonParamRec(processBO.getContainerId(), EntityNames.CONTAINER));
			} else {
				throw new IllegalArgumentException("userSessionId cannot be null");
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void changeOracleTrace(Long userSessionId, Map params, Boolean enable) {
		SqlMapSession ssn = null;
		try {
			if (params != null) {
				if (userSessionId != null) {
					ssn = getIbatisSession(userSessionId);
				} else {
					ssn = getIbatisSessionNoContext();
				}
				if (enable) {
					ssn.update("process.enable-oracle-trace", params);
				} else {
					ssn.update("process.disable-oracle-trace", params);
				}
			} else {
				throw new IllegalArgumentException("Incoming params cannot be null");
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getTraceMessage(Long userSessionId, Long sessionId, Integer threadNumber) {
		String message = new String();
		SqlMapSession ssn = null;
		try {
			if (sessionId != null && threadNumber != null) {
				if (userSessionId != null) {
					ssn = getIbatisSession(userSessionId);
				} else {
					ssn = getIbatisSessionNoContext();
				}
				Map<String, Object> map = new HashMap<String, Object>();
				map.put( "sessionId", sessionId );
				map.put( "threadNumber", threadNumber );
				ssn.queryForObject("process.get-trace-message", map);
				message = map.get("fullDesc").toString();
			} else {
				throw new IllegalArgumentException("SessionId and ThreadNumber cannot be null");
			}
		} catch (SQLException e) {
			if (e.getErrorCode() != 1403 ){
				throw createDaoException( e );
			} else {
				logger.error("", e);
			}
		} finally {
			close(ssn);
		}
		return message;
	}


	public Integer getOracleTraceLevel(Long userSessionId, Long sessionId, Integer threadNumber) {
		Integer level = new Integer(0);
		SqlMapSession ssn = null;
		try {
			if (sessionId != null && threadNumber != null) {
				if (userSessionId != null) {
					ssn = getIbatisSession(userSessionId);
				} else {
					ssn = getIbatisSessionNoContext();
				}
				Map<String, Object> map = new HashMap<String, Object>();
				map.put( "sessionId", sessionId );
				map.put( "threadNumber", threadNumber );
				ssn.queryForObject("process.get-session-trace-level", map);
				if (map.get("traceLevel") != null) {
					level = Integer.valueOf(map.get("traceLevel").toString());
				}
			} else {
				throw new IllegalArgumentException("SessionId and ThreadNumber cannot be null");
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} catch (NumberFormatException e) {
			logger.error("", e);
		} finally {
			close(ssn);
		}
		return level;
	}


	public void addProcessHistoryParams(Long userSessionId, Long processSessionId, Integer processId, Integer containerBindId, Map<String, Object> parameters) {
		ProcessParameter[] processParams = getProcessParams(userSessionId,
															SelectionParams.build("processId", processId, "containerBindId", containerBindId, "lang", SystemConstants.ENGLISH_LANGUAGE).setRowIndexAll(), true);
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<Integer, Object> params = new HashMap<Integer, Object>();
			for (ProcessParameter processParam : processParams) {
				Object paramValue = parameters.get(processParam.getSystemName());
				Map<String, Object> map = new HashMap<String, Object>();
				map.put("i_session_id", processSessionId);
				map.put("i_param_id", processParam.getId());
				map.put("i_param_value", paramValue);
				ssn.update("process.add-process-history-param", map);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String generateFilePassword(Long userSessionId, Long sessionFileId) {
		String password = "";
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("i_sess_file_id", sessionFileId);
			ssn.queryForObject("process.generate-file-password", map);
			if (map.get("o_file_password") != null) {
				password = map.get("o_file_password").toString();
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return password;
	}


	public boolean isHoliday(Long userSessionId, Date currentDate, Integer instId) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("currentDay", currentDate);
			map.put("instId", (instId == null) ? SystemConstants.DEFAULT_INSTITUTION : instId);
			ssn.queryForObject("process.is-holiday", map);
			return (Boolean)map.get("isHoliday");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void storeNbcFastTransactions(Long userSessionId, Integer containerId,
										 String fileName, String filePurpose,
										 String fileContent, Long recordCount)
			throws Exception {
		SqlMapSession ssn = null;
		Connection connection = null;
		CallableStatement statement = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			connection = ssn.getCurrentConnection();

			statement = connection.prepareCall("{call prc_api_session_pkg.start_session(io_session_id => ?, i_container_id => ?)}");
			statement.setLong(1, userSessionId);
			statement.setLong(2, containerId);
			statement.execute();
			DBUtils.close(statement);

			statement = connection.prepareCall("{call prc_api_file_pkg.open_file(?,?,?,?)}");
			statement.registerOutParameter(1, Types.NUMERIC);
			statement.setString(2, fileName);
			statement.setString(3, ProcessConstants.FILE_TYPE_NBC_FAST);
			statement.setString(4, filePurpose);
			statement.execute();
			Long fileId = statement.getLong(1);
			DBUtils.close(statement);

			statement = connection.prepareCall("{call prc_api_file_pkg.put_file(?,?)}");
			statement.setLong(1, fileId);
			statement.setObject(2, fileContent);
			statement.execute();
			DBUtils.close(statement);

			statement = connection.prepareCall("{call prc_api_file_pkg.close_file(?,?,?)}");
			statement.setLong(1, fileId);
			statement.setString(2, ProcessConstants.FILE_STATUS_ACCEPTED);
			statement.setLong(3, recordCount);
			statement.execute();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			DBUtils.close(statement);
			DBUtils.close(connection);
			close(ssn);
		}
	}

	private Map<String, Object> getScheduleParameters(SqlMapSession ssn, SelectionParams params) throws SQLException {
		Map<String, Object> map = new HashMap<String, Object>();
		String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_PROCESS_SCHEDULE);
		List<Filter> filters = Filter.asList(params.getFilters());
		filters.add(Filter.create("PRIVIL_LIMITATION", limitation));
		for (Filter filter : filters) {
			if ("date".equals(filter.getElement())) {
				map.put("date", filter.getValue());
				break;
			}
		}
		if (map.get("date") == null) {
			map.put("date", new Date());
		}
		map.put("params", Filter.asArray(filters));
		map.put("firstRow", convertQueryParams(params, limitation).getRange().getStartPlusOne());
		map.put("lastRow", convertQueryParams(params, limitation).getRange().getEndPlusOne());
		map.put("sorting", params.getSortElement());
		return map;
	}


	public List<ProcessSchedule> getScheduleList(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  ProcessPrivConstants.VIEW_PROCESS_SCHEDULE,
								  AuditParamUtil.getCommonParamRec(params.getFilters()),
								  logger,
								  new IbatisSessionCallback<List<ProcessSchedule>>() {
			@Override
			public List<ProcessSchedule> doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = getScheduleParameters(ssn, params);
				ssn.update("process.get-process-schedules", map);
				return (map.get("info") != null) ? (List<ProcessSchedule>)map.get("info") : null;
			}
		});
	}


	public int getScheduleListCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  ProcessPrivConstants.VIEW_PROCESS_SCHEDULE,
								  AuditParamUtil.getCommonParamRec(params.getFilters()),
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = getScheduleParameters(ssn, params);
				ssn.update("process.get-process-schedules-count", map);
				return (map.get("count") != null) ? ((Long)map.get("count")).intValue() : 0;
			}
		});
	}
}
