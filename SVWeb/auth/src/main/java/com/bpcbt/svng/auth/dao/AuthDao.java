package com.bpcbt.svng.auth.dao;

import com.bpcbt.svng.auth.beans.AppPrivilegeData;
import com.bpcbt.svng.auth.beans.MenuSimpleNode;
import org.apache.log4j.Logger;
import ru.bpc.sv2.logic.utility.JndiUtils;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class AuthDao {
	private static final Logger logger = Logger.getLogger(AuthDao.class);

	public List<MenuSimpleNode> getMenu(String lang) {
		Connection con = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			con = JndiUtils.getConnection();
			pstm = con.prepareStatement(
					"SELECT id, parent_id, caption FROM acm_ui_section_vw " +
							"WHERE section_type IN ('folder', 'page') AND lang=? ORDER BY section_type, display_order");
			pstm.setString(1, lang);
			rs = pstm.executeQuery();
			List<MenuSimpleNode> list = new ArrayList<MenuSimpleNode>();
			while (rs.next()) {
				MenuSimpleNode msn = new MenuSimpleNode();
				msn.setId(rs.getString("id"));
				msn.setParentId(rs.getString("parent_id"));
				msn.setName(rs.getString("caption"));
				list.add(msn);
			}
			return list;
		} catch (SQLException e) {
			logger.error("Get menu error", e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (pstm != null) {
					pstm.close();
				}
				if (con != null) {
					con.close();
				}
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
		return null;
	}

	public List<AppPrivilegeData> getAppPrivileges(String lang) {
		Connection con = null;
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			con = JndiUtils.getConnection();
			pstm = con.prepareStatement(
					"SELECT ap.id, ap.name, ap.section_id as section, c.text as description " +
							"FROM acm_privilege ap LEFT JOIN com_i18n c ON (ap.id=c.object_id) " +
							"WHERE ap.is_active=1 AND c.table_name='ACM_PRIVILEGE' AND c.column_name='LABEL' AND c.lang=? ORDER BY ap.section_id");
			pstm.setString(1, lang);
			rs = pstm.executeQuery();
			List<AppPrivilegeData> list = new ArrayList<AppPrivilegeData>();
			while (rs.next()) {
				AppPrivilegeData apd = new AppPrivilegeData();
				apd.setId(rs.getLong("id"));
				apd.setName(rs.getString("name"));
				apd.setSection(rs.getString("section"));
				apd.setDescription(rs.getString("description"));
				list.add(apd);
			}
			return list;
		} catch (SQLException e) {
			logger.error("Get app privileges error", e);
		} finally {
			try {
				if (rs != null) {
					rs.close();
				}
				if (pstm != null) {
					pstm.close();
				}
				if (con != null) {
					con.close();
				}
			} catch (Exception ex) {
				ex.printStackTrace();
			}
		}
		return null;
	}
}
