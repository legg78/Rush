package ru.bpc.sv2.application;

import java.io.Serializable;
import java.util.Date;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class ApplicationComment implements Serializable {

    private static final long serialVersionUID = -2802672453704752492L;

    private Long applicationId;
    private Integer userId;
    private Date regDate;
    private String userName;
    private String commentText;

    public Long getApplicationId() {
        return applicationId;
    }

    public void setApplicationId(Long applicationId) {
        this.applicationId = applicationId;
    }

    public Integer getUserId() {
        return userId;
    }

    public void setUserId(Integer userId) {
        this.userId = userId;
    }

    public Date getRegDate() {
        return regDate;
    }

    public void setRegDate(Date regDate) {
        this.regDate = regDate;
    }

    public String getUserName() {
        return userName;
    }

    public void setUserName(String userName) {
        this.userName = userName;
    }

    public String getCommentText() {
        return commentText;
    }

    public void setCommentText(String commentText) {
        this.commentText = commentText;
    }
}
