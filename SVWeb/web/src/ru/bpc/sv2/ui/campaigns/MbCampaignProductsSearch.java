package ru.bpc.sv2.ui.campaigns;

import org.apache.log4j.Logger;
import ru.bpc.sv2.campaign.Campaign;
import ru.bpc.sv2.campaign.CampaignProduct;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.FilterBuilder;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.CampaignDao;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.ui.utils.AbstractSearchBean;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.*;

@ViewScoped
@ManagedBean (name = "MbCampaignProductsSearch")
public class MbCampaignProductsSearch extends AbstractSearchBean<CampaignProduct, CampaignProduct> {
    private static final Logger logger = Logger.getLogger("CPN");

    private CampaignDao campaignDao = new CampaignDao();

    private List<SelectItem> productTypes;

    @Override
    protected CampaignProduct createFilter() {
        return new CampaignProduct();
    }

    @Override
    protected Logger getLogger() {
        return logger;
    }

    @Override
    protected void initFilters(CampaignProduct filter, List<Filter> filters) {
        filters.addAll(FilterBuilder.createFiltersDatesAsString(filter));
        filters.add(Filter.create(LANGUAGE, userLang));
    }

    @Override
    public void add() {
        super.add();
        setNewItem(new CampaignProduct());
        getNewItem().setCampaignId(getFilter().getCampaignId());
        getNewItem().setInstId(getFilter().getInstId());
        getNewItem().setLang(userLang);
    }

    @Override
    protected CampaignProduct addItem(CampaignProduct item) {
        return campaignDao.addProduct(userSessionId, item);
    }

    @Override
    protected CampaignProduct editItem(CampaignProduct item) {
        return item;
    }

    @Override
    protected void deleteItem(CampaignProduct item) {
        campaignDao.removeProduct(userSessionId, item);
    }

    @Override
    protected List<CampaignProduct> getObjectList(Long userSessionId, SelectionParams params) {
        return campaignDao.getProducts(userSessionId, params);
    }

    @Override
    protected int getObjectCount(Long userSessionId, SelectionParams params) {
        return campaignDao.getProductsCount(userSessionId, params);
    }

    public List<SelectItem> getProductTypes() {
        if (productTypes == null) {
            productTypes = getDictUtils().getLov(LovConstants.PRODUCT_TYPES);
            if (productTypes == null) {
                productTypes = new ArrayList<SelectItem>();
            }
        }
        return productTypes;
    }

    public List<SelectItem> getProducts() {
        if (getNewItem() != null) {
            Map<String, Object> params = new HashMap<String, Object>(1);
            if (getNewItem().getInstId() != null) {
                params.put("institution_id", getNewItem().getInstId());
            }
            if (ProductConstants.ISSUING_PRODUCT.equals(getNewItem().getProductType())) {
                return getDictUtils().getLov(LovConstants.ISSUING_PRODUCTS, params);
            } else if (ProductConstants.ACQUIRING_PRODUCT.equals(getNewItem().getProductType())) {
                return getDictUtils().getLov(LovConstants.ACQUIRING_PRODUCTS, params);
            } else if (ProductConstants.INSTITUTION_PRODUCT.equals(getNewItem().getProductType())) {
                return getDictUtils().getLov(LovConstants.INSTITUTION_PRODUCTS, params);
            }
        }
        return new ArrayList<SelectItem>();
    }

    public boolean isActive() {
        if (activeItem != null) {
            MbCampaignsSearch bean = ManagedBeanWrapper.getManagedBean(MbCampaignsSearch.class);
            if (bean != null) {
                return !bean.isActive();
            }
        }
        return false;
    }
}
