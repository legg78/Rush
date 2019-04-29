package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import oracle.sql.ARRAY;
import org.apache.commons.codec.binary.Base64;
import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv2.application.*;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.common.ObjectEntity;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.*;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.ApplicationController;
import ru.bpc.sv2.logic.controller.ApplicationsSaver;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.controller.LovController;
import ru.bpc.sv2.logic.utility.db.QueryParams;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.utils.*;


import ru.bpc.sv2.logic.utility.db.DataAccessException;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import java.io.ByteArrayInputStream;
import java.math.BigDecimal;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.SQLException;
import java.text.SimpleDateFormat;
import java.util.*;

/**
 * Session Bean implementation class Application
 */
public class ApplicationDao extends IbatisAware {
    private static final Logger logger = Logger.getLogger("APPLICATIONS");

    private RolesDao rolesDao = new RolesDao();

    public ApplicationDao() {
    }

    private Map<String, Object> getParamsMap(SqlMapSession ssn, String privilege, SelectionParams params, boolean isCount) throws SQLException {
        String limitation = CommonController.getLimitationByPriv(ssn, privilege);
        List<Filter> filters = new ArrayList<Filter> (Arrays.asList(params.getFilters()));
        filters.add(Filter.create("PRIVIL_LIMITATION", limitation));
        params.setFilters(Filter.asArray(filters));
        Map<String, Object> paramsMap = new HashMap<String, Object>();
        paramsMap.put("tab_name", "MAIN");
        paramsMap.put("param_tab", filters.toArray(new Filter[filters.size()]));
        if (!isCount) {
            QueryParams qparams = convertQueryParams(params);
            paramsMap.put("first_row", qparams.getRange().getStartPlusOne());
            paramsMap.put("last_row", qparams.getRange().getEndPlusOne());
            paramsMap.put("row_count", params.getRowCount());
            paramsMap.put("sorting_tab", params.getSortElement());
        }
        return paramsMap;
    }


    public ApplicationElement getApplicationStructure(Long userSessionId, Application app,
                                                      Map<Integer, ApplicationFlowFilter> filtersMap) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            ApplicationFlowStage stage = (ApplicationFlowStage) ssn.queryForObject("application.get-flow-stage", app);
            ApplicationElement root = (ApplicationElement) ssn.queryForObject("application.get-app-structure-root-element", app);

            if (!(app.getStatus().equals(ApplicationStatuses.PROCESSES_SUCCESSFULLY) ||
                  app.getStatus().equals(ApplicationStatuses.PROCESSING_FAILED))) {
                if (stage == null) {
                    return null;
                }
                if (root == null) {
                    return new ApplicationElement();
                }
                root.setParentDataId(null);

                SelectionParams filterParams = new SelectionParams();

                ArrayList<Filter> filters = new ArrayList<Filter>();
                Filter paramFilter = new Filter();
                paramFilter.setElement("stageId");
                paramFilter.setValue(stage.getId().toString());
                filters.add(paramFilter);

                app.setStageId(stage.getId().intValue());

                filterParams.setFilters(filters.toArray(new Filter[filters.size()]));
                filterParams.setRowIndexEnd(-1);
                ApplicationFlowFilter[] flowFilters = getApplicationFlowFilters(ssn, filterParams);

                if (filtersMap == null) {
                    filtersMap = new HashMap<Integer, ApplicationFlowFilter>();
                }
                for (ApplicationFlowFilter flowFilter : flowFilters) {
                    filtersMap.put(flowFilter.getStructId(), flowFilter);
                }
                setFilter(filtersMap, root);
            }

            root.setPath("/" + root.getName());
            fillRootChilds(ssn, app.getInstId(), root, app, filtersMap);

