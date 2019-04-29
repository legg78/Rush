package ru.bpc.sv2.logic;

import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import org.apache.log4j.Logger;

import ru.bpc.sv2.audit.AuditTrail;
import ru.bpc.sv2.audit.AuditableObject;
import ru.bpc.sv2.audit.EntityType;
import ru.bpc.sv2.audit.TrailDetails;
import ru.bpc.sv2.common.*;
import ru.bpc.sv2.common.arrays.*;
import ru.bpc.sv2.common.rates.Rate;
import ru.bpc.sv2.common.rates.RatePair;
import ru.bpc.sv2.common.rates.RateType;
import ru.bpc.sv2.constants.DataTypes;
import ru.bpc.sv2.constants.DictNames;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.fcl.cycles.Cycle;
import ru.bpc.sv2.fcl.cycles.CycleShift;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.controller.LovController;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.process.ProcessPrivConstants;
import ru.bpc.sv2.process.ProcessSession;
import ru.bpc.sv2.process.ProcessTrace;
import ru.bpc.sv2.utils.AuditParamUtil;
import ru.bpc.sv2.utils.KeyLabelItem;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class Cycles
 */
public class CommonDao extends IbatisAware {

	/**
	 * Default constructor.
	 */
	public CommonDao() {
	}

	private static final Logger logger = Logger.getLogger("COMMON");

	@SuppressWarnings("unchecked")
	public Dictionary[] getDictionaries(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_DICTIONARY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_DICTIONARY);
			List<Dictionary> dicts = ssn.queryForList("common.get-dictionaries",
					convertQueryParams(params, limitation));

