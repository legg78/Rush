package ru.bpc.sv2.ui.common.wizard.product;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.constants.LovConstants;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.products.ProductService;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.common.wizard.MbCommonWizard;
import ru.bpc.sv2.ui.issuing.MbProductSearchModal;
import ru.bpc.sv2.ui.products.MbProductServices;
import ru.bpc.sv2.ui.utils.AbstractBean;
import ru.bpc.sv2.ui.utils.FacesUtils;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import javax.faces.model.SelectItem;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbProductAppInitializeDS")
public class MbProductAppInitializeDS extends AbstractBean implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(ProductAppConstants.LOGGER);

    private Map<String, Object> context;
    private Product product;
    private MbProductServices services;
    private String parentProductNumber;
    private Boolean isNewProduct;
    private List<SelectItem> productTypes;

    @Override
    public void init(Map<String, Object> context) {
        this.context = context;
        context.put(MbCommonWizard.PAGE, ProductAppConstants.INITIALIZE_PAGE);

        productTypes = new ArrayList<SelectItem>(3);
        productTypes.add(new SelectItem(ProductConstants.ISSUING_PRODUCT, "PRDT0100 - Issuing product"));
        productTypes.add(new SelectItem(ProductConstants.ACQUIRING_PRODUCT, "PRDT0200 - Acquiring product"));
        productTypes.add(new SelectItem(ProductConstants.INSTITUTION_PRODUCT, "PRDT0300 - Institution product"));

        product = new Product();
        product.setProductType(ProductConstants.ISSUING_PRODUCT);
        isNewProduct = Boolean.TRUE;

        services = (MbProductServices) ManagedBeanWrapper.getManagedBean(MbProductServices.class);
        services.fullCleanBean();
        services.getFilter().setProductName(product.getName());
        services.setProductType(product.getProductType());
        services.setCurMode(VIEW_MODE);
    }
    @Override
    public Map<String, Object> release(Direction direction) {
        if (direction == Direction.FORWARD) {
            context.put(ProductAppConstants.PRODUCT, product);
        } else {
            reset();
        }
        return context;
    }
    @Override
    public boolean validate() {
        return false;
    }
    @Override
    public void clearFilter() {}

    public Product getProduct() {
        if (product == null) {
            product = new Product();
        }
        return product;
    }
    public void setProduct(Product product) {
        this.product = product;
    }

    public Boolean getIsNewProduct() {
        return isNewProduct;
    }
    public void setIsNewProduct(Boolean newProduct) {
        isNewProduct = newProduct;
    }

    public String getParentProductNumber() {
        return parentProductNumber;
    }
    public void setParentProductNumber(String parentProductNumber) {
        this.parentProductNumber = parentProductNumber;
    }

    public MbProductServices getServices() {
        if (services != null) {
            Integer mode = services.isNewMode() ? NEW_MODE : services.isEditMode() ? EDIT_MODE : VIEW_MODE;
            services.fullCleanBean();
            if (product.getId() != null) {
                services.getFilter().setProductId(product.getId().intValue());
                services.getFilter().setProductName(product.getName());
                services.setProductType(product.getProductType());
                services.setInstId(product.getInstId());
                services.setCurMode(mode);
                if (mode != NEW_MODE && mode != EDIT_MODE) {
                    services.search();
                }
            }
        }
        return services;
    }
    public void setServices(MbProductServices services) {
        this.services = services;
    }

    public List<SelectItem> getServiceList() {
        Map<String, Object> params = new HashMap<String, Object>();
        if (product.getInstId() != null) {
            params.put("inst_id", product.getInstId());
        }
        if (product.getId() != null && !product.getId().equals(ProductAppConstants.DEFAULT_PRODUCT_ID)) {
            params.put("product_id", product.getId());
        }
        List<SelectItem> servicesList = getDictUtils().getLov(LovConstants.NO_LINKED_PRODUCT_SERVICES, params);
        return servicesList;
    }

    public List<SelectItem> getInstitutions() {
        return getDictUtils().getLov(LovConstants.INSTITUTIONS);
    }

    public List<SelectItem> getProductTypes() {
        return productTypes;
    }

    public List<SelectItem> getContractTypes() {
        Map<String, Object> paramMap = new HashMap<String, Object>();
        if (isAcquiringType()) {
            paramMap.put(ProductAppConstants.PRODUCT_TYPE, ProductConstants.ACQUIRING_PRODUCT);
        } else if (isIssuingType()) {
            paramMap.put(ProductAppConstants.PRODUCT_TYPE, ProductConstants.ISSUING_PRODUCT);
        } else if (isInstitutionType()) {
            paramMap.put(ProductAppConstants.PRODUCT_TYPE, ProductConstants.INSTITUTION_PRODUCT);
        } else {
            return new ArrayList<SelectItem>(0);
        }
        return getDictUtils().getLov(LovConstants.PRODUCT_CONTRACT_TYPES, paramMap);
    }

    public void showProducts() {
        MbProductSearchModal bean = (MbProductSearchModal) ManagedBeanWrapper.getManagedBean("MbProductSearchModal");
        bean.clearFilter();
        bean.setProductType(product.getProductType());
        bean.getFilter().setInstId(product.getInstId());
    }

    public void selectProduct() {
        MbProductSearchModal bean = (MbProductSearchModal) ManagedBeanWrapper.getManagedBean("MbProductSearchModal");
        Product selected = bean.getDetailNode();
        if (selected != null) {
            try {
                product = selected.clone();
            } catch (CloneNotSupportedException e) {
                logger.error("Failed to save selected product", e);
                FacesUtils.addMessageError(e.getLocalizedMessage());
            }
        }
    }

    public void selectParentProduct() {
        MbProductSearchModal bean = (MbProductSearchModal) ManagedBeanWrapper.getManagedBean("MbProductSearchModal");
        Product selected = bean.getDetailNode();
        if (selected != null) {
            product.setParentId(selected.getId());
        }
    }

    private void reset() {}

    private boolean isIssuingType() {
        return ProductConstants.ISSUING_PRODUCT.equals(getProduct().getProductType());
    }
    private boolean isAcquiringType() {
        return ProductConstants.ACQUIRING_PRODUCT.equals(getProduct().getProductType());
    }
    private boolean isInstitutionType() {
        return ProductConstants.INSTITUTION_PRODUCT.equals(getProduct().getProductType());
    }
}
