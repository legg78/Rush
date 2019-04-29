package ru.bpc.sv2.ui.application.wizard;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.roles.ComplexRole;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.RolesDao;
import ru.bpc.sv2.ui.common.application.AppWizStep;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.ArrayList;

import static ru.bpc.sv2.utils.AppStructureUtils.instance;
import static ru.bpc.sv2.utils.AppStructureUtils.retrive;
import static ru.bpc.sv2.utils.AppStructureUtils.tryRetrive;

@ViewScoped
@ManagedBean(name = "MbAppWizAcmNewUser")
public class MbAppWizAcmNewUser extends AbstractBean implements AppWizStep, Serializable {
    private static final Logger logger = Logger.getLogger(MbAppWizAcmNewUser.class);
    private String page = "/pages/acquiring/applications/wizard/appWizAcmNewUser.jspx";

    private ApplicationWizardContext appWizCtx;
    private ApplicationElement applicationRoot;
    private ApplicationElement userElement;

    private User newUser;
    private Integer defaultRoleId;
    private Integer defaultInstId;
    private ArrayList<SelectItem> roles;
    private ArrayList<SelectItem> institutions;
    private ArrayList<SelectItem> genders;
    private String mobilePhone;
    private String email;

    private RolesDao _rolesDao = new RolesDao();

    private ApplicationDao applicationDao = new ApplicationDao();

    @Override
    public void clearFilter() {

    }

    @Override
    public ApplicationWizardContext release() {
        //appWizCtx.setLinkedMap(linkedMap);
        appWizCtx.setApplicationRoot(applicationRoot);
        ApplicationElement user = applicationRoot.getChildByName(AppElements.USER,1);
        user.getChildByName(AppElements.USER_NAME, 1).setValueV(newUser.getName());

        ApplicationElement user_inst = user.getChildByName(AppElements.USER_INST ,1);
        user_inst.getChildByName(AppElements.INSTITUTION_ID, 1).setValueN(defaultInstId);

        applicationRoot.getChildByName(AppElements.INSTITUTION_ID,1).setValueN(defaultInstId);

        ApplicationElement person = user.getChildByName(AppElements.PERSON ,1);
        person.getChildByName(AppElements.GENDER,1).setValueV(newUser.getPerson().getGender());
        person.getChildByName(AppElements.BIRTHDAY,1).setValueD(newUser.getPerson().getBirthday());

        ApplicationElement person_name = person.getChildByName(AppElements.PERSON_NAME ,1);
        person_name.getChildByName(AppElements.SURNAME,1).setValueV(newUser.getPerson().getSurname());
        person_name.getChildByName(AppElements.FIRST_NAME,1).setValueV(newUser.getPerson().getFirstName());
        person_name.getChildByName(AppElements.SECOND_NAME,1).setValueV(newUser.getPerson().getSecondName());

        ApplicationElement user_role = user.getChildByName(AppElements.USER_ROLE ,1);
        user_role.getChildByName(AppElements.ROLE_ID,1).setValueN(defaultRoleId);

        ApplicationElement contact;
        boolean added = false;
        if(mobilePhone != null && !mobilePhone.isEmpty()) {
            ApplicationElement contactData = null;
            contact = user.getChildByName(AppElements.CONTACT, 1);
            if (contact == null) {
                contact = createElement(user, AppElements.CONTACT, null);
            }
            contactData = contact.getChildByName(AppElements.CONTACT_DATA, 1);
            if (contactData == null) {
                contactData = createElement(contact, AppElements.CONTACT_DATA, null);
            }
            added = true;
            contactData.getChildByName(AppElements.COMMUN_METHOD, 1).setValueV("CMNM0001");
            contactData.getChildByName(AppElements.COMMUN_ADDRESS, 1).setValueV(mobilePhone);
        }

        if(email != null && !email.isEmpty()) {
            contact = user.getChildByName(AppElements.CONTACT, 1);
            ApplicationElement contactData = null;
            if (contact == null) {
                contact = createElement(user, AppElements.CONTACT, null);
            }
            contactData = contact.getChildByName(AppElements.CONTACT_DATA, 1);
            if (contactData == null || added) {
                contactData = createElement(contact, AppElements.CONTACT_DATA, null);
            }
            contactData.getChildByName(AppElements.COMMUN_METHOD, 1).setValueV("CMNM0002");
            contactData.getChildByName(AppElements.COMMUN_ADDRESS, 1).setValueV(email);
        }
        Application app = (Application) appWizCtx.get("application");
        app.setInstId(defaultInstId);

        applicationRoot = null;
        return appWizCtx;
    }

