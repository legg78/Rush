package ru.bpc.sv2.scheduler.process.nbc.entity;

import ru.bpc.sv2.utils.SystemException;

public class NBCFastConnection {
    private String url;
    private String username;
    private String password;
    private String participantCode;

    public String getUrl() {
        return url;
    }
    public void setUrl(String url) {
        this.url = url;
    }

    public String getUsername() {
        return username;
    }
    public void setUsername(String username) {
        this.username = username;
    }

    public String getPassword() {
        return password;
    }
    public void setPassword(String password) {
        this.password = password;
    }

    public String getParticipantCode() {
        return participantCode;
    }
    public void setParticipantCode(String participantCode) {
        this.participantCode = participantCode;
    }

    public Boolean check() throws Exception {
        if (url == null || url.trim().isEmpty()) {
            throw new SystemException("Missed NBC FAST Web-service URL");
        }
        if (username == null || username.trim().isEmpty()) {
            throw new SystemException("Missed NBC FAST Web-service user name");
        }
        if (participantCode == null || participantCode.trim().isEmpty()) {
            throw new SystemException("Missed NBC FAST Web-service participant code");
        }
        if (password == null || password.trim().isEmpty()) {
            throw new SystemException("Missed NBC FAST Web-service password");
        }
        return Boolean.TRUE;
    }
}
