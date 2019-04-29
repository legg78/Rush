package ru.bpc.sv2.mastercom.api.format.impl;

import ru.bpc.sv2.mastercom.api.format.MasterComValueFormatter;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComRetrievalDetails;

public class MasterComDocNeededFormatter implements MasterComValueFormatter<MasterComRetrievalDetails.DocNeeded> {
	@Override
	public MasterComRetrievalDetails.DocNeeded parse(Object value) {
		if (value == null) {
			return null;
		}
		return MasterComRetrievalDetails.DocNeeded.getByCode(Integer.valueOf(value.toString()));
	}

	@Override
	public Object format(MasterComRetrievalDetails.DocNeeded value) {
		if (value == null) {
			return null;
		}
		return value.getCode().toString();
	}
}
