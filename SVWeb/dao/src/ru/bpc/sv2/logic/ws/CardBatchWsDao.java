package ru.bpc.sv2.logic.ws;

import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.utils.UserException;


import java.sql.SQLException;


public class CardBatchWsDao extends IbatisAware {

	public Long registerSession(String userWS, String privName) throws UserException {
		try {
			return getUserSessionId(userWS, privName, null, null);
		} catch (SQLException e) {
			if (e.getErrorCode() >= 20000 && e.getErrorCode() <= 20999) {
				throw new UserException(e.getCause().getMessage());
			} else {
				throw createDaoException(e);
			}
		}
	}

}
