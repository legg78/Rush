package ru.bpc.sv2.application;

import java.io.Serializable;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class CaseApplicationComment implements Serializable {

    private static final long serialVersionUID = 4727365511192359655L;

    private String systemComment;
    private String userComment;

    public String getSystemComment() {
        return systemComment;
    }

    public void setSystemComment(String systemComment) {
        this.systemComment = systemComment;
    }

    public String getUserComment() {
        return userComment;
    }

    public void setUserComment(String userComment) {
        this.userComment = userComment;
    }

    public boolean isDisabledComment(){
        if (systemComment != null && userComment != null) { return true; }
        else { return false; }
    }
}
