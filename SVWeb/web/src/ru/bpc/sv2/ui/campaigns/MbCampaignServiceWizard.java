package ru.bpc.sv2.ui.campaigns;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.campaign.CampaignService;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.products.Service;
import ru.bpc.sv2.ui.application.MbApplication;
import ru.bpc.sv2.ui.application.MbApplicationCreate;
import ru.bpc.sv2.ui.application.MbApplicationsSearch;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.navigation.Menu;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import java.io.Serializable;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@SessionScoped
@ManagedBean (name = "MbCampaignServiceWizard")
public class MbCampaignServiceWizard implements Serializable {
    private static final Logger logger = Logger.getLogger("APPLICATIONS");
    private static final long serialVersionUID = 1L;
    private static final String INIT_PAGE = "/pages/campaigns/app_campaign_init_modal_panel.jspx";
    private static final String STEP_PAGE = "/pages/campaigns/app_campaign_wizard_modal_panel.jspx";
    private static final String TREE_PAGE = "applications|edit";
    private static final String APPS_PAGE = "applications|list_cmpn_apps";
    private static final String FAIL_PAGE = "fail";

    private int innerId = 1;
    private long userSessionId;
    private String userLang;
    private String productNumber;
    private String productName;
    private String backLink;

    protected ApplicationWizardContext context;
    private List<CampaignService> services;

    private ApplicationDao applDao = new ApplicationDao();
    private CampaignDao campaignDao = new CampaignDao();

    public void init(ApplicationWizardContext ctx) {
        context = ctx;
        userLang = (String)context.get("userLang");
        userSessionId = (Long)context.get("userSessionId");
        innerId = (Integer)context.get("innerId");
        backLink = (String)context.get("backlink");
        services = null;

        Application application = (Application)context.get("application");
        ApplicationElement campaign = context.getApplicationRoot().getChildByName(AppElements.CAMPAIGN);
        ApplicationElement product = campaign.getChildByName(AppElements.CAMPAIGN_PRODUCT, innerId);

        if (product != null) {
            productNumber = product.getChildByName(AppElements.PRODUCT_NUMBER).getValueV();
            if (product.getChildByName(AppElements.PRODUCT_NAME) != null) {
                productName = product.getChildByName(AppElements.PRODUCT_NAME).getValueV();
                product.removeLastChild(AppElements.PRODUCT_NAME);
            }

            SelectionParams params = SelectionParams.build("lang", userLang, "productNumber", productNumber);
            params.setRowIndexStart(0);
            params.setRowIndexEnd(9999);
            services = campaignDao.getServiceList(userSessionId, params);
        }
    }

    public void next() {
        logger.trace("Next service step");
        Application application = (Application)context.get("application");
        ApplicationElement campaign = context.getApplicationRoot().getChildByName(AppElements.CAMPAIGN);
        ApplicationElement product = campaign.getChildByName(AppElements.CAMPAIGN_PRODUCT, innerId);
        context.set("innerId", ++innerId);

        if (product != null) {
            for (CampaignService service : services) {
                if (service.isChecked()) {
                    product.addChildren(addBlock(product, application));
                    ApplicationElement elService = product.getChildByName(AppElements.PRODUCT_SERVICE);
                    elService.addValue(AppElements.COMMAND, ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
                    elService.addValue(AppElements.SERVICE_NUMBER, service.getServiceNumber());
                }
            }
            context.set("application", application);
            init(context);
        } else {
            logger.trace("Finish wizard steps");
        }

        logger.trace("Finish next service step");
    }

    public void back() {
        logger.trace("Back service step");
        context.set("innerId", --innerId);
        init(context);
        logger.trace("Finish back service step");
    }

    public void cancel() {

    }

    public String finish() {
        Application application = (Application)context.get("application");
        ApplicationElement campaign = context.getApplicationRoot().getChildByName(AppElements.CAMPAIGN);
        ApplicationElement product = campaign.getChildByName(AppElements.CAMPAIGN_PRODUCT, innerId);
        context.set("innerId", ++innerId);

        if (product != null) {
            for (CampaignService service : services) {
                if (service.isChecked()) {
                    product.addChildren(addBlock(product, application));
                    ApplicationElement elService = product.getChildByName(AppElements.PRODUCT_SERVICE);
                    elService.addValue(AppElements.COMMAND, ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
                    elService.addValue(AppElements.SERVICE_NUMBER, service.getServiceNumber());
                }
            }
            context.set("application", application);
        }

        try {
            MbApplication bean = ManagedBeanWrapper.getManagedBean(MbApplication.class);
            if (bean != null) {
                bean.setCurMode(MbApplication.NEW_MODE);
                bean.setPageNumber(1);
                bean.setRowsNum(20);
                bean.setActiveApp(application);
                bean.setBackLink(backLink);
                bean.setModule(MbApplicationsSearch.CAMPAIGN);
                bean.setKeepState(true);
                bean.setApplicationTree(context.getApplicationRoot());
                bean.setFiltersMap(context.getApplicationFilters());
            }
            Menu menu = ManagedBeanWrapper.getManagedBean(Menu.class);
            menu.setKeepState(true);
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return TREE_PAGE;
    }

    public boolean isFinished() {
        if (context != null) {
            ApplicationElement campaign = context.getApplicationRoot().getChildByName(AppElements.CAMPAIGN);
            ApplicationElement product = campaign.getChildByName(AppElements.CAMPAIGN_PRODUCT, innerId + 1);
            if (product == null) {
                return true;
            }
        }
        return false;
    }

    public boolean blockRollback() {
        return (innerId <= 1);
    }

    public List<CampaignService> getServices() {
        if (services == null) {
            services = new ArrayList<CampaignService>();
        }
        return services;
    }
    public void setServices(List<CampaignService> services) {
        this.services = services;
    }

    public String getProductNumber() {
        return productNumber;
    }
    public void setProductNumber(String productNumber) {
        this.productNumber = productNumber;
    }

    public String getProductName() {
        return productName;
    }
    public void setProductName(String productName) {
        this.productName = productName;
    }

    public int getInnerId() {
        return innerId;
    }
    public void setInnerId(int innerId) {
        this.innerId = innerId;
    }

    private ApplicationElement addBlock(ApplicationElement root, Application application) {
        ApplicationElement template = root.getChildByName(AppElements.PRODUCT_SERVICE, 0);
        Integer instId = (Integer)context.get("instId");
        if (template != null) {
            ApplicationElement node = new ApplicationElement();
            Map<Integer, ApplicationFlowFilter> filters = new HashMap<Integer, ApplicationFlowFilter>();
            template.clone(node);
            node.setContent(false);
            template.setMaxCopy(template.getMaxCopy() + 1);
            node.setInnerId(template.getMaxCopy());
            node.setContentBlock(template);
            applDao.fillRootChilds(userSessionId, instId, node, application, filters);
            return node;
        }
        return null;
    }
}
