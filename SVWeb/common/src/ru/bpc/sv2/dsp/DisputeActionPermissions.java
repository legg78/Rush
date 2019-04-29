package ru.bpc.sv2.dsp;

import java.io.Serializable;

public class DisputeActionPermissions implements Serializable {
    private static final long serialVersionUID = 1L;

    private Long caseId;
    private boolean newCaseEnable;
    private boolean takeEnable;
    private boolean refuseEnable;
    private boolean hideEnable;
    private boolean unhideEnable;
    private boolean closeEnable;
    private boolean reopenEnable;
    private boolean duplicateEnable;
    private boolean commentEnable;
    private boolean statusEnable;
    private boolean resolutionEnable;
    private boolean teamEnable;
    private boolean reassignEnable;
    private boolean letterEnable;
    private boolean progressEnable;
    private boolean reasonEnable;
    private boolean checkDueEnable;
    private boolean setDueEnable;

    public DisputeActionPermissions() {}
    public DisputeActionPermissions(Long caseId) {
        setCaseId(caseId);
    }

    public Long getCaseId() {
        return caseId;
    }
    public void setCaseId(Long caseId) {
        this.caseId = caseId;
    }

    public boolean isNewCaseEnable() {
        return newCaseEnable;
    }
    public void setNewCaseEnable(boolean newCaseEnable) {
        this.newCaseEnable = newCaseEnable;
    }

    public boolean isTakeEnable() {
        return takeEnable;
    }
    public void setTakeEnable(boolean takeEnable) {
        this.takeEnable = takeEnable;
    }

    public boolean isRefuseEnable() {
        return refuseEnable;
    }
    public void setRefuseEnable(boolean refuseEnable) {
        this.refuseEnable = refuseEnable;
    }

    public boolean isHideEnable() {
        return hideEnable;
    }
    public void setHideEnable(boolean hideEnable) {
        this.hideEnable = hideEnable;
    }

    public boolean isUnhideEnable() {
        return unhideEnable;
    }
    public void setUnhideEnable(boolean unhideEnable) {
        this.unhideEnable = unhideEnable;
    }

    public boolean isCloseEnable() {
        return closeEnable;
    }
    public void setCloseEnable(boolean closeEnable) {
        this.closeEnable = closeEnable;
    }

    public boolean isReopenEnable() {
        return reopenEnable;
    }
    public void setReopenEnable(boolean reopenEnable) {
        this.reopenEnable = reopenEnable;
    }

    public boolean isDuplicateEnable() {
        return duplicateEnable;
    }
    public void setDuplicateEnable(boolean duplicateEnable) {
        this.duplicateEnable = duplicateEnable;
    }

    public boolean isCommentEnable() {
        return commentEnable;
    }
    public void setCommentEnable(boolean commentEnable) {
        this.commentEnable = commentEnable;
    }

    public boolean isStatusEnable() {
        return statusEnable;
    }
    public void setStatusEnable(boolean statusEnable) {
        this.statusEnable = statusEnable;
    }

    public boolean isResolutionEnable() {
        return resolutionEnable;
    }
    public void setResolutionEnable(boolean resolutionEnable) {
        this.resolutionEnable = resolutionEnable;
    }

    public boolean isTeamEnable() {
        return teamEnable;
    }
    public void setTeamEnable(boolean teamEnable) {
        this.teamEnable = teamEnable;
    }

    public boolean isReassignEnable() {
        return reassignEnable;
    }
    public void setReassignEnable(boolean reassignEnable) {
        this.reassignEnable = reassignEnable;
    }

    public boolean isLetterEnable() {
        return letterEnable;
    }
    public void setLetterEnable(boolean letterEnable) {
        this.letterEnable = letterEnable;
    }

    public boolean isProgressEnable() {
        return progressEnable;
    }
    public void setProgressEnable(boolean progressEnable) {
        this.progressEnable = progressEnable;
    }

    public boolean isReasonEnable() {
        return reasonEnable;
    }
    public void setReasonEnable(boolean reasonEnable) {
        this.reasonEnable = reasonEnable;
    }

    public boolean isCheckDueEnable() {
        return checkDueEnable;
    }
    public void setCheckDueEnable(boolean checkDueEnable) {
        this.checkDueEnable = checkDueEnable;
    }

    public boolean isSetDueEnable() {
        return setDueEnable;
    }
    public void setSetDueEnable(boolean setDueEnable) {
        this.setDueEnable = setDueEnable;
    }

    public void intersect(DisputeActionPermissions actions) {
        if (actions != null) {
            newCaseEnable  &= actions.isNewCaseEnable();
            takeEnable     &= actions.isTakeEnable();
            refuseEnable   &= actions.isRefuseEnable();
            hideEnable     &= actions.isHideEnable();
            unhideEnable   &= actions.isUnhideEnable();
            closeEnable    &= actions.isCloseEnable();
            reopenEnable   &= actions.isReopenEnable();
            commentEnable  &= actions.isCommentEnable();
            teamEnable     &= actions.isTeamEnable();
            reassignEnable &= actions.isReassignEnable();
            letterEnable   &= actions.isLetterEnable();

            duplicateEnable  = false;
            statusEnable     = false;
            resolutionEnable = false;
            progressEnable   = false;
            reasonEnable     = false;
            checkDueEnable   = false;
            setDueEnable     = false;
        }
    }
}
