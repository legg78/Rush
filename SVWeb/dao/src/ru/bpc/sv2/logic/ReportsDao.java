package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.constants.ModuleNames;
import ru.bpc.sv2.constants.reports.ReportConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.reports.*;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.UserException;

import java.io.File;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.SQLException;
import java.util.*;

/**
 * Session Bean implementation class ReportsDao
 */
@SuppressWarnings("unchecked")
public class ReportsDao extends IbatisAware {

	private static final Logger logger = Logger.getLogger("REPORTS");
	private static final String user = "ADMIN";

	private RolesDao rolesDao = new RolesDao();

	@SuppressWarnings ("unchecked")
	public Report[] getReports(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT, paramArr);

			List<Report> reports = ssn.queryForList("rpt.get-reports-hier",
													convertQueryParams(params));

			for (Report report : reports) {
				SelectionParams paramsReportTags = SelectionParams.build("reportId", report.getId(), "lang",
																		 report.getLang());

				List<ReportTag> tags = ssn.queryForList("rpt.get-report-tags", convertQueryParams(paramsReportTags));
				report.setTags(tags);
			}
			return reports.toArray(new Report[reports.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")
	public Report[] getReportsList(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT, paramArr);

			// prepare lang for queryParams
			String lang = null;
			Filter[] allFilters = params.getFilters();
			for (Filter filter : allFilters) {
				if ("lang".equals(filter.getElement())) {
					lang = (String) filter.getValue();
				}
			}

			List<Report> reports = ssn.queryForList("rpt.get-reports", convertQueryParams(params,
																						  null, lang));

			for (Report report : reports) {
				SelectionParams paramsReportTags = SelectionParams.build("reportId", report.getId(), "lang",
																		 report.getLang());
				List<ReportTag> tags = ssn.queryForList("rpt.get-report-tags", convertQueryParams(paramsReportTags));
				report.setTags(tags);
			}

			return reports.toArray(new Report[reports.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	/**
	 * Gets <i>ru.bpc.sv2.reports.Report</i>s without its data which is CLOB
	 */
	@SuppressWarnings ("unchecked")

	public Report[] getReportsLight(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT, paramArr);

			List<Report> reports = ssn.queryForList("rpt.get-reports-light",
													convertQueryParams(params));
			return reports.toArray(new Report[reports.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public Report addReport(Long userSessionId, Report report, List<Integer> tagsToAdd) {
		SqlMapSession ssn = null;
		Report result = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(report.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.ADD_REPORT, paramArr);

			ssn.update("rpt.add-report", report);

			// add role to report if user choose role
			if (report.getRoleId() != null) {
				// Report.getId() is actually integer
				rolesDao.addReportRole(userSessionId, report.getId().intValue(), report.getRoleId());
			}

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(report.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(report.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			result = (Report) ssn.queryForObject("rpt.get-reports", convertQueryParams(params));

			if (tagsToAdd != null) {
				Map<String, Integer> paramMap = new HashMap<String, Integer>();
				for (Integer tagId : tagsToAdd) {
					paramMap.clear();
					paramMap.put("tagId", tagId);
					paramMap.put("reportId", result.getId().intValue()); // Report.getId() is actually integer
					ssn.update("rpt.add-report-tag", paramMap);
				}
			}

			SelectionParams paramsReportTags = SelectionParams.build("reportId", result.getId(), "lang",
																	 result.getLang());


			List<ReportTag> tags = ssn.queryForList("rpt.get-report-tags",
													convertQueryParams(paramsReportTags));
			result.setTags(tags);

		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}

	@SuppressWarnings ("unchecked")

	public Report modifyReport(Long userSessionId, Report report, List<Integer> tagsToAdd,
							   List<Integer> tagsToRemove) {
		SqlMapSession ssn = null;
		Report result = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(report.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.MODIFY_REPORT, paramArr);

			ssn.update("rpt.modify-report", report);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(report.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(report.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			result = (Report) ssn.queryForObject("rpt.get-reports", convertQueryParams(params));

			if (tagsToAdd != null) {
				Map<String, Integer> paramMap = new HashMap<String, Integer>();
				for (Integer tagId : tagsToAdd) {
					paramMap.clear();
					paramMap.put("tagId", tagId);
					paramMap.put("reportId", result.getId().intValue());  // Report.getId() is actually integer
					ssn.update("rpt.add-report-tag", paramMap);
				}
			}

			if (tagsToRemove != null) {
				Map<String, Integer> paramMap = new HashMap<String, Integer>();
				for (Integer tagId : tagsToRemove) {
					paramMap.clear();
					paramMap.put("tagId", tagId);
					paramMap.put("reportId", result.getId().intValue());  // Report.getId() is actually integer
					ssn.update("rpt.remove-report-tag", paramMap);
				}
			}

			SelectionParams paramsReportTags = SelectionParams.build("reportId", result.getId(), "lang",
																	 result.getLang());

			List<ReportTag> tags = ssn.queryForList("rpt.get-report-tags",
													convertQueryParams(paramsReportTags));
			result.setTags(tags);

		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public void removeReport(Long userSessionId, Report report) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(report.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.REMOVE_REPORT, paramArr);

			ssn.delete("rpt.remove-report", report);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Report addReportGroup(Long userSessionId, Report report) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("rpt.add-group", report);

			// add role to report group if user choose role
			if (report.getRoleId() != null) {
				// Report.getId() is actually integer
				rolesDao.addReportRole(userSessionId, report.getId().intValue(), report.getRoleId());
			}

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(report.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(report.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Report) ssn.queryForObject("rpt.get-reports-light", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Report modifyReportGroup(Long userSessionId, Report report) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("rpt.modify-group", report);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(report.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(report.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Report) ssn.queryForObject("rpt.get-reports-light", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeReportGroup(Long userSessionId, Report report) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("rpt.remove-group", report);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public ReportParameter[] getReportParameters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_PARAMETERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_PARAMETERS);
			List<ReportParameter> reportParameters = ssn.queryForList("rpt.get-report-parameters",
																	  convertQueryParams(params, limitation));
			return reportParameters.toArray(new ReportParameter[reportParameters.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReportParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_PARAMETERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_PARAMETERS);
			return (Integer) ssn.queryForObject("rpt.get-report-parameters-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void syncReportParameters(Long userSessionId, Integer reportId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("rpt.sync-report-parameters", reportId);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportParameter addReportParameter(Long userSessionId, ReportParameter reportParameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reportParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.ADD_REPORT_PARAMETER, paramArr);

			ssn.update("rpt.add-report-parameter", reportParameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(reportParameter.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(reportParameter.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReportParameter) ssn.queryForObject("rpt.get-report-parameters",
														convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportParameter modifyReportParameter(Long userSessionId, ReportParameter reportParameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reportParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.MODIFY_REPORT_PARAMETER, paramArr);

			ssn.update("rpt.modify-report-parameter", reportParameter);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(reportParameter.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(reportParameter.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReportParameter) ssn.queryForObject("rpt.get-report-parameters",
														convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeReportParameter(Long userSessionId, ReportParameter reportParameter) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reportParameter.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.REMOVE_REPORT_PARAMETER, paramArr);

			ssn.delete("rpt.remove-report-parameter", reportParameter);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public ReportRun[] getReportRuns(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_RUNS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_RUNS);
			List<ReportRun> runs = ssn.queryForList("rpt.get-report-runs", convertQueryParams(
					params, limitation));
			return runs.toArray(new ReportRun[runs.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReportRunsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_RUNS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_RUNS);
			return (Integer) ssn.queryForObject("rpt.get-report-runs-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public ReportRunParameter[] getReportRunParameters(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_RUN_PARAMETERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_RUN_PARAMETERS);
			List<ReportRunParameter> runParameters = ssn.queryForList("rpt.get-run-parameters",
																	  convertQueryParams(params, limitation));
			return runParameters.toArray(new ReportRunParameter[runParameters.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReportRunParametersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_RUN_PARAMETERS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_RUN_PARAMETERS);
			return (Integer) ssn.queryForObject("rpt.get-run-parameters-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public ReportResult runReport(Long userSessionId, Report report, Integer templateId, ReportParameter[] params) {
		SqlMapSession ssn = null;
		ResultSet rs;
		try {
			ReportResult result = new ReportResult();
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("reportId", report.getId());
			if (templateId != null) {
				map.put("templateId", templateId);
			} else {
				map.put("templateId", null);
			}
			Map<String, Object> commonParams = new HashMap<String, Object>();
			for (ReportParameter param : params) {
				commonParams.put(param.getSystemName(), param.getValue());
			}
			map.put("parameters", commonParams);

			if (userSessionId != null) {
				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
				ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.RUN_REPORT, paramArr);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("rpt.start-report", map);

			Long runId = (Long) map.get("runId");
			Boolean isDeterministic = (Boolean) map.get("isDeterministic");
			if (isDeterministic == null) {
				isDeterministic = Boolean.FALSE; // iBatis "nullValue" doesn't work for some reason 
			}
			String savePath = (String) map.get("savePath");
			boolean alreadySaved = false;
			if (savePath != null) {
				File file = new File(savePath);
				if (file.exists()) {
					alreadySaved = true;
				}
			}
			if (!alreadySaved) {
				// when report is deterministic and it's not the first run we suppose
				// that report is already generated so no further actions needed
				// otherwise do as usual 
				if (ReportConstants.REPORT_SOURCE_TYPE_XML.equals(report.getSourceType())) {
					File xml = (File) map.get("xml");
					result.setXmlFile(xml);

					Filter[] filters = new Filter[2];
					filters[0] = new Filter("id", templateId);
					filters[1] = new Filter("lang", report.getLang());
					SelectionParams tmplParams = new SelectionParams();
					tmplParams.setFilters(filters);

					List<ReportTemplate> templates = ssn.queryForList(
							"rpt.get-report-templates-light", convertQueryParams(tmplParams, null));
					if (templates.size() > 0) {
						result.setProcessor(templates.get(0).getProcessor());
					}
				}

				if (ReportConstants.REPORT_SOURCE_TYPE_SIMPLE.equals(report.getSourceType())) {
					QueryResult data = new QueryResult();
					rs = (ResultSet) map.get("resultSet");
					ResultSetMetaData metaData = rs.getMetaData();
					for (int i = 1; i <= metaData.getColumnCount(); i++) {
						data.getFieldNames().add(metaData.getColumnName(i));
					}

					while (rs.next()) {
						HashMap<String, String> hm = new HashMap<String, String>();
						for (int i = 1; i <= metaData.getColumnCount(); i++) {
							hm.put(metaData.getColumnName(i), rs.getString(i));
						}
						data.getFields().add(hm);
					}

					result.setSqlData(data);
				}
			}
			result.setAlreadySaved(alreadySaved);
			result.setDeterministic(isDeterministic);
			result.setFileName((String) map.get("fileName"));
			result.setSavePath((String) map.get("savePath"));
			result.setRunId(runId);
			return result;
		} catch (Exception e) {
			logger.error("", e);
			if (e.getCause() == null) {
				throw new DataAccessException(e.getMessage());
			}
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public void setReportStatus(Long userSessionId, Long runId, String status) {
		SqlMapSession ssn = null;
		try {
			HashMap<String, Object> map = new HashMap<String, Object>();

			map.put("runId", runId);
			map.put("status", status);

			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map);
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.SET_REPORT_STATUS, paramArr);

			ssn.update("rpt.set-report-status", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings ("unchecked")
	public void setReportStatus(Long runId, String status) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("runId", runId);
			map.put("status", status);
			ssn.update("rpt.set-report-status", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public ReportTemplate[] getReportTemplates(Long userSessionId,
											   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_TEMPLATE);
			List<ReportTemplate> templates = ssn.queryForList(
					"rpt.get-report-templates",
					convertQueryParams(params, limitation));
			return templates.toArray(new ReportTemplate[templates.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public ReportTemplate[] getReportTemplatesNoContext(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();

			String limitation = "1 = 1";
			List<ReportTemplate> templates = ssn.queryForList(
					"rpt.get-report-templates",
					convertQueryParams(params, limitation));
			return templates.toArray(new ReportTemplate[templates.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	/**
	 * Gets <i>ru.bpc.sv2.reports.ReportTemplate</i>s without its data which is
	 * CLOB
	 */
	@SuppressWarnings ("unchecked")

	public ReportTemplate[] getReportTemplatesLight(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_TEMPLATE);
			List<ReportTemplate> templates = ssn.queryForList("rpt.get-report-templates-light",
															  convertQueryParams(params, limitation));
			return templates.toArray(new ReportTemplate[templates.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReportTemplatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_TEMPLATE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_TEMPLATE);
			return (Integer) ssn.queryForObject("rpt.get-report-templates-count",
												convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportTemplate addReportTemplate(Long userSessionId, ReportTemplate template) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.ADD_REPORT_TEMPLATE, paramArr);

			ssn.update("rpt.add-report-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(template.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(template.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReportTemplate) ssn.queryForObject("rpt.get-report-templates",
													   convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportTemplate modifyReportTemplate(Long userSessionId, ReportTemplate template) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.MODIFY_REPORT_TEMPLATE, paramArr);

			ssn.update("rpt.modify-report-template", template);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(template.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(template.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReportTemplate) ssn.queryForObject("rpt.get-report-templates",
													   convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifyReportTemplate(ReportTemplate template) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();

			ssn.update("rpt.modify-report-template", template);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeReportTemplate(Long userSessionId, ReportTemplate template) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(template.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.REMOVE_REPORT_TEMPLATE, paramArr);

			ssn.delete("rpt.remove-report-template", template);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public ReportBanner[] getReportBanners(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_BANNER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_BANNER);
			List<ReportBanner> banners = ssn.queryForList("rpt.get-report-banners",
														  convertQueryParams(params, limitation));
			return banners.toArray(new ReportBanner[banners.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReportBannersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_BANNER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
																	 ReportPrivConstants.VIEW_REPORT_BANNER);
			return (Integer) ssn.queryForObject("rpt.get-report-banners-count", convertQueryParams(
					params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportBanner addReportBanner(Long userSessionId, ReportBanner banner) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(banner.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.ADD_REPORT_BANNER, paramArr);

			ssn.update("rpt.add-report-banner", banner);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(banner.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(banner.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReportBanner) ssn.queryForObject("rpt.get-report-banners",
													 convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportBanner modifyReportBanner(Long userSessionId, ReportBanner banner) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(banner.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.MODIFY_REPORT_BANNER, paramArr);

			ssn.update("rpt.modify-report-banner", banner);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(banner.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(banner.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ReportBanner) ssn.queryForObject("rpt.get-report-banners",
													 convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeReportBanner(Long userSessionId, ReportBanner banner) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(banner.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.REMOVE_REPORT_BANNER, paramArr);

			ssn.delete("rpt.remove-report-banner", banner);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public TreeMap[] getPlainReport(Long userSessionId, String query) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<TreeMap<String, String>> results = ssn.queryForList("rpt.execute-plain-report",
																	 query);
			return results.toArray(new TreeMap[results.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getXmlFromReportDatasource(Long userSessionId, Report report) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (String) ssn.queryForObject("rpt.get-xml-from-datasource", report);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getReportsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		Integer result = 0;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT, paramArr);

			// prepare lang for queryParams
			String lang = null;
			Filter[] filters = params.getFilters();
			for (Filter filter : filters) {
				if ("lang".equals(filter.getElement())) {
					lang = (String) filter.getValue();
				}
			}

			result = (Integer) ssn.queryForObject("rpt.get-reports-count", convertQueryParams(
					params, null, lang));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}

	@SuppressWarnings ("unchecked")

	public ReportTag[] getReportTags(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_TAG, paramArr);

			List<ReportTag> items = ssn.queryForList("rpt.get-tags", convertQueryParams(params));
			return items.toArray(new ReportTag[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReportTagsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_TAG, paramArr);
			return (Integer) ssn.queryForObject("rpt.get-tags-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportTag createReportTag(Long userSessionId, ReportTag editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.ADD_TAG, paramArr);
			ssn.update("rpt.add-tag", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ReportTag) ssn.queryForObject("rpt.get-tags", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportTag modifyReportTag(Long userSessionId, ReportTag editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.EDIT_TAG, paramArr);
			ssn.update("rpt.modify-tag", editingItem);

			Filter[] filters = new Filter[2];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(editingItem.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ReportTag) ssn.queryForObject("rpt.get-tags", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeReportTag(Long userSessionId, ReportTag activeItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(activeItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.REMOVE_TAG, paramArr);
			ssn.update("rpt.remove-tag", activeItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void getDocument(Map<String, Object> map) throws UserException {
		SqlMapSession ssn = null;
		try {
			HashMap<String, Object> params = new HashMap<String, Object>();
			params.put("sessionId", null);
			params.put("user", user);
			ssn = getIbatisSessionInitContext(params);
			ssn.update("rpt.get-document", map);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public RptDocument[] getOrderDocuments(Map<String, Object> map) throws UserException {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			ssn.update("rpt.get-order-documents", map);
			List<RptDocument> docs = (List<RptDocument>) map.get("orderList");
			return docs.toArray(new RptDocument[docs.size()]);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public RptDocument[] getDocuments(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			if (params.getModule() != null && params.getModule().equals(ModuleNames.CASE_MANAGEMENT)) {
				ssn = getIbatisSession(userSessionId);
			} else {
				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
				ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.SHOW_REPORT_DOCUMENTS, paramArr);
			}
			List<RptDocument> items = ssn.queryForList("rpt.get-rpt-documents", convertQueryParams(params));
			return items.toArray(new RptDocument[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public RptDocument[] getDocuments(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<RptDocument> items = ssn.queryForList("rpt.get-rpt-documents-sys", convertQueryParams(params));
			return items.toArray(new RptDocument[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public RptDocument[] getDocumentContents(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<RptDocument> items = ssn.queryForList("rpt.get-rpt-document-contents", convertQueryParams(params));
			return items.toArray(new RptDocument[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getDocumentsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			if (params.getModule() != null && params.getModule().equals(ModuleNames.CASE_MANAGEMENT)) {
				ssn = getIbatisSession(userSessionId);
			} else {
				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
				ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.SHOW_REPORT_DOCUMENTS, paramArr);
			}
			return (Integer) ssn.queryForObject("rpt.get-rpt-documents-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addDocument(Long userSessionId, RptDocument doc) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}

			ssn.update("rpt.add-document", doc);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addDocumentWithParams(Long userSessionId, RptDocument doc) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}

			ssn.update("rpt.add-document-params", doc);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addDocumentXml(Long userSessionId, RptDocument doc) throws UserException {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}

			ssn.update("rpt.add-document-xml", doc);
		} catch (SQLException e) {
			logger.error("", e);
			if (e.getErrorCode() == 20001) {
				throw new UserException(e.getCause().getMessage(), e);
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public DocumentContent[] getDocumentContentsOld(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<DocumentContent> contents = ssn.queryForList("rpt.get-document-contents",
															  convertQueryParams(params));
			return contents.toArray(new DocumentContent[contents.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public RptDocument[] getPrintDocuments(Long userSessionId,
										   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_PRINT_FORM_DOCUMENT, paramArr);

			List<RptDocument> items = ssn.queryForList("rpt.get-print-documents", convertQueryParams(params));
			return items.toArray(new RptDocument[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public int getPrintDocumentsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_PRINT_FORM_DOCUMENT, paramArr);

			return (Integer) ssn.queryForObject("rpt.get-print-documents-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}

	@SuppressWarnings ("unchecked")

	public RptDocument[] getProcessDocuments(Long userSessionId,
											 SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_PRINT_FORM_DOCUMENT, paramArr);

			List<RptDocument> items = ssn.queryForList(
					"rpt.get-process-documents", convertQueryParams(params));
			return items.toArray(new RptDocument[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public int getReportRunLogsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_RUNS, paramArr);
			return (Integer) ssn.queryForObject("rpt.get-report-run-logs-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public ReportLog[] getReportRunLogs(Long userSessionId,
										SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_PRINT_FORM_DOCUMENT, paramArr);

			List<ReportLog> items = ssn.queryForList(
					"rpt.get-report-run-logs", convertQueryParams(params));
			return items.toArray(new ReportLog[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public OutReportParameter[] getOutReportParameters(Long userSessionId,
													   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_PARAMETERS, paramArr);

			List<OutReportParameter> items = ssn.queryForList(
					"rpt.get-out-report-parameters", convertQueryParams(params));
			return items.toArray(new OutReportParameter[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getOutReportParametersCount(Long userSessionId,
										   SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT_PARAMETERS, paramArr);

			return (Integer) ssn.queryForObject("rpt.get-out-report-parameters-count", convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public OutReportParameter addOutReportParam(
			OutReportParameter newOutReportParam, Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(newOutReportParam.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.ADD_REPORT_PARAMETER, paramArr);

			ssn.update("rpt.add-out-report-parameter", newOutReportParam);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(newOutReportParam.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(newOutReportParam.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (OutReportParameter) ssn.queryForObject("rpt.get-out-report-parameters",
														   convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public OutReportParameter modifyOutReportParam(
			OutReportParameter newOutReportParam, Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(newOutReportParam.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.MODIFY_REPORT_PARAMETER, paramArr);

			ssn.update("rpt.modify-out-report-parameter", newOutReportParam);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(newOutReportParam.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(newOutReportParam.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (OutReportParameter) ssn.queryForObject("rpt.get-out-report-parameters",
														   convertQueryParams(params));
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeOutReportParameter(Long userSessionId, OutReportParameter outReportParam) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(outReportParam.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.REMOVE_REPORT_PARAMETER, paramArr);

			ssn.delete("rpt.remove-out-report-parameter", outReportParam);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportEntity[] getReportObject(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT, paramArr);

			List<ReportEntity> reportobjects = ssn.queryForList("rpt.get-report-objects", convertQueryParams(params));
			return reportobjects.toArray(new ReportEntity[reportobjects.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getReportObjectCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.VIEW_REPORT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ReportPrivConstants.VIEW_REPORT);
			return (Integer) ssn.queryForObject("rpt.get-report-objects-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportEntity addReportObject(Long userSessionId, ReportEntity reportEntity) {
		SqlMapSession ssn = null;
		ReportEntity result = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reportEntity.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.ADD_REPORT, paramArr);

			ssn.update("rpt.add-report-object", reportEntity);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(reportEntity.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			result = (ReportEntity) ssn.queryForObject("rpt.get-report-objects", convertQueryParams(params));

		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public ReportEntity modifyReportObject(Long userSessionId, ReportEntity reportEntity) {
		SqlMapSession ssn = null;
		ReportEntity result = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reportEntity.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.ADD_REPORT, paramArr);

			ssn.update("rpt.modify-report-object", reportEntity);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(reportEntity.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			result = (ReportEntity) ssn.queryForObject("rpt.get-report-objects", convertQueryParams(params));

		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public void removeReportObject(Long userSessionId, ReportEntity reportEntity) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(reportEntity.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, ReportPrivConstants.REMOVE_REPORT, paramArr);

			ssn.delete("rpt.remove-report-object", reportEntity);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings ("unchecked")

	public Parameter[] getEntityObjectValues(Long userSessionId, SelectionParams params) throws UserException {
		SqlMapSession ssn = null;
		try {
			Map<String, Object> map = new HashMap<String, Object>();
			Filter[] filters = params.getFilters();
			for (int i = 1; i < filters.length; i++) {
				map.put(filters[i].getElement(), filters[i].getValue());
			}

			ssn = getIbatisSessionNoContext();
			ssn.update("rpt.get-entity-object-info", map);
			List<Parameter> results = (List<Parameter>) map.get("resultSet");
			return results.toArray(new Parameter[results.size()]);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw new DataAccessException(e);
			}
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings ("unchecked")
	public Integer getReportIdByTemplate(Long userSessionId, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSessionFE(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			return (Integer) ssn.queryForObject("rpt.get-report-id-by-template", params);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings ("unchecked")
	public String getInstantCreditStatement(Long userSessionId, String account, Date effDate, String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("account", account);
			map.put("effDate", effDate);
			map.put("language", lang);
			ssn.update("rpt.get-instant-credit-statement", map);
			return (String) map.get("statement");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings ("unchecked")
	public String runReport(Long userSessionId, String lang, Long invoiceId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			HashMap<String, Object> map = new HashMap<String, Object>();
			map.put("language", lang);
			map.put("invoice", invoiceId);
			ssn.update("rpt.get-run-report", map);
			return (String) map.get("report");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings ("unchecked")
	public ReportResult runReport(Report report, Integer templateId, ReportParameter[] params) {
		return runReport(null, report, templateId, params);
	}


	@SuppressWarnings("unchecked")
	public Long getInvoiceIdByCardAndDate(String cardNumber, Date effDate, String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("card_number", cardNumber);
			map.put("eff_date", effDate);
			map.put("lang", lang);
			return (Long)ssn.queryForObject("rpt.get-invoice-id-by-card-and-date", map);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Integer getInstIdByCard(Long userSessionId, final String cardNumber) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("rpt.get-inst-id-by-card", cardNumber);
			}
		});
	}


	@SuppressWarnings("unchecked")
	public String getName(Long userSessionId, Integer instId, String entityType, Map<String, Object> params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("instId", instId);
			map.put("entityType", entityType);
			map.put("parameters", params);
			ssn.queryForObject("rpt.get-name", map);
			String out = (map.get("name") != null) ? (String)map.get("name") : null;
			return out;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public ReportParameter[] getReportParameters(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<ReportParameter> reportParameters = ssn.queryForList("rpt.get-report-parameters", convertQueryParams(params));
			return reportParameters.toArray(new ReportParameter[reportParameters.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Report getReport(Integer reportId, String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("id", reportId);
			map.put("lang", lang);
			return (Report)ssn.queryForObject("rpt.get-report", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ReportTemplate getReportTemplate(Long userSessionId, final Integer templateId, final String lang) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<ReportTemplate>() {
			@Override
			public ReportTemplate doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> params = new HashMap<String, Object>(2);
				params.put("id", templateId);
				params.put("lang", lang);
				return (ReportTemplate)ssn.queryForObject("rpt.get-rpt-template", params);
			}
		});
	}


	public List<ReportParameter> getReportParameters(Long userSessionId, final Integer reportId, final String lang) throws DataAccessException {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<ReportParameter>>() {
			@Override
			public List<ReportParameter> doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> params = new HashMap<String, Object>(2);
				params.put("reportId", reportId);
				params.put("lang", lang);
				return ssn.queryForList("rpt.get-rpt-template-params", params);
			}
		});
	}


	public List<ReportImage> getReportImages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  ReportPrivConstants.VIEW_REPORT_BANNER,
								  params,
								  logger,
								  new IbatisSessionCallback<List<ReportImage>>() {
			@Override
			public List<ReportImage> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("rpt.get-report-images", convertQueryParams(params));
			}
		});
	}


	public int getReportImagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId,
								  ReportPrivConstants.VIEW_REPORT_BANNER,
								  params,
								  logger,
								  new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				Object count = ssn.queryForObject("rpt.get-report-images-count", convertQueryParams(params));
				return (count != null) ? (Integer)count : 0;
			}
		});
	}
}
