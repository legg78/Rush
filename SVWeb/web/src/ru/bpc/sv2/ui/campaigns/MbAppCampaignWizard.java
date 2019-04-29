package ru.bpc.sv2.ui.campaigns;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.Application;
import ru.bpc.sv2.application.ApplicationElement;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.application.ApplicationFlowFilter;
import ru.bpc.sv2.campaign.CampaignConstants;
import ru.bpc.sv2.campaign.CampaignProduct;
import ru.bpc.sv2.common.application.AppFlowStep;
import ru.bpc.sv2.common.application.ApplicationStatuses;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.constants.SystemConstants;
import ru.bpc.sv2.constants.application.AppElements;
import ru.bpc.sv2.constants.application.ApplicationConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.invocation.SortElement;
import ru.bpc.sv2.logic.ApplicationDao;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.logic.OrgStructDao;
import ru.bpc.sv2.logic.UsersDao;
import ru.bpc.sv2.logic.utility.db.DataAccessException;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.application.wizard.MbAcmWizard;
import ru.bpc.sv2.ui.common.application.ApplicationWizardContext;
import ru.bpc.sv2.ui.common.application.MbAppWizardFirstPage;
import ru.bpc.sv2.ui.common.application.MbWizard;
import ru.bpc.sv2.ui.session.UserSession;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.DictUtils;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbAppCampaignWizard")
public class MbAppCampaignWizard extends AbstractBean implements Serializable {
    private static final Logger logger = Logger.getLogger(MbAppCampaignWizard.class);

    private CampaignDao campaignDao = new CampaignDao();
    private ApplicationDao applDao = new ApplicationDao();
    private OrgStructDao orgStructDao = new OrgStructDao();

    private String backlink;
    private Integer instId;
    private Integer flowId;
    private Integer userId;
    private String userName;
    private String productType;
    private List<Product> products;

    public MbAppCampaignWizard() {
        init();
    }

    @Override
    public void clearFilter() {}

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public Integer getFlowId() {
        return flowId;
    }
    public void setFlowId(Integer flowId) {
        this.flowId = flowId;
    }

    public String getProductType() {
        return productType;
    }
    public void setProductType(String productType) {
        this.productType = productType;
    }

    public Integer getUserId() {
        return userId;
    }
    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public String getUserName() {
        return userName;
    }
    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getBacklink() {
        return backlink;
    }
    public void setBacklink(String backlink) {
        this.backlink = backlink;
    }

    public void init() {
        userSessionId = SessionWrapper.getRequiredUserSessionId();
        userLang = SessionWrapper.getField("language");
        products = new ArrayList<Product>();
        instId = null;
        flowId = null;
        userId = null;
        backlink = null;
        productType = null;
    }

    public List<SelectItem> getInstitutions() {
        return getDictUtils().getLov(LovConstants.INSTITUTIONS);
    }

    public List<SelectItem> getFlows() {
        List<SelectItem> items = new ArrayList<SelectItem>();
        try {
            SelectionParams params = SelectionParams.build("lang", curLang, "instId", instId,
                                                           "applType", ApplicationConstants.TYPE_CAMPAIGNS);
            List<ApplicationFlow> flows = campaignDao.getApplicationFlows(userSessionId, params);
            for (ApplicationFlow flow : flows) {
                items.add(createSelectItem(flow));
            }
        } catch (Exception e) {
            FacesUtils.addMessageError(e);
            logger.error("", e);
        }
        return items;
    }

    public List<SelectItem> getProductTypes() {
        return getDictUtils().getLov(LovConstants.PRODUCT_TYPES);
    }

    public List<Product> getProducts() {
        List<Filter> filters = new ArrayList<Filter>();
        filters.add(Filter.create("lang", curLang));
        filters.add(Filter.create("instId", instId));
        if (productType != null) {
            filters.add(Filter.create("productType", productType));
        }
        SelectionParams params = new SelectionParams(filters);
        products = campaignDao.getProductList(userSessionId, params);
        return products;
    }

    public boolean isAllowCreate() {
        return (instId != null && flowId != null && productType != null);
    }

    public void create() {
        if (userId == null) {
            UserSession userSession = ManagedBeanWrapper.getManagedBean("usession");
            if (userSession != null) {
                if (userSession.getUser() != null) {
                    userId = userSession.getUser().getId();
                    userName = userSession.getUser().getName();
                }
            }
        }

        Application application = new Application();
        application.setId(null);
        application.setPrioritized(false);
        application.setInstId(instId);
        application.setUserId(userId);
        application.setUserName(userName);
        application.setAgentId(orgStructDao.getDefaultAgentId(userSessionId, instId));
        application.setFlowId(flowId);
        application.setAppType(ApplicationConstants.TYPE_CAMPAIGNS);
        application.setStatus(ApplicationStatuses.JUST_CREATED);

        Map<Integer, ApplicationFlowFilter> filters = new HashMap<Integer, ApplicationFlowFilter>();
        ApplicationElement root = applDao.getApplicationStructure(userSessionId, application, filters);

        root.addValue(AppElements.APPLICATION_STATUS, ApplicationStatuses.JUST_CREATED);
        root.addValue(AppElements.APPLICATION_TYPE, ApplicationConstants.TYPE_CAMPAIGNS);
        root.addValue(AppElements.APPLICATION_DATE, new Date());
        root.addValue(AppElements.APPLICATION_FLOW_ID, flowId);
        root.addValue(AppElements.INSTITUTION_ID, instId);
        root.addValue(AppElements.OPERATOR_ID, userName);

        ApplicationElement campaign = root.getChildByName(AppElements.CAMPAIGN);
        campaign.addValue(AppElements.COMMAND, ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
        campaign.addValue(AppElements.START_DATE, getCampaignStartDate());
        campaign.addChildren(addBlock(campaign, application, AppElements.CAMPAIGN_NAME));

        for (Product product : products) {
            if (product.isChecked()) {
                campaign.addChildren(addBlock(campaign, application, AppElements.CAMPAIGN_PRODUCT));
                ApplicationElement elProduct = campaign.getChildByName(AppElements.CAMPAIGN_PRODUCT);
                elProduct.addValue(AppElements.COMMAND, ApplicationConstants.COMMAND_CREATE_OR_EXCEPT);
                elProduct.addValue(AppElements.PRODUCT_NUMBER, product.getProductNumber());
                elProduct.addValue(AppElements.PRODUCT_NAME, product.getName());
            }
        }

        ApplicationWizardContext ctx = new ApplicationWizardContext();
        ctx.setApplicationFilters(filters);
        ctx.setApplicationRoot(root);
        ctx.set("instId", instId);
        ctx.set("userId", userId);
        ctx.set("userName", userName);
        ctx.set("innerId", 1);
        ctx.set("userLang", userLang);
        ctx.set("backlink", backlink);
        ctx.set("userSessionId", userSessionId);
        ctx.set("application", application);

        MbCampaignServiceWizard mbWizard = ManagedBeanWrapper.getManagedBean(MbCampaignServiceWizard.class);
        mbWizard.init(ctx);
    }

    private SelectItem createSelectItem(ApplicationFlow flow) {
        return new SelectItem(flow.getId(), flow.getId() + " - " + flow.getName(), flow.getDescription());
    }

    private ApplicationElement addBlock(ApplicationElement root, Application application, String name) {
        ApplicationElement template = root.getChildByName(name, 0);
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

    private Date getCampaignStartDate() {
        Calendar calendar = new GregorianCalendar();
        calendar.setTime(new Date());
        calendar.add(Calendar.DAY_OF_MONTH, 1);
        return calendar.getTime();
    }
}