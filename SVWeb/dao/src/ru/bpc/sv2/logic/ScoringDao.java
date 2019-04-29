package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.scoring.*;
import ru.bpc.sv2.utils.AuditParamUtil;


import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@SuppressWarnings("unchecked")
public class ScoringDao extends IbatisAware {
    private static final Logger logger = Logger.getLogger("SCORING");


    public List<ScoringScheme> getScoringSchemes(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.VIEW_SCR_SCHEMES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<ScoringScheme>>() {
	        @Override
            public List<ScoringScheme> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, ScoringPrivileges.VIEW_SCR_SCHEMES);
                return ssn.queryForList("scr.get-schemes", convertQueryParams(params, limitation));
            }
        });
    }

    public int getScoringSchemesCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.VIEW_SCR_SCHEMES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, ScoringPrivileges.VIEW_SCR_SCHEMES);
                Object result = ssn.queryForObject("scr.get-schemes-count", convertQueryParams(params, limitation));
                return (result != null) ? (Integer)result : 0;
            }
        });
    }


    public List<ScoringCriteria> getScoringCriterias(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.VIEW_SCR_SCHEMES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<ScoringCriteria>>() {
	        @Override
            public List<ScoringCriteria> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, ScoringPrivileges.VIEW_SCR_SCHEMES);
                return ssn.queryForList("scr.get-criterias", convertQueryParams(params, limitation));
            }
        });
    }

    public int getScoringCriteriasCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.VIEW_SCR_SCHEMES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, ScoringPrivileges.VIEW_SCR_SCHEMES);
                Object result = ssn.queryForObject("scr.get-criterias-count", convertQueryParams(params, limitation));
                return (result != null) ? (Integer)result : 0;
            }
        });
    }


    public List<ScoringValue> getValues(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.VIEW_SCR_SCHEMES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<ScoringValue>>() {
        	@Override
            public List<ScoringValue> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, ScoringPrivileges.VIEW_SCR_SCHEMES);
                return ssn.queryForList("scr.get-values", convertQueryParams(params, limitation));
            }
        });
    }

    public int getValuesCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.VIEW_SCR_SCHEMES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, ScoringPrivileges.VIEW_SCR_SCHEMES);
                Object result = ssn.queryForObject("scr.get-values-count", convertQueryParams(params, limitation));
                return (result != null) ? (Integer)result : 0;
            }
        });
    }


    public List<ScoringGrade> getScoringGrades(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.VIEW_SCR_SCHEMES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<List<ScoringGrade>>() {
	        @Override
            public List<ScoringGrade> doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, ScoringPrivileges.VIEW_SCR_SCHEMES);
                return ssn.queryForList("scr.get-grades", convertQueryParams(params, limitation));
            }
        });
    }

    public int getScoringGradesCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.VIEW_SCR_SCHEMES,
                                  AuditParamUtil.getCommonParamRec(params.getFilters()),
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                String limitation = CommonController.getLimitationByPriv(ssn, ScoringPrivileges.VIEW_SCR_SCHEMES);
                Object result = ssn.queryForObject("scr.get-grades-count", convertQueryParams(params, limitation));
                return (result != null) ? (Integer)result : 0;
            }
        });
    }


    public ScoringScheme addScoringScheme(Long userSessionId, final ScoringScheme scheme) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.ADD_SCR_SCHEMES,
                                  logger,
                                  new IbatisSessionCallback<ScoringScheme>() {
	        @Override
            public ScoringScheme doInSession(SqlMapSession ssn) throws Exception {
                ScoringScheme object = scheme;
                ssn.queryForObject("scr.add-scheme", object);
                return object;
            }
        });
    }

    public ScoringScheme modifyScoringScheme(Long userSessionId, final ScoringScheme scheme) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.MODIFY_SCR_SCHEMES,
                                  logger,
                                  new IbatisSessionCallback<ScoringScheme>() {
	        @Override
            public ScoringScheme doInSession(SqlMapSession ssn) throws Exception {
                ScoringScheme object = scheme;
                ssn.queryForObject("scr.modify-scheme", object);
                return object;
            }
        });
    }

    public void removeScoringScheme(Long userSessionId, final Map<String, Object> scheme) {
        executeWithSession(userSessionId,
                                  ScoringPrivileges.REMOVE_SCR_SCHEMES,
                                  logger,
                                  new IbatisSessionCallback<Void>() {
	        @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("scr.remove-scheme", scheme);
                return null;
            }
        });
    }


    public ScoringCriteria addScoringCriteria(Long userSessionId, final ScoringCriteria criteria) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.ADD_SCR_CRITERIAS,
                                  logger,
                                  new IbatisSessionCallback<ScoringCriteria>() {
	        @Override
            public ScoringCriteria doInSession(SqlMapSession ssn) throws Exception {
                ScoringCriteria object = criteria;
                ssn.queryForObject("scr.add-criteria", object);
                return object;
            }
        });
    }

    public ScoringCriteria modifyScoringCriteria(Long userSessionId, final ScoringCriteria criteria) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.MODIFY_SCR_CRITERIAS,
                                  logger,
                                  new IbatisSessionCallback<ScoringCriteria>() {
	        @Override
            public ScoringCriteria doInSession(SqlMapSession ssn) throws Exception {
                ScoringCriteria object = criteria;
                ssn.queryForObject("scr.modify-criteria", object);
                return object;
            }
        });
    }

    public void removeScoringCriteria(Long userSessionId, final Map<String, Object> criteria) {
        executeWithSession(userSessionId,
                           ScoringPrivileges.REMOVE_SCR_CRITERIAS,
                           logger,
                           new IbatisSessionCallback<Void>() {
	        @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("scr.remove-criteria", criteria);
                return null;
            }
        });
    }


    public ScoringValue addCriteriaValue(Long userSessionId, final ScoringValue value) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.ADD_SCR_CRITERIAS,
                                  logger,
                                  new IbatisSessionCallback<ScoringValue>() {
	        @Override
            public ScoringValue doInSession(SqlMapSession ssn) throws Exception {
                ScoringValue object = value;
                ssn.queryForObject("scr.add-criteria-value", object);
                return object;
            }
        });
    }

    public ScoringValue modifyCriteriaValue(Long userSessionId, final ScoringValue value) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.MODIFY_SCR_CRITERIAS,
                                  logger,
                                  new IbatisSessionCallback<ScoringValue>() {
	        @Override
            public ScoringValue doInSession(SqlMapSession ssn) throws Exception {
                ScoringValue object = value;
                ssn.queryForObject("scr.modify-criteria-value", object);
                return object;
            }
        });
    }

    public void removeCriteriaValue(Long userSessionId, final ScoringValue value) {
        executeWithSession(userSessionId,
                           ScoringPrivileges.REMOVE_SCR_CRITERIAS,
                           logger,
                           new IbatisSessionCallback<Void>() {
	        @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("scr.remove-criteria-value", value);
                return null;
            }
        });
    }


    public ScoringGrade addScoringGrade(Long userSessionId, final ScoringGrade grade) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.ADD_SCR_GRADES,
                                  logger,
                                  new IbatisSessionCallback<ScoringGrade>() {
	        @Override
            public ScoringGrade doInSession(SqlMapSession ssn) throws Exception {
                ScoringGrade object = grade;
                ssn.queryForObject("scr.add-grade", object);
                return object;
            }
        });
    }

    public ScoringGrade modifyScoringGrade(Long userSessionId, final ScoringGrade grade) {
        return executeWithSession(userSessionId,
                                  ScoringPrivileges.MODIFY_SCR_GRADES,
                                  logger,
                                  new IbatisSessionCallback<ScoringGrade>() {
	        @Override
            public ScoringGrade doInSession(SqlMapSession ssn) throws Exception {
                ScoringGrade object = grade;
                ssn.queryForObject("scr.modify-grade", object);
                return object;
            }
        });
    }

    public void removeScoringGrade(Long userSessionId, final ScoringGrade grade) {
        executeWithSession(userSessionId,
                           ScoringPrivileges.REMOVE_SCR_GRADES,
                           logger,
                           new IbatisSessionCallback<Void>() {
	        @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.queryForObject("scr.remove-grade", grade);
                return null;
            }
        });
    }
}
