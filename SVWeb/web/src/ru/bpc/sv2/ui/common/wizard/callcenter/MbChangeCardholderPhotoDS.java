package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import org.richfaces.event.UploadEvent;
import org.richfaces.model.UploadItem;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.logic.*;
import ru.bpc.sv2.ui.common.wizard.AbstractWizardStep;
import ru.bpc.sv2.ui.utils.FacesUtils;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.io.ByteArrayOutputStream;
import java.io.FileInputStream;
import java.util.*;

@ViewScoped
@ManagedBean(name = "MbChangeCardholderPhotoDS")
public class MbChangeCardholderPhotoDS extends AbstractWizardStep {

    protected static final Logger logger = Logger.getLogger("COMMON");
    private static final String PAGE = "/pages/common/wizard/callcenter/changeCardholderPhotoDS.jspx";
    private static final String OBJECT_ID = "OBJECT_ID";
    private static final String ENTITY_TYPE = "ENTITY_TYPE";

    private IssuingDao issuingDao = new IssuingDao();

    private String newPhotoFileName;

    private Long cardId;
    private String entityType;



    public MbChangeCardholderPhotoDS() {
    }

    @Override
    public void init(Map<String, Object> context) {
        super.init(context, PAGE, true);

        reset();
        logger.trace("MbReissueCardDS::init...");
        if (context.containsKey(OBJECT_ID)) {
            cardId = (Long) context.get(OBJECT_ID);
        } else {
            throw new IllegalStateException(OBJECT_ID + " is not defined in wizard context");
        }
        entityType = (String) context.get(ENTITY_TYPE);
    }

    private void reset() {
        newPhotoFileName = null;
    }

    @Override
    public Map<String, Object> release(Direction direction) {
        if (direction == Direction.FORWARD) {
            if (EntityNames.CARD.equals(entityType)) {
                handleChangeCardholderPhotoFileName();
            }
        }
        return getContext();
    }

    private void handleChangeCardholderPhotoFileName() {
        logger.trace("handleChangeCardholderPhotoFileName...");
        issuingDao.updateCardholderPhotoFileName(userSessionId, cardId, newPhotoFileName);
    }

    public void fileUploadListener(UploadEvent event) throws Exception {
        newPhotoFileName = event.getUploadItem().getFileName();
    }

    @Override
    public boolean validate() {
        logger.trace("validate...");
        return StringUtils.isNotBlank(newPhotoFileName);
    }

    public String getNewPhotoFileName() {
        return newPhotoFileName;
    }

    public void setNewPhotoFileName(String newPhotoFileName) {
        this.newPhotoFileName = newPhotoFileName;
    }

}
