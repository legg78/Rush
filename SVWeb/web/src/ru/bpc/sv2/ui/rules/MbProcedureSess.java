package ru.bpc.sv2.ui.rules;

import java.io.Serializable;

import ru.bpc.sv2.rules.Procedure;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

@SessionScoped
@ManagedBean (name = "MbProcedureSess")
public class MbProcedureSess implements Serializable {

	private static final long serialVersionUID = 1L;
	
	private Procedure procedure;
	private Procedure newProcedure;

	private int pageNum;
	private int rowsNum;
	private String tabName;

	private Procedure filter;

	public Procedure getProcedure() {
		return procedure;
	}

	public void setProcedure(Procedure procedure) {
		this.procedure = procedure;
	}

	public Procedure getNewProcedure() {
		return newProcedure;
	}

	public void setNewProcedure(Procedure newProcedure) {
		this.newProcedure = newProcedure;
	}

	public int getPageNum() {
		return pageNum;
	}

	public void setPageNum(int pageNum) {
		this.pageNum = pageNum;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public String getTabName() {
		return tabName;
	}

	public void setTabName(String tabName) {
		this.tabName = tabName;
	}

	public Procedure getFilter() {
		return filter;
	}

	public void setFilter(Procedure filter) {
		this.filter = filter;
	}

}
