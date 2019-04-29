package ru.bpc.sv2.logic;

import java.sql.SQLException;
import java.util.List;


import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.notes.NotePrivConstants;
import ru.bpc.sv2.notes.ObjectNote;
import ru.bpc.sv2.utils.AuditParamUtil;

import com.ibatis.sqlmap.client.SqlMapSession;

/**
 * Session Bean implementation class NotesDao
 */

public class NotesDao extends IbatisAware {


	@SuppressWarnings("unchecked")
	public ObjectNote[] getNotes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotePrivConstants.VIEW_NOTE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotePrivConstants.VIEW_NOTE);
			List<ObjectNote> notes = ssn
			        .queryForList("notes.get-notes", convertQueryParams(params, limitation));
			return notes.toArray(new ObjectNote[notes.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Integer getNotesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NotePrivConstants.VIEW_NOTE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NotePrivConstants.VIEW_NOTE);
			return (Integer) ssn
			        .queryForObject("notes.get-notes-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public ObjectNote addNote(Long userSessionId, ObjectNote note) {
		SqlMapSession ssn = null;

		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(note.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NotePrivConstants.ADD_NOTE, paramArr);
			ssn.insert("notes.add-note", note);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(note.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(note.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (ObjectNote) ssn.queryForObject("notes.get-notes", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

}
