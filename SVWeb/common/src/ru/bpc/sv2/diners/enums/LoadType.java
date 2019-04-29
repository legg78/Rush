package ru.bpc.sv2.diners.enums;

import ru.bpc.sv2.constants.DictNames;

public enum LoadType {
	DIN_CLEARING_IN("0001"), DIN_BIN("0002"), DIN_CLEARING_OUT("0003");

	public static final String DICT_CODE = DictNames.DIN_LOAD_TYPE;
	private String articleCode;

	LoadType(String articleCode) {
		this.articleCode = articleCode;
	}

	public static LoadType getByArticleCode(String articleCode) {
		for (LoadType loadType : LoadType.values()) {
			if (loadType.articleCode.equals(articleCode))
				return loadType;
		}
		throw new IllegalArgumentException("Could not find LoadType with articleCode=" + articleCode);
	}

	public String getArticleCode() {
		return articleCode;
	}
}
