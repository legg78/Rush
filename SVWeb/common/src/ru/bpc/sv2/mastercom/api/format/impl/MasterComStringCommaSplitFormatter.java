package ru.bpc.sv2.mastercom.api.format.impl;

import org.apache.commons.lang3.StringUtils;
import ru.bpc.sv2.mastercom.api.format.MasterComValueFormatter;

import java.util.Arrays;
import java.util.List;

public class MasterComStringCommaSplitFormatter implements MasterComValueFormatter<List<String>> {

	@Override
	public List<String> parse(Object value) {
		if (value == null) {
			return null;
		}

		List<String> result = Arrays.asList(value.toString().split(","));
		for (int i = 0; i < result.size(); i++) {
			result.set(i, result.get(i).trim());
		}
		return result;
	}

	@Override
	public Object format(List<String> value) {
		if (value == null) {
			return null;
		}

		return StringUtils.join(value);
	}
}
