package ru.bpc.sv2.mastercom.api.format.impl;

import ru.bpc.sv2.mastercom.api.format.MasterComValueFormatter;
import ru.bpc.sv2.mastercom.api.types.claim.response.MasterComCaseFilingDetails;

public class MasterComParticipantFormatter implements MasterComValueFormatter<MasterComCaseFilingDetails.Participant> {
	@Override
	public MasterComCaseFilingDetails.Participant parse(Object value) {
		if (value == null) {
			return null;
		}

		switch (value.toString()) {
			case "I":
				return MasterComCaseFilingDetails.Participant.Issuer;
			case "A":
				return MasterComCaseFilingDetails.Participant.Acquirer;
		}

		throw new RuntimeException("Unsupported participant value: " + value);
	}

	@Override
	public Object format(MasterComCaseFilingDetails.Participant value) {
		if (value == null) {
			return null;
		}

		switch (value) {
			case Issuer:
				return "I";
			case Acquirer:
				return "A";
		}

		throw new RuntimeException("Unsupported participant value: " + value);
	}
}
