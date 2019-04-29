package ru.bpc.sv2.ui.application.wizard;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.common.application.MbAppWizardFirstPage;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

/**
 * Created by Gasanov on 12.11.2015.
 */
@ViewScoped
@ManagedBean(name = "MbAppWizAcmFlow")
public class MbAppWizAcmFlow extends MbAppWizardFirstPage {
    private static final Logger logger = Logger.getLogger(MbAppWizAcmFlow.class);
    //private String page = "/pages/acquiring/applications/wizard/appWizAcmFlow.jspx";
    private String DEFAULT_INST = "9999";
    private String backlink;

    ApplicationDao _applicationDao = new ApplicationDao();

    UsersDao _usersDao = new UsersDao();

    public List<SelectItem> getApplicationFlows() {
        ArrayList<SelectItem> items = new ArrayList<SelectItem>();
        try {
            SelectionParams params = new SelectionParams();
            params.setRowIndexEnd(-1);
            ArrayList<Filter> filtersFlow = new ArrayList<Filter>();
            filtersFlow.add(new Filter("instId", DEFAULT_INST));

            filtersFlow.add(new Filter("lang", curLang));
            filtersFlow.add(new Filter("type", getApplicationType()));

            params.setFilters(filtersFlow);
            params.setSortElement(new SortElement("id", SortElement.Direction.ASC));
            params.setPrivilege("ADD_ACM_APPLICATION");
            Object[] key = {userSessionId, params};
                ApplicationFlow[] flows = _applicationDao.getApplicationFlowsWithRoles(userSessionId, params);

                for (ApplicationFlow flow : flows) {
                    items.add(new SelectItem(flow.getId(), flow.getId() + " - " + flow.getName(), flow.getDescription()));
                }
        } catch (DataAccessException e) {
            logger.error("", e);
            if (!e.getMessage().contains(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR)) {
                FacesUtils.addMessageError(e);
            }
        }
        return items;
    }

    public void create() {
        Application application = new Application();
        application.setInstId(instId);
        //application.setAgentId(agentId);
        application.setFlowId(getFlowId());
        application.setAppType(getApplicationType());
        application.setStatus(ApplicationStatuses.JUST_CREATED);

        // Obtain blank application by flowId and fill it
        Map<Integer, ApplicationFlowFilter> applicationFilters = new HashMap<Integer, ApplicationFlowFilter>();;
        ApplicationElement applicationRoot = _applicationDao.getApplicationStructure(userSessionId, application, applicationFilters);
        ApplicationElement aeFlowId = applicationRoot.getChildByName(AppElements.APPLICATION_FLOW_ID, 1);
        aeFlowId.setValueN(getFlowId());
        ApplicationElement aeAppStatus = applicationRoot.getChildByName(AppElements.APPLICATION_STATUS, 1);
        aeAppStatus.setValueV(ApplicationStatuses.JUST_CREATED);
        ApplicationElement aeAppType = applicationRoot.getChildByName(AppElements.APPLICATION_TYPE, 1);
        aeAppType.setValueV(getApplicationType());
        ApplicationElement operId = applicationRoot.getChildByName(AppElements.OPERATOR_ID, 1);

        UserSession usession = ManagedBeanWrapper.getManagedBean("usession");
	    operId.setValueV(usession.getUser().getName());

	    Integer instId = (Integer) SessionWrapper.getObjectField("defaultInst");
	    if (instId != null && instId != 9999) {
		    ApplicationElement instIdElement = applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1);
		    instIdElement.setValueN(instId);
	    }



        SelectionParams sp = new SelectionParams(
                new Filter("flowId", getFlowId()),
                new Filter("lang", userLang),
                new Filter("appStatus", ApplicationStatuses.JUST_CREATED)
        );
        sp.setSortElement(
                new SortElement("displayOrder", SortElement.Direction.ASC)
        );

        AppFlowStep[] appFlowStepsArr = _applicationDao.getAppFlowSteps(userSessionId, sp);
        appFlowSteps = Arrays.asList(appFlowStepsArr);
        if (appFlowSteps == null || appFlowSteps.isEmpty()){
            FacesUtils.addMessageError("There is no wizard flow has been found");
            return ;
        }

        appFlowSteps.get(0).setKeyStep(true); // "Customer and Contact" step is always "Reset Step"
        MbWizard mbWizard = ManagedBeanWrapper.getManagedBean(MbAcmWizard.class);
        ApplicationWizardContext ctx = new ApplicationWizardContext();
        ctx.setSteps(appFlowSteps);
        ctx.setApplicationFilters(applicationFilters);
        ctx.setApplicationRoot(applicationRoot);
        ctx.set("backlink", backlink);
        ctx.set("application", application);

        mbWizard.init(ctx);
    }

    public void setBacklink(String backlink) {
        this.backlink = backlink;
    }
}
