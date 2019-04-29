package ru.bpc.sv2.logic;

import org.apache.log4j.Logger;
import ru.bpc.sv2.application.ApplicationFlow;
import ru.bpc.sv2.campaign.*;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.products.Product;

import java.util.ArrayList;
import java.util.List;

import static ru.bpc.sv2.campaign.CampaignConstants.*;

public class CampaignDao extends AbstractDao {
    private static final Logger logger = Logger.getLogger("CPN");
    private static final String sqlMap = "campaign";

    @Override
    protected Logger getLogger() {
        return logger;
    }
    @Override
    protected String getSqlMap() {
        return sqlMap;
    }

    public List<Campaign> getCampaigns(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_CAMPAIGNS, "get-campaigns");
    }

    public int getCampaignsCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_CAMPAIGNS, "get-campaigns-count");
    }

    public Campaign addCampaign(Long userSessionId, Campaign campaign) {
        campaign = insert(userSessionId, campaign, ADD_CAMPAIGN, "insert-campaign");

        List<Filter> filters = new ArrayList<Filter>(2);
        filters.add(Filter.create("id", campaign.getId()));
        filters.add(Filter.create("lang", campaign.getLang()));
        List<Campaign> out = getCampaigns(userSessionId, new SelectionParams(filters));
        return (out != null) ? out.get(0) : campaign;
    }

    public Campaign modifyCampaign(Long userSessionId, Campaign campaign) {
        return update(userSessionId, campaign, MODIFY_CAMPAIGN, "update-campaign");
    }

    public void removeCampaign(Long userSessionId, Campaign campaign) {
        delete(userSessionId, campaign, REMOVE_CAMPAIGN, "remove-campaign");
    }

    public List<CampaignProduct> getProducts(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_CAMPAIGN_PRODUCTS, "get-products");
    }

    public int getProductsCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_CAMPAIGN_PRODUCTS, "get-products-count");
    }

    public CampaignProduct addProduct(Long userSessionId, CampaignProduct product) {
        product = insert(userSessionId, product, ADD_CAMPAIGN_PRODUCT, "insert-product");

        List<Filter> filters = new ArrayList<Filter>(2);
        filters.add(Filter.create("id", product.getId()));
        filters.add(Filter.create("lang", product.getLang()));
        List<CampaignProduct> out = getProducts(userSessionId, new SelectionParams(filters));
        return (out != null) ? out.get(0) : product;
    }

    public void removeProduct(Long userSessionId, CampaignProduct product) {
        delete(userSessionId, product, REMOVE_CAMPAIGN_PRODUCT, "remove-product");
    }

    public List<CampaignService> getServices(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_CAMPAIGN_SERVICES, "get-services");
    }

    public int getServicesCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_CAMPAIGN_SERVICES, "get-services-count");
    }

    public List<CampaignService> getServiceList(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_CAMPAIGN_SERVICES, "get-service-list");
    }

    public int getServiceListCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_CAMPAIGN_SERVICES, "get-service-list-count");
    }

    public CampaignService addService(Long userSessionId, CampaignService service) {
        service = insert(userSessionId, service, ADD_CAMPAIGN_SERVICE, "insert-service");

        List<Filter> filters = new ArrayList<Filter>(2);
        filters.add(Filter.create("id", service.getId()));
        filters.add(Filter.create("lang", service.getLang()));
        List<CampaignService> out = getServices(userSessionId, new SelectionParams(filters));
        return (out != null) ? out.get(0) : service;
    }

    public void removeService(Long userSessionId, CampaignService service) {
        delete(userSessionId, service, REMOVE_CAMPAIGN_SERVICE, "remove-service");
    }

    public List<CampaignAttribute> getAttributes(Long userSessionId, SelectionParams params) {
        List<CampaignAttribute> base = getObjects(userSessionId, params, VIEW_CAMPAIGN_ATTRIBUTES, "get-attributes-base");
        List<CampaignAttribute> attr = getObjects(userSessionId, params, VIEW_CAMPAIGN_ATTRIBUTES, "get-attributes");
        base.addAll(attr);
        return base;
    }

    public int getAttributesCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_CAMPAIGN_ATTRIBUTES, "get-attributes-count");
    }

    public CampaignAttribute addAttribute(Long userSessionId, CampaignAttribute attribute) {
        attribute = insert(userSessionId, attribute, ADD_CAMPAIGN_ATTRIBUTE, "insert-attribute");

        List<Filter> filters = new ArrayList<Filter>(2);
        filters.add(Filter.create("id", attribute.getId()));
        filters.add(Filter.create("lang", attribute.getLang()));
        List<CampaignAttribute> out = getAttributes(userSessionId, new SelectionParams(filters));
        return (out != null) ? out.get(0) : attribute;
    }

    public void removeAttribute(Long userSessionId, CampaignAttribute attribute) {
        delete(userSessionId, attribute, REMOVE_CAMPAIGN_ATTRIBUTE, "remove-attribute");
    }

    public List<CampaignAttributeValue> getAttributeValues(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_CAMPAIGN_ATTRIBUTES, "get-attribute-values");
    }

    public int getAttributeValuesCount(Long userSessionId, SelectionParams params) {
        return getCount(userSessionId, params, VIEW_CAMPAIGN_ATTRIBUTES, "get-attribute-values-count");
    }

    public CampaignAttributeValue addAttributeValue(Long userSessionId, CampaignAttributeValue value) {
        return insert(userSessionId, value, ADD_CAMPAIGN_ATTRIBUTE, "insert-attribute-value");
    }

    public void removeAttributeValue(Long userSessionId, CampaignAttributeValue attribute) {
        delete(userSessionId, attribute, REMOVE_CAMPAIGN_ATTRIBUTE, "remove-attribute-value");
    }

    public List<ApplicationFlow> getApplicationFlows(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, ADD_CAMPAIGN_APPLICATION, "get-campaign-app-flows");
    }

    public List<Product> getProductList(Long userSessionId, SelectionParams params) {
        return getObjects(userSessionId, params, VIEW_CAMPAIGN_PRODUCTS, "get-campaign-products-list");
    }
}