			return dicts.toArray(new Dictionary[dicts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getDictionariesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_DICTIONARY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_DICTIONARY);
			return (Integer) ssn.queryForObject("common.get-dictionaries-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Dictionary createDictionary(Long userSessionId, Dictionary dict) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dict.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_DICTIONARY_ARTICLE, paramArr);

			ssn.insert("common.insert-new-dictionary", dict);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("dict");
			filters[0].setValue(DictNames.MAIN_DICTIONARY);
			filters[1] = new Filter();
			filters[1].setElement("code");
			filters[1].setValue(dict.getCode());
			filters[2] = new Filter();
			filters[2].setElement("lang");
			filters[2].setValue(dict.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Dictionary) ssn.queryForObject("common.get-dictionaries",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Dictionary modifyDictionary(Long userSessionId, Dictionary dict) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(dict.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_DICTIONARY_ARTICLE, paramArr);
			ssn.insert("common.modify-article", dict);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("dict");
			filters[0].setValue(DictNames.MAIN_DICTIONARY);
			filters[1] = new Filter();
			filters[1].setElement("code");
			filters[1].setValue(dict.getCode());
			filters[2] = new Filter();
			filters[2].setElement("lang");
			filters[2].setValue(dict.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Dictionary) ssn.queryForObject("common.get-dictionaries",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Dictionary[] getArticles(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_DICTIONARY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_DICTIONARY);
			List<Dictionary> dicts = ssn.queryForList("common.get-dictionaries",
					convertQueryParams(params, limitation));

			return dicts.toArray(new Dictionary[dicts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public int getArticlesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_DICTIONARY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_DICTIONARY);
			return (Integer) ssn.queryForObject("common.get-dictionaries-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Dictionary createArticle(Long userSessionId, Dictionary article) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(article.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_DICTIONARY_ARTICLE, paramArr);

			ssn.insert("common.insert-new-article", article);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("dict");
			filters[0].setValue(article.getDict());
			filters[1] = new Filter();
			filters[1].setElement("code");
			filters[1].setValue(article.getCode());
			filters[2] = new Filter();
			filters[2].setElement("lang");
			filters[2].setValue(article.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Dictionary) ssn.queryForObject("common.get-dictionaries",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Dictionary modifyArticle(Long userSessionId, Dictionary article) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(article.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_DICTIONARY_ARTICLE, paramArr);
			ssn.insert("common.modify-article", article);

			Filter[] filters = new Filter[3];
			filters[0] = new Filter();
			filters[0].setElement("dict");
			filters[0].setValue(article.getDict());
			filters[1] = new Filter();
			filters[1].setElement("code");
			filters[1].setValue(article.getCode());
			filters[2] = new Filter();
			filters[2].setElement("lang");
			filters[2].setValue(article.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Dictionary) ssn.queryForObject("common.get-dictionaries",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteArticle(Long userSessionId, Dictionary article) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(article.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_DICTIONARY_ARTICLE, paramArr);

			ssn.delete("common.delete-article", article);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Dictionary[] getArticlesByDict(Long userSessionId, String dictName) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			if (dictName == null || dictName.equals("")) {
				return new Dictionary[0];
			}

			List<Dictionary> dicts = ssn.queryForList("common.get-articles-by-dict", dictName);

			return dicts.toArray(new Dictionary[dicts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String[] getArticlesByDictNoContext(String dictName) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			if (dictName == null || dictName.equals("")) {
				return new String[0];
			}

			List<String> dicts = ssn.queryForList("common.get-articles-by-dict-no-context", dictName);

			return dicts.toArray(new String[dicts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuditTrail[] getAuditLogTrails(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_AUDIT_LOGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_AUDIT_LOGS);
			List<AuditTrail> trails = ssn.queryForList("common.get-audit-trails",
					convertQueryParams(params, limitation));

			return trails.toArray(new AuditTrail[trails.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAuditLogTrailsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_AUDIT_LOGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_AUDIT_LOGS);
			return (Integer) ssn.queryForObject("common.get-audit-trails-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public TrailDetails[] getTrailDetails(Long userSessionId, Long trailId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<TrailDetails> trails = ssn.queryForList("common.get-trail-details", trailId);

			return trails.toArray(new TrailDetails[trails.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuditableObject[] getAuditableObjects(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_AUDIT_SETTINGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_AUDIT_SETTINGS);
			List<AuditableObject> objects = ssn.queryForList("common.get-auditables",
					convertQueryParams(params, limitation));

			return objects.toArray(new AuditableObject[objects.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAuditableObjectsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_AUDIT_SETTINGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_AUDIT_SETTINGS);
			return (Integer) ssn.queryForObject("common.get-auditables-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void changeAuditableStatus(Long userSessionId, AuditableObject obj) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("common.change-auditable-status", obj);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public StateHoliday[] getStateHolidays(Long userSessionId, SelectionParams params, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_STATE_HOLIDAY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_STATE_HOLIDAY);
			List<StateHoliday> holidays = ssn.queryForList("common.get-state-holidays",
					convertQueryParams(params, limitation));

			return holidays.toArray(new StateHoliday[holidays.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getStateHolidayCounts(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(null);
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_STATE_HOLIDAY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_STATE_HOLIDAY);
			return (Integer) ssn.queryForObject("common.get-state-holidays-count", convertQueryParams(null, limitation));

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public StateHoliday addStateHoliday(Long userSessionId, StateHoliday holiday, Cycle cycle,
			ArrayList<CycleShift> cycleShifts) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(holiday.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_STATE_HOLIDAY, paramArr);

			ssn.update("cycles.insert-new-cycle", cycle);
			if (cycleShifts != null) {
				for (CycleShift shift: cycleShifts) {
					shift.setCycleId(cycle.getId());
					ssn.insert("cycles.insert-new-cycle-shift", shift);
				}
			}

			holiday.setCycleId(cycle.getId());
			ssn.insert("common.add-state-holiday", holiday);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(holiday.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(holiday.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (StateHoliday) ssn.queryForObject("common.get-state-holidays",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public StateHoliday editStateHoliday(Long userSessionId, StateHoliday holiday, Cycle cycle,
			ArrayList<CycleShift> newShifts, ArrayList<CycleShift> oldShifts) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(holiday.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_STATE_HOLIDAY, paramArr);

			ssn.update("cycles.modify-cycle", cycle);

			if (oldShifts != null && newShifts != null) {
				// look for old shifts among new shifts, update them if found,
				// delete if not
				for (CycleShift oldShift: oldShifts) {
					boolean found = false;
					for (CycleShift newShift: newShifts) {
						if (oldShift.getId().equals(newShift.getId())) {
							found = true;
							ssn.update("cycles.modify-cycle-shift", newShift);
							newShifts.remove(newShift);
							break;
						}
					}
					if (!found) {
						ssn.delete("cycles.remove-cycle-shift", oldShift);
					}
				}

				// The remnants of newShifts are really new. Save them.
				for (CycleShift shift: newShifts) {
					shift.setId(null);
					shift.setCycleId(cycle.getId());
					ssn.insert("cycles.insert-new-cycle-shift", shift);
				}
			}

			ssn.insert("common.edit-state-holiday", holiday);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(holiday.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(holiday.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (StateHoliday) ssn.queryForObject("common.get-state-holidays",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeStateHoliday(Long userSessionId, Integer id) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(null);
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_STATE_HOLIDAY, paramArr);

			ssn.delete("common.remove-state-holiday", id);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public void addRemoveHoliday(Long userSessionId, Date date, Integer instId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			HashMap map = new HashMap();
			map.put("date", date);
			map.put("instId", instId);
			ssn.update("common.add-remove-holiday", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String[] getMonthYears(Long userSessionId) {

		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<String> mmyys = ssn.queryForList("common.get-mmyys");
			return mmyys.toArray(new String[mmyys.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String[] getCalendarYears(Long userSessionId) {

		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<String> years = ssn.queryForList("common.get-calendar-years");
			return years.toArray(new String[years.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Week[] getCalendarWeeks(Long userSessionId, String month, int year, Integer instId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			List<Week> objects;

			HashMap map = new HashMap();
			map.put("year", year);
			map.put("instId", instId);

			if (month == null) {
				objects = ssn.queryForList("common.get-weeks", map);
			} else {
				map.put("month", month);
				objects = ssn.queryForList("common.get-weeks-in-month", map);
			}
			return objects.toArray(new Week[objects.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public SettlementDay[] getSettlementDays(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_SETTLEMENT_DAY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_SETTLEMENT_DAY);
			List<SettlementDay> holidays = ssn.queryForList("common.get-settlement-days",
					convertQueryParams(params, limitation));

			return holidays.toArray(new SettlementDay[holidays.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSettlementDaysCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_SETTLEMENT_DAY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_SETTLEMENT_DAY);
			return (Integer) ssn.queryForObject("common.get-settlement-days-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Dictionary[] getAllArticles(String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();

			List<Dictionary> articles = ssn.queryForList("common.get-all-articles", lang);
			return articles.toArray(new Dictionary[articles.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String getDml(Long userSessionId, String dictCode) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			HashMap map = new HashMap();
			map.put("code", dictCode);
			map.put("ref", new ArrayList<String>());
			String txt = "";
			List<String> lst = ssn.queryForList("common.get-dml", map);
			for (Iterator<String> it = lst.iterator(); it.hasNext();) {
				txt += it.next() + "\n";
			}
			return txt;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Country[] getCountries(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		String limitation = null;
		try {
			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
			} else {
				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
				ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_COUNTRY, paramArr);
				limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_COUNTRY);
			}

			List<Country> countries = ssn.queryForList("common.get-countries",
					convertQueryParams(params, limitation));
			return countries.toArray(new Country[countries.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getCountriesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_COUNTRY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_COUNTRY);
			return (Integer) ssn.queryForObject("common.get-countries-count",
					convertQueryParams(params, limitation));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Address addAddress(Long userSessionId, Address address) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(address.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ADDRESS, paramArr);

			ssn.update("common.add-address-relation", address);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("relationId");
			filters[0].setValue(address.getAddressObjectId());
			filters[1] = new Filter();
			filters[1].setElement("currentLang");
			filters[1].setValue(address.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Address) ssn.queryForObject("common.get-addresses", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Address[] getAddresses(Long userSessionId, SelectionParams params, String curLang) {
		SqlMapSession ssn = null;
		try {
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : CommonPrivConstants.VIEW_ADDRESS);
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<Address> adrs = ssn.queryForList("common.get-addresses", convertQueryParams(
					params, limitation, curLang));

			// remove all blank addresses which are addresses that
			// exist neither on default language nor on requested
			for (int i = adrs.size() - 1; i >= 0; i--) {
				if (adrs.get(i).getAddressId() == null) {
					adrs.remove(i);
				}
			}

			return adrs.toArray(new Address[adrs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public int getAddressesCount(Long userSessionId, SelectionParams params, String curLang) {
		SqlMapSession ssn = null;
		try {
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : CommonPrivConstants.VIEW_ADDRESS);
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<Address> adrs = ssn.queryForList("common.get-addresses", convertQueryParams(
					params, limitation, curLang));

			// remove all blank addresses which are addresses that
			// exist neither on default language nor on requested
			for (int i = adrs.size() - 1; i >= 0; i--) {
				if (adrs.get(i).getAddressId() == null) {
					adrs.remove(i);
				}
			}
			return adrs.size();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public String[] getAddressLangs(Long userSessionId, Address address) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<String> langs = ssn.queryForList("common.get-address-langs", address
					.getAddressId());
			return langs.toArray(new String[langs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteAddress(Long userSessionId, Address address) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(address.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ADDRESS, paramArr);

			ssn.update("common.remove-address", address);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteAddressObject(Long userSessionId, Address address) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("common.remove-address-object", address);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Address editAddress(Long userSessionId, Address address) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(address.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_ADDRESS, paramArr);

			ssn.update("common.edit-address", address);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("relationId");
			filters[0].setValue(address.getAddressObjectId());
			filters[1] = new Filter();
			filters[1].setElement("currentLang");
			filters[1].setValue(address.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Address) ssn.queryForObject("common.get-addresses", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public List<String> exportDescriptions(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<String> lst = ssn.queryForList("common.get-all-descriptions");

			return lst;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public FlexFieldData[] getFlexFieldsData(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : CommonPrivConstants.VIEW_FLEXIBLE_DATA);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<FlexFieldData> fields = ssn.queryForList("common.get-flex-fields-data",
					convertQueryParams(params, limitation));
			return fields.toArray(new FlexFieldData[fields.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public FlexFieldData[] getFlexFieldsDataWithChildEntities(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : CommonPrivConstants.VIEW_FLEXIBLE_DATA);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			List<FlexFieldData> fields = ssn.queryForList("common.get-flex-fields-data-with-child-entities",
					convertQueryParams(params, limitation));
			return fields.toArray(new FlexFieldData[fields.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFlexFieldsDataCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : CommonPrivConstants.VIEW_FLEXIBLE_DATA);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			return (Integer) ssn.queryForObject("common.get-flex-fields-data-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFlexFieldsDataWithChildEntitiesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			String privil = (params.getPrivilege()!=null ? params.getPrivilege() : CommonPrivConstants.VIEW_FLEXIBLE_DATA);
			ssn = getIbatisSession(userSessionId, null, privil, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, privil);
			return (Integer) ssn.queryForObject("common.get-flex-fields-data-with-child-entities-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public FlexField[] getFlexFields(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_FLEXIBLE_FIELD, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_FLEXIBLE_FIELD);
			List<FlexField> fields = ssn.queryForList("common.get-flex-fields", convertQueryParams(params, limitation));
			return fields.toArray(new FlexField[fields.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getFlexFieldsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_FLEXIBLE_FIELD, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_FLEXIBLE_FIELD);
			return (Integer) ssn.queryForObject("common.get-flex-fields-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public FlexField createFlexField(Long userSessionId, FlexField ffield) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ffield.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_FLEXIBLE_FIELD, paramArr);

			ssn.insert("common.add-flex-field", ffield);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(ffield.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(ffield.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (FlexField) ssn.queryForObject("common.get-flex-fields",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteFlexField(Long userSessionId, FlexField field) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(field.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_FLEXIBLE_FIELD, paramArr);

			ssn.delete("common.delete-flex-field", field);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public FlexField updateFlexField(Long userSessionId, FlexField ffield, String currLang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ffield.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_FLEXIBLE_FIELD, paramArr);

			ssn.update("common.modify-flex-field", ffield);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(ffield.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(currLang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (FlexField) ssn.queryForObject("common.get-flex-fields",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	public FlexFieldData setFlexFieldData(Long userSessionId, FlexFieldData ffdata) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			if (ffdata.isChar()) {
				ssn.update("common.set-flexible-value_v", ffdata);
			} else if (ffdata.isNumber()) {
				ssn.update("common.set-flexible-value_n", ffdata);
			} else if (ffdata.isDate()) {
				ssn.update("common.set-flexible-value_d", ffdata);
			}
			return ffdata;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Contact addContact(Long userSessionId, Contact contact, String entityType, Long objectId) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contact.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_CONTACT, paramArr);

			ssn.update("common.add-contact", contact);
			ContactData data = new ContactData();
			data.setContactId(contact.getId());
			data.setAddress(contact.getAddress());
			data.setType(contact.getType());
			ssn.update("common.add-contact-data", data);

			HashMap paramMap = new HashMap();
			paramMap.put("objectId", objectId);
			paramMap.put("entityType", entityType);
			paramMap.put("contactId", contact.getId());

			paramMap.put("contactType", contact.getContactType());
			ssn.update("common.add-contact-relation", paramMap);
			contact.setRelationId((Long) paramMap.get("relationId"));

			return contact;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Contact[] getContacts(Long userSessionId, SelectionParams params, String curLang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_CONTACT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CONTACT);
			List<Contact> contacts = ssn.queryForList("common.get-contacts", convertQueryParams(
					params, limitation, curLang));
			return contacts.toArray(new Contact[contacts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContactsCount(Long userSessionId, SelectionParams params, String curLang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_CONTACT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CONTACT);
			return (Integer) ssn.queryForObject("common.get-contacts-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Contact[] getUserPersonContacts(Long userSessionId, final SelectionParams params, final String curLang) {
		return executeWithSession(userSessionId,
				CommonPrivConstants.VIEW_CONTACT,
				AuditParamUtil.getCommonParamRec(params.getFilters()),
				logger,
				new IbatisSessionCallback<Contact[]>() {
					@Override
					public Contact[] doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CONTACT);
						List<Contact> contacts =  ssn.queryForList("common.get-user-person-contacts", convertQueryParams(params, limitation, curLang));
						return contacts.toArray(new Contact[contacts.size()]);
					}
				});
	}


	public int getUserPersonContactsCount(Long userSessionId, final SelectionParams params, final String curLang) {
		return executeWithSession(userSessionId,
				CommonPrivConstants.VIEW_CONTACT,
				AuditParamUtil.getCommonParamRec(params.getFilters()),
				logger,
				new IbatisSessionCallback<Integer>() {
					@Override
					public Integer doInSession(SqlMapSession ssn) throws Exception {
						String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CONTACT);
						Object result = ssn.queryForObject("common.get-user-person-contacts-count", convertQueryParams(params, limitation, curLang));
						return (result != null) ? (Integer)result : 0;
					}
				});
	}

	@SuppressWarnings("unchecked")
	public ContactData[] getContactDatas(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_CONTACT_DATA, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CONTACT_DATA);
			List<ContactData> contacts = ssn.queryForList("common.get-contact-datas", convertQueryParams(
					params, limitation));
			return contacts.toArray(new ContactData[contacts.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getContactDatasCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_CONTACT_DATA, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CONTACT_DATA);
			return (Integer) ssn.queryForObject("common.get-contact-datas-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public ContactData addContactData(Long userSessionId, ContactData contactData) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contactData.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_CONTACT_DATA, paramArr);
			ssn.update("common.add-contact-data", contactData);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter("id", contactData.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ContactData) ssn.queryForObject("common.get-contact-datas",
					convertQueryParams(params));

		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public ContactData modifyContactData(Long userSessionId, ContactData contactData) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contactData.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_CONTACT_DATA, paramArr);
			ssn.update("common.modify-contact-data", contactData);
			Filter[] filters = new Filter[1];
			filters[0] = new Filter("id", contactData.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ContactData) ssn.queryForObject("common.get-contact-datas",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	public void deleteContactData(Long userSessionId, ContactData contactData) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contactData.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_CONTACT_DATA, paramArr);
			ssn.update("common.remove-contact-data", contactData);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}



	public Contact editContact(Long userSessionId, Contact contact) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contact.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_CONTACT, paramArr);

			ssn.update("common.modify-contact", contact);

			// as we don't modify anything that could require getting data from
			// other tables we don't have to query for modified object
			return contact;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteContact(Long userSessionId, Contact contact) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(contact.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_CONTACT, paramArr);
			ssn.update("common.remove-contact-object", contact);
			ssn.update("common.remove-contact", contact);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Person[] getPersons(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.SEARCH_PERSON, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.SEARCH_PERSON);
			List<Person> persons = ssn.queryForList("common.get-persons",
					convertQueryParams(params, limitation));
			return persons.toArray(new Person[persons.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getPersonsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.SEARCH_PERSON, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.SEARCH_PERSON);
			return (Integer) ssn.queryForObject("common.get-persons-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Person getPersonById(Long userSessionId, Long personId, String lang) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return CommonController.getPersonById(ssn, personId, lang);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public String[] getPersonLangs(Long userSessionId, Long personId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<String> langs = ssn.queryForList("common.get-person-langs", personId);
			return langs.toArray(new String[langs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Person addPerson(Long userSessionId, Person person) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(person.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_PERSON, paramArr);

			ssn.update("common.add-person", person);

			return (Person) ssn.queryForObject("common.get-person-by-id", person);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Person addPersonWithIds(Long userSessionId, Person person, ArrayList<PersonId> ids) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.insert("common.add-person", person);

			if (ids != null && ids.size() > 0) {
				for (PersonId id: ids) {
					id = (PersonId) id.clone();
					id.setObjectId(person.getPersonId());
					id.setEntityType(EntityNames.PERSON);
					id.setInstId(person.getInstId());
					id.setId(null);

					ssn.insert("common.add-object-id", id);
				}
			}

			return (Person) ssn.queryForObject("common.get-person-by-id", person);
		} catch (SQLException e) {
			throw createDaoException(e);
		} catch (CloneNotSupportedException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Person modifyPerson(Long userSessionId, Person person) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(person.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_PERSON, paramArr);

			ssn.update("common.modify-person", person);

			return (Person) ssn.queryForObject("common.get-person-by-id", person);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Person modifyPersonWithIds(Long userSessionId, Person person,
			ArrayList<PersonId> newIds, ArrayList<PersonId> oldIds) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("common.modify-person", person);

			// look for old ids among new ids, update them if found, delete if
			// not
			for (PersonId oldId: oldIds) {
				boolean found = false;
				for (PersonId newId: newIds) {
					if (oldId.getId().equals(newId.getId())) {
						found = true;
						ssn.update("common.modify-object-id", newId);
						newIds.remove(newId);
						break;
					}
				}
				if (!found) {
					Map<String, Long> map = new HashMap<String, Long>();
					map.put("id", oldId.getId());
					ssn.delete("common.remove-object-id", map);
				}
			}

			// add new ids
			for (PersonId newId: newIds) {
				newId = (PersonId) newId.clone();
				newId.setId(null);
				newId.setInstId(person.getInstId());
				ssn.insert("common.add-object-id", newId);
			}

			return (Person) ssn.queryForObject("common.get-person-by-id", person);
		} catch (SQLException e) {
			throw createDaoException(e);
		} catch (CloneNotSupportedException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removePerson(Long userSessionId, Person person) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(person.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_PERSON, paramArr);

			ssn.update("common.remove-person", person);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public PersonId[] getObjectIds(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_PERSON_ID, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_PERSON_ID);
			List<PersonId> personIds = ssn.queryForList("common.get-object-ids",
					convertQueryParams(params, limitation));
			return personIds.toArray(new PersonId[personIds.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getObjectIdsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_PERSON_ID, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_PERSON_ID);
			return (Integer) ssn.queryForObject("common.get-object-ids-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PersonId addPersonId(Long userSessionId, PersonId personId) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(personId.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_PERSON_ID, paramArr);

			ssn.update("common.add-object-id", personId);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter("id", personId.getId());
			filters[1] = new Filter("lang", personId.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PersonId) ssn.queryForObject("common.get-object-ids",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public PersonId modifyPersonId(Long userSessionId, PersonId personId) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(personId.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_PERSON_ID, paramArr);

			ssn.update("common.modify-object-id", personId);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter("id", personId.getId());
			filters[1] = new Filter("lang", personId.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (PersonId) ssn.queryForObject("common.get-object-ids",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removePersonId(Long userSessionId, Long id) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(null);
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_PERSON_ID, paramArr);
			Map<String, Long> map = new HashMap<String, Long>();
			map.put("id", id);
			ssn.delete("common.remove-object-id", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public List<String> getEntityTypes(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return ssn.queryForList("common.get-entity-types");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	@SuppressWarnings("unchecked")
	public Currency[] getCurrencies(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		String limitation = null;
		try {
			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
			} else {
				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
				ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_CURRENCY, paramArr);
				limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CURRENCY);
			}
			List<Currency> currs = ssn.queryForList("common.get-currencies",
					convertQueryParams(params, limitation));

			return currs.toArray(new Currency[currs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getCurrenciesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_CURRENCY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CURRENCY);
			return (Integer) ssn.queryForObject("common.get-currencies-count",
					convertQueryParams(params, limitation));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public HashMap<String, EntityType> getEntityTypeObjects(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<EntityType> types = ssn.queryForList("common.get-entity-type-objects");
			HashMap<String, EntityType> result = new HashMap<String, EntityType>();

			for (EntityType type: types) {
				result.put(type.getEntityType(), type);
			}
			return result;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Label[] getLabels(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_LABEL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_LABEL);
			List<Label> labels = ssn.queryForList("common.get-labels", convertQueryParams(params, limitation));

			return labels.toArray(new Label[labels.size()]);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getLabelsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_LABEL, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_LABEL);
			return (Integer) ssn.queryForObject("common.get-labels-count",
					convertQueryParams(params, limitation));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Label[] getCaptions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_CAPTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CAPTION);
			List<Label> labels = ssn
					.queryForList("common.get-captions", convertQueryParams(params, limitation));

			return labels.toArray(new Label[labels.size()]);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getCaptionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_CAPTION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_CAPTION);
			return (Integer) ssn.queryForObject("common.get-captions-count",
					convertQueryParams(params, limitation));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addLabel(Long userSessionId, Label label) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("common.add-label", label);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Label getLabelById(Long userSessionId, Label label) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return (Label) ssn.queryForObject("common.get-label-by-id", label);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ProcessTrace[] getProcessTrace(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_TRACE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_TRACE);
			List<ProcessTrace> traces = ssn.queryForList("trace.get-trace",
					convertQueryParams(params, limitation));
			return traces.toArray(new ProcessTrace[traces.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getProcessTraceCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_TRACE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_TRACE);
			return (Integer) ssn
					.queryForObject("trace.get-trace-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public MenuNode[] getMenus(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MenuNode> menus = ssn.queryForList("common.get-menus",
					convertQueryParams(params));

			return menus.toArray(new MenuNode[menus.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public MenuNode[] getSearchMenus(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MenuNode> menus = ssn.queryForList("common.get-search-menus",
					convertQueryParams(params));

			return menus.toArray(new MenuNode[menus.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public MenuNode[] getMenu(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MenuNode> menu = ssn.queryForList("common.get-menu");

			return menu.toArray(new MenuNode[menu.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
//	public MenuNode[] getMenuFavorites(Long userSessionId, boolean isPlain) {
	public MenuNode[] getMenuFavorites(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MenuNode> menu = null;
//			if (isPlain) {
//				menu = ssn.queryForList("common.get-menu-favorites-plain");
//			} else {
				menu = ssn.queryForList("common.get-menu-favorites");
//			}
			return menu.toArray(new MenuNode[menu.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void addToFavourites(Long userSessionId, Long sectionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("common.add-to-favourites", sectionId);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeFromFavourites(Long userSessionId, Long sectionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("common.remove-from-favourites", sectionId);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public MenuNode[] getMenuAll(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MenuNode> menu = ssn.queryForList("common.get-menu-all");

			return menu.toArray(new MenuNode[menu.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public KeyLabelItem[] getLov(int lovId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			return LovController.getLov(ssn, lovId);
		} catch (SQLException e) {
			logger.error("LOV ID = " + lovId, e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public KeyLabelItem[] getLov(Long userSessionId, int lovId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return LovController.getLov(ssn, lovId);
		} catch (SQLException e) {
			logger.error("LOV ID = " + lovId, e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public KeyLabelItem[] getLovStyleIcon(Long userSessionId, int lovId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return LovController.getLovStyleIcon(ssn, lovId);
		} catch (SQLException e) {
			logger.error("LOV ID = " + lovId, e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public KeyLabelItem[] getLov(Long userSessionId, int lovId, Map<String, Object> params,
			List<String> where, String appearance) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return LovController.getLov(ssn, lovId, params, where, appearance);
		} catch (SQLException e) {
			logger.error("LOV ID = " + lovId, e);
			throw new DataAccessException(e);
		} catch (Exception e) {
			logger.error("LOV ID = " + lovId, e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}

	}


	public KeyLabelItem[] getLovNoContext(int lovId, Map<String, Object> params,
			List<String> where, String appearance) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			return LovController.getLov(ssn, lovId, params, where, appearance);
		} catch (SQLException e) {
			logger.error("LOV ID = " + lovId, e);
			throw new DataAccessException(e);
		} catch (Exception e) {
			logger.error("LOV ID = " + lovId, e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}

	}


	public KeyLabelItem[] getArray(Long userSessionId, int arrayId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return LovController.getArray(ssn, arrayId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	@SuppressWarnings("unchecked")
	public MenuNode[] getModalWindows(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MenuNode> menu = ssn.queryForList("common.get-modal-windows");

			return menu.toArray(new MenuNode[menu.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	// -------------------------------------------------------------------
	// MENU CREATION
	// -------------------------------------------------------------------

	@SuppressWarnings("unchecked")
	public MenuNode[] getMenuLight(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<MenuNode> menu = ssn.queryForList("common.get-menu-light");

			return menu.toArray(new MenuNode[menu.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MenuNode addMenuNode(Long userSessionId, MenuNode menuNode) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.insert("common.add-menu-node", menuNode);

			return menuNode;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MenuNode modifyMenuNode(Long userSessionId, MenuNode menuNode) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("common.update-menu-node", menuNode);

			return menuNode;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteMenuNode(Long userSessionId, Integer nodeId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.delete("common.delete-menu-node", nodeId);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	// -------------------------------------------------------------------
	// END MENU CREATION
	// -------------------------------------------------------------------


	@SuppressWarnings("unchecked")
	public List<Lov> getLovsList(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_LOV, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_LOV);
			return ssn.queryForList("common.get-lovs-list", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Lov[] getLovs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_LOV, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_LOV);
			List<Lov> lovs = ssn.queryForList("common.get-lovs", convertQueryParams(params, limitation));

			return (Lov[]) lovs.toArray(new Lov[lovs.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getLovsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_LOV, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_LOV);
			return (Integer) ssn
					.queryForObject("common.get-lovs-count", convertQueryParams(params, limitation));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Lov addLov(Long userSessionId, Lov lov) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(lov.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_LOV, paramArr);

			ssn.update("common.add-lov", lov);

			return lov;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Lov editLov(Long userSessionId, Lov lov) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(lov.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_LOV, paramArr);

			ssn.update("common.edit-lov", lov);

			return lov;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	// -------------------------------------------------------------------
	// RATES
	// -------------------------------------------------------------------
	@SuppressWarnings("unchecked")
	public RateType[] getRateTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_RATE_TYPES);
			List<RateType> types = ssn.queryForList("common.get-rate-types",
					convertQueryParams(params, limitation));

			return types.toArray(new RateType[types.size()]);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getRateTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_RATE_TYPES);
			return (Integer) ssn.queryForObject("common.get-rate-types-count",
					convertQueryParams(params, limitation));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public RateType addRateType(Long userSessionId, RateType rateType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rateType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_RATE_TYPE, paramArr);

			ssn.update("common.add-rate-type", rateType);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(rateType.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (RateType) ssn.queryForObject("common.get-rate-types",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public RateType editRateType(Long userSessionId, RateType rateType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rateType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_RATE_TYPE, paramArr);

			ssn.update("common.edit-rate-type", rateType);

			// as we don't modify anything that could require getting data from
			// other tables and changed seqNum is returned into object we don't
			// have to query for modified object
			return rateType;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRateType(Long userSessionId, RateType rateType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rateType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_RATE_TYPE, paramArr);

			ssn.update("common.delete-rate-type", rateType);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public RatePair[] getRatePairs(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_RATE_PAIRS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_RATE_PAIRS);
			List<RatePair> pairs = ssn.queryForList("common.get-rate-pairs",
					convertQueryParams(params, limitation));

			return pairs.toArray(new RatePair[pairs.size()]);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getRatePairsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_RATE_PAIRS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_RATE_PAIRS);
			return (Integer) ssn.queryForObject("common.get-rate-pairs-count",
					convertQueryParams(params, limitation));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public RatePair addRatePair(Long userSessionId, RatePair ratePair) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ratePair.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_RATE_PAIR, paramArr);

			ssn.update("common.add-rate-pair", ratePair);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(ratePair.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (RatePair) ssn.queryForObject("common.get-rate-pairs",
					convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public RatePair editRatePair(Long userSessionId, RatePair ratePair) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ratePair.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_RATE_PAIR, paramArr);

			ssn.update("common.edit-rate-pair", ratePair);

			// as we don't modify anything that could require getting data from
			// other tables and changed seqNum is returned into object we don't
			// have to query for modified object
			return ratePair;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteRatePair(Long userSessionId, RatePair ratePair) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ratePair.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_RATE_PAIR, paramArr);

			ssn.update("common.delete-rate-pair", ratePair);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Rate[] getRatePairsToAdd(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId);
			List<Rate> pairs = ssn.queryForList("common.get-rate-pairs-to-add", convertQueryParams(params));
			return pairs.toArray(new Rate[pairs.size()]);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Rate[] getRates(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_RATES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_RATES);
			List<Rate> list = ssn.queryForList("common.get-rates", convertQueryParams(params, limitation));
			return list.toArray(new Rate[list.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getRatesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_RATES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_RATES);
			return (Integer) ssn.queryForObject("common.get-rates-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public List<Rate> setRate(Long userSessionId, Rate rate) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.SET_RATE, paramArr);

			ssn.insert("common.set-rate", rate);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("initiateId");
			filters[0].setValue(rate.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			params.setRowIndexEnd(Integer.MAX_VALUE);

			return ssn.queryForList("common.get-rates", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public List<Rate> setRates(Long userSessionId, Rate[] rates) {
		SqlMapSession ssn = null;
		List<Rate> addedRates = null;
		try {
			for (Rate rate : rates) {
				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rate.getAuditParameters());
				ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.SET_RATE, paramArr);
				ssn.insert("common.set-rate", rate);
				SelectionParams params = new SelectionParams(new Filter("initiateId", rate.getId().toString()));
				params.setRowIndexEnd(Integer.MAX_VALUE);
				List<Rate> newRates = (List<Rate>)ssn.queryForList("common.get-rates", convertQueryParams(params));
				if (newRates.size() > 0) {
					if (addedRates == null) {
						addedRates = new ArrayList<Rate>();
					}
					addedRates.addAll(newRates);
				}
			}
			return addedRates;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			if (addedRates == null) {
				addedRates = Collections.EMPTY_LIST;
			}
			close(ssn);
		}
	}


	public Rate checkRate(Long userSessionId, Rate rate) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.CHECK_RATE, paramArr);

			ssn.update("common.check-rate", rate);

			return rate;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void invalidateRates(Long userSessionId, List<Rate> rates) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(null);
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.INVALIDATE_RATE, paramArr);

			for (Rate rate: rates) {
				if (rate.isInvalidate()) {
					ssn.update("common.invalidate-rate", rate);
				}
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Rate invalidateRate(Long userSessionId, Rate rate) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(rate.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.INVALIDATE_RATE, paramArr);

			ssn.update("common.invalidate-rate", rate);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(rate.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Rate) ssn.queryForObject("common.get-rates", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	// -------------------------------------------------------------------
	// END RATES
	// -------------------------------------------------------------------


	public String getLastVersion(Long userSessionId) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionNoContext();

			return (String) ssn.queryForObject("common.get-last-version");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void importLabels(Long userSessionId, ArrayList<Label> labels) {
		SqlMapSession ssn = null;

		try {
			ssn = getIbatisSessionFE(userSessionId);

			for (Label label: labels) {
				ssn.update("common.add-label", label);
			}
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public Company[] getCompanies(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.SEARCH_COMPANY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.SEARCH_COMPANY);
			List<Company> companies = ssn.queryForList("common.get-companies",
					convertQueryParams(params, limitation));
			return companies.toArray(new Company[companies.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCompaniesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.SEARCH_COMPANY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.SEARCH_COMPANY);
			return (Integer) ssn.queryForObject("common.get-companies-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public IdType[] getIdTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ID_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ID_TYPE);
			List<IdType> idTypes = ssn.queryForList("common.get-id-types",
					convertQueryParams(params, limitation));

			return idTypes.toArray(new IdType[idTypes.size()]);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getIdTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ID_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ID_TYPE);
			return (Integer) ssn.queryForObject("common.get-id-types-count",
					convertQueryParams(params, limitation));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public IdType addIdType(Long userSessionId, IdType idType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(idType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ID_TYPE, paramArr);

			ssn.update("common.add-id-type", idType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(idType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(idType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (IdType) ssn.queryForObject("common.get-id-types", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public IdType modifyIdType(Long userSessionId, IdType idType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(idType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_ID_TYPE, paramArr);

			ssn.update("common.modify-id-type", idType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(idType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(idType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (IdType) ssn.queryForObject("common.get-id-types", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeIdType(Long userSessionId, IdType idType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(idType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ID_TYPE, paramArr);

			ssn.update("common.remove-id-type", idType);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Translation[] getTranslations(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<Translation> translations = ssn.queryForList("common.get-translations",
					convertQueryParams(params));

			return translations.toArray(new Translation[translations.size()]);
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getTranslationCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			return (Integer) ssn.queryForObject("common.get-translation-count",
					convertQueryParams(params));
		} catch (Exception e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifyTranslations(Long userSessionId, Translation translation) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("common.modify-translation-source", translation);
			ssn.update("common.modify-translation-dest", translation);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifyTranslationSource(Long userSessionId, Translation translation) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("common.modify-translation-source", translation);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void modifyTranslationDest(Long userSessionId, Translation translation) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			ssn.update("common.modify-translation-dest", translation);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public String getErrorDetais(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			return (String) ssn.queryForObject("trace.get-error-details");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ArrayType[] getArrayTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_TYPE);
			List<ArrayType> arrayTypes = ssn.queryForList("common.get-array-types", convertQueryParams(params, limitation));
			return arrayTypes.toArray(new ArrayType[arrayTypes.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getArrayTypesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_TYPE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_TYPE);
			return (Integer) ssn.queryForObject("common.get-array-types-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ArrayType addArrayType(Long userSessionId, ArrayType arrayType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ARRAY_TYPE, paramArr);
			ssn.insert("common.add-array-type", arrayType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(arrayType.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(arrayType.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ArrayType) ssn.queryForObject("common.get-array-types",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ArrayType editArrayType(Long userSessionId, ArrayType arrayType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_ARRAY_TYPE, paramArr);
			ssn.update("common.edit-array-type", arrayType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(arrayType.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(arrayType.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ArrayType) ssn.queryForObject("common.get-array-types",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteArrayType(Long userSessionId, ArrayType arrayType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ARRAY_TYPE, paramArr);
			ssn.delete("common.delete-array-type", arrayType);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Array[] getArrays(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY);
			List<Array> arrays = ssn.queryForList("common.get-arrays", convertQueryParams(params, limitation));
			return arrays.toArray(new Array[arrays.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getArraysCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY);
			return (Integer) ssn.queryForObject("common.get-arrays-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Array addArray(Long userSessionId, Array array) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(array.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ARRAY, paramArr);
			ssn.insert("common.add-array", array);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(array.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(array.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (Array) ssn.queryForObject("common.get-arrays",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Array editArray(Long userSessionId, Array array) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(array.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_ARRAY, paramArr);
			ssn.update("common.edit-array", array);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(array.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(array.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (Array) ssn.queryForObject("common.get-arrays",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteArray(Long userSessionId, Array array) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(array.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ARRAY, paramArr);
			ssn.delete("common.delete-array", array);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    //todo must be removed as dublicate after finish default DefaultArrayElement functionality
	@SuppressWarnings("unchecked")
	public ArrayElement[] getArrayElements(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_ELEMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_ELEMENT);
			List<ArrayElement> objects = ssn.queryForList("common.get-array-elements", convertQueryParams(params, limitation));
			return objects.toArray(new ArrayElement[objects.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    //todo must be removed as dublicate after finish default DefaultArrayElement functionality

	public int getArrayElementsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_ELEMENT, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_ELEMENT);
			return (Integer) ssn.queryForObject("common.get-array-elements-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    //todo must be removed as dublicate after finish default DefaultArrayElement functionality

	public ArrayElement addArrayElement(Long userSessionId, ArrayElement arrayElement) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayElement.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ARRAY_ELEMENT, paramArr);
			ssn.insert("common.add-array-element", arrayElement);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(arrayElement.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(arrayElement.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ArrayElement) ssn.queryForObject("common.get-array-elements",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    //todo must be removed as dublicate after finish default DefaultArrayElement functionality

	public ArrayElement editArrayElement(Long userSessionId, ArrayElement arrayElement) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayElement.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_ARRAY_ELEMENT, paramArr);
			ssn.update("common.edit-array-element", arrayElement);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(arrayElement.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(arrayElement.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ArrayElement) ssn.queryForObject("common.get-array-elements",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

    //todo must be removed as dublicate after finish default DefaultArrayElement functionality

	public void deleteArrayElement(Long userSessionId, ArrayElement arrayElement) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayElement.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ARRAY_ELEMENT, paramArr);
			ssn.delete("common.delete-array-element", arrayElement);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ArrayConversion[] getArraysConversion(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_CONVERSION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_CONVERSION);
			List<ArrayConversion> arraysConversion = ssn.queryForList("common.get-arrays-conversion",
			        convertQueryParams(params, limitation));
			return arraysConversion.toArray(new ArrayConversion[arraysConversion.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getArraysConversionCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_CONVERSION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_CONVERSION);
			return (Integer) ssn.queryForObject("common.get-arrays-conversion-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ArrayConversion addArrayConversion(Long userSessionId, ArrayConversion arrayConv) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayConv.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ARRAY_CONVERSION, paramArr);
			ssn.insert("common.add-array-conversion", arrayConv);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(arrayConv.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(arrayConv.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ArrayConversion) ssn.queryForObject("common.get-arrays-conversion",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ArrayConversion editArrayConversion(Long userSessionId, ArrayConversion arrayConv) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayConv.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_ARRAY_CONVERSION, paramArr);
			ssn.update("common.edit-array-conversion", arrayConv);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("lang");
			filters[0].setValue(arrayConv.getLang());
			filters[1] = new Filter();
			filters[1].setElement("id");
			filters[1].setValue(arrayConv.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ArrayConversion) ssn.queryForObject("common.get-arrays-conversion",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteArrayConversion(Long userSessionId, ArrayConversion arrayConv) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayConv.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ARRAY_CONVERSION, paramArr);
			ssn.delete("common.delete-array-conversion", arrayConv);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public ArrayConvElement[] getArrayConvElems(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_CONV_ELEM, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_CONV_ELEM);
			List<ArrayConvElement> objects = ssn.queryForList("common.get-array-conv-elems", convertQueryParams(params, limitation));
			return objects.toArray(new ArrayConvElement[objects.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getArrayConvElemsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_CONV_ELEM, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_CONV_ELEM);
			return (Integer) ssn.queryForObject("common.get-array-conv-elems-count",
			        convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ArrayConvElement addArrayConvElem(Long userSessionId, ArrayConvElement arrayConvElem, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayConvElem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ARRAY_CONV_ELEM, paramArr);
			ssn.insert("common.add-array-conv-elem", arrayConvElem);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(arrayConvElem.getId().toString());

            filters[1] = new Filter("lang", lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ArrayConvElement) ssn.queryForObject("common.get-array-conv-elems",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ArrayConvElement editArrayConvElem(Long userSessionId, ArrayConvElement arrayConvElem, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayConvElem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_ARRAY_CONV_ELEM, paramArr);
			ssn.update("common.edit-array-conv-elem", arrayConvElem);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(arrayConvElem.getId().toString());

            filters[1] = new Filter("lang", lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			return (ArrayConvElement) ssn.queryForObject("common.get-array-conv-elems",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteArrayConvElem(Long userSessionId, ArrayConvElement arrayConvElem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayConvElem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ARRAY_CONV_ELEM, paramArr);
			ssn.delete("common.delete-array-conv-elem", arrayConvElem);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Object getFunctionValue(Long userSessionId, String functionName, String entityType,
			Long objectId, String dataType) {
		SqlMapSession ssn = null;
		CallableStatement stmt = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			stmt = ssn.getCurrentConnection().prepareCall(
					"{? = call " + functionName + "(?, ?)}");
			if (DataTypes.NUMBER.equals(dataType)) {
				stmt.registerOutParameter(1, java.sql.Types.NUMERIC);
			} else if (DataTypes.DATE.equals(dataType)) {
				stmt.registerOutParameter(1, java.sql.Types.DATE);
			} else {
				stmt.registerOutParameter(1, java.sql.Types.VARCHAR);
			}
			// can't use named parameters (unless we can name returned value
			// somehow) because : "Ordinal binding and Named binding cannot be combined!"
			stmt.setString(2, entityType);
			stmt.setLong(3, objectId);
			stmt.execute();
			Object result = null;

			if (DataTypes.NUMBER.equals(dataType)) {
				result = stmt.getLong(1);
			} else if (DataTypes.DATE.equals(dataType)) {
				result = stmt.getDate(1);
			} else {
				result = stmt.getString(1);
			}
			return result;
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			DBUtils.close(stmt);
			close(ssn);
		}
	}



	public Currency addCurrency(Long userSessionId, Currency currency) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(currency.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_CURRENCY, paramArr);
			ssn.update("common.add-currency", currency);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(currency.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(currency.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Currency) ssn.queryForObject("common.get-currencies",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCurrency(Long userSessionId, Currency currency) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(currency.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_CURRENCY, paramArr);
			ssn.update("common.remove-currency", currency);

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public Currency editCurrency(Long userSessionId, Currency currency) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(currency.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_CURRENCY, paramArr);
			ssn.update("common.modify-currency", currency);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(currency.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(currency.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Currency) ssn.queryForObject("common.get-currencies",
			        convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Date getDbSystemDate(Long userSessionId){
		SqlMapSession ssn = null;
		Date result = null;
		String oracleDateFormat = "yyyy.mm.dd hh24:mi:ss";
		String javaDateFormat = "yyyy.MM.dd HH:mm:ss";
		try {
			ssn = getIbatisSessionFE(userSessionId);
			Connection connection = ssn.getCurrentConnection();
			PreparedStatement ps = connection.prepareStatement("select to_char(current_date, '"
					+ oracleDateFormat + "') from dual");

			ResultSet rs = ps.executeQuery();
			rs.next();
			String dateString = rs.getString(1);

			SimpleDateFormat dateFormat = new SimpleDateFormat(javaDateFormat);
			result = dateFormat.parse(dateString);

		} catch (SQLException e) {
			throw createDaoException(e);
		} catch (ParseException e) {
			throw new DataAccessException(e.getCause().getMessage(), e);
		} finally {
			close(ssn);
		}
		return result;
	}


	public String getFlexFieldValue (String fieldName, String entityType, Long objectId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, Object> map = new HashMap<String, Object>();
			map.put("fieldName", fieldName);
			map.put("entityType", entityType);
			map.put("objectId", objectId);
			String result = (String)ssn.queryForObject("common.get-flex-field-value", map);
			return result;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public String getLastError(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String result = (String) ssn.queryForObject("common.get-last-error");
			return result;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public String getArrayOutElement(Long userSessionId, SelectionParams params) {
		// TODO: actually now it gets only char representation of element value
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String result = (String) ssn.queryForObject("common.get-array-out-element",
					convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public String getArrayOutElement(SelectionParams params) {
		// TODO: actually now it gets only char representation of element value
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			String result = (String) ssn.queryForObject("common.get-array-out-element",
					convertQueryParams(params));
			return result;
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Appearance[] getAppearances(Long userSessionId,
			SelectionParams params) {
		SqlMapSession ssn = null;
		List<Appearance> result = null;
		try {
			if (userSessionId == null) {
				ssn = getIbatisSessionNoContext();
				result = ssn.queryForList("common.get-appearance", convertQueryParams(params));
			} else {
				CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
				ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_APPEARANCES, paramArr);
				String limitation = CommonController.getLimitationByPriv(ssn,
						CommonPrivConstants.VIEW_APPEARANCES);
				result = ssn.queryForList("common.get-appearance", convertQueryParams(params, limitation));
			}
			return result.toArray(new Appearance[result.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getAppearanceCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_APPEARANCES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn,
					CommonPrivConstants.VIEW_APPEARANCES);
			return (Integer) ssn.queryForObject("common.get-appearance-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Appearance addAppearance(Long userSessionId, Appearance editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_APPEARANCE, paramArr);
			ssn.update("common.add-appearance", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			List<Appearance> items = ssn.queryForList("common.get-appearance",
					convertQueryParams(params));
			if (items.size() > 0){
				return items.get(0);
			} else {
				throw new IllegalStateException("");
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Appearance modifyAppearance(Long userSessionId,
			Appearance editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_APPEARANCE, paramArr);
			ssn.update("common.modify-appearance", editingItem);

			Filter[] filters = new Filter[1];
			Filter f = new Filter();
			f.setElement("id");
			f.setValue(editingItem.getId());
			filters[0] = f;
			SelectionParams params = new SelectionParams();
			params.setFilters(filters);
			List<Appearance> items = ssn.queryForList("common.get-appearance",
					convertQueryParams(params));
			if (items.size() > 0){
				return items.get(0);
			} else {
				throw new IllegalStateException("");
			}
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteAppearance(Long usersessionId, Appearance editingItem) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(editingItem.getAuditParameters());
			ssn = getIbatisSession(usersessionId, null, CommonPrivConstants.REMOVE_APPEARANCE, paramArr);
			ssn.update("common.remove-appearance", editingItem);
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}


	public String mapErrorCode(String errorCode) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			Map<String, String> map = new HashMap<String, String>();
			map.put("errorCode", errorCode);
			ssn.update("common.map-error-code", map);

			return map.get("mappedCode");
		} catch (SQLException e) {
			logger.error("", e);
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CommonWizardStepInfo[] getWizardSteps(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			List<CommonWizardStepInfo> items = ssn.queryForList(
					"common.get-wizard-steps", convertQueryParams(params));
			return items.toArray(new CommonWizardStepInfo[items.size()]);
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getWizardStepsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			int count = (Integer)ssn.queryForObject("common.get-wizard-steps-count",
					convertQueryParams(params));
			return count;
		} catch (SQLException e) {
			logger.error("", e);
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}



// Default Elements early was ArrayElement

    public int getDefaultArrayElementsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_ELEMENT, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_ELEMENT);
            return (Integer) ssn.queryForObject("common.get-default-array-elements-count",
                    convertQueryParams(params, limitation));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings("unchecked")
    public DefaultArrayElement[] getDefaultArrayElements(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_ELEMENT, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_ELEMENT);
            List<DefaultArrayElement> objects = ssn.queryForList("common.get-default-array-elements", convertQueryParams(params, limitation));
            return objects.toArray(new DefaultArrayElement[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public DefaultArrayElement addDefaultArrayElement(Long userSessionId, DefaultArrayElement arrayElement) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayElement.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ARRAY_ELEMENT, paramArr);
            ssn.insert("common.add-default-array-element", arrayElement);

            Filter[] filters = new Filter[2];
            filters[0] = new Filter();
            filters[0].setElement("lang");
            filters[0].setValue(arrayElement.getLang());
            filters[1] = new Filter();
            filters[1].setElement("id");
            filters[1].setValue(arrayElement.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (DefaultArrayElement) ssn.queryForObject("common.get-default-array-elements",
                    convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public DefaultArrayElement editDefaultArrayElement(Long userSessionId, DefaultArrayElement arrayElement) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayElement.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_ARRAY_ELEMENT, paramArr);
            ssn.update("common.edit-default-array-element", arrayElement);

            Filter[] filters = new Filter[2];
            filters[0] = new Filter();
            filters[0].setElement("lang");
            filters[0].setValue(arrayElement.getLang());
            filters[1] = new Filter();
            filters[1].setElement("id");
            filters[1].setValue(arrayElement.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (DefaultArrayElement) ssn.queryForObject("common.get-default-array-elements",
                    convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void deleteDefaultArrayElement(Long userSessionId, DefaultArrayElement arrayElement) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayElement.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ARRAY_ELEMENT, paramArr);
            ssn.delete("common.delete-default-array-element", arrayElement);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


//Atm Elements


    public int getAtmArrayElementsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_ELEMENT, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_ELEMENT);
            int count = (Integer)ssn.queryForObject("atm.get-atm-array-elements-count",
                    convertQueryParams(params, limitation));
            return count;
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings("unchecked")
    public AtmArrayElement[] getAtmArrayElements(Long userSessionId, SelectionParams params) {
        //todo Must be implemented
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ARRAY_ELEMENT, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ARRAY_ELEMENT);
            List<AtmArrayElement> items = ssn.queryForList(
                    "atm.get-atm-array-elements", convertQueryParams(params, limitation));
            return items.toArray(new AtmArrayElement[items.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public AtmArrayElement addAtmArrayElement(Long userSessionId, AtmArrayElement arrayElement) {
        //todo Must be implemented
        return new AtmArrayElement();
    }


    public AtmArrayElement editAtmArrayElement(Long userSessionId, AtmArrayElement arrayElement) {
        //todo Must be implemented
        return new AtmArrayElement();
    }


    public void deleteAtmArrayElement(Long userSessionId, AtmArrayElement arrayElement) {
        //todo Must be implemented
    }


    public AtmGroup[] getAtmGroups(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<AtmGroup> items = ssn.queryForList(
                    "common.get-atm-groups", convertQueryParams(params));
            return items.toArray(new AtmGroup[items.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getAtmGroupsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            int count = (Integer)ssn.queryForObject("common.get-atm-groups-count",
                    convertQueryParams(params));
            return count;
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void removeAtmFromGroup(Long userSessionId, AtmGroup atmGroup){
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(atmGroup.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_ARRAY_ELEMENT, paramArr);
            ssn.delete("common.remove-atm-from-group", atmGroup);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public AtmGroup addAtmToGroup(Long userSessionId, ArrayElement arrayElement) {
        SqlMapSession ssn = null;
        try {

            String currLang = arrayElement.getLang();
            arrayElement.setLang(null);
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(arrayElement.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_ARRAY_ELEMENT, paramArr);

            ssn.update("common.add-atm-to-group", arrayElement);

            Filter[] filters = new Filter[3];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(arrayElement.getArrayId());
            filters[1] = new Filter();
            filters[1].setElement("lang");
            filters[1].setValue(currLang);
            filters[2] = new Filter();
            filters[2].setElement("elementId");
            filters[2].setValue(arrayElement.getId());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (AtmGroup) ssn.queryForObject("common.get-atm-groups",
                    convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    public Date getOpenSttlDate(Integer instId) {
    	SqlMapSession ssn = null;
        try {
        	ssn = getIbatisSessionNoContext();
            return (Date) ssn.queryForObject("common.get-open-sttl-date", instId);
        } catch (SQLException e) {
        	if(instId.toString().equals("9999")){
        		return null;
        	}
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    public Country addCountry(Long userSessionId, Country country) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(country.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_COUNTRY, paramArr);
            ssn.update("common.add-country", country);

            Filter[] filters = new Filter[2];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(country.getId().toString());
            filters[1] = new Filter();
            filters[1].setElement("lang");
            filters[1].setValue(country.getLang());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);

            return (Country) ssn.queryForObject("common.get-countries",
                    convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void deleteCountry(Long userSessionId, Country country) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(country.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_COUNTRY, paramArr);
            ssn.update("common.remove-country", country);

        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }

    }


    public Country editCountry(Long userSessionId, Country country) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(country.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_COUNTRY, paramArr);
            ssn.update("common.modify-country", country);

            Filter[] filters = new Filter[2];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(country.getId().toString());
            filters[1] = new Filter();
            filters[1].setElement("lang");
            filters[1].setValue(country.getLang());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);

            return (Country) ssn.queryForObject("common.get-countries",
                    convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


	public Date getBankDate(Long userSessionId, Integer instId) {
		SqlMapSession ssn = null;
		try{
			ssn = getIbatisSessionNoContext();
			Date xml = (Date) ssn.queryForObject("common.get-calc-date", instId);
			return xml;

		}catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }

	}

	@SuppressWarnings("unchecked")
	public ProcessSession[] getUserSessionInfo(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, ProcessPrivConstants.VIEW_SESSION, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, ProcessPrivConstants.VIEW_SESSION);
			List<ProcessSession> sessions = ssn.queryForList("common.user-session-info", convertQueryParams(params, limitation));
			return sessions.toArray(new ProcessSession[sessions.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ContactData[] getContactUser(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_ACM_APPLICATIONS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_ACM_APPLICATIONS);
			List<ContactData> contacts = ssn.queryForList("common.get-contact-user", convertQueryParams(
					params, limitation));
			return contacts.toArray(new ContactData[contacts.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public AuditTrail[] getAuditLogTrailsFull(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.VIEW_AUDIT_LOGS, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_AUDIT_LOGS);
			List<AuditTrail> trails = ssn.queryForList("common.get-audit-trails-full",
					convertQueryParams(params, limitation));

			return trails.toArray(new AuditTrail[trails.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	@SuppressWarnings("unchecked")
	public void setSessionFileId(Long userSessionId, Long sessionFileId) {
		SqlMapSession ssn = null;
		try {
			if (userSessionId != null) {
				ssn = getIbatisSession(userSessionId);
			} else {
				ssn = getIbatisSessionNoContext();
			}
			ssn.update("common.set-session-file-id", sessionFileId);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void setUserContext(Long userSessionId, String userName) {
		SqlMapSession ssn = null;
		try {
			Map<String, Object> params = new HashMap<String, Object>();
			params.put("sessionId", userSessionId);
			params.put("userName", userName);
			ssn = getIbatisSession(userSessionId);
			ssn.update("common.set-user-context", params);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


    public List<String> getUniqueI18nStrings(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<String> translations = ssn.queryForList("common.get-unique-i18n-strings", convertQueryParams(params));

            return translations;
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void loadTranslationText(Long userSessionId, String sourceLang, String destinationLang, List<TranslationTextRec> list) {
        SqlMapSession ssn = null;
        try {
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("sessionId", userSessionId);
            params.put("src_lang", sourceLang);
            params.put("dst_lang", destinationLang);
            params.put("text_trans", list);
            ssn = getIbatisSession(userSessionId);
            ssn.update("common.load-translation-text", params);
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings("unchecked")
    public int getFlexFieldUsageCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  CommonPrivConstants.VIEW_FLEX_FIELD_USAGE,
                                  params,
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
			@Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_FLEX_FIELD_USAGE);
                Object count = ssn.queryForObject("common.get-flex-field-usage-count", convertQueryParams(params, limitation));
                return (count != null) ? (Integer)count : 0;
            }
        });
    }

    @SuppressWarnings("unchecked")
    public List<FlexFieldUsage> getFlexFieldUsages(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  CommonPrivConstants.VIEW_FLEX_FIELD_USAGE,
                                  params,
                                  logger,
                                  new IbatisSessionCallback<List<FlexFieldUsage>>() {
        	@Override
            public List<FlexFieldUsage> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_FLEX_FIELD_USAGE);
                return ssn.queryForList("common.get-flex-field-usages", convertQueryParams(params, limitation));
            }
        });
    }


    public FlexFieldUsage createFlexFieldUsage(Long userSessionId, FlexFieldUsage ffUsage) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ffUsage.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.ADD_FLEX_FIELD_USAGE, paramArr);

            ssn.insert("common.add-flex-field-usage", ffUsage);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(ffUsage.getId());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);

            return getFlexFieldUsages(userSessionId, params).iterator().next();
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void deleteFlexFieldUsage(Long userSessionId, FlexFieldUsage ffUsage) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ffUsage.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.REMOVE_FLEX_FIELD_USAGE, paramArr);


            ssn.delete("common.delete-flex-field-usage", ffUsage);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public FlexFieldUsage updateFlexFieldUsage(Long userSessionId, FlexFieldUsage ffUsage) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(ffUsage.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, CommonPrivConstants.MODIFY_FLEX_FIELD_USAGE, paramArr);

            ssn.update("common.modify-flex-field-usage", ffUsage);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(ffUsage.getId());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);

            return getFlexFieldUsages(userSessionId, params).iterator().next();
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public List<FlexStandardField> getFlexStandardFields(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  CommonPrivConstants.VIEW_FLEX_FIELD_STANDARD,
                                  params,
                                  logger,
                                  new IbatisSessionCallback<List<FlexStandardField>>() {
	        @Override
            public List<FlexStandardField> doInSession(SqlMapSession ssn) throws Exception {
                String limit = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_FLEX_FIELD_STANDARD);
                return ssn.queryForList("common.get-flex-standard-fields", convertQueryParams(params, limit));
            }
        });
    }


    public int getFlexStandardFieldsCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  CommonPrivConstants.VIEW_FLEX_FIELD_STANDARD,
                                  params,
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limit = CommonController.getLimitationByPriv(ssn, CommonPrivConstants.VIEW_FLEX_FIELD_STANDARD);
                Object count = ssn.queryForObject("common.get-flex-standard-fields-count", convertQueryParams(params, limit));
                return (count != null) ? (Integer)count : 0;
            }
        });
    }


    public FlexStandardField addFlexStandardField(final Long userSessionId, final FlexStandardField field) {
        return executeWithSession(userSessionId,
                                  CommonPrivConstants.ADD_FLEX_FIELD_STANDARD,
                                  AuditParamUtil.getCommonParamRec(field.getAuditParameters()),
                                  logger,
                                  new IbatisSessionCallback<FlexStandardField>() {
	        @Override
            public FlexStandardField doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("common.add-flex-standard-field", field);

                List<Filter> filters = new ArrayList<Filter>(2);
                filters.add(Filter.create("id", field.getId()));
                filters.add(Filter.create("lang", field.getLang()));
                List<FlexStandardField> fields = getFlexStandardFields(userSessionId, new SelectionParams(filters));
                if (fields != null && fields.size() > 0) {
                    return fields.get(0);
                } else {
                    return field.clone();
                }
            }
        });
    }


    public FlexStandardField modifyFlexStandardField(final Long userSessionId, final FlexStandardField field) {
        return executeWithSession(userSessionId,
                                  CommonPrivConstants.MODIFY_FLEX_FIELD_STANDARD,
                                  AuditParamUtil.getCommonParamRec(field.getAuditParameters()),
                                  logger,
                                  new IbatisSessionCallback<FlexStandardField>() {
	        @Override
            public FlexStandardField doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("common.modify-flex-standard-field", field);

                List<Filter> filters = new ArrayList<Filter>(2);
                filters.add(Filter.create("id", field.getId()));
                filters.add(Filter.create("lang", field.getLang()));
                List<FlexStandardField> fields = getFlexStandardFields(userSessionId, new SelectionParams(filters));
                if (fields != null && fields.size() > 0) {
                    return fields.get(0);
                } else {
                    return field.clone();
                }
            }
        });
    }


    public void removeFlexStandardField(Long userSessionId, final FlexStandardField field) {
        executeWithSession(userSessionId,
                           CommonPrivConstants.REMOVE_FLEX_FIELD_STANDARD,
                           AuditParamUtil.getCommonParamRec(field.getAuditParameters()),
                           logger,
                           new IbatisSessionCallback<Void>() {
	        @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("common.remove-flex-standard-field", field);
                return null;
            }
        });
    }


    public List<FlexField> getFlexFieldItems(Long userSessionId, final String lang) {
        return executeWithSession(userSessionId,
                                  CommonPrivConstants.VIEW_FLEXIBLE_FIELD,
                                  logger,
                                  new IbatisSessionCallback<List<FlexField>>() {
	            @Override
                public List<FlexField> doInSession(SqlMapSession ssn) throws Exception {
                    return ssn.queryForList("common.get-flex-field-items", lang);
                }
        });
    }

	public boolean isLovEditable(Long userSessionId, final Long lovId) throws Exception {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Boolean>() {
			@Override
			public Boolean doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> map = new HashMap<String, Object>(2);
				map.put("lovId", lovId);
				ssn.update("common.is-editable-lov", map);
				return (map.get("result") != null) ? ((Integer)map.get("result") != 0) : false;
			}
		});
	}
}
