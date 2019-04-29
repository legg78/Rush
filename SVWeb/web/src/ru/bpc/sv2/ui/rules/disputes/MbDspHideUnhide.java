package ru.bpc.sv2.ui.rules.disputes;

import ru.bpc.sv2.application.DspApplication;
import ru.bpc.sv2.logic.DisputesDao;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;
import java.util.Date;

@ViewScoped
@ManagedBean (name = "MbDspHideUnhide")
public class MbDspHideUnhide extends DspModal {
    public final static String BTN_HIDE   = "BTN_HIDE";
    public final static String BTN_UNHIDE = "BTN_UNHIDE";

    private final long DAYS_45_IN_MILLIS  = 3888000000L;

    private Date hideDate;
    private Date unhideDate;

    private DisputesDao disputesDao = new DisputesDao();

    public Date getHideDate() {
        return hideDate;
    }
    public void setHideDate(Date hideDate) {
        this.hideDate = hideDate;
    }

    public Date getUnhideDate() {
        return unhideDate;
    }
    public void setUnhideDate(Date unhideDate) {
        this.unhideDate = unhideDate;
    }

    public boolean isHide() {
        return BTN_HIDE.equals(getType());
    }
    public boolean isUnhide() {
        return BTN_UNHIDE.equals(getType());
    }

    public void checkHideDate() {
        if (isDatesTooFar()) {
            setHideDate(new Date(unhideDate.getTime() - DAYS_45_IN_MILLIS));
        }
    }

    public void checkUnhideDate() {
        if (isDatesTooFar()) {
            setUnhideDate(new Date(hideDate.getTime() + DAYS_45_IN_MILLIS));
        }
    }

    @Override
    public void execute(DspApplication app) {
        if (isHide()) {
            app.setHideDate(new Date());
            app.setUnhideDate(unhideDate);
            disputesDao.setHideUnhideDate(userSessionId, app);
        } else if (isUnhide()) {
            disputesDao.changeCaseVisibility(userSessionId, app);
        }
    }

    private boolean isDatesTooFar() {
        if (hideDate != null && unhideDate != null) {
            return (unhideDate.getTime() - hideDate.getTime() > DAYS_45_IN_MILLIS);
        }
        return !(hideDate == null && unhideDate == null);
    }

    public void clearCache(){
        unhideDate = null;
    }
}
