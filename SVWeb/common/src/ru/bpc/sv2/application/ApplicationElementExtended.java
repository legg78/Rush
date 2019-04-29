package ru.bpc.sv2.application;

import org.apache.commons.beanutils.BeanUtils;
import org.apache.commons.beanutils.BeanUtilsBean;

public class ApplicationElementExtended extends ApplicationElement {
    private Integer instId;
    private Integer stageId;

    public ApplicationElementExtended() {
        setInstId(null);
        setStageId(null);
    }
    public ApplicationElementExtended(Integer instId, ApplicationElement applicationElement) {
        setInstId(instId);
        setStageId(null);
        copy(applicationElement);
    }
    public ApplicationElementExtended(Integer instId, Integer stageId, ApplicationElement applicationElement) {
        setInstId(instId);
        setStageId(stageId);
        copy(applicationElement);
    }

    private void copy(ApplicationElement applicationElement) {
        try {
            BeanUtilsBean.getInstance().getConvertUtils().register(false, false, 0);
            BeanUtils.copyProperties(this, applicationElement);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    public Integer getInstId() {
        return instId;
    }
    public void setInstId(Integer instId) {
        this.instId = instId;
    }

    public Integer getStageId() {
        return stageId;
    }
    public void setStageId(Integer stageId) {
        this.stageId = stageId;
    }
}
