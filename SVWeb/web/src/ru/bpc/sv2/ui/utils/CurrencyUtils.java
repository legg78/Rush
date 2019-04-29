package ru.bpc.sv2.ui.utils;

import ru.bpc.sv2.common.Currency;
import util.auxil.SessionWrapper;

import javax.faces.bean.ManagedBean;
import javax.faces.bean.SessionScoped;
import javax.faces.model.SelectItem;
import java.io.Serializable;
import java.util.List;
import java.util.Map;

@SuppressWarnings("UnusedDeclaration")
@SessionScoped
@ManagedBean(name = "CurrencyUtils")
public class CurrencyUtils implements Serializable {
	private static final long serialVersionUID = 1L;

	public CurrencyUtils() {

	}

	public Map<String, String> getCurrencyMap() {
		String userLang = SessionWrapper.getField("language");
		return CurrencyCache.getInstance().getCurrencyMapByLang(userLang);
	}

	public Map<String, String> getCurrencyShortNamesMap() {
		return CurrencyCache.getInstance().getCurrencyShortNamesMap();
	}

	public Map<String, Currency> getCurrencyObjectsMap() {
		return CurrencyCache.getInstance().getCurrencyObjectsMap();
	}

	public Map<String, String> getCodeMap() {
		return CurrencyCache.getInstance().getCodeMap();
	}

	public List<SelectItem> getAllCurrencies() {
		String userLang = SessionWrapper.getField("language");
		return CurrencyCache.getInstance().getAllCurrencies(userLang);
	}

	public Map<String, String> getFlagMap() {
		String lang = SessionWrapper.getField("language");
		return CurrencyCache.getInstance().getCurrencyFlagByLang(lang);
	}

	public Map<String, Map<Number, String>> getObjectsMap() {
		return CurrencyCache.getInstance().getObjectsMap();
	}
}
