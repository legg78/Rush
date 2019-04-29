package ru.bpc.sv2.ui.rules;

import java.io.Serializable;

import ru.bpc.sv2.rules.ProcedureParam;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbProcedureParamSess")
public class MbProcedureParamSess implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private ProcedureParam procedureParam;
	private ProcedureParam newProcedureParam;
	private String backLink;
	private int curMode;
	private Integer procedureId;

	public Integer getProcedureId() {
		return procedureId;
	}

	public void setProcedureId(Integer procedureId) {
		this.procedureId = procedureId;
	}

	public ProcedureParam getProcedureParam() {
		return procedureParam;
	}

	public void setProcedureParam(ProcedureParam procedureParam) {
		this.procedureParam = procedureParam;
	}

	public ProcedureParam getNewProcedureParam() {
		return newProcedureParam;
	}

	public void setNewProcedureParam(ProcedureParam newProcedureParam) {
		this.newProcedureParam = newProcedureParam;
	}

	public String getBackLink() {
		return backLink;
	}

	public void setBackLink(String backLink) {
		this.backLink = backLink;
	}

	public int getCurMode() {
		return curMode;
	}

	public void setCurMode(int curMode) {
		this.curMode = curMode;
	}

}
