package ru.bpc.sv2.ui.application.wizard;

import org.apache.log4j.Logger;
import ru.bpc.sv2.administrative.users.User;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.common.ContactData;
import ru.bpc.sv2.common.Person;
import ru.bpc.sv2.common.PersonId;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.invocation.SelectionParams;
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
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.*;

import static ru.bpc.sv2.utils.AppStructureUtils.instance;
import static ru.bpc.sv2.utils.AppStructureUtils.retrive;
import static ru.bpc.sv2.utils.AppStructureUtils.tryRetrive;

@ViewScoped
@ManagedBean(name = "MbAppWizAcmChangeUser")
public class MbAppWizAcmChangeUser extends AbstractBean implements AppWizStep, Serializable {
    private static final Logger logger = Logger.getLogger(MbAppWizAcmChangeUser.class);
    private String page = "/pages/acquiring/applications/wizard/appWizAcmChangeUser.jspx";

    private ApplicationWizardContext appWizCtx;
    private ApplicationElement applicationRoot;
    private ApplicationElement userElement;

    private String mobilePhone;
    private String email;

    private boolean initIdType = false;

    private User newUser;
    private ArrayList<SelectItem> genders;
    private Map<String, ContactData> contactDataMap;

    private ApplicationDao applicationDao = new ApplicationDao();

    private CommonDao _commonDao = new CommonDao();

    @Override
    public void clearFilter() {

    }

    @Override
    public ApplicationWizardContext release() {
        //appWizCtx.setLinkedMap(linkedMap);
        appWizCtx.setApplicationRoot(applicationRoot);
        ApplicationElement user = applicationRoot.getChildByName(AppElements.USER, 1);
        ApplicationElement person = user.getChildByName(AppElements.PERSON, 1);
        ApplicationElement person_name = person.getChildByName(AppElements.PERSON_NAME, 1);
        if(newUser.getName() != null) {
            user.getChildByName(AppElements.USER_NAME, 1).setValueV(newUser.getName());
        }
        if(newUser.getId() != null) {
            user.getChildByName(AppElements.USER_ID, 1).setValueN(newUser.getId());
        }
        if(newUser.getStatus() != null) {
            user.getChildByName(AppElements.USER_STATUS, 1).setValueV(newUser.getStatus());
        }
        if(newUser.getInstId() != null) {
            Application app = (Application) appWizCtx.get("application");
            app.setInstId(newUser.getInstId());
            applicationRoot.getChildByName(AppElements.INSTITUTION_ID,1).setValueN(newUser.getInstId());
        }

        if(newUser.getPerson() != null) {
            if (newUser.getPerson().getGender() != null) {
                person.getChildByName(AppElements.GENDER, 1).setValueV(newUser.getPerson().getGender());
            }
            if (newUser.getPerson().getBirthday() != null) {
                person.getChildByName(AppElements.BIRTHDAY, 1).setValueD(newUser.getPerson().getBirthday());
            }

            if (newUser.getPerson().getSurname() != null) {
                person_name.getChildByName(AppElements.SURNAME, 1).setValueV(newUser.getPerson().getSurname());
            }
            if (newUser.getPerson().getFirstName() != null){
                person_name.getChildByName(AppElements.FIRST_NAME, 1).setValueV(newUser.getPerson().getFirstName());
            }
            if (newUser.getPerson().getSecondName() != null) {
                person_name.getChildByName(AppElements.SECOND_NAME, 1).setValueV(newUser.getPerson().getSecondName());
            }
        }




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

        ApplicationElement identity;
        List<PersonId> identityList = getIdentity();
        if(!identityList.isEmpty()){
            identity = person.getChildByName(AppElements.IDENTITY_CARD, 1);
            added = false;
            for(PersonId personId : identityList){
                if(added || identity == null) {
                    identity = createElement(person, AppElements.IDENTITY_CARD, null);
                }
                added = true;
                identity.getChildByName(AppElements.ID_TYPE, 1).setValueV(personId.getIdType());
                identity.getChildByName(AppElements.ID_NUMBER, 1).setValueV(personId.getIdNumber());
                identity.getChildByName(AppElements.ID_SERIES, 1).setValueV(personId.getIdSeries());
            }
        }

        applicationRoot = null;
        return appWizCtx;
    }

    @Override
    public void init(ApplicationWizardContext ctx) {
        newUser = new User();
        newUser.setPerson(new Person());

        logger.trace("MbAppWizAcmChangeUser::init(ApplicationWizardContext)...");
        appWizCtx = ctx;
        this.applicationRoot = ctx.getApplicationRoot();
        applicationRoot.getChildByName(AppElements.INSTITUTION_ID, 1).setValueN(userInstId);;
        ctx.setStepPage(page);
        userElement = tryRetrive(applicationRoot, AppElements.USER);
        if (userElement == null){
            userElement = createElement(applicationRoot, AppElements.USER, null);
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

    public List<PersonId> getIdentity(){
        SelectionParams params = SelectionParams.build("entityType", EntityNames.PERSON, "objectId", newUser.getPersonId(), "lang", userLang);
        params.setRowIndexEnd(Integer.MAX_VALUE);
        params.setRowIndexStart(0);
        PersonId[] persons = _commonDao.getObjectIds(userSessionId, params);
        return new ArrayList<PersonId>(Arrays.asList(persons));
    }

    public Map<String, ContactData> getContactData(){
        if(contactDataMap == null) {
            SelectionParams params = SelectionParams.build("entity_type", EntityNames.USER, "objectId", newUser.getId());
            params.setRowIndexEnd(Integer.MAX_VALUE);
            params.setRowIndexStart(0);
            ContactData[] contactData = _commonDao.getContactUser(userSessionId, params);

            contactDataMap = new HashMap<String, ContactData>();
            for (ContactData contact : contactData) {
                contactDataMap.put(contact.getType(), contact);
            }
        }
        return contactDataMap;
    }

    public User getNewUser() {
        if(newUser == null){
            newUser = new User();
            newUser.setPerson(new Person());
        }
        return newUser;
    }

    public void setNewUser(User newUser) {
        this.newUser = newUser;
    }

	public String getMobilePhone() {
		if (initIdType) {
			ContactData cd = getContactData().get("CMNM0001");
			if (cd != null) {
				mobilePhone = cd.getAddress();
			}
		}
		return mobilePhone;
	}

    public void setMobilePhone(String mobilePhone) {
        this.mobilePhone = mobilePhone;
    }

	public String getEmail() {
		if (initIdType) {
			ContactData cd = getContactData().get("CMNM0002");
			if (cd != null) {
				email = cd.getAddress();
			}
		}
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

    public void initPanel() {
        logger.debug("init search user panel for flow change user");
    }

    public void selectUser() {
        MbUserSearchModal userBean = (MbUserSearchModal) ManagedBeanWrapper
                .getManagedBean("MbUserSearchModal");
        newUser = userBean.getActiveUser();
        initIdType = true;
        contactDataMap = null;
    }

}
