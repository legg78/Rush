package ru.bpc.sv2.ui.common.wizard.callcenter;

import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.ReconciliationDao;
import ru.bpc.sv2.reconciliation.RcnMessage;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped
@ManagedBean(name = "MbWzRcnDetails")
public class MbWzRcnDetails {
	private static final Logger classLogger = Logger.getLogger(MbWzRcnDetails.class);

	private ReconciliationDao dao = new ReconciliationDao();
	private RcnMessage message;

	public void init(Long id, String module) {
		classLogger.trace("init...");

		Long userSessionId = SessionWrapper.getRequiredUserSessionId();
		String curLang = SessionWrapper.getField("language");
		SelectionParams params = SelectionParams.build(
			"id", id,
			"lang", curLang
		);

		params.setModule(module);

		this.message = dao.getMessages(userSessionId, params).get(0);
	}

	public RcnMessage getMessage() {
		return message;
	}
}
