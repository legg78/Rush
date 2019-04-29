package ru.bpc.sv2.ui.common.wizard.product;

import org.apache.log4j.Logger;
import ru.bpc.sv2.ui.common.wizard.CommonWizardStep;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Map;

@ViewScoped
@ManagedBean (name = "MbProductAppAccountTypesDS")
public class MbProductAppAccountTypesDS implements CommonWizardStep {
    private static final Logger logger = Logger.getLogger(ProductAppConstants.LOGGER);

    private Map<String, Object> context;

    @Override
    public void init(Map<String, Object> context) {
        this.context = context;
    }
    @Override
    public Map<String, Object> release(Direction direction) {
        if (direction == Direction.FORWARD) {

        } else {
            reset();
        }
        return context;
    }
    @Override
    public boolean validate() {
        return false;
    }

    private void reset() {}
}
