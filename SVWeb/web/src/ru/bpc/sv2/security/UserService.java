package ru.bpc.sv2.security;

import org.springframework.dao.IncorrectResultSizeDataAccessException;
import org.springframework.jdbc.core.ConnectionCallback;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.authority.AuthorityUtils;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.util.StringUtils;

import java.sql.*;
import java.util.List;

public class UserService {

	private final JdbcTemplate jdbcTemplate;

	public UserService(JdbcTemplate jdbcTemplate) {
		this.jdbcTemplate = jdbcTemplate;
	}

	public void initUser(String userName) {
		Integer id = retrieveUserId(userName);
		setCurrentUserId(id);
	}

	public Integer retrieveUserId(final String userName) {
		try {
			return jdbcTemplate.queryForObject("SELECT id FROM acm_user_vw WHERE name = upper(?) AND status = 'USSTACTV'", Integer.class, userName);
		} catch (IncorrectResultSizeDataAccessException ignored) {
			throw new UsernameNotFoundException(String.format("User %s not found", userName));
		}
	}

	public void setCurrentUserId(final Integer id) {
		jdbcTemplate.execute(new ConnectionCallback<Void>() {
			@Override
			public Void doInConnection(Connection con) throws SQLException {
				try (CallableStatement cstmt = con.prepareCall("{ call acm_ui_user_pkg.set_user_id( i_user_id => ? )}")) {
					cstmt.setLong(1, id);
					cstmt.executeQuery();
					return null;
				}
			}
		});

	}

	public String getPasswordHash(final String userName) {
		return jdbcTemplate.execute(new ConnectionCallback<String>() {
			@Override
			public String doInConnection(Connection con) throws SQLException {
				String passwordHash = null;
				try (PreparedStatement ps = con.prepareStatement("select acm_api_password_pkg.get_password_hash(?) from dual")) {
					ps.setString(1, userName);
					ResultSet rs = ps.executeQuery();
					if (rs.next()) {
						passwordHash = rs.getString(1);
					}
				}
				if (!StringUtils.hasText(passwordHash)) {
					throw new UsernameNotFoundException(String.format("Could not get password for user %s", userName));
				}
				return passwordHash;
			}
		});
	}

	public List<String> getPrivileges() {
		List<String> authorities = jdbcTemplate.queryForList("select distinct priv_name from acm_ui_user_privilege_vw", String.class);
		authorities.add("SV_AUTHED");
		return authorities;
	}

	public List<GrantedAuthority> getAuthorities() {
		List<String> authorities = getPrivileges();
		return AuthorityUtils.createAuthorityList(authorities.toArray(new String[authorities.size()]));
	}

	public Long startSession(final Integer userId, final String ipAddress) {
		return jdbcTemplate.execute(new ConnectionCallback<Long>() {
			@Override
			public Long doInConnection(Connection con) throws SQLException {
				try (CallableStatement cstmt = con.prepareCall("{ call prc_api_session_pkg.start_session( io_session_id => ?, i_ip_address => ?, i_user_id => ? )}")) {
					cstmt.setString(2, ipAddress);
					cstmt.setInt(3, userId);

					cstmt.registerOutParameter(1, Types.NUMERIC);
					cstmt.executeQuery();

					return cstmt.getLong(1);
				}
			}
		});
	}

	public String reportLogin(final Integer id, final Long sessionId, final String ipAddress, final String status) {
		return jdbcTemplate.execute(new ConnectionCallback<String>() {
			@Override
			public String doInConnection(Connection con) throws SQLException {
				try (CallableStatement cstmt = con.prepareCall("{ call acm_ui_user_pkg.user_login( i_user_id => ?, io_status => ?, io_session_id => ?, i_ip_address => ? )}")) {
					if (id != null) {
						cstmt.setInt(1, id);
					} else {
						cstmt.setNull(1, Types.NUMERIC);
					}
					cstmt.setString(2, status);

					if (sessionId != null) {
						cstmt.setLong(3, sessionId);
						// ip address needed only for create session(session_id = null)
						cstmt.setNull(4, Types.VARCHAR);
					} else {
						cstmt.setNull(3, Types.NUMERIC);
						cstmt.setString(4, ipAddress);
					}

					cstmt.registerOutParameter(2, Types.VARCHAR);
					cstmt.registerOutParameter(3, Types.NUMERIC);
					cstmt.executeQuery();

					return cstmt.getString(2);
				}
			}
		});
	}
}