    @Override
    public void init(ApplicationWizardContext ctx) {
        newUser = new User();
        newUser.setPerson(new Person());

        logger.trace("MbAppWizAcmNewUser::init(ApplicationWizardContext)...");
        appWizCtx = ctx;
        this.applicationRoot = ctx.getApplicationRoot();
        applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).setValueN(userInstId);;
        ctx.setStepPage(page);
        userElement = tryRetrive(applicationRoot, AppElements.USER);
        if (userElement == null){
            userElement = createElement(applicationRoot, AppElements.USER, null);
        }

        ApplicationElement user_inst = userElement.getChildByName(AppElements.USER_INST ,1);
        if (user_inst == null){
            createElement(userElement, AppElements.USER_INST, null);
        }

        ApplicationElement person = userElement.getChildByName(AppElements.PERSON ,1);
        if (person == null){
            person = createElement(userElement, AppElements.PERSON, null);
        }

        ApplicationElement person_name = person.getChildByName(AppElements.PERSON_NAME,1);
        if (person_name == null){
            createElement(person, AppElements.PERSON_NAME, null);
        }

        ApplicationElement user_role = userElement.getChildByName(AppElements.USER_ROLE,1);
        if (user_role == null){
            createElement(userElement, AppElements.USER_ROLE, null);
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
        return newUser.getName() != null && defaultRoleId != null && defaultInstId != null;
    }

    @Override
    public boolean checkKeyModifications() {
        return false;
    }

    @Override
    public boolean getLock() {
        return true;
    }

    public ArrayList<SelectItem> getRoles() {
        if(roles != null){
            return roles;
        }

        Filter[] filters = new Filter[1];
        filters[0] = new Filter();
        filters[0].setElement("lang");
        filters[0].setValue(curLang);

        SelectionParams params = new SelectionParams();
        params.setRowIndexEnd(-1);
        params.setFilters(filters);
        try {
            ComplexRole[] rolesList = _rolesDao.getRoles(userSessionId, params);
            roles = new ArrayList<SelectItem>(rolesList.length);
            for (ComplexRole role: rolesList) {
                roles.add(new SelectItem(role.getId(), role.getShortDesc(), role.getFullDesc()));
            }
        } catch (Exception e) {
            logger.error("", e);
            if (e.getMessage().indexOf(SystemConstants.INSUFFICIENT_PRIVILEGES_ERROR) < 0) {
                FacesUtils.addMessageError(e);
            }
        }

        if (roles == null)
            roles = new ArrayList<SelectItem>(0);

        return roles;
    }

    public ArrayList<SelectItem> getInstitutions() {
        if (institutions == null) {
            institutions = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.INSTITUTIONS);
        }
        if (institutions == null)
            institutions = new ArrayList<SelectItem>();
        return institutions;
    }

    public User getNewUser() {
        return newUser;
    }

    public void setNewUser(User newUser) {
        this.newUser = newUser;
    }

    public Integer getDefaultRoleId() {
        return defaultRoleId;
    }

    public void setDefaultRoleId(Integer defaultRoleId) {
        this.defaultRoleId = defaultRoleId;
    }

    public Integer getDefaultInstId() {
        return defaultInstId;
    }

    public void setDefaultInstId(Integer defaultInstId) {
        this.defaultInstId = defaultInstId;
    }

    public String getMobilePhone() {
        return mobilePhone;
    }

    public void setMobilePhone(String mobilePhone) {
        this.mobilePhone = mobilePhone;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public ArrayList<SelectItem> getGenders(){
        if (genders == null) {
            genders = (ArrayList<SelectItem>) getDictUtils().getLov(LovConstants.PERSON_GENDER);
        }
        if (genders == null)
            genders = new ArrayList<SelectItem>();
        return genders;
    }
}

