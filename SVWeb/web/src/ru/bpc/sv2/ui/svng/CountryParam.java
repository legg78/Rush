package ru.bpc.sv2.ui.svng;

import ru.bpc.sv2.ps.ModuleParam;
import ru.bpc.sv2.ui.utils.CountryUtils;
import util.auxil.ManagedBeanWrapper;

import java.util.Map;

public class CountryParam extends ModuleParam {
	private String letterCode;
	private String numCode;

	public CountryParam() {
	}

	public CountryParam(ModuleParam param) {
		if (param == null) {
			return;
		}
		setId(param.getId());
		setName(param.getName());
		setValue(param.getValue());
		setModule(param.getModule());
		setInstId(param.getInstId());
		setNetworkId(param.getNetworkId());
		setNumCode(param.getName().substring(8));
		setLetterCode(getLetterCodeByNumCode(numCode));
	}

	public String getLetterCode() {
		return letterCode;
	}

	public void setLetterCode(String letterCode) {
		if (letterCode == null) {
			return;
		}
		this.letterCode = letterCode;
		CountryUtils cu = (CountryUtils) ManagedBeanWrapper.getManagedBean("CountryUtils");
		setName("COUNTRY_" + cu.getCodeMap().get(letterCode));
	}

	public String getNumCode() {
		return numCode;
	}

	public void setNumCode(String numCode) {
		this.numCode = numCode;
		if (numCode != null) {
			setName("COUNTRY_" + numCode);
		}
	}

	private String getLetterCodeByNumCode(String numCode) {
		CountryUtils cu = (CountryUtils) ManagedBeanWrapper.getManagedBean("CountryUtils");
		Map<String, String> map = cu.getCodeMap();
		for (Map.Entry<String, String> en : map.entrySet()) {
			if (en.getValue().equals(numCode)) {
				return en.getKey();
			}
		}
		return null;
	}
}
