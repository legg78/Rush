package ru.bpc.sv2.rest.v1;

import java.util.List;

public class PaginatedListResult<T> {
	private Integer offset;
	private Integer count;
	private Integer total;
	private List<T> entries;

	public Integer getOffset() {
		return offset;
	}

	public void setOffset(Integer offset) {
		this.offset = offset;
	}

	public Integer getCount() {
		return count;
	}

	public void setCount(Integer count) {
		this.count = count;
	}

	public Integer getTotal() {
		return total;
	}

	public void setTotal(Integer total) {
		this.total = total;
	}

	public List<T> getEntries() {
		return entries;
	}

	public void setEntries(List<T> entries) {
		this.entries = entries;
	}
}
