package ru.bpc.sv2.ui.application.wizard;

import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.ui.application.MbApplication;
import ru.bpc.sv2.ui.application.MbApplicationsSearch;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import java.util.HashMap;

/**
 * Created by Gasanov on 13.11.2015.
 */
@SessionScoped
@ManagedBean(name = "MbAcmWizard")
public class MbAcmWizard extends MbWizard{

    public String finish() {
        validateForWeb();
        if(!isValid()){
            return null;
        }
        logger.trace("MbWizard::finish...");
        releaseCurrentStep();
        Application app = (Application) context.get("application");
        MbApplication appBean = (MbApplication) ManagedBeanWrapper.getManagedBean("MbApplication");
        appBean.setApplicationTree(applicationRoot);
        appBean.setActiveApp(app);
        appBean.setCurMode(MbApplication.NEW_MODE);
        appBean.setBackLink(getBackLink());
        appBean.setModule("acm");
        appBean.setFiltersMap(getApplicationFilters());
        return "applications|edit";
        /*
        boolean saved = saveApplication();
        if (saved){
            FacesUtils.setSessionMapValue("APP_TYPE", appType);
            Menu menu = (Menu) ManagedBeanWrapper.getManagedBean("menu");
            menu.setKeepState(true);
            setKeepState(true);
            if (backLink != null){
                return backLink;
            }else{
                return "blankPage";
            }
        } else {
            return "";
        }
        */

    }
}
