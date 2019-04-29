package ru.bpc.sv2.ui.application.wizard;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.orgstruct.OrgStructType;
import ru.bpc.sv2.ui.administrative.users.MbUserInstsNAgents;
import ru.bpc.sv2.ui.common.application.AppWizStep;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.Serializable;

import static ru.bpc.sv2.utils.AppStructureUtils.*;

@ViewScoped
@ManagedBean(name = "MbAppWizAcmUserInsts")
public class MbAppWizAcmUserInsts extends AbstractBean implements AppWizStep, Serializable {
    private static final Logger logger = Logger.getLogger(MbAppWizAcmNewUser.class);
    private String page = "/pages/acquiring/applications/wizard/appWizAcmUserInsts.jspx";

    private ApplicationWizardContext appWizCtx;
    private ApplicationElement applicationRoot;

    private RolesDao _rolesDao = new RolesDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void clearFilter() {

    }

    @Override
    public ApplicationWizardContext release() {
        //appWizCtx.setLinkedMap(linkedMap);
        MbUserInstsNAgentsWiz bean = (MbUserInstsNAgentsWiz)ManagedBeanWrapper.getManagedBean("MbUserInstsNAgentsWiz");
        OrgStructType[] org = bean.getTree();
        ApplicationElement user = applicationRoot.getChildByName(AppElements.USER,1);
        ApplicationElement user_inst = null;
        ApplicationElement user_agent;

        for(int i = 0; i < org.length; i++) {
            if(!org[i].isAgent()) {
                user_inst = createElement(user, AppElements.USER_INST, null);
                if(user_inst != null) {
                    user_inst.getChildByName(AppElements.INSTITUTION_ID, 1).setValueN(org[i].getId().intValue());
                }
            }else {
                user_agent = createElement(user_inst, AppElements.USER_AGENT, null);
                if(user_agent != null) {
                    user_agent.getChildByName(AppElements.AGENT_ID, 1).setValueN(org[i].getId().intValue());
                    user_agent.getChildByName(AppElements.IS_DEFAULT, 1).setValueN((org[i].isDefaultAgent()) ? 1 : 0);
                }
            }
        }

        appWizCtx.setApplicationRoot(applicationRoot);
        return appWizCtx;
    }

    @Override
    public void init(ApplicationWizardContext ctx) {
        logger.trace("MbAppWizAcmUserInsts::init(ApplicationWizardContext)...");
        ctx.setStepPage(page);
        appWizCtx = ctx;
        this.applicationRoot = ctx.getApplicationRoot();

        ApplicationElement user = applicationRoot.getChildByName(AppElements.USER,1);
        ApplicationElement userIdEl = user.getChildByName(AppElements.USER_ID, 1);
        if(userIdEl != null && userIdEl.getValue() != null) {
            Integer userId = Integer.valueOf(userIdEl.getValue().toString());

            User _activeUser = new User();
            _activeUser.setId(userId);
            MbUserInstsNAgents userInstAgentsBean = (MbUserInstsNAgentsWiz) ManagedBeanWrapper
                    .getManagedBean("MbUserInstsNAgentsWiz");
            userInstAgentsBean.setUserId(userId);
            userInstAgentsBean.setUser(_activeUser);
            userInstAgentsBean.searchOrgStructTypes();
        }
    }

    private ApplicationElement createElement(ApplicationElement parent, String elementName, String command){

        ApplicationElement result = null;
        try{
            Integer intId = retrive(applicationRoot, AppElements.INSTITUTION_ID).getValueN().intValue();
            Application appStub = new Application();
            appStub.setInstId(intId);
            appStub.setFlowId(((Application)appWizCtx.get("application")).getFlowId());

            result = instance(parent, elementName);
            applicationDao.fillRootChilds(userSessionId, intId, result, appWizCtx.getApplicationFilters());

            if(command != null) {
                retrive(result, AppElements.COMMAND).setValueV(command);
            }
            applicationDao.applyDependencesWhenAdd(userSessionId, appStub, result, appWizCtx.getApplicationFilters());
        }catch(Exception e){
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return result;
    }

    @Override
    public boolean validate() {
        return true;
    }

    @Override
    public boolean checkKeyModifications() {
        return false;
    }

    @Override
    public boolean getLock() {
        return true;
    }
}

