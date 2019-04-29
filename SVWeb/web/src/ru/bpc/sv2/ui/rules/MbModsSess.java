package ru.bpc.sv2.ui.rules;

import java.io.Serializable;
import java.util.List;

import ru.bpc.sv2.rules.ModParam;
import ru.bpc.sv2.rules.ModScale;
import ru.bpc.sv2.ui.utils.TableRowSelection;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;

/**
 * For use with beans connected with rule modifiers:
 * MbModScales, MbModParams, MbModScaleParams.
 */
@SessionScoped
@ManagedBean (name = "MbModsSess")
public class MbModsSess implements Serializable {
	
	private static final long serialVersionUID = 1L;
	
	private ModScale scalesFilter;
	private ModScale activeModScale;
	private List<ModScale> activeModScaleList;
	private ModParam paramsFilter;
	private ModParam activeModParam;
	private TableRowSelection<ModParam> paramsSelection;
	private String scalesTabName;
	private int rowsNum;
	private int pageNumber;
	
	public ModScale getScalesFilter() {
		return scalesFilter;
	}
	
	public List<ModScale> getActivePageList() {
		return activeModScaleList;
	}

	public void setActivePageList(List<ModScale> activeModScaleList) {
		this.activeModScaleList = activeModScaleList;
	}

	public void setScalesFilter(ModScale scalesFilter) {
		this.scalesFilter = scalesFilter;
	}
	
	public ModScale getActiveModScale() {
		return activeModScale;
	}
	
	public void setActiveModScale(ModScale activeModScale) {
		this.activeModScale = activeModScale;
	}
	
	

	public ModParam getParamsFilter() {
		return paramsFilter;
	}

	public void setParamsFilter(ModParam paramsFilter) {
		this.paramsFilter = paramsFilter;
	}

	public ModParam getActiveModParam() {
		return activeModParam;
	}

	public void setActiveModParam(ModParam activeModParam) {
		this.activeModParam = activeModParam;
	}

	public TableRowSelection<ModParam> getParamsSelection() {
		return paramsSelection;
	}

	public void setParamsSelection(TableRowSelection<ModParam> paramsSelection) {
		this.paramsSelection = paramsSelection;
	}

	public String getScalesTabName() {
		return scalesTabName;
	}

	public void setScalesTabName(String scalesTabName) {
		this.scalesTabName = scalesTabName;
	}

	public int getRowsNum() {
		return rowsNum;
	}

	public void setRowsNum(int rowsNum) {
		this.rowsNum = rowsNum;
	}

	public int getPageNumber() {
		return pageNumber;
	}

	public void setPageNumber(int pageNumber) {
		this.pageNumber = pageNumber;
	}
	
}