            return root;
        } catch (SQLException e) {
            throw createDaoException(e);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    private void setFilter(Map<Integer, ApplicationFlowFilter> filtersMap, ApplicationElement el) throws Exception {
        ApplicationFlowFilter filter = filtersMap.get(el.getStId());
        if (filter != null) {
            if (filter.getValue() != null) {
                if (DataTypes.CHAR.equals(el.getDataType())) {
                    el.setValueV(filter.getValueV());
                } else if (DataTypes.NUMBER.equals(el.getDataType())) {
                    el.setValueN(filter.getValueN());
                } else if (DataTypes.DATE.equals(el.getDataType())) {
                    el.setValueD(filter.getValueD());
                }
            }
            if (filter.getDefaultValue() != null) {
                el.setDefaultValue(filter.getDefaultValue());
            }
            if (filter.getMinCount() != null) {
                el.setMinCount(filter.getMinCount());
            }
            if (filter.getMaxCount() != null) {
                el.setMaxCount(filter.getMaxCount());
            }
            if (filter.getVisible() != null) {
                el.setVisible(filter.getVisible());
            }
            if (filter.getInsertable() != null) {
                el.setInsertable(filter.getInsertable());
            }
            if (filter.getUpdatable() != null) {
                el.setUpdatable(filter.getUpdatable());
            }
        }
    }

    /**
     * This method is similar to <code>fillRootChilds</code> but, in contrast to it,
     * <code>fillTopChildren</code> doesn't fill complex elements. All the complex elements
     * in the result tree are presented as content elements i.e. innerId=0 & isContent=true.
     */
    @SuppressWarnings ("unchecked")

    public void fillTopChildren(Long userSessionId, Integer instId, ApplicationElement node, Map<Integer, ApplicationFlowFilter> flowFilters) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            if (node == null || node.getType() == null || !node.isComplex()) {
                return;
            }
            List<ApplicationElement> childs = ssn.queryForList("application.get-app-element-childs",
                                                               new ApplicationElementExtended(instId, node));
            node.setChildren(new ArrayList<ApplicationElement>());
            for (ApplicationElement el : childs) {
                el.setPath(node.getPath() + "/" + el.getName());
                setFilter(flowFilters, el);
                el.setParent(node);
                if (el.getLovId() != null) { // fill LOV if necessary
                    fillElementLov(ssn, el);
                }

                if (el.isComplex() || el.getMaxCount() > 1) {
                    el.setContent(true);
                    el.setInnerId(0);
                    node.getChildren().add(el);
                    ApplicationElement contentBlock = el;
                    // this is a simple field, not a block
                    int count = el.getMinCount();
                    int minCount = 1;
                    if (count == 0 && el.getType().equals(ApplicationConstants.ELEMENT_TYPE_SIMPLE)) {
                        count = 1; // add 1 field if non-block
                        minCount = 0;
                        el.setMaxCopy(1);
                    }
                    if (!el.isComplex()) {
                        // if structure needs several blocks of that type add them. They are all
                        // required
                        for (int i = 1; i <= count; i++) {
                            // add blocks which are needed
                            ApplicationElement tmpEl = new ApplicationElement();
                            el.clone(tmpEl);
                            tmpEl.setContentBlock(contentBlock);
                            tmpEl.setContent(false);
                            tmpEl.setInnerId(i);
                            tmpEl.setMaxCount(1);
                            tmpEl.setMinCount(minCount);
                            if (minCount == 0) {
                                tmpEl.setRequired(false);
                            } else {
                                tmpEl.setRequired(true);
                            }
                            tmpEl.setPath(tmpEl.getPath() + tmpEl.getInnerId());
                            node.getChildren().add(tmpEl);
                        }
                        el.setCopyCount(count);
                        el.setMaxCopy(count);
                    }
                } else {
                    // this is simple element and maxCount <=1

                    // set required if necessary
                    if (el.getMinCount().equals(1)) {
                        el.setRequired(true);
                    }
                    el.setPath(el.getPath() + el.getInnerId());
                    node.getChildren().add(el);
                }
            }

        } catch (SQLException e) {
            throw createDaoException(e);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")
    private void fillRootChilds(SqlMapSession ssn,
                                Integer instId,
                                ApplicationElement node,
                                Application app,
                                Map<Integer, ApplicationFlowFilter> flowFilters) throws Exception {
        if (node == null || node.getType() == null || !node.isComplex()) {
            return;
        }
        List<ApplicationElement> childs = ssn.queryForList("application.get-app-element-childs",
                                                           new ApplicationElementExtended(instId, (app != null) ? app.getStageId() : null, node));
        node.setChildren(new ArrayList<ApplicationElement>());

        for (ApplicationElement el : childs) {
            el.setPath(node.getPath() + "/" + el.getName());
            setFilter(flowFilters, el);
            el.setParent(node);

            if (el.getLovId() != null) {
                fillElementLov(ssn, el);
            }
            if (AppElements.START_DATE.equals(el.getName())) {
                el.setValueD(new Date());
            }
            if (el.isComplex() || el.getMaxCount() > 1) {
                el.setContent(true);
                el.setInnerId(0);
                node.getChildren().add(el);
                ApplicationElement contentBlock = el;
                // this is a simple field, not a block
                int count = el.getMinCount();
                int minCount = 1;
                if (count == 0 && el.getType().equals(ApplicationConstants.ELEMENT_TYPE_SIMPLE)) {
                    count = 1; // add 1 field if non-block
                    minCount = 0;
                    el.setMaxCopy(1);
                }
                if (el.getEntityType() == null || el.getEntityType().equals("") || count > 0) {
                    // if structure needs several blocks of that type add them. They are all required
                    for (int i = 1; i <= count; i++) {
                        // add blocks which are needed
                        ApplicationElement tmpEl = new ApplicationElement();
                        el.clone(tmpEl);
                        tmpEl.setContentBlock(contentBlock);
                        tmpEl.setContent(false);
                        tmpEl.setInnerId(i);
                        tmpEl.setMaxCount(1);
                        tmpEl.setMinCount(minCount);
                        if (minCount == 0) {
                            tmpEl.setRequired(false);
                        } else {
                            tmpEl.setRequired(true);
                        }
                        tmpEl.setPath(tmpEl.getPath() + tmpEl.getInnerId());
                        fillRootChilds(ssn, instId, tmpEl, app, flowFilters);
                        node.getChildren().add(tmpEl);
                    }
                    el.setCopyCount(count);
                    el.setMaxCopy(count);
                }
            } else {
                // this is simple element and maxCount <=1 set required if necessary
                if (el.getMinCount().equals(1)) {
                    el.setRequired(true);
                }
                el.setPath(el.getPath() + el.getInnerId());
                node.getChildren().add(el);
            }
        }
    }


    public void fillRootChilds(Long userSessionId,
                               Integer instId,
                               ApplicationElement node,
                               Map<Integer, ApplicationFlowFilter> filtersMap) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            fillRootChilds(ssn, instId, node, null, filtersMap);
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void fillRootChilds(Long userSessionId,
                               Integer instId,
                               ApplicationElement node,
                               Application app,
                               Map<Integer, ApplicationFlowFilter> filtersMap) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            fillRootChilds(ssn, instId, node, app, filtersMap);
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public List<ApplicationElement> fillAppElementChilds(Long userSessionId, Integer instId, ApplicationElement node) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<ApplicationElement> childs = ssn.queryForList("application.get-app-element-childs",
                                                               new ApplicationElementExtended(instId, node));
            for (ApplicationElement child : childs) {
                if (child.getDataType() == null && child.getMaxCount() > 1) {
                    child.setContent(true);
                    child.setInnerId(0);
                }
                child.setParent(node);
                if (child.getLovId() != null) {
                    fillElementLov(ssn, child);
                }
            }
            return childs;
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }

    }


    public Long getNextDataId(Long userSessionId, Long applicationId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            return ApplicationController.getNextDataId(ssn, applicationId);

        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationType[] getAvailableAppTypes(Long userSessionId) {
        SqlMapSession ssn = null;

        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<ApplicationType> types = ssn.queryForList("application.get-app-types");

            return types.toArray(new ApplicationType[types.size()]);
        } catch (SQLException e) {
            throw new DataAccessException(e.getCause() != null ? e.getCause().getMessage() : e.getMessage());
        } finally {
            close(ssn);
        }

    }


    public void saveApplication(Long userSessionId, ApplicationElement appTree, Application app) {
        saveApplication(userSessionId, appTree, app, 0);
    }


    public void saveApplication(Long userSessionId, ApplicationElement appTree, Application app, Integer isNew) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(app.getAuditParameters());
            String priv = null;
            if (app.getAppType().equals(ApplicationConstants.TYPE_ISSUING)) {
                priv = ApplicationPrivConstants.MODIFY_ISSUING_APPLICATION;
            } else if (app.getAppType().equals(ApplicationConstants.TYPE_DISPUTES)) {
                priv = ApplicationPrivConstants.MODIFY_DISPUTE_APPLICATIONS;
            } else if (app.getAppType().equals(ApplicationConstants.TYPE_CAMPAIGNS)) {
                priv = ApplicationPrivConstants.MODIFY_CAMPAIGN_APPLICATION;
            } else {
                priv = ApplicationPrivConstants.MODIFY_ACQUIRING_APPLICATION;
            }
            ssn = getIbatisSession(userSessionId, null, priv, paramArr);
            if (app.getAppType().equals(ApplicationConstants.TYPE_DISPUTES)) {
                ssn.insert("application.modify-application-with-user", app);
            } else {
                ssn.insert("application.modify-application", app);
            }
            saveApplicationWithoutComment(userSessionId, appTree, app, isNew);
        } catch (SQLException e) {
            throw new DataAccessException(e.getCause() != null ? e.getCause().getMessage() : e.getMessage());
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public void saveApplicationWithoutComment(Long userSessionId, ApplicationElement appTree, Application app, Integer isNew) {
        SqlMapSession ssn = null;
        CallableStatement cstmt = null;
        Connection con = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            con = ssn.getCurrentConnection();
            cstmt = con.prepareCall("{ call app_ui_application_pkg.modify_application_data(?,?,?) }");

            cstmt.setLong(1, app.getId());
            ApplicationElement tmpEl = appTree.getChildByName(AppElements.APPLICATION_STATUS, 1);
            tmpEl.setValueV(app.getNewStatus());

            List<ApplicationRec> appAsArray = new ArrayList<ApplicationRec>(0);
            ApplicationsSaver appSaver = new ApplicationsSaver(app.getId());
            appSaver.initArray(ssn, appTree, appAsArray);
            ApplicationRec[] appRecs = appAsArray.toArray(new ApplicationRec[appAsArray.size()]);

            ARRAY oracleApps = DBUtils.createArray(AuthOracleTypeNames.APP_DATA_TAB, con, appRecs);
            cstmt.setArray(2, oracleApps);
            cstmt.setInt(3, (isNew != null) ? isNew.intValue() : 0);
            cstmt.execute();
        } catch (Exception e) {
            throw createDaoException(e);
        } finally {
            DBUtils.close(cstmt);
            DBUtils.close(con);
            close(ssn);
        }
    }


    public Application createApplication(Long userSessionId, final Application app) {
        CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(app.getAuditParameters());
        String privilege = ApplicationPrivConstants.ADD_ACQUIRING_APPLICATION;
        if (ApplicationConstants.TYPE_DISPUTES.equals(app.getAppType())) {
            privilege = ApplicationPrivConstants.ADD_DISPUTE_APPLICATIONS;
        } else if (ApplicationConstants.TYPE_INSTITUTION.equals(app.getAppType())) {
            privilege = ApplicationPrivConstants.ADD_INSTITUTION_APPLICATION;
        } else if (ApplicationConstants.TYPE_ISSUING.equals(app.getAppType())) {
            privilege = ApplicationPrivConstants.ADD_ISSUING_APPLICATION;
        } else if (ApplicationConstants.TYPE_CAMPAIGNS.equals(app.getAppType())) {
            privilege = ApplicationPrivConstants.ADD_CAMPAIGN_APPLICATION;
        }
        return executeWithSession(userSessionId, privilege, paramArr, logger, new IbatisSessionCallback<Application>() {
	        @Override
            public Application doInSession(SqlMapSession ssn) throws Exception {
                ssn.insert("application.add-application", app);
                return app;
            }
        });
    }


    public ApplicationElement getApplicationForEdit(Long userSessionId, Application app) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            ApplicationElement root = (ApplicationElement) ssn.queryForObject("application.get-app-root-element-for-edit", app);
            fillAppElementChildsForEdit(ssn, root);
            return root;
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationElement getNewApplicationForEdit(Long userSessionId, Application app) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            HashMap<String, Object> params = new HashMap<String, Object>();
            params.put("appType", app.getAppType());
            params.put("applNumber", app.getApplNumber());
            params.put("flowId", app.getFlowId());
            params.put("agentId", app.getAgentId());
            params.put("instId", app.getInstId());
            params.put("status", app.getStatus());
            params.put("customerType", app.getCustomerType());
            params.put("parentId", null);
            ssn.update("application.get-appl-struct", params);
            ApplicationElement root2 = ((ArrayList<ApplicationElement>) params.get("ref_cursor")).get(0);
            params = new HashMap<String, Object>();
            params.put("appType", app.getAppType());
            params.put("applNumber", app.getApplNumber());
            params.put("flowId", app.getFlowId());
            params.put("agentId", app.getAgentId());
            params.put("instId", app.getInstId());
            params.put("status", app.getStatus());
            params.put("customerType", app.getCustomerType());
            params.put("parentId", root2.getDataId());
            ssn.update("application.get-appl-struct", params);
            ArrayList<ApplicationElement> childrens = (ArrayList<ApplicationElement>) params.get("ref_cursor");
            root2.getChildren().addAll(childrens);

            return root2;

        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    @SuppressWarnings ("unchecked")
    public List<ApplicationElement> getChildrensForElement(Long userSessionId, Application app) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            ApplicationElement appElem = new ApplicationElement();
            appElem.setDataId(app.getId());
            return ssn.queryForList("application.get-app-element-childs-for-update", appElem);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")
    private void fillAppElementChildsForEdit(SqlMapSession ssn, ApplicationElement node)
            throws SQLException {
        if (node == null || !node.isComplex()) {
            return;
        }
        List<ApplicationElement> childs = ssn.queryForList("application.get-app-element-childs-for-edit", node);
        node.getChildren().addAll(childs);

        for (ApplicationElement el : node.getChildren()) {
            fillAppElementChildsForEdit(ssn, el);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationElement[] getApplicationErrors(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<ApplicationElement> errors = ssn.queryForList(
                    "application.get-application-errors", convertQueryParams(params));

            return errors.toArray(new ApplicationElement[errors.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getApplicationErrorsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            return (Integer) ssn.queryForObject("application.get-application-errors-count",
                                                convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void mergeApplication(Long userSessionId, ApplicationElement source, ApplicationElement destination) {
        try {
            List<ApplicationElement> sourceChilds = source.getChildren();
            List<ApplicationElement> destChilds = destination.getChildren();

            HashSet<ApplicationElement> clearChilds = new HashSet<ApplicationElement>();
            Collections.addAll(clearChilds, destChilds.toArray(new ApplicationElement[destChilds.size()]));
            destChilds.clear();
            destChilds.addAll(clearChilds);

            for (ApplicationElement element : sourceChilds) {
                Boolean found = false;
                for (ApplicationElement child : destChilds) {
                    if (child.getName().equals(element.getName())) {
                        found = true;
                        if (element.isComplex()) {
                            mergeApplication(userSessionId, element, child);
                        }
                        break;
                    }
                }
                if (!found) {
                    destChilds.add(element);
                }
            }
        } catch (Exception e) {
            throw createDaoException(e);
        }
    }


    public void mergeApplication(Long userSessionId, Application app, ApplicationElement source,
                                 ApplicationElement destination, Map<Integer, ApplicationFlowFilter> filtersMap) {
        ApplicationElement rootEdit = source;
        ApplicationElement rootTree = destination;

        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            // now let's merge tree
            mergeNodes(ssn, app.getInstId(), rootEdit, rootTree, filtersMap);

            setDependences(userSessionId, app, rootTree, filtersMap);
            setPathForSubtree(rootTree);

            Long instId = getInstitutionId(rootTree);
            Long productId = getProductId(rootTree);
            if (instId != null && productId != null)
                setParamLovs(ssn, rootTree, instId, productId);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    private void setParamLovs(SqlMapSession ssn, ApplicationElement rootTree, Long instId,
                              Long productId) throws Exception {
        try {
            ApplicationElement idType = rootTree.getChildByName(AppElements.CUSTOMER, 1)
                                                .getChildByName(AppElements.PERSON, 1)
                                                .getChildByName(AppElements.IDENTITY_CARD, 1)
                                                .getChildByName(AppElements.ID_TYPE, 1);
            String entityType = rootTree.getChildByName(AppElements.CUSTOMER_TYPE, 1).getValueV();
            HashMap<String, Object> idTypeParams = new HashMap<String, Object>();
            idTypeParams.put("institution_id", instId);
            idTypeParams.put("CUSTOMER_TYPE", entityType);
            idType.setLov(LovController.getLov(ssn, idType.getLovId(), idTypeParams, null));
        } catch (Exception ignored) {}

        try {
            ApplicationElement accountType = rootTree.getChildByName(AppElements.CUSTOMER, 1)
                                                     .getChildByName(AppElements.CONTRACT, 1)
                                                     .getChildByName(AppElements.ACCOUNT, 1)
                                                     .getChildByName(AppElements.ACCOUNT_TYPE, 1);
            HashMap<String, Object> params = new HashMap<String, Object>();
            params.put("product_id", productId);
            params.put("institution_id", instId);
            accountType.setLov(LovController.getLov(ssn, accountType.getLovId(), params, null));
        } catch (Exception ignored) {}
    }

    private ApplicationElement getRootElement(ApplicationElement element) {
        ApplicationElement el = element;
        while (el.getParent() != null)
            el = el.getParent();
        return el;
    }

    private Long getInstitutionId(ApplicationElement element) {
        try {
            return getRootElement(element).getChildByName(AppElements.INSTITUTION_ID, 1).getValueN().longValue();
        } catch (Exception e) {
            return null;
        }
    }

    private Long getProductId(ApplicationElement element) {
        try {
            return getRootElement(element).getChildByName(AppElements.CUSTOMER, 1)
                                          .getChildByName(AppElements.CONTRACT, 1)
                                          .getChildByName(AppElements.PRODUCT_ID, 1)
                                          .getValueN().longValue();
        } catch (Exception e) {
            return null;
        }
    }

    private String getContractType(ApplicationElement element) {
        try {
            return getRootElement(element).getChildByName(AppElements.CUSTOMER, 1)
                                          .getChildByName(AppElements.CONTRACT, 1)
                                          .getChildByName(AppElements.CONTRACT_TYPE, 1)
                                          .getValueV();
        } catch (Exception e) {
            return null;
        }
    }

    private Long getCardType(ApplicationElement element) {
        try {
            return getRootElement(element).getChildByName(AppElements.CUSTOMER, 1)
                                          .getChildByName(AppElements.CONTRACT, 1)
                                          .getChildByName(AppElements.MERCHANT, 1)
                                          .getChildByName(AppElements.MERCHANT_CARD, 1)
                                          .getChildByName(AppElements.CARD_TYPE, 1)
                                          .getValueN().longValue();
        } catch (Exception e) {
            return null;
        }
    }

    private Map<String, Object> getProductParam(ApplicationElement element) {
        HashMap<String, Object> params = new HashMap<String, Object>();
        Long productId = getProductId(element);
        if (productId != null) {
            params.put(AppElements.PRODUCT_ID, productId);
        }
        return (params.size() > 0) ? params : null;
    }

    private Map<String, Object> getInstitutionParam(ApplicationElement element) {
        HashMap<String, Object> params = new HashMap<String, Object>();
        Long instId = getInstitutionId(element);
        if (instId != null) {
            params.put(AppElements.INSTITUTION_ID, instId);
        }
        String contractType = getContractType(element);
        if (contractType != null && !contractType.trim().isEmpty()) {
            params.put(AppElements.CONTRACT_TYPE, contractType);
        }
        return (params.size() > 0) ? params : null;
    }

    private Map<String, Object> getCardTypeParam(ApplicationElement element) {
        HashMap<String, Object> params = new HashMap<String, Object>();
        Long cardType = getCardType(element);
        if (cardType != null) {
            params.put(AppElements.CARD_TYPE, cardType);
        }
        return (params.size() > 0) ? params : null;
    }

    private void fillElementLov(SqlMapSession ssn, ApplicationElement element) {
        try {
            if (element.getLovId() != null) {
                KeyLabelItem[] lov;
                Map<String, Object> params = null;
                if (element.getLovId().equals(LovConstants.CURRENCY_BY_PRODUCT)) {
                    params = getProductParam(element);
                } else if (element.getLovId().equals(LovConstants.CARD_PRODUCT_ID)) {
                    params = getInstitutionParam(element);
                } else if (element.getLovId().equals(LovConstants.CARD_TYPE_BY_PRODUCT)) {
                    params = getProductParam(element);
                } else if (element.getLovId().equals(LovConstants.MERCHANT_CARD_NUMBER)) {
                    params = getCardTypeParam(element);
                }
                if (params != null) {
                    lov = LovController.getLov(ssn, element.getLovId(), params, null);
                } else {
                    lov = LovController.getLov(ssn, element.getLovId());
                }
                element.setLov(lov);
            }
        } catch (Exception e) {
            logger.error("Cannot get LOV " + element.getLovId() + " for " + element.getPath(), e);
            throw new DataAccessException(e.getMessage(), e);
        }
    }

    private void setDependences(Long userSessionId, Application app, ApplicationElement appTree,
                                Map<Integer, ApplicationFlowFilter> filtersMap) throws Exception {
        List<ApplicationElement> children = new ArrayList<ApplicationElement>();
        for (ApplicationElement el : appTree.getChildren()) {
            children.add(el);
        }
        for (ApplicationElement el : children) {
            try {
                if (el.getContent()) {
                    continue;
                }
                if (el.getDependence()) {
                    ArrayList<Filter> filtersFlow = new ArrayList<Filter>();
                    filtersFlow.add(Filter.create("lang", SystemConstants.ENGLISH_LANGUAGE));
                    filtersFlow.add(Filter.create("structId", el.getStId()));

                    SelectionParams params = new SelectionParams(filtersFlow);
                    params.setRowIndexEnd(-1);
                    applyDependences(userSessionId, app, el, el.getParent(), params, filtersMap);
                }
                if (el.isHasChildren()) {
                    setDependences(userSessionId, app, el, filtersMap);
                }
            } catch (Exception e) {
                logger.error("Error: setDependences()!!! element : " + el.getName() + "; subtree : " + appTree.getName());
                throw e;
            }
        }
    }

    private void mergeNodes(SqlMapSession ssn, Integer instId, ApplicationElement editTree,
                            ApplicationElement appTree, Map<Integer, ApplicationFlowFilter> filtersMap) throws Exception {
        ApplicationElement rootEdit = editTree;
        ApplicationElement structureTree = appTree;
        rootEdit.merge(structureTree);
        // FIXME
        // TODO create independent number of copyElement
        // get children from saved application
        List<ApplicationElement> editChilds = rootEdit.getChildren();

        List<ApplicationElement> treeChilds = structureTree.getChildren();
        List<ApplicationElement> tmpChilds = new ArrayList<ApplicationElement>();
        List<ApplicationElement> childrenToRemove = new ArrayList<ApplicationElement>();

        // look through the structure children
        for (ApplicationElement child : treeChilds) {
            if (child.getContent()) // look for the same multi blocks
            {
                int count = 0;
                int maxCount = 0;
                // look for the same elements in editElement children to match
                Collections.sort(editChilds);
                for (ApplicationElement el : editChilds) {
                    if (el.getName().equals(child.getName())) {
                        count++;

                        ApplicationElement blockInstance = new ApplicationElement();
                        el.clone(blockInstance);

                        int tmpInnerId = blockInstance.getInnerId();
                        if (tmpInnerId > maxCount)
                            maxCount = tmpInnerId;
                        blockInstance.setInnerId(count);
                        int tmpindex = treeChilds.indexOf(blockInstance);

                        if (tmpindex == -1) {
                            // if no blockInstance in structure was found
                            blockInstance.setParentId(child.getParentId());
                            blockInstance.setOrderNum(child.getOrderNum());
                            blockInstance.setAppType(child.getAppType());
                            blockInstance.setParent(child.getParent());
                            blockInstance.setVisible(child.getVisible());
                            blockInstance.setUpdatable(child.getUpdatable());
                            blockInstance.setMultiLang(child.isMultiLang());
                            blockInstance.setShortDesc(child.getShortDesc());
                            blockInstance.setDependent(child.getDependent());
                            blockInstance.setDependence(child.getDependence());
                            blockInstance.setLov(child.getLov());
                            blockInstance.setLovId(child.getLovId());
                            blockInstance.setStId(child.getStId());
                            blockInstance.setPath(child.getPath());
                            blockInstance.setMinCount(1);
                            blockInstance.setMaxCount(1);
                            blockInstance.setRequired(false);
                            blockInstance.setEntityType(child.getEntityType());
                            fillRootChilds(ssn, instId, blockInstance, null, filtersMap);
                        } else {
                            // if blockInstance was found
                            treeChilds.get(tmpindex).clone(blockInstance);
                            ApplicationElement elToRemove = new ApplicationElement();
                            elToRemove.setName(blockInstance.getName());
                            elToRemove.setInnerId(blockInstance.getInnerId());
                            elToRemove.setId(blockInstance.getId());
                            elToRemove.setParentId(blockInstance.getStId() == null ?
                                                   null : blockInstance.getStId().longValue());
                            elToRemove.setStId(blockInstance.getStId());
                            childrenToRemove.add(elToRemove);
                        }
                        // return initial innerId and save to tmpChilds
                        blockInstance.setContentBlock(child);
                        blockInstance.setEditForm(child.getEditForm());
                        blockInstance.setInnerId(tmpInnerId);
                        tmpChilds.add(blockInstance);
                    }
                }
                if (count > child.getCopyCount()) {
                    child.setCopyCount(count);
                }
                if (maxCount > 0) {
                    child.setMaxCopy(maxCount);
                }
            }
        }

        treeChilds.removeAll(childrenToRemove);
        treeChilds.addAll(tmpChilds);

        if (tmpChilds.size() > 0)
            Collections.sort(treeChilds);

        for (ApplicationElement child : treeChilds) {
            int index = editChilds.indexOf(child);
            if (index == -1) {
                // TODO here we must set dependences
                // if (child.getDependent() && child.getLovId()!=null) {
                // Map<String, Object> params = new HashMap<String, Object>();
                // Map<Integer, ApplicationDependence> dependencesForElementMap =
                // getDependencesMapByDependentElement(ssn, child);
                // collectParamsForDependenceUp(ssn, child, params, dependencesForElementMap);
                // LovController lovController = new LovController();
                // child.setLov(lovController.getLov(ssn, child.getLovId(), params));
                // }
                // this node is not filled, so there's nothing to merge
            } else {

                // if (!child.getContent() && child.getDataType() == null && (child.getChilds() ==
                // null || child.getChilds().size() == 0)) {
                // fillRootChilds(child);
                // }
                ApplicationElement tmp = editChilds.get(index);
                if (!child.getContent() && !tmp.getContent()) {

                    if (child.isComplex()) {
                        mergeNodes(ssn, instId, tmp, child, filtersMap);
                    } else {
                        tmp.merge(child);
                    }
                }
            }

        }
    }


    public void deleteApplication(Long userSessionId, Application app) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            ssn.delete("application.remove-application", app);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void processApplication(Long userSessionId, Long appId, boolean force) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            if (force) {
                ssn.insert("application.process-application-force", appId);
            } else {
                ssn.insert("application.process-application", appId);
            }
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public boolean validateApplication(Long userSessionId, ApplicationElement appTree,
                                       List<ApplicationElement> requiredList) {
        List<ApplicationElement> invalidList = new ArrayList<ApplicationElement>();
        validate(appTree, invalidList, requiredList);
        return invalidList.size() <= 0;
    }

    private void validate(ApplicationElement appTree, List<ApplicationElement> invalidList,
                          List<ApplicationElement> requiredList) {
        if (appTree.getContent())
            return;
        appTree.validateB();

        appTree.setValidRequired(true);
        if (appTree.getInnerId() != null && appTree.getInnerId() > 0) {
            if (appTree.getType().equals(ApplicationConstants.ELEMENT_TYPE_SIMPLE) &&
                    appTree.isRequired()) {
                if (appTree.getValueN() == null && appTree.getValueD() == null) {
                    if (appTree.getValueV() == null || appTree.getValueV().trim().equals("")) {
                        appTree.setValidRequired(false);
                        requiredList.add(appTree);
                    }
                }
            }
        }
        if (!appTree.isValid() || !appTree.isValidRequired()) {
            invalidList.add(appTree);
        }

        for (ApplicationElement child : appTree.getChildren()) {
            if (!child.getContent() && Boolean.TRUE.equals(child.getVisible()))
                validate(child, invalidList, requiredList);
            // If child is invalid then mark its parent as invalid too.
            // It's made just for user to see what block is invalid
            if (!child.isValid())
                appTree.setValid(false);
            if (!child.isValidRequired())
                appTree.setValidRequired(false);
        }

    }

    @SuppressWarnings ("unchecked")

    public ApplicationFlow[] getApplicationFlows(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_FLOW, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     ApplicationPrivConstants.VIEW_APPLICATION_FLOW);
            List<ApplicationFlow> flows = ssn.queryForList("application.get-flows",
                                                           convertQueryParams(params, limitation));

            return flows.toArray(new ApplicationFlow[flows.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationFlow[] getApplicationFlowsWithRoles(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, (params.getPrivilege() != null ? params.getPrivilege() : ApplicationPrivConstants.VIEW_APPLICATION_FLOW), paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     (params.getPrivilege() != null ? params.getPrivilege() : ApplicationPrivConstants.VIEW_APPLICATION_FLOW));
            List<ApplicationFlow> flows = ssn.queryForList("application.get-flows-with-roles",
                                                           convertQueryParams(params, limitation));

            return flows.toArray(new ApplicationFlow[flows.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getApplicationFlowsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_FLOW, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     ApplicationPrivConstants.VIEW_APPLICATION_FLOW);
            return (Integer) ssn.queryForObject("application.get-flows-count", convertQueryParams(
                    params, limitation));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationFlow addApplicationFlow(Long userSessionId, ApplicationFlow appFlow) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(appFlow.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.ADD_APPLICATION_FLOW, paramArr);
            ssn.insert("application.add-flow", appFlow);

            Filter[] filters = new Filter[2];
            filters[0] = new Filter();
            filters[0].setElement("lang");
            filters[0].setValue(appFlow.getLang());
            filters[1] = new Filter();
            filters[1].setElement("id");
            filters[1].setValue(appFlow.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (ApplicationFlow) ssn.queryForObject("application.get-flows",
                                                        convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationFlow editApplicationFlow(Long userSessionId, ApplicationFlow appFlow) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(appFlow.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.MODIFY_APPLICATION_FLOW, paramArr);
            ssn.update("application.edit-flow", appFlow);

            Filter[] filters = new Filter[2];
            filters[0] = new Filter();
            filters[0].setElement("lang");
            filters[0].setValue(appFlow.getLang());
            filters[1] = new Filter();
            filters[1].setElement("id");
            filters[1].setValue(appFlow.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (ApplicationFlow) ssn.queryForObject("application.get-flows",
                                                        convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void deleteApplicationFlow(Long userSessionId, ApplicationFlow appFlow) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(appFlow.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.REMOVE_APPLICATION_FLOW, paramArr);
            ssn.delete("application.delete-flow", appFlow);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationFlowStage[] getApplicationFlowStages(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_FLOW_STAGE, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, ApplicationPrivConstants.VIEW_APPLICATION_FLOW_STAGE);
            List<ApplicationFlowStage> stages = ssn.queryForList("application.get-flow-stages", convertQueryParams(params, limitation));
            return stages.toArray(new ApplicationFlowStage[stages.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getApplicationFlowStagesCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_FLOW_STAGE, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn, ApplicationPrivConstants.VIEW_APPLICATION_FLOW_STAGE);
            return (Integer) ssn.queryForObject("application.get-flow-stages-count", convertQueryParams(params, limitation));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationFlowStage addApplicationFlowStage(Long userSessionId, ApplicationFlowStage flowStage) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowStage.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.ADD_APPLICATION_FLOW_STAGE, paramArr);
            ssn.insert("application.add-flow-stage", flowStage);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(flowStage.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (ApplicationFlowStage) ssn.queryForObject("application.get-flow-stages", convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationFlowStage editApplicationFlowStage(Long userSessionId, ApplicationFlowStage flowStage) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowStage.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.MODIFY_APPLICATION_FLOW_STAGE, paramArr);
            ssn.update("application.edit-flow-stage", flowStage);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(flowStage.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (ApplicationFlowStage) ssn.queryForObject("application.get-flow-stages", convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void deleteApplicationFlowStage(Long userSessionId, ApplicationFlowStage flowStage) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowStage.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.REMOVE_APPLICATION_FLOW_STAGE, paramArr);
            ssn.delete("application.delete-flow-stage", flowStage);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationFlowTransition[] getApplicationFlowTransitions(Long userSessionId,
                                                                     SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPL_FLOW_TRANSITION, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     ApplicationPrivConstants.VIEW_APPL_FLOW_TRANSITION);
            List<ApplicationFlowTransition> transitions = ssn.queryForList(
                    "application.get-flow-transitions", convertQueryParams(params, limitation));

            return transitions.toArray(new ApplicationFlowTransition[transitions.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getApplicationFlowTransitionsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPL_FLOW_TRANSITION, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     ApplicationPrivConstants.VIEW_APPL_FLOW_TRANSITION);
            return (Integer) ssn.queryForObject("application.get-flow-transitions-count",
                                                convertQueryParams(params, limitation));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationFlowTransition addApplicationFlowTransition(Long userSessionId,
                                                                  ApplicationFlowTransition flowTransition) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowTransition.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.ADD_APPL_FLOW_TRANSITION, paramArr);
            ssn.insert("application.add-flow-transition", flowTransition);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(flowTransition.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (ApplicationFlowTransition) ssn.queryForObject(
                    "application.get-flow-transitions", convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationFlowTransition editApplicationFlowTransition(Long userSessionId,
                                                                   ApplicationFlowTransition flowTransition) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowTransition.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.MODIFY_APPL_FLOW_TRANSITION, paramArr);
            ssn.update("application.edit-flow-transition", flowTransition);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(flowTransition.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (ApplicationFlowTransition) ssn.queryForObject(
                    "application.get-flow-transitions", convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void deleteApplicationFlowTransition(Long userSessionId,
                                                ApplicationFlowTransition flowTransition) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowTransition.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.REMOVE_APPL_FLOW_TRANSITION, paramArr);
            ssn.delete("application.delete-flow-transition", flowTransition);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public AppElement[] getApplicationElements(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_ELEMENT, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     ApplicationPrivConstants.VIEW_APPLICATION_ELEMENT);
            List<AppElement> elements = ssn.queryForList("application.get-app-elements",
                                                         convertQueryParams(params, limitation));
            return elements.toArray(new AppElement[elements.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getApplicationElementsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_ELEMENT, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     ApplicationPrivConstants.VIEW_APPLICATION_ELEMENT);
            return (Integer) ssn.queryForObject("application.get-app-elements-count",
                                                convertQueryParams(params, limitation));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public AppElement addApplicationElement(Long userSessionId, AppElement element) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(element.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.ADD_APPLICATION_ELEMENT, paramArr);
            ssn.insert("application.add-app-element", element);

            Filter[] filters = new Filter[1];
            filters[0] = new Filter();
            filters[0].setElement("id");
            filters[0].setValue(element.getId().toString());

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (AppElement) ssn.queryForObject("application.get-app-elements",
                                                   convertQueryParams(params));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationFlowFilter[] getApplicationFlowFilters(Long userSessionId,
                                                             SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_FLOW_FILTER, paramArr);

            return getApplicationFlowFilters(ssn, params);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")
    private ApplicationFlowFilter[] getApplicationFlowFilters(SqlMapSession ssn,
                                                              SelectionParams params) throws SQLException {
        String limitation = CommonController.getLimitationByPriv(ssn,
                                                                 ApplicationPrivConstants.VIEW_APPLICATION_FLOW_FILTER);
        List<ApplicationFlowFilter> filters = ssn.queryForList("application.get-flow-filters",
                                                               convertQueryParams(params, limitation));
        return filters.toArray(new ApplicationFlowFilter[filters.size()]);
    }


    public int getApplicationFlowFiltersCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_FLOW_FILTER, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     ApplicationPrivConstants.VIEW_APPLICATION_FLOW_FILTER);
            return (Integer) ssn.queryForObject("application.get-flow-filters-count",
                                                convertQueryParams(params, limitation));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public List<ApplicationFlowTransition> getTransitionApplicationStatuses(Long userSessionId, Application app) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

	        List<ApplicationFlowTransition> statuses = ssn
                    .queryForList("application.get-transition-app-statuses", app);

            return statuses;
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public List<ApplicationFlowTransition> getTransitionApplicationStatusesNoSucFail(Long userSessionId, Application app) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

	        List<ApplicationFlowTransition> statuses = ssn
                    .queryForList("application.get-transition-app-statuses-no-suc-fail", app);
	        return statuses;
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public ApplicationDependence[] getApplicationDependences(Long userSessionId,
                                                             SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_DEPENDENCY, paramArr);

            return getApplicationDependences(ssn, params);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")
    private ApplicationDependence[] getApplicationDependences(SqlMapSession ssn,
                                                              SelectionParams params) throws SQLException {
        String limitation = CommonController.getLimitationByPriv(ssn,
                                                                 ApplicationPrivConstants.VIEW_APPLICATION_DEPENDENCY);
        List<ApplicationDependence> dependences = ssn.queryForList("application.get-dependences",
                                                                   convertQueryParams(params, limitation));
        return dependences.toArray(new ApplicationDependence[dependences.size()]);
    }

    @SuppressWarnings ("unchecked")
    private ApplicationDependence[] getApplicationDependencesByElement(SqlMapSession ssn,
                                                                       ApplicationElement el) throws SQLException {
        List<ApplicationDependence> dependences = new ArrayList<ApplicationDependence>();
        for (ApplicationElement child : el.getChildren()) {
            if (child.getContent()) {
                continue;
            }
            List<ApplicationDependence> dependencesList = ssn.queryForList(
                    "application.get-dependences-by-element", child.getStId());
            for (ApplicationDependence dep : dependencesList) {
                dep.setValueD(child.getValueD());
                dep.setValueN(child.getValueN());
                dep.setValueV(child.getValueV());
                dep.setElementName(child.getName());
            }
            dependences.addAll(dependencesList);
        }
        return dependences.toArray(new ApplicationDependence[dependences.size()]);
    }

    @SuppressWarnings ("unchecked")
    private ApplicationDependence[] getApplicationDependencesByDependentElement(SqlMapSession ssn,
                                                                                ApplicationElement el) throws SQLException {
        List<ApplicationDependence> dependencesList = ssn.queryForList(
                "application.get-dependences-by-dependent-element", el.getStId());
        return dependencesList.toArray(new ApplicationDependence[dependencesList.size()]);
    }


    public int getApplicationDependencesCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_APPLICATION_DEPENDENCY, paramArr);
            String limitation = CommonController.getLimitationByPriv(ssn,
                                                                     ApplicationPrivConstants.VIEW_APPLICATION_DEPENDENCY);
            return (Integer) ssn.queryForObject("application.get-dependences-count",
                                                convertQueryParams(params, limitation));
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    private void applyDependence(Long userSessionId, SqlMapSession ssn, Application app,
                                 ApplicationElement startBlock, Map<Integer, List<ApplicationDependence>> dependenceMap,
                                 Integer count, Map<Integer, ApplicationFlowFilter> filtersMap, int level) throws Exception {
        applyDependence(userSessionId, ssn, app, startBlock, dependenceMap, count, filtersMap, level, true);
    }

    /**
     * @param indMod - Set it as false to prevent indirect modifications of application tree
     *               structure (addition/removing of elements) during applying
     *               of dependencies. E.g. this modifications can be performed when an element has
     *               state [content=true;minCount=1;copyCount=0]. In this case we need to create a copy
     *               of the element and add it to the tree.
     */
    private void applyDependence(Long userSessionId, SqlMapSession ssn, Application app,
                                 ApplicationElement startBlock, Map<Integer, List<ApplicationDependence>> dependenceMap,
                                 Integer count, Map<Integer, ApplicationFlowFilter> filtersMap, int level, boolean indMod)
            throws Exception {
        level++;
        List<ApplicationElement> childs = startBlock.getChildren();
        List<ApplicationElement> childsTmp = new ArrayList<ApplicationElement>();
        if (childs == null) {
            return;
        }

        for (Iterator<ApplicationElement> iterator = childs.iterator(); iterator.hasNext();) {
            ApplicationElement el = iterator.next();
            List<ApplicationDependence> dependences = dependenceMap.get(el.getStId());
            if (dependences == null) {
                continue;
            }
            HashMap<String, Object> params = null;
            Set<String> paramsWhereClause = null;
            boolean setLov = false;
            for (final Iterator<ApplicationDependence> depIterator = dependences.iterator(); depIterator.hasNext(); ) {
                ApplicationDependence dependence = depIterator.next();
                count++;

                if (dependence.getDependence().equals(ApplicationConstants.DEPENDENCE_VALUE)) {
                    params = new HashMap<String, Object>();
                    params.put("value", new Object());
                    params.put("valueV", dependence.getValueV());
                    params.put("valueN", dependence.getValueN());
                    params.put("valueD", dependence.getValueD());
                    params.put("dependId", dependence.getId());
                    params.put("elementName", dependence.getElementName());
                    if (el.getDataType().equals(DataTypes.DATE)) {
                        ssn.update("application.get-property_d", params);
                        el.setValueD((Date) params.get("value"));
                    }
                    if (el.getDataType().equals(DataTypes.NUMBER)) {
                        ssn.update("application.get-property_n", params);
                        el.setValueN((BigDecimal) params.get("value"));
                    }
                    if (el.getDataType().equals(DataTypes.CHAR)) {
                        ssn.update("application.get-property", params);
                        el.setValueV((String) params.get("value"));
                    }
                    params.clear();
                    params = null;
                }
                if (dependence.getDependence().equals(ApplicationConstants.DEPENDENCE_REQUIRED)) {
                    params = new HashMap<String, Object>();
                    params.put("value", new Object());
                    params.put("valueV", dependence.getValueV());
                    params.put("valueN", (dependence.getValueN() != null) ? dependence.getValueN().doubleValue() : null);
                    params.put("valueD", dependence.getValueD());
                    params.put("dependId", dependence.getId());
                    params.put("elementName", dependence.getElementName());
                    ssn.update("application.get-property_b", params);
                    boolean mandatory = (Boolean) params.get("value");
                    if (!el.getContent() && el.getContentBlock() == null) {
                        // this is not a contentBlock and without contentBlock, i.e.
                        // this element is simple with maxCount = 1. We can't check by these
                        // conditions as it can be one of many same blocks
                        // every block has it's contentBlock
                        if (mandatory) {
                            el.setMinCount(1);
                            el.setRequired(true);
                        } else {
                            el.setMinCount(0);
                            el.setRequired(false);
                        }
                    } else if (el.getContent()) {
                        // this is a contentBlock which responses for blocks or multiple simple
                        // elements
                        // we must look whether it already is required, i.e. minCount = 1
                        if (mandatory) {
                            if (el.getMinCount() >= 1) {

                            } else {
                                // no of the elements in this content are required
                                el.setMinCount(1);
                                if (el.getCopyCount() > 0) {
                                    // there are several elements for this content
                                    // make one of them required
                                    List<ApplicationElement> childrenByName = el.getParent()
                                            .getChildrenByName(el.getName());
                                    for (ApplicationElement el1 : childrenByName) {
                                        el1.setMinCount(1);
                                        el1.setRequired(true);
                                        break;
                                    }
                                } else {
                                    if (el.getCopyCount().equals(el.getMaxCount())) {
                                        return; // we can't add more blocks than is possible
                                    } else {
                                        if (indMod) {
                                            ApplicationElement newNode = new ApplicationElement();
                                            el.clone(newNode);
                                            newNode.setRequired(true);
                                            newNode.setContent(false);
                                            newNode.setInnerId(el.getMaxCopy() + 1);
                                            newNode.setContentBlock(el);
                                            fillRootChilds(ssn, app.getInstId(), newNode, app, filtersMap); // fill
                                            // new
                                            // node
                                            // children
                                            childsTmp.add(newNode); // add new node to current node tmp
                                            // children
                                        }
                                    }
                                }
                            }
                        } else {
                            if (el.getMinCount() > 1) {
                                // nothing to do yet, as it's strange situation
                                // TODO ask Filimonov what to do in this case
                            } else if (el.getMinCount() == 1) {
                                el.setMinCount(0);
                                el.setRequired(false);

                                List<ApplicationElement> childrenByName = el.getParent()
                                        .getChildrenByName(el.getName());
                                for (ApplicationElement el1 : childrenByName) {
                                    el1.setRequired(false);
                                    el1.setMinCount(0);
                                }
                            }
                        }

                    }
                    params.clear();
                    params = null;
                }
                if (dependence.getDependence().equals(ApplicationConstants.DEPENDENCE_VISIBLE)) {
                    params = new HashMap<String, Object>();
                    params.put("value", new Object());
                    params.put("valueV", dependence.getValueV());
                    params.put("valueN", (dependence.getValueN() != null) ? dependence.getValueN().doubleValue() : null);
                    params.put("valueD", dependence.getValueD());
                    params.put("dependId", dependence.getId());
                    params.put("elementName", dependence.getElementName());
                    ssn.update("application.get-property_b", params);
                    el.setVisible((Boolean) params.get("value"));
                    params.clear();
                    params = null;
                    setFilter(filtersMap, el);
                }
                if (dependence.getDependence().equals(ApplicationConstants.DEPENDENCE_LOV)) {
                    if (params == null) {
                        params = new HashMap<String, Object>();
                    }
                    if (paramsWhereClause == null) {
                        paramsWhereClause = new HashSet<String>();
                    }
                    Map<Integer, ApplicationDependence> dependencesForElementMap = getDependencesMapByDependentElement(
                            ssn, el);
                    collectParamsForDependenceUp(app, el, ApplicationConstants.DEPENDENCE_LOV,
                                                 params, dependencesForElementMap, paramsWhereClause);
                    setLov = true;
                }
                if (dependence.getDependence().equals(ApplicationConstants.DEPENDENCE_ENTITY_TYPE)) {
                    if (params == null) {
                        params = new HashMap<String, Object>();
                    }
                    if (paramsWhereClause == null) {
                        paramsWhereClause = new HashSet<String>();
                    }
                    Map<Integer, ApplicationDependence> dependencesForElementMap = getDependencesMapByDependentElement(
                            ssn, el);
                    collectParamsForDependenceUp(app, el,
                                                 ApplicationConstants.DEPENDENCE_ENTITY_TYPE, params,
                                                 dependencesForElementMap, paramsWhereClause);
                    setLov = true;
                }

                if (ApplicationConstants.DEPENDENCE_AFFECTED_ZONE_CHILDREN.equals(dependence.getAffectedZone())) {

                } else if (ApplicationConstants.DEPENDENCE_AFFECTED_ZONE_SIBLINGS.equals(dependence
                                                                                                 .getAffectedZone())) {
                    if (level == 1) {
                        // this means that we found dependence of the 1st level among siblings.
                        depIterator.remove();
                        if (dependences.size() == 0) {
                            dependenceMap.remove(el.getStId());
                        }
                    }
                }
            } // end for dependences
            if (setLov && !el.getContent()) {
                ArrayList<String> parametersList = new ArrayList<String>(paramsWhereClause);
                if (el.getLovId() != null) {
                    el.setLov(LovController.getLov(ssn, el.getLovId(), params, parametersList));
                }
                params.clear();
                params = null;
            }
        }// end for childs
        for (ApplicationElement el : childsTmp) {
            childs.add(el);
            el.getContentBlock().setCopyCount(el.getContentBlock().getCopyCount() + 1);
            el.getContentBlock().setMaxCopy(el.getContentBlock().getMaxCopy() + 1);
            applyDependencesWhenAdd(userSessionId, app, el, filtersMap);
        }
        for (ApplicationElement el : childs) {
            if (!dependenceMap.isEmpty()) {
                applyDependence(userSessionId, ssn, app, el, dependenceMap, count, filtersMap,
                                level);
            }
        }
    }

    private void collectAllParamsForDependence(Application app,
                                              ApplicationElement startEl, Map<String, Object> params,
                                              Map<Integer, ApplicationDependence> dependencesForElementMap,
                                              Set<String> paramsWhereClause) throws Exception {
        if (startEl.getParent() != null) {
            collectAllParamsForDependence(app, startEl.getParent(), params,
                    dependencesForElementMap, paramsWhereClause);
        }
        for (ApplicationElement el : startEl.getChildren()) {
            if (el.getContent() == null || el.getDependence() == null) {
                continue;
            }
            if (el.getContent() || !el.getDependence()) {
                continue;
            }
            ApplicationDependence dependence = dependencesForElementMap.get(el.getStId());
            if (dependence != null && StringUtils.isNotBlank(dependence.getDependence())) {
                if (dependence.getDependence().equals(ApplicationConstants.DEPENDENCE_LOV)) {
                    if (el.getValueD() != null) {
                        params.put(el.getName(), el.getValueD());
                    }
                    if (el.getValueN() != null) {
                        params.put(el.getName(), el.getValueN());
                    }
                    if (el.getValueV() != null) {
                        params.put(el.getName(), el.getValueV());
                    }
                } else if (dependence.getDependence().equals(ApplicationConstants.DEPENDENCE_ENTITY_TYPE)) {
                    String whereClause = dependence.getCondition().replace(":parent_id", el.getParent().getStId().toString());
                    whereClause = whereClause.replace(":appl_inst_id", app.getInstId().toString());
                    String elNameReplace = ":" + el.getName();
                    if (whereClause.contains(elNameReplace)) {
                        whereClause = whereClause.replace(elNameReplace, getElValueForSql(el));
                    }
                    if (app.getFlowId() != null) {
                        whereClause = whereClause.replace(":flow_id", app.getFlowId().toString());
                    }
                    if (!paramsWhereClause.contains(whereClause)) {
                        paramsWhereClause.add(whereClause);
                    }
                }
            }
        }
    }

    private void collectParamsForDependenceUp(Application app,
                                              ApplicationElement startEl, String dependenceType, Map<String, Object> params,
                                              Map<Integer, ApplicationDependence> dependencesForElementMap,
                                              Set<String> paramsWhereClause) throws Exception {
        if (startEl.getParent() != null) {
            collectParamsForDependenceUp(app, startEl.getParent(), dependenceType, params,
                                         dependencesForElementMap, paramsWhereClause);
        }
        for (ApplicationElement el : startEl.getChildren()) {
            if (el.getContent() == null || el.getDependence() == null) {
                continue;
            }
            if (el.getContent() || !el.getDependence()) {
                continue;
            }
            ApplicationDependence dependence = dependencesForElementMap.get(el.getStId());
            if (dependence != null && dependence.getDependence().equals(dependenceType)) {
                if (dependenceType.equals(ApplicationConstants.DEPENDENCE_LOV)) {
                    if (el.getValueD() != null) {
                        params.put(el.getName(), el.getValueD());
                    }
                    if (el.getValueN() != null) {
                        params.put(el.getName(), el.getValueN());
                    }
                    if (el.getValueV() != null) {
                        params.put(el.getName(), el.getValueV());
                    }
                } else if (dependenceType.equals(ApplicationConstants.DEPENDENCE_ENTITY_TYPE)) {
                    String whereClause = dependence.getCondition().replace(":parent_id", el.getParent().getStId().toString());
                    whereClause = whereClause.replace(":appl_inst_id", app.getInstId().toString());
                    String elNameReplace = ":" + el.getName();
                    if (whereClause.contains(elNameReplace)) {
                        whereClause = whereClause.replace(elNameReplace, getElValueForSql(el));
                    }
                    if (app.getFlowId() != null) {
                        whereClause = whereClause.replace(":flow_id", app.getFlowId().toString());
                    }
                    if (!paramsWhereClause.contains(whereClause)) {
                        paramsWhereClause.add(whereClause);
                    }
                }
            }
        }
    }

    private String getElValueForSql(ApplicationElement el) {
        if (el.getValueV() != null && !el.getValueV().isEmpty()) {
            return "'" + el.getValueV().replace("'", "''") + "'";
        } else if (el.getValueN() != null) {
            return el.toString();
        } else if (el.getValueD() != null) {
            return String.format("to_date('%s', '%s')",
                                 new SimpleDateFormat(DatePatterns.DATE_PATTERN).format(el.getValueD()),
                                 DatePatterns.DATE_PATTERN);
        } else {
            return el.getValue() == null ? "null" : "'" + el.getValue().toString().replace("'", "''") + "'";
        }
    }

    private Map<Integer, List<ApplicationDependence>> getDependencesMapByElement(SqlMapSession ssn,
                                                                                 ApplicationElement appTree) throws SQLException {
        ApplicationDependence[] dependences = getApplicationDependencesByElement(ssn, appTree);
        Map<Integer, List<ApplicationDependence>> dependenceMap = new HashMap<Integer, List<ApplicationDependence>>();
        for (ApplicationDependence dep : dependences) {
            List<ApplicationDependence> deps = dependenceMap.get(dep.getDependStructId());
            if (deps == null) {
                deps = new ArrayList<ApplicationDependence>();
            }
            deps.add(dep);
            dependenceMap.put(dep.getDependStructId(), deps);
        }
        return dependenceMap;
    }

    private Map<Integer, ApplicationDependence> getDependencesMapByDependentElement(
            SqlMapSession ssn, ApplicationElement appTree) throws SQLException {
        ApplicationDependence[] dependences = getApplicationDependencesByDependentElement(ssn,
                                                                                          appTree);
        Map<Integer, ApplicationDependence> dependenceMap = new HashMap<Integer, ApplicationDependence>();
        for (ApplicationDependence dep : dependences) {
            dependenceMap.put(dep.getStructId(), dep);
        }
        return dependenceMap;
    }

    private void fillDependencesList(SqlMapSession ssn,
                                     ApplicationElement appTree,
                                     List<Map<Integer, List<ApplicationDependence>>> dependencesListByParents) throws SQLException {
        if (appTree.getParent() != null)
            fillDependencesList(ssn, appTree.getParent(), dependencesListByParents);

        Map<Integer, List<ApplicationDependence>> dependencesMap = getDependencesMapByElement(ssn, appTree);

        if (dependencesMap.size() > 0)
            dependencesListByParents.add(dependencesMap);
    }


    public void applyDependencesWhenAdd(Long userSessionId, Application app,
                                        ApplicationElement addedBlock, Map<Integer, ApplicationFlowFilter> filtersMap) {
        SqlMapSession ssn = null;

        try {
            ssn = getIbatisSessionFE(userSessionId);
            // fuck my brain.
            // and my too.
            List<Map<Integer, List<ApplicationDependence>>> dependencesListByParents = new ArrayList<Map<Integer, List<ApplicationDependence>>>();
            fillDependencesList(ssn, addedBlock, dependencesListByParents);
            int count;
            for (Map<Integer, List<ApplicationDependence>> dependencesListByParent : dependencesListByParents) {
                count = 0;
                applyDependence(userSessionId, ssn, app, addedBlock, dependencesListByParent, count, filtersMap, 0);
            }

        } catch (SQLException e) {
            throw new DataAccessException(e);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public int applyDependences(Long userSessionId, Application app, ApplicationElement appTree,
                                ApplicationElement startBlock, SelectionParams params,
                                Map<Integer, ApplicationFlowFilter> filtersMap) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            ApplicationDependence[] dependences = getApplicationDependences(ssn, params);
            // Map of elements to affect
            Map<Integer, List<ApplicationDependence>> dependenceMap = new HashMap<Integer, List<ApplicationDependence>>();
            for (ApplicationDependence dep : dependences) {
                dep.setValueD(appTree.getValueD());
                dep.setValueN(appTree.getValueN());
                dep.setValueV(appTree.getValueV());
                dep.setElementName(appTree.getName());
                List<ApplicationDependence> deps = dependenceMap.get(dep.getDependStructId());
                if (deps == null) {
                    deps = new ArrayList<ApplicationDependence>();
                }
                deps.add(dep);
                dependenceMap.put(dep.getDependStructId(), deps);
            }
            Integer count = 0;
            applyDependence(userSessionId, ssn, app, startBlock, dependenceMap, count, filtersMap, 0);

            return count;
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    public void applyLovDependence(Long userSessionId, Application app,  ApplicationElement el, Map<String, Object> params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            Map<Integer, ApplicationDependence> dependencesForElementMap = getDependencesMapByDependentElement(ssn, el);
            if (params == null) {
                params = new HashMap<String, Object>();
            }
            Set<String> paramsWhereClause = new HashSet<String>();
            collectAllParamsForDependence(app, el, params, dependencesForElementMap, paramsWhereClause);
            ArrayList<String> parametersList = new ArrayList<String>(paramsWhereClause);
            el.setLov(LovController.getLov(ssn, el.getLovId(), params, parametersList));

        }
        catch (SQLException e) {
            throw new DataAccessException(e);
        }
        catch (Exception e) {
            throw new DataAccessException(e);
        }
        finally {
            close(ssn);
        }

    }


    public void setPathForSubtree(ApplicationElement startEl) {
        String parentPath;
        try {
            if (startEl.getParent() == null) {
                parentPath = "";
            } else {
                parentPath = startEl.getParent().getPath();
            }

            startEl.setPath(parentPath + "/" + startEl.getName() + startEl.getInnerId());

            for (ApplicationElement el : startEl.getChildren()) {
                setPathForSubtree(el);
            }
        } catch (Exception e) {
            throw new DataAccessException(e);
        }
    }


    public void setPathForSubtree(Long userSessionId, ApplicationElement startEl) {
        String parentPath;
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            if (startEl.getParent() == null) {
                parentPath = "";
            } else {
                parentPath = startEl.getParent().getPath();
            }

            startEl.setPath(parentPath + "/" + startEl.getName() + startEl.getInnerId());

            for (ApplicationElement el : startEl.getChildren()) {
                setPathForSubtree(el);
            }
            ApplicationsSaver appSaver = new ApplicationsSaver(startEl.getAppId());
            appSaver.initDataIds(ssn, startEl);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    /**
     * @param filter . entityType = CARD get all cards for contract. entityType = ACCOUNT get all cards
     *               for contract merged with account with number.
     */
    @SuppressWarnings ("unchecked")

    public ContractObject[] getContractCards(Long userSessionId, ContractObject filter) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<ContractObject> objects = null;
            if (filter.getContractNumber() != null && filter.getEntityType() != null) {
                if (EntityNames.SERVICE.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-cards-by-service", filter);
                } else if (EntityNames.ACCOUNT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-cards-by-account", filter);
                } else if (EntityNames.CARD.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-cards", filter);
                }
            }
            if (objects == null) {
                objects = Collections.EMPTY_LIST;
            }
            return objects.toArray(new ContractObject[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    /**
     * @param filter . entityType = CARD get all cards for contract. entityType = ACCOUNT get all cards
     *               for contract merged with account with number.
     */
    @SuppressWarnings ("unchecked")

    public ContractObject[] getCustomerCards(Long userSessionId, ContractObject filter) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<ContractObject> objects = null;
            if (filter.getEntityType() != null) {
                if (EntityNames.SERVICE.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-cards-by-service", filter);
                } else if (EntityNames.ACCOUNT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-cards-by-account", filter);
                } else if (EntityNames.CARD.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-cards", filter);
                }
            }
            if (objects == null) {
                objects = Collections.EMPTY_LIST;
            }
            return objects.toArray(new ContractObject[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ContractObject[] getContractMerchants(Long userSessionId, ContractObject filter) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<ContractObject> objects = null;
            if (filter.getContractNumber() != null) {
                if (EntityNames.SERVICE.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-merchants-by-service",
                                               filter);
                } else if (EntityNames.ACCOUNT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-merchants-by-account",
                                               filter);
                } else if (EntityNames.MERCHANT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-merchants", filter);
                }
            }
            if (objects == null) {
                objects = Collections.EMPTY_LIST;
            }
            return objects.toArray(new ContractObject[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void setApplicationUser(Long userSessionId, final Application application) throws UserException {
        executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
	        @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.update("application.set-app-user", application);
                return null;
            }
        });
    }

    @SuppressWarnings ("unchecked")

    public ContractObject[] getContractTerminals(Long userSessionId, ContractObject filter) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<ContractObject> objects = null;
            if (filter.getContractNumber() != null) {
                if (EntityNames.SERVICE.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-terminals-by-service",
                                               filter);
                } else if (EntityNames.ACCOUNT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-terminals-by-account",
                                               filter);
                } else if (EntityNames.TERMINAL.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-terminals", filter);// TODO
                    // make
                    // query
                }
            } else {
                if (EntityNames.TERMINAL.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-terminals", filter);// TODO
                    // make
                    // query
                }
            }
            if (objects == null) {
                objects = Collections.EMPTY_LIST;
            }
            return objects.toArray(new ContractObject[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ContractObject[] getContractAccounts(Long userSessionId, ContractObject filter) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<ContractObject> objects = null;
            if (filter.getContractNumber() != null && filter.getEntityType() != null) {
                if (EntityNames.SERVICE.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-accounts-by-service", filter);
                } else if (EntityNames.CARD.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-accounts-by-card", filter);
                } else if (EntityNames.MERCHANT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-accounts-by-merchant", filter);
                } else if (EntityNames.TERMINAL.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-accounts-by-terminal", filter);
                } else if (EntityNames.ACCOUNT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-contract-accounts", filter);
                }
            }
            if (objects == null) {
                objects = Collections.EMPTY_LIST;
            }
            return objects.toArray(new ContractObject[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ContractObject[] getCustomerAccounts(Long userSessionId, ContractObject filter) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<ContractObject> objects = null;
            if (filter.getEntityType() != null) {
                if (EntityNames.SERVICE.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-accounts-by-service", filter);
                } else if (EntityNames.CARD.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-accounts-by-card", filter);
                } else if (EntityNames.MERCHANT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-accounts-by-merchant", filter);
                } else if (EntityNames.TERMINAL.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-accounts-by-terminal", filter);
                } else if (EntityNames.ACCOUNT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-accounts", filter);
                }
            }
            if (objects == null) {
                objects = Collections.EMPTY_LIST;
            }
            return objects.toArray(new ContractObject[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ContractObject[] getContractServices(Long userSessionId, ContractObject filter) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<ContractObject> objects = null;

            if (filter.getObjectId() == null || filter.getContractNumber() == null) {
                // get services for entity type card
                if (EntityNames.CUSTOMER.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-services", filter);
                } else {
                    objects = ssn.queryForList("application.get-services-hier", filter);
                    List<ContractObject> tree = new ArrayList<ContractObject>(objects.size());
                    TreeUtils.fillTreeByIndex(0, tree, objects);
                    objects = tree;
                }
            } else if (filter.getObjectId() != null && StringUtils.isEmpty(filter.getContractNumber())) {
                if (EntityNames.CUSTOMER.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-customer-services", filter);
                }
            }
              else {
                if (EntityNames.ACCOUNT.equals(filter.getEntityType())) {
                    // get services by accountId from filter
                    objects = ssn.queryForList("application.get-contract-services-by-account", filter);
                    List<ContractObject> tree = new ArrayList<ContractObject>(objects.size());
                    TreeUtils.fillTreeByIndex(0, tree, objects);
                    objects = tree;
                } else if (EntityNames.CARD.equals(filter.getEntityType())) {
                    // get services by cardId from filter
                    objects = ssn.queryForList("application.get-contract-services-by-card", filter);
                } else if (EntityNames.MERCHANT.equals(filter.getEntityType())) {
                    // get services by cardId from filter
                    objects = ssn.queryForList("application.get-contract-services-by-merchant", filter);
                } else if (EntityNames.TERMINAL.equals(filter.getEntityType())) {
                    // get services by cardId from filter
                    objects = ssn.queryForList("application.get-contract-services-by-terminal", filter);
                } else if (EntityNames.CUSTOMER.equals(filter.getEntityType())) {
                    // get services by cardId from filter
                    objects = ssn.queryForList("application.get-contract-services-by-customer", filter);
                } else if (EntityNames.SERVICE.equals(filter.getEntityType())) {

                } else if (EntityNames.CONTRACT.equals(filter.getEntityType())) {
                    objects = ssn.queryForList("application.get-services-hier", filter);
                    List<ContractObject> tree = new ArrayList<ContractObject>(objects.size());
                    TreeUtils.fillTreeByIndex(0, tree, objects);
                    objects = tree;
                } else if (filter.getEntityType() == null || filter.getEntityType().equals("")) {
                    objects = ssn.queryForList("application.get-services", filter);
                }
            }

            if (objects == null) {
                objects = Collections.EMPTY_LIST;
            }
            return objects.toArray(new ContractObject[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ContractObject[] getContractServicesByEntity(Long userSessionId, ContractObject filter) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<ContractObject> objects = null;
            if (EntityNames.ACCOUNT.equals(filter.getEntityType())) {
                // get services by accountId from filter
                objects = ssn.queryForList("application.get-contract-services-by-account-extended",
                                           filter);
                List<ContractObject> tree = new ArrayList<ContractObject>(objects.size());
                TreeUtils.fillTreeByIndex(0, tree, objects);
                objects = tree;
            } else if (EntityNames.CARD.equals(filter.getEntityType())) {
                // get services by cardId from filter
                objects = ssn.queryForList("application.get-contract-services-by-card-extended", filter);
            } else if (EntityNames.MERCHANT.equals(filter.getEntityType())) {
                // get services by cardId from filter
                objects = ssn.queryForList("application.get-contract-services-by-merchant",
                                           filter);
            } else if (EntityNames.TERMINAL.equals(filter.getEntityType())) {
                // get services by cardId from filter
                objects = ssn.queryForList("application.get-contract-services-by-terminal",
                                           filter);
            } else if (EntityNames.CUSTOMER.equals(filter.getEntityType())) {
                // get services by cardId from filter
                objects = ssn.queryForList("application.get-contract-services-by-customer-extended",
                                           filter);
            } else if (EntityNames.SERVICE.equals(filter.getEntityType())) {

            } else if (EntityNames.CONTRACT.equals(filter.getEntityType())) {
                objects = ssn.queryForList("application.get-services-hier",
                                           filter);
                List<ContractObject> tree = new ArrayList<ContractObject>(
                        objects.size());
                TreeUtils.fillTreeByIndex(0, tree, objects);
                objects = tree;
            } else if (filter.getEntityType() == null
                    || filter.getEntityType().equals("")) {
                objects = ssn.queryForList("application.get-services",
                                           filter);
            }
            if (objects == null) {
                objects = Collections.EMPTY_LIST;
            }
            return objects.toArray(new ContractObject[objects.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationFlowFilterStruct[] getApplicationFiltersTree(Long userSessionId,
                                                                   SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<ApplicationFlowFilterStruct> filters = ssn.queryForList(
                    "application.get-application-structure-filters", convertQueryParams(params));
            return filters.toArray(new ApplicationFlowFilterStruct[filters.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void addApplicationFlowFilter(Long userSessionId, ApplicationFlowFilter flowFilter) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowFilter.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.ADD_APPLICATION_FLOW_FILTER, paramArr);
            ssn.insert("application.add-flow-filter", flowFilter);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void editApplicationFlowFilter(Long userSessionId, ApplicationFlowFilter flowFilter) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowFilter.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.MODIFY_APPLICATION_FLOW_FILTER, paramArr);
            ssn.update("application.edit-flow-filter", flowFilter);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void deleteApplicationFlowFilter(Long userSessionId, ApplicationFlowFilter flowFilter) {
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(flowFilter.getAuditParameters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.REMOVE_APPLICATION_FLOW_FILTER, paramArr);
            ssn.delete("application.delete-flow-filter", flowFilter);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    public String getXml(Long appId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            return (String) ssn.queryForObject("application.get-xml", appId);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    public void getXml(ApplicationFlow flow) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            ssn.update("application.get-flow-source", flow);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationElement[] getAllElements() {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            List<ApplicationElement> elements = ssn.queryForList("application.get-all-elements");
            return elements.toArray(new ApplicationElement[elements.size()]);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationFlow[] getAllFlows() {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            List<ApplicationFlow> flows = ssn.queryForList("application.get-all-flows");
            return flows.toArray(new ApplicationFlow[flows.size()]);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationHistory[] getApplicationHistories(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<ApplicationHistory> items = ssn.queryForList(
                    "application.get-application-histories", convertQueryParams(params));

            return items.toArray(new ApplicationHistory[items.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getApplicationHistoriesCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            return (Integer) ssn.queryForObject("application.get-application-histories-count", convertQueryParams(params));
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationFlowStage[] getAllApplicationFlowStages() {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            List<ApplicationFlowStage> stages = ssn.queryForList("application.get-all-stages");

            return stages.toArray(new ApplicationFlowStage[stages.size()]);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public ApplicationFlowTransition[] getAllApplicationFlowTransitions() {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            List<ApplicationFlowTransition> transitions = ssn.queryForList("application.get-all-transitions");

            return transitions.toArray(new ApplicationFlowTransition[transitions.size()]);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public Long getNextDataId(Long applicationId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();
            return ApplicationController.getNextDataId(ssn, applicationId);

        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void checkCustomerName(Long userSessionId, Map<String, Object> parameters)
            throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            ssn.update("application.check-customer-name", parameters);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    public void changeApplicationStatus(Long userSessionId, Application application)
            throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            if (ApplicationConstants.TYPE_DISPUTES.equals(application.getAppType())) {
                ssn.update("application.modify-application-with-user", application);
            } else {
                ssn.update("application.modify-application", application);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    @SuppressWarnings ("unchecked")
    public ObjectEntity[] getApplicationOnlineObjects(Long userSessionId, SelectionParams params)
            throws UserException {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionNoContext();

            List<ObjectEntity> objects = ssn.queryForList("application.get-application-online-objects", convertQueryParams(params));
            return objects.toArray(new ObjectEntity[objects.size()]);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw createDaoException(e);
            }
        } finally {
            close(ssn);
        }
    }


    public List<String> saveDocuments(Long userSessionId, List<Long> documentsDataIdList,
                                      Map<Long, String> documentsMap, Map<Long, String> edsMap, Map<Long, String> svEdsMap,
                                      List<byte[]> byteList) throws UserException, Exception {
        List<String> result = new ArrayList<String>();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            for (Long documentDataId : documentsDataIdList) {
                String documentTextBase64 = documentsMap.get(documentDataId);
                String eds = edsMap.get(documentDataId);
                String svEds = svEdsMap.get(documentDataId);
                byte[] decodedBytes = new byte[0];
                boolean needSave = true;
                String str = null;
                if (documentTextBase64 == null || "".equals(documentTextBase64)) {
                    needSave = false;
                } else {
                    decodedBytes = Base64.decodeBase64(documentTextBase64);
                    str = new String(decodedBytes, "UTF-8");

                    try {
                        DocumentBuilderFactory dbf = DocumentBuilderFactory.newInstance();
                        DocumentBuilder db = dbf.newDocumentBuilder();
                        db.parse(new ByteArrayInputStream(decodedBytes));
                    } catch (Exception e) {
                        throw new UserException("Cannot parse document!");
                    }
                }

                Map<String, Object> map = new HashMap<String, Object>();
                map.put("dataId", documentDataId);
                map.put("document", str);
                map.put("customerEds", eds);
                map.put("supervisorEds", svEds);
                ssn.queryForObject("application.save-document", map);
                String savePath = (String) map.get("savePath");

                if (needSave) {
                    result.add(savePath);
                    byteList.add(decodedBytes);
                } else {
                    result.add(null);
                    byteList.add(null);
                }
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw getUserExceptionWithErrorCode(ssn, e.getCause().getMessage());
            } else {
                throw new DataAccessException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public void modifyApplicationData(Long userSessionId, ApplicationRec[] appRecs, Long appId) throws UserException {
        SqlMapSession ssn = null;
        CallableStatement cstmt = null;
        Connection con = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            con = ssn.getCurrentConnection();

            cstmt = con.prepareCall("{ call app_ui_application_pkg.modify_application_data(?,?) }");
            cstmt.setLong(1, appId);
            ARRAY oracleApps = DBUtils.createArray(AuthOracleTypeNames.APP_DATA_TAB, con, appRecs);
            cstmt.setArray(2, oracleApps);
            cstmt.execute();
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw new UserException(e.getCause().getMessage());
            } else {
                throw new DataAccessException(e);
            }
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            DBUtils.close(cstmt);
            if (con != null)
                try {
                    con.close();
                } catch (SQLException e) {
                    throw new DataAccessException(e);
                }
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public AppFlowStep[] getAppFlowSteps(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<AppFlowStep> items = ssn.queryForList("application.get-app-flow-steps", convertQueryParams(params));
            return items.toArray(new AppFlowStep[items.size()]);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getAppFlowStepsCount(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            return (Integer) ssn.queryForObject("application.get-app-flow-steps-count", convertQueryParams(params));
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public AppFlowStep createAppFlowStep(Long userSessionId, AppFlowStep editingItem) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            ssn.update("application.add-app-flow-step", editingItem);

            Filter[] filters = new Filter[2];
            Filter f = new Filter();
            f.setElement("id");
            f.setValue(editingItem.getId());
            filters[0] = f;
            f = new Filter();
            f.setElement("lang");
            f.setValue(editingItem.getLang());
            filters[1] = f;
            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (AppFlowStep) ssn.queryForObject("application.get-app-flow-steps", convertQueryParams(params));
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public AppFlowStep modifyAppFlowStep(Long userSessionId, AppFlowStep editingItem) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            ssn.update("application.modify-app-flow-step", editingItem);

            Filter[] filters = new Filter[2];
            Filter f = new Filter();
            f.setElement("id");
            f.setValue(editingItem.getId());
            filters[0] = f;
            f = new Filter();
            f.setElement("lang");
            f.setValue(editingItem.getLang());
            filters[1] = f;

            SelectionParams params = new SelectionParams();
            params.setFilters(filters);
            return (AppFlowStep) ssn.queryForObject("application.get-app-flow-steps", convertQueryParams(params));
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public void removeAppFlowStep(Long userSessionId, AppFlowStep activeItem) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            ssn.update("application.remove-app-flow-step", activeItem);
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public Integer getServiceIdByCardType(Long userSessionId, Integer cardTypeId, Integer productId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("cardTypeId", cardTypeId);
            params.put("productId", productId);
            return (Integer) ssn.queryForObject("application.get-service-by-product-card-type", params);
        } catch (SQLException e) {
            return null;
        } finally {
            close(ssn);
        }
    }


    public String getArrayConvertedValue(Long userSessionId, String arrayTypeName, String value) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("arrayTypeName", arrayTypeName);
            params.put("value", value);
            return (String) ssn.queryForObject("application.get-array-converted-value", params);
        } catch (SQLException e) {
            return null;
        } finally {
            close(ssn);
        }
    }


    public Integer getServiceId(Long userSessionId, String accountType, Integer productId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("accountType", accountType);
            params.put("productId", productId);
            return (Integer) ssn.queryForObject("application.get-service-by-product-account-type", params);
        } catch (SQLException e) {
            return null;
        } finally {
            close(ssn);
        }
    }

    /**
     * Apply filters contained in <code>filtersMap</code> to <code>element</code>. This method is similar to
     * applyDependenciesWhenAdd, but this implementation don't cause indirect modifications in application tree structure.
     *
     * @param userSessionId
     * @param element       - The element we need to work with
     * @param filtersMap    - Map of filters for applying.
     * @param instId
     */
    public void applyFilters(Long userSessionId, ApplicationElement element, Map<Integer, ApplicationFlowFilter> filtersMap, Integer instId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            List<Map<Integer, List<ApplicationDependence>>> dependencesListByParents = new ArrayList<Map<Integer, List<ApplicationDependence>>>();
            fillDependencesList(ssn, element, dependencesListByParents);
            Application stub = new Application();
            stub.setInstId(instId);
            for (Map<Integer, List<ApplicationDependence>> dependencesListByParent : dependencesListByParents) {
                applyDependence(userSessionId, ssn, stub, element, dependencesListByParent, 0, filtersMap, 0, false);
            }
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")

    public List<ApplicationLinkedObjects> getApplicationLinkedObjects(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  logger,
                                  new IbatisSessionCallback<List<ApplicationLinkedObjects>>() {
        	@Override
            public List<ApplicationLinkedObjects> doInSession(SqlMapSession ssn) throws Exception {
                return ssn.queryForList("application.get-application-linked-objects", convertQueryParams(params));
            }
        });
    }


    public int getApplicationLinkedObjectsCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId,
                                  logger,
                                  new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                Object count = ssn.queryForObject("application.get-application-linked-objects-count", convertQueryParams(params));
                return (count != null) ? (Integer)count : 0;
            }
        });
    }


    public Map<String, Integer> getFlowMandatory(Long userSessionId, SelectionParams params) {
        SqlMapSession ssn = null;
        Map<String, Integer> result = new HashMap<String, Integer>();
        try {
            ssn = getIbatisSessionFE(userSessionId);

            List<Map<String, Object>> list = ssn.queryForList("application.get-flow-mandatory",
                                                              convertQueryParams(params));
            for (Map<String, Object> map : list) {
                final Object key = map.get("key");
                final Object value = map.get("value");
                Integer val = 0;
                if (value == null) {
                    logger.warn(String.format(
                            "Minimal count for mandatory field '%s' is not set. Zero will be used as a default value",
                            key));
                } else {
                    val = Integer.valueOf(value.toString());
                }
                result.put(key.toString(), val);
            }
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
        return result;
    }

    @SuppressWarnings ("unchecked")

    public List<DspApplication> getDspApplications(Long userSessionId, SelectionParams params) {
        List<DspApplication> out = new ArrayList<>();
        SqlMapSession ssn = null;
        try {
            CommonParamRec[] rec = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_DISPUTE_APPLICATIONS, rec);
            String limit = CommonController.getLimitationByPriv(ssn, ApplicationPrivConstants.VIEW_DISPUTE_APPLICATIONS);
            Map<String, Object>map = new HashMap<String, Object>();
            map.put("tab_name", params.getTable());
            if (limit != null) {
                List<Filter> filters = new ArrayList<Filter>(Arrays.asList(params.getFilters()));
                filters.add(new Filter("PRIVIL_LIMITATION", limit));
                map.put("param_tab", filters.toArray(new Filter[filters.size()]));
            } else {
                map.put("param_tab", params.getFilters());
            }
            if (params.getSortElement() != null) {
                map.put("sorting_tab", params.getSortElement());
            }
            if (convertQueryParams(params).getRange() != null) {
                map.put("first_row", convertQueryParams(params).getRange().getStartPlusOne());
                map.put("last_row", convertQueryParams(params).getRange().getEndPlusOne());
            }
            ssn.update("application.get-apps-dsp", map);
            if (map.get("ref_cur") != null) {
                out = (ArrayList<DspApplication>) map.get("ref_cur");
            }
        } catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
        return out;
    }


    public int getDspApplicationsCount(Long userSessionId, SelectionParams params) {
        Integer out = 0;
        SqlMapSession ssn = null;
        try{
            CommonParamRec[] rec = AuditParamUtil.getCommonParamRec(params.getFilters());
            ssn = getIbatisSession(userSessionId, null, ApplicationPrivConstants.VIEW_DISPUTE_APPLICATIONS, rec);
            String limit = CommonController.getLimitationByPriv(ssn, ApplicationPrivConstants.VIEW_DISPUTE_APPLICATIONS);
            Map<String, Object>map = new HashMap<String, Object>();
            map.put("tab_name", params.getTable());
            if (limit != null) {
                List<Filter> filters = new ArrayList<Filter>(Arrays.asList(params.getFilters()));
                filters.add(new Filter("PRIVIL_LIMITATION", limit));
                map.put("param_tab", filters.toArray(new Filter[filters.size()]));
            } else {
                map.put("param_tab", params.getFilters());
            }
            ssn.update("application.get-apps-dsp-count", map);
            out = (Integer)map.get("row_count");
        }catch (SQLException e) {
            logger.error("", e);
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
        return out;
    }


    public void deleteDspApplication(Long userSessionId, DspApplication app) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            ssn.delete("application.remove-dsp-application", app);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public List<String> saveDspDocument(Long userSessionId, Map<String, Object> params) throws Exception {
        List<String> result = new ArrayList<String>();
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            if (params.get("applIds") != null) {
                ssn.queryForObject("application.multi-save-dsp-document", params);
            } else {
                ssn.queryForObject("application.save-dsp-document", params);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw getUserExceptionWithErrorCode(ssn, e.getCause().getMessage());
            } else {
                throw new DataAccessException(e);
            }
        } finally {
            close(ssn);
        }
        return result;
    }


    public void addApplicationObject(Long userSessionId, final Long applicationId, final String entityType, final Long objectId, final Integer seqNum) {
        executeWithSession(userSessionId, logger, new IbatisSessionCallback<Object>() {
	        @Override
            public Object doInSession(SqlMapSession ssn) throws Exception {
                Map<String, Object> params = new HashMap<String, Object>();
                params.put("applId", applicationId);
                params.put("entityType", entityType);
                params.put("objectId", objectId);
                params.put("seqNum", seqNum);
                ssn.update("application.add-object", params);
                return null;
            }
        });
    }

    @SuppressWarnings ("unchecked")
    public List<FreqApplication> getFreqApplications(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId, ApplicationPrivConstants.VIEW_FIN_REQUESTS, params, logger, new IbatisSessionCallback<List<FreqApplication>>() {
            @Override
            public List<FreqApplication> doInSession(SqlMapSession ssn) throws Exception {
                Map<String, Object> paramsMap = getParamsMap(ssn, ApplicationPrivConstants.VIEW_FIN_REQUESTS, params, false);
                ssn.update("application.get-apps-freq-cur", paramsMap);
                return (paramsMap.get("ref_cur") != null) ? (List<FreqApplication>) paramsMap.get("ref_cur") : new ArrayList<FreqApplication>();
            }
        });
    }

    @SuppressWarnings ("unchecked")
    public int getFreqApplicationsCount(Long userSessionId, final SelectionParams params) {
        return executeWithSession(userSessionId, ApplicationPrivConstants.VIEW_FIN_REQUESTS, params, logger, new IbatisSessionCallback<Integer>() {
            @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                Map<String, Object> paramsMap = getParamsMap(ssn, ApplicationPrivConstants.VIEW_FIN_REQUESTS, params, true);
                ssn.update("application.get-apps-freq-cur-count", paramsMap);
                return (paramsMap.get("row_count") != null) ? (Integer)paramsMap.get("row_count") : 0;
            }
        });
    }


    public List<ApplicationElement> getObjectNumberData(Long userSessionId, String entityType, Long objectId, String number, Integer instId) {
        SqlMapSession ssn = null;
        List<ApplicationElement> result;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("entityType", entityType);
            params.put("objectId", objectId);
            params.put("objectNumber", number);
            params.put("instId", instId);
            result = ssn.queryForList("application.get-object-number-data", params);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
        return result;
    }


    public List<ApplicationElement> getObjectTypeData(Long userSessionId, String entityType,
                                                      String objectType, String parentEntityType,
                                                      Long parentObjectId, String parentObjectNumber,
                                                      Integer instId, Integer innerId) {
        SqlMapSession ssn = null;
        List<ApplicationElement> result;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            Map<String, Object> params = new HashMap<String, Object>();
            params.put("entityType", entityType);
            params.put("objectType", objectType);
            params.put("parentEntityType", parentEntityType);
            params.put("parentObjectId", parentObjectId);
            params.put("parentObjectNumber", parentObjectNumber);
            params.put("instId", instId);
            params.put("innerId", innerId);
            result = ssn.queryForList("application.get-object-type-data", params);
        } catch (SQLException e) {
            throw new DataAccessException(e);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
        return result;
    }


    public Integer refuseDspApplication(Long userSessionId, Map<String, Object> params) throws Exception {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            ssn.queryForObject("application.refuse-dsp-application", params);
            return (Integer) params.get("userId");
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw getUserExceptionWithErrorCode(ssn, e.getCause().getMessage());
            } else {
                throw new DataAccessException(e);
            }
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public void changeDspApplicationVisibility(Long userSessionId, Map<String, Object> params) {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            ssn.update("application.update-dsp-app-visibility", params);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public Date getDueDate(Long userSessionId, Map<String, Object> params) {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            ssn.queryForObject("application.get-due-date", params);
            return (Date)params.get("dueDate");
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public void updateDueDate(Long userSessionId, final Map<String, Object> params) {
        executeWithSession(userSessionId, logger, new IbatisSessionCallback<Void>() {
	        @Override
            public Void doInSession(SqlMapSession ssn) throws Exception {
                ssn.update("application.update-due-date", params);
                return null;
            }
        });
    }


    public Long initiateDispute(Long userSessionId, Map<String, Object> params) {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            ssn.queryForObject("application.initiate-dsp", params);
            return (Long)params.get("disputeId");
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public void processDispute(Long userSessionId, Map<String, Object> params) {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            ssn.queryForObject("application.process-dsp-app", params);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public Map<String, Object> getCustomerInfo(Long userSessionId, Map<String, Object> params) {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            return (Map<String, Object>)ssn.queryForObject("application.get-customer-info", params);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public void getOperationByDisputeId(Long userSessionId, Map<String, Object> params) {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            ssn.queryForObject("application.process-dsp-app", params);
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public String getAppInitialStatus(Long userSessionId, Integer flowId) {
        SqlMapSession ssn = null;
        try {
            if (userSessionId != null) {
                ssn = getIbatisSession(userSessionId);
            } else {
                ssn = getIbatisSessionNoContext();
            }
            Map<String, Object> map = new HashMap<String, Object>();
            map.put("flowId", flowId);
            ssn.queryForObject("application.get-app-initial-status", map);
            return (String)map.get("status");
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public String getFlexFieldTypeByName(Long userSessionId, String fieldName) throws DataAccessException {
        SqlMapSession ssn = null;
        try {
            if (fieldName != null) {
                if (userSessionId != null) {
                    ssn = getIbatisSession(userSessionId);
                } else {
                    ssn = getIbatisSessionNoContext();
                }
                return (String) ssn.queryForObject("application.get-flexible-field-data-type-by-name", fieldName);
            } else {
                return DataTypes.CHAR;
            }
        } catch (Exception e) {
            throw new DataAccessException(e);
        } finally {
            close(ssn);
        }
    }


    public void addDisputeHistory(Long userSessionId, Map<String, Object> params) throws Exception {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            ssn.queryForObject("application.add-dispute-history", params);
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw getUserExceptionWithErrorCode(ssn, e.getCause().getMessage());
            } else {
                throw new DataAccessException(e);
            }
        } finally {
            close(ssn);
        }
    }

    @SuppressWarnings ("unchecked")
    private List<Application> getApplications(Long userSessionId, final SelectionParams params, final String privilege) {
        return executeWithSession(userSessionId, privilege, params, logger, new IbatisSessionCallback<List<Application>>() {
	        @Override
            public List<Application> doInSession(SqlMapSession ssn) throws Exception {
                Map<String, Object> paramsMap = getParamsMap(ssn, privilege, params, false);
                ssn.update("application.get-applications-cur", paramsMap);
                return (paramsMap.get("ref_cur") != null) ? (List<Application>) paramsMap.get("ref_cur") : new ArrayList<Application>();
            }
        });
    }

    @SuppressWarnings ("unchecked")
    private int getApplicationsCount(Long userSessionId, final SelectionParams params, final String privilege) {
        return executeWithSession(userSessionId, privilege, params, logger, new IbatisSessionCallback<Integer>() {
	        @Override
            public Integer doInSession(SqlMapSession ssn) throws Exception {
                Map<String, Object> paramsMap = getParamsMap(ssn, privilege, params, true);
                ssn.update("application.get-applications-cur-count", paramsMap);
                return (paramsMap.get("row_count") != null) ? (Integer)paramsMap.get("row_count") : 0;
            }
        });
    }

    public List<Application> getApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_APPLICATION_DATA);
    }

    public int getApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_APPLICATION_DATA);
    }

    public List<Application> getIssuingApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_ISSUING_APPLICATION);
    }

    public int getIssuingApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_ISSUING_APPLICATION);
    }

    public List<Application> getIssProductApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_ISS_PRD_APPLICATION);
    }

    public int getIssProductApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_ISS_PRD_APPLICATION);
    }

    public List<Application> getAcquiringApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_ACQUIRING_APPLICATION);
    }

    public int getAcquiringApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_ACQUIRING_APPLICATION);
    }

    public List<Application> getAcqProductApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_ACQ_PRD_APPLICATION);
    }

    public int getAcqProductApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_ACQ_PRD_APPLICATION);
    }

    public List<Application> getInstitutionApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_INSTITUTION_APPLICATION);
    }

    public int getInstitutionApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_INSTITUTION_APPLICATION);
    }

    public List<Application> getPMOApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_PMO_APPLICATIONS);
    }

    public int getPMOApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_PMO_APPLICATIONS);
    }

    public List<Application> getACMApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_ACM_APPLICATIONS);
    }

    public int getACMApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_ACM_APPLICATIONS);
    }

    public List<Application> getQuestionaryApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_QUESTIONARY_APPLICATION);
    }

    public int getQuestionaryApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_QUESTIONARY_APPLICATION);
    }

    public List<Application> getCampaignApplications(Long userSessionId, final SelectionParams params) {
        return getApplications(userSessionId, params, ApplicationPrivConstants.VIEW_CAMPAIGN_APPLICATION);
    }

    public int getCampaignApplicationsCount(Long userSessionId, final SelectionParams params) {
        return getApplicationsCount(userSessionId, params, ApplicationPrivConstants.VIEW_CAMPAIGN_APPLICATION);
    }

    public void approveApplications(Long userSessionId, List<Application> apps) throws Exception {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            for (Application app : apps) {
                app.setStatus(ApplicationStatuses.SUCCESS_EVALUATION);
                ssn.insert("application.approve-application", app);
            }
        } catch (SQLException e) {
            if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
                throw getUserExceptionWithErrorCode(ssn, e.getCause().getMessage());
            } else {
                throw new DataAccessException(e);
            }
        } finally {
            close(ssn);
        }
    }

    public PriorityCriteria[] getPriorityCriteria(Long userSessionId, Long applId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            Map<String, Object> paramMap = new HashMap<>();
            paramMap.put("applId", applId);
            ssn.update("application.get-priority-criteria", paramMap);
            List <PriorityCriteria> criteria = (List<PriorityCriteria>)paramMap.get("priorityCriteria");

            return criteria.toArray(new PriorityCriteria[criteria.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getPriorityCriteriaCount(Long userSessionId, Long applId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            Map<String, Object> paramMap = new HashMap<>();
            paramMap.put("applId", applId);
            ssn.update("application.get-priority-criteria", paramMap);
            List <PriorityCriteria> criteria = (List<PriorityCriteria>)paramMap.get("priorityCriteria");
            return criteria.size();
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }

    public ApplicationPriorityProduct[] getPriorityProducts(Long userSessionId, Long applId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);

            Map<String, Object> paramMap = new HashMap<>();
            paramMap.put("applId", applId);
            ssn.update("application.get-priority-products", paramMap);
            List <ApplicationPriorityProduct> products = (List<ApplicationPriorityProduct>)paramMap.get("priorityProducts");

            return products.toArray(new ApplicationPriorityProduct[products.size()]);
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }


    public int getPriorityProductsCount(Long userSessionId, Long applId) {
        SqlMapSession ssn = null;
        try {
            ssn = getIbatisSessionFE(userSessionId);
            Map<String, Object> paramMap = new HashMap<>();
            paramMap.put("applId", applId);
            ssn.update("application.get-priority-products", paramMap);
            List <ApplicationPriorityProduct> criteria = (List<ApplicationPriorityProduct>)paramMap.get("priorityProducts");
            return criteria.size();
        } catch (SQLException e) {
            throw createDaoException(e);
        } finally {
            close(ssn);
        }
    }
}
