package ru.bpc.sv2.ui.application.wizard;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.orgstruct.OrgStructType;
import ru.bpc.sv2.ui.administrative.roles.MbUserRolesSearch;
import ru.bpc.sv2.ui.common.application.AppWizStep;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.Serializable;
import java.util.*;

import static ru.bpc.sv2.utils.AppStructureUtils.instance;
import static ru.bpc.sv2.utils.AppStructureUtils.retrive;

@ViewScoped
@ManagedBean(name = "MbAppWizAcmUserRoles")
public class MbAppWizAcmUserRoles extends AbstractBean implements AppWizStep, Serializable {
    private static final Logger logger = Logger.getLogger(MbAppWizAcmNewUser.class);
    private String page = "/pages/acquiring/applications/wizard/userRolesWiz.jspx";

    private ApplicationWizardContext appWizCtx;
    private ApplicationElement applicationRoot;

    private RolesDao _rolesDao = new RolesDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void clearFilter() {

    }

    @Override
    public ApplicationWizardContext release() {
        ApplicationElement user = applicationRoot.getChildByName(AppElements.USER, 1);

        MbUserRolesWizSearch userInstAgentsBean = ManagedBeanWrapper.getManagedBean("MbUserRolesWizSearch");
	    Map<Integer, ComplexRole> addRoles = new HashMap<>(userInstAgentsBean.getAddRoles());
        Map<Integer, ComplexRole> deleteRoles = new HashMap<>(userInstAgentsBean.getDeleteRoles());

        Map<Integer, ComplexRole> allRoles = new LinkedHashMap<>(addRoles);
        allRoles.putAll(deleteRoles);
        int step = 0;

        for (Map.Entry<Integer, ComplexRole> entry : allRoles.entrySet()) {
        	ComplexRole role = entry.getValue();
	        ApplicationElement user_role = null;
	        if (step == 0) {
	            user_role = user.getChildByName(AppElements.USER_ROLE, 1);
	        }
	        if (user_role == null) {
		        user_role = createElement(user, AppElements.USER_ROLE, addRoles.containsKey(entry.getKey()) ?
                        ApplicationConstants.COMMAND_CREATE_OR_PROCEED : ApplicationConstants.COMMAND_PROCEED_OR_REMOVE);
	        }
	        user_role.getChildByName(AppElements.ROLE_ID, 1).setValueN(role.getId());
	        user_role.getChildByName(AppElements.ROLE_NAME, 1).setValueV(role.getName());
	        ++step;
        }

        appWizCtx.setApplicationRoot(applicationRoot);
        return appWizCtx;
    }

    @Override
    public void init(ApplicationWizardContext ctx) {
        logger.trace("MbAppWizAcmUserRoles::init(ApplicationWizardContext)...");
        ctx.setStepPage(page);
        appWizCtx = ctx;
        this.applicationRoot = ctx.getApplicationRoot();

        ApplicationElement user = applicationRoot.getChildByName(AppElements.USER,1);
        ApplicationElement userIdEl = user.getChildByName(AppElements.USER_ID, 1);
        if(userIdEl != null && userIdEl.getValue() != null) {
            Integer userId = Integer.valueOf(userIdEl.getValue().toString());

            User _activeUser = new User();
            _activeUser.setId(userId);
            MbUserRolesWizSearch userInstAgentsBean = (MbUserRolesWizSearch) ManagedBeanWrapper
                    .getManagedBean("MbUserRolesWizSearch");
            userInstAgentsBean.setPreFind(false);
            userInstAgentsBean.clearFilter();
            userInstAgentsBean.setUserId(userId);
            userInstAgentsBean.search();
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
        MbUserRolesWizSearch userInstAgentsBean = ManagedBeanWrapper.getManagedBean("MbUserRolesWizSearch");
        if (userInstAgentsBean.getTotalRolesCount() == userInstAgentsBean.getDeleteRoles().size()) {
            FacesUtils.addMessageError(FacesUtils.getMessage("ru.bpc.sv2.ui.bundles.Acm", "user_one_role"));
            return false;
        }
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

