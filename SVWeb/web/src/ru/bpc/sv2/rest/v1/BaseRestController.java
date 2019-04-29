package ru.bpc.sv2.rest.v1;

import ru.bpc.sv2.invocation.SelectionParams;
import util.auxil.SessionWrapper;

public abstract class BaseRestController {
	protected Long getSessionId() {
		String userSession = SessionWrapper.getUserSessionIdStr();
		return userSession != null ? Long.parseLong(userSession) : null;
	}

	protected SelectionParams createSelectionParams(Integer offset, Integer count, Object... filters) {
		SelectionParams params = SelectionParams.build(true, filters);

		params.setRowIndexStart(offset == null || offset < 0 ? 0 : offset);
		params.setRowIndexEnd(count == null || count <= 0 ? -1 : (offset + count) - 1);
		return params;
	}
}
