package ru.bpc.sv2.mastercom.api.format.impl;

import ru.bpc.sv2.mastercom.api.format.MasterComValueFormatter;

public class MasterComBooleanYNFormatter implements MasterComValueFormatter<Boolean> {

	@Override
	public Boolean parse(Object value) {
		if (value == null) {
			return null;
		}
		if (value instanceof Boolean) {
			return (Boolean) value;
		}

		if ("N".equals(value)) {
			return false;
		} else if ("Y".equals(value)) {
			return true;
		} else {
			return false;
		}
	}

	@Override
	public Object format(Boolean value) {
		if (value == null) {
			return null;
		}
		if (Boolean.TRUE.equals(value)) {
			return "Y";
		} else {
			return "N";
		}
	}
}
