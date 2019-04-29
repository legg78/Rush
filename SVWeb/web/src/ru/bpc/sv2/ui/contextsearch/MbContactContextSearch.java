package ru.bpc.sv2.ui.contextsearch;


import ru.bpc.sv2.ui.common.MbContactDataSearch;
import ru.bpc.sv2.ui.common.MbContactSearch;
import util.auxil.ManagedBeanWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.ViewScoped;

@ViewScoped

@ManagedBean(name = "MbContactContextSearch")
public class MbContactContextSearch extends MbContactSearch {

	public MbContactContextSearch(){
		super();
		contactDataBean = (MbContactDataSearch) ManagedBeanWrapper.getManagedBean("MbContactDataContextSearch");
	}
}
