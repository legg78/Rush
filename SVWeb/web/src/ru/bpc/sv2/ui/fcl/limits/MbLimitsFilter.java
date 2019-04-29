package ru.bpc.sv2.ui.fcl.limits;

import ru.bpc.sv2.fcl.limits.Limit;

public class MbLimitsFilter
{
	private Limit filter;
	
	public MbLimitsFilter()
	{
		filter = new Limit();
	}

	public Limit getFilter() {
		return filter;
	}

	public void setFilter(Limit filter) {
		this.filter = filter;
	}
	
	
}
