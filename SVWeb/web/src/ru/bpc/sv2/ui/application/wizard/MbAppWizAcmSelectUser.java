package ru.bpc.sv2.ui.application.wizard;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.CommonDao;
import ru.bpc.sv2.ui.audit.MbUserSearchModal;
import ru.bpc.sv2.ui.common.application.AppWizStep;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.Serializable;

import static ru.bpc.sv2.utils.AppStructureUtils.instance;
import static ru.bpc.sv2.utils.AppStructureUtils.retrive;
import static ru.bpc.sv2.utils.AppStructureUtils.tryRetrive;

@ViewScoped
@ManagedBean(name = "MbAppWizAcmSelectUser")
public class MbAppWizAcmSelectUser extends AbstractBean implements AppWizStep, Serializable {
    private static final Logger logger = Logger.getLogger(MbAppWizAcmSelectUser.class);
    private String page = "/pages/acquiring/applications/wizard/appWizAcmSelectUser.jspx";

    private ApplicationWizardContext appWizCtx;
    private ApplicationElement applicationRoot;
    private ApplicationElement userElement;

    private User newUser;

    private ApplicationDao applicationDao = new ApplicationDao();

    private CommonDao _commonDao = new CommonDao();

    @Override
    public void clearFilter() {

    }

    @Override
    public ApplicationWizardContext release() {
        //appWizCtx.setLinkedMap(linkedMap);
        appWizCtx.setApplicationRoot(applicationRoot);
        ApplicationElement user = applicationRoot.getChildByName(AppElements.USER,1);
        if (user != null){
            if (newUser.getName() != null) {
                if(user.getChildByName(AppElements.USER_NAME, 1) != null) {
                    user.getChildByName(AppElements.USER_NAME, 1).setValueV(newUser.getName());
                }
            }
            if (newUser.getId() != null) {
                if (user.getChildByName(AppElements.USER_ID, 1) != null) {
                    user.getChildByName(AppElements.USER_ID, 1).setValueN(newUser.getId());
                }
            }
            if (newUser.getStatus() != null) {
                if(user.getChildByName(AppElements.USER_STATUS, 1) != null){
                    user.getChildByName(AppElements.USER_STATUS, 1).setValueV(newUser.getStatus());
                }
            }
            if (newUser.getInstId() != null) {
                if(user.getChildByName(AppElements.INSTITUTION_ID, 1) != null) {
                    user.getChildByName(AppElements.INSTITUTION_ID, 1).setValueN(newUser.getInstId());
                }
            }
        }

        applicationRoot = null;
        return appWizCtx;
    }

    @Override
    public void init(ApplicationWizardContext ctx) {
        newUser = new User();
        newUser.setPerson(new Person());

        logger.trace("MbAppWizAcmSelectUser::init(ApplicationWizardContext)...");
        appWizCtx = ctx;
        this.applicationRoot = ctx.getApplicationRoot();
        applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).setValueN(userInstId);;
        ctx.setStepPage(page);
        userElement = tryRetrive(applicationRoot, AppElements.USER);
        if (userElement == null){
            userElement = createElement(applicationRoot, AppElements.USER, null);
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
        return newUser.getName() != null && !newUser.getName().isEmpty(); //newUser.getName() != null && newUser.getStatus() != null;
    }

    @Override
    public boolean checkKeyModifications() {
        return false;
    }

    @Override
    public boolean getLock() {
        return true;
    }

    public User getNewUser() {
        return newUser;
    }

    public void setNewUser(User newUser) {
        this.newUser = newUser;
    }

    public void initPanel() {
        logger.debug("init search user panel for flow change roles");
    }

    public void selectUser() {
        MbUserSearchModal userBean = (MbUserSearchModal) ManagedBeanWrapper
                .getManagedBean("MbUserSearchModal");
        newUser = userBean.getActiveUser();
    }
}
