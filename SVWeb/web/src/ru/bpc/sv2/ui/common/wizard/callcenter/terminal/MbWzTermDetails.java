package ru.bpc.sv2.ui.common.wizard.callcenter.terminal;


import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

import org.apache.log4j.Logger;

import ru.bpc.sv2.acquiring.Terminal;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.AcquiringDao;
import util.auxil.SessionWrapper;

@ViewScoped
@ManagedBean(name = "MbWzTermDetails")
public class MbWzTermDetails {
	private static final Logger classLogger = Logger.getLogger(MbWzTermDetails.class);
	private long userSessionId;
	private String curLang;
	private Long termId;
	private Terminal term;
	
	private AcquiringDao acquiringDao = new AcquiringDao();
	
	public void init(Long termId){
		classLogger.trace("init...");
		userSessionId = SessionWrapper.getRequiredUserSessionId();
		curLang = SessionWrapper.getField("language");		
		this.termId = termId;
		term = retriveTerminal(termId);
	}
	
	private Terminal retriveTerminal(Long terminalId){
		classLogger.trace("retriveTerminal...");
		Terminal result;
		SelectionParams sp = SelectionParams.build("id", terminalId);
		Terminal[] terminals = acquiringDao.getTerminals(userSessionId, sp);
		if (terminals.length > 0){
			result = terminals[0];
		} else {
			throw new IllegalStateException("Terminal with ID:" + terminalId + " is not found!");
		}
		return result;
	}
	
	public Terminal getTerminal(){
		return term;
	}
}
