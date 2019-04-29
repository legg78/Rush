package ru.bpc.sv2.common;

import ru.bpc.sv2.utils.AuthOracleTypeNames;

import java.math.BigDecimal;
import java.sql.SQLData;
import java.sql.SQLException;
import java.sql.SQLInput;
import java.sql.SQLOutput;
import java.util.Calendar;
import java.util.GregorianCalendar;

public class UserDataRec extends SQLDataRec {
    private Long userId;

    private Integer userRoleId;
    private String roleCommand;

    private Integer userInstId;
    private String instCommand;
    private Boolean isEntirely;
    private Boolean isInstDefault;

    private Long userAgentId;
    private String agentCommand;
    private Boolean isAgentDefault;

    public UserDataRec() {}

    public UserDataRec(Long userId, Integer userRoleId, String roleCommand) {
        this(userId, userRoleId, roleCommand, null, null, null, null, null, null, null);
    }

    public UserDataRec(Long userId, Integer userRoleId, String roleCommand,
                       Integer userInstId, String instCommand, Boolean isEntirely, Boolean isInstDefault,
                       Long userAgentId, String agentCommand, Boolean isAgentDefault) {
        setUserId(userId);
        setUserRoleId(userRoleId);
        setRoleCommand(roleCommand);
        setUserInstId(userInstId);
        setInstCommand(instCommand);
        setEntirely(isEntirely);
        setInstDefault(isInstDefault);
        setUserAgentId(userAgentId);
        setAgentCommand(agentCommand);
        setAgentDefault(isAgentDefault);
    }

    public UserDataRec(Long userId,
                       Integer userInstId, String instCommand, Boolean isEntirely, Boolean isInstDefault) {
        this(userId, null, null, userInstId, instCommand, isEntirely, isInstDefault, null, null, null);
    }
    public UserDataRec(Long userId, Integer userRoleId, String roleCommand,
                       Integer userInstId, String instCommand, Boolean isEntirely, Boolean isInstDefault) {
        this(userId, userRoleId, roleCommand, userInstId, instCommand, isEntirely, isInstDefault, null, null, null);
    }

    public UserDataRec(Long userId,
                       Long userAgentId, String agentCommand, Boolean isAgentDefault) {
        this(userId, null, null, null, null, null, null, userAgentId, agentCommand, isAgentDefault);
    }
    public UserDataRec(Long userId, Integer userRoleId, String roleCommand,
                       Long userAgentId, String agentCommand, Boolean isAgentDefault) {
        this(userId, userRoleId, roleCommand, null, null, null, null, userAgentId, agentCommand, isAgentDefault);
    }

    public Long getUserId() {
        return userId;
    }
    public void setUserId(Long userId) {
        this.userId = userId;
    }

    public String getInstCommand() {
        return instCommand;
    }
    public void setInstCommand(String instCommand) {
        this.instCommand = instCommand;
    }

    public Integer getUserInstId() {
        return userInstId;
    }
    public void setUserInstId(Integer userInstId) {
        this.userInstId = userInstId;
    }

    public Boolean getEntirely() {
        return (isEntirely != null) ? isEntirely : false;
    }
    public void setEntirely(Boolean entirely) {
        isEntirely = entirely;
    }

    public Boolean getInstDefault() {
        return (isInstDefault != null) ? isInstDefault : false;
    }
    public void setInstDefault(Boolean instDefault) {
        isInstDefault = instDefault;
    }

    public String getAgentCommand() {
        return agentCommand;
    }
    public void setAgentCommand(String agentCommand) {
        this.agentCommand = agentCommand;
    }

    public Long getUserAgentId() {
        return userAgentId;
    }
    public void setUserAgentId(Long userAgentId) {
        this.userAgentId = userAgentId;
    }

    public Boolean getAgentDefault() {
        return (isAgentDefault != null) ? isAgentDefault : false;
    }
    public void setAgentDefault(Boolean agentDefault) {
        isAgentDefault = agentDefault;
    }

    public String getRoleCommand() {
        return roleCommand;
    }
    public void setRoleCommand(String roleCommand) {
        this.roleCommand = roleCommand;
    }

    public Integer getUserRoleId() {
        return userRoleId;
    }
    public void setUserRoleId(Integer userRoleId) {
        this.userRoleId = userRoleId;
    }

    @Override
    public String getSQLTypeName() throws SQLException {
        return AuthOracleTypeNames.ACM_USER_DATA_REC;
    }
    @Override
    public void writeSQL(SQLOutput stream) throws SQLException {
        // user_id             number(8)       01
        writeValueN(stream, getUserId());
        // inst_command        varchar2(8)     02
        writeValueV(stream, getInstCommand());
        // user_inst_id        number(4)       03
        writeValueN(stream, getUserInstId());
        // is_entirely         number(1)       04
        writeValueB(stream, getEntirely());
        // is_inst_default     number(1)       05
        writeValueB(stream, getInstDefault());
        // agent_command       varchar2(8)     06
        writeValueV(stream, getAgentCommand());
        // user_agent_id       number(8)       07
        writeValueN(stream, getUserAgentId());
        // is_agent_default    number(1)       08
        writeValueB(stream, getAgentDefault());
        // role_command        varchar2(8)     09
        writeValueV(stream, getRoleCommand());
        // user_role_id        number(4)       10
        writeValueN(stream, getUserRoleId());
    }
}
