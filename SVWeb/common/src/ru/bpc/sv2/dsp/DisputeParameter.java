package ru.bpc.sv2.dsp;

import java.io.Serializable;

import ru.bpc.sv2.common.Parameter;
import ru.bpc.sv2.invocation.ModelIdentifiable;

public class DisputeParameter extends Parameter implements Serializable, ModelIdentifiable {
	private static final long serialVersionUID = 1L;

	@Override
	public Object getModelId() {
		return getSystemName();
	}
}
