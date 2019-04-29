package ru.bpc.sv2.jcb.enums;

import ru.bpc.sv2.constants.DictNames;

/**
 * Created by Nikishkin on 07.10.2015.
 */
public enum LoadType {
	JCB_CLEARING("0001"), JCB_BIN("0002"), JCB_CLEARING_OUT("0003"), JCB_MERCHANT("0004"), JCB_STOP_DATA("0005");

	public static final String DICT_CODE = DictNames.JCB_LOAD_TYPE;
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

	public String getArticleCodeFull() {
		return DICT_CODE + getArticleCode();
	}
}
