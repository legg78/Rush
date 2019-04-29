package ru.bpc.sv2.mastercom.api.format.impl;

import ru.bpc.sv2.mastercom.api.format.MasterComValueFormatter;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComCaseType;

public class MasterComCaseTypeFormatter implements MasterComValueFormatter<MasterComCaseType> {
	@Override
	public MasterComCaseType parse(Object value) {
		if (value == null) {
			return null;
		}
		switch (value.toString()) {
			case "1":
				return MasterComCaseType.PreArbitration;
			case "2":
				return MasterComCaseType.Arbitration;
			case "3":
				return MasterComCaseType.PreCompliance;
			case "4":
				return MasterComCaseType.Compliance;
		}
		throw new RuntimeException("Unsupported case type value: " + value);
	}

	@Override
	public Object format(MasterComCaseType value) {
		if (value == null) {
			return null;
		}

		switch (value) {
			case PreArbitration:
				return "1";
			case Arbitration:
				return "2";
			case PreCompliance:
				return "3";
			case Compliance:
				return "4";
		}
		throw new RuntimeException("Unsupported case type value: " + value);
	}
}
