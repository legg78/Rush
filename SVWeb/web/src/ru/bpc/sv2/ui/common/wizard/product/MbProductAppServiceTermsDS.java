package ru.bpc.sv2.ui.common.wizard.product;

import org.apache.log4j.Logger;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.products.Product;
import ru.bpc.sv2.products.ProductConstants;
import ru.bpc.sv2.products.ProductService;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;
import ru.bpc.sv2.ui.products.MbAttributeValues;
import ru.bpc.sv2.ui.products.MbObjectAttributes;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.List;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbProductAppServiceTermsDS")
public class MbProductAppServiceTermsDS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(ProductAppConstants.LOGGER);

    private Map<String, Object> context;
    private Product product;
    private List<ProductService> services;
    private MbObjectAttributes attributes;

    @Override
    public void init(Map<String, Object> context) {
        this.context = context;
        if (context.containsKey(ProductAppConstants.PRODUCT)){
            product = (Product)context.get(ProductAppConstants.PRODUCT);
        } else {
            throw new IllegalStateException(ProductAppConstants.PRODUCT + "is not defined in wizard context");
        }
        if (context.containsKey(ProductAppConstants.SERVICES)){
            services = (List<ProductService>)context.get(ProductAppConstants.SERVICES);
        } else {
            throw new IllegalStateException(ProductAppConstants.SERVICES + "is not defined in wizard context");
        }

        attributes = (MbObjectAttributes) ManagedBeanWrapper.getManagedBean("MbObjectAttributes");
        attributes.fullCleanBean();
        attributes.setProductId(product.getId().intValue());
        attributes.setEntityType(EntityNames.SERVICE);
        attributes.setProductType(product.getProductType());
        attributes.setInstId(product.getInstId());
        if (product.getProductType().equals(ProductConstants.INSTITUTION_PRODUCT)) {
            attributes.setProductsModule(ProductAppConstants.INSTITUTION_STR);
        } else if (product.getProductType().equals(ProductConstants.ACQUIRING_PRODUCT)) {
            attributes.setProductsModule(ProductAppConstants.ACQUIRING_STR);
        } else {
            attributes.setProductsModule(ProductAppConstants.ISSUING_STR);
        }
        attributes.setServices(services);
    }
    @Override
    public Map<String, Object> release(CommonWizardStep.Direction direction) {
        if (direction == Direction.FORWARD) {
            MbAttributeValues attrValues = (MbAttributeValues) ManagedBeanWrapper.getManagedBean("MbAttributeValues");
            attrValues.setCaching(false);
            context.put(ProductAppConstants.ATTRIBUTES, attributes.getNodeList());
        } else {
            reset();
        }
        return context;
    }
    @Override
    public boolean validate() {
        return false;
    }

    public MbObjectAttributes getAttributes() {
        return attributes;
    }
    public void setAttributes(MbObjectAttributes attributes) {
        this.attributes = attributes;
    }

    private void reset() {}
}
