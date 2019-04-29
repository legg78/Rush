package ru.bpc.sv2.ui.utils.model;

public interface IPageable {
	int getRowsPerPage();

	void setRowsPerPage(int rowsPerPage);

	int getPageNo();

	void setPageNo(int pageNo);

	int getRowCount();
}
