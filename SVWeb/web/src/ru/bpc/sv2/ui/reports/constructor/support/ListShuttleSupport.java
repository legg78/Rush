package ru.bpc.sv2.ui.reports.constructor.support;

import java.io.Serializable;
import java.util.List;
import java.util.Set;

public final class ListShuttleSupport<S extends Serializable, T extends Serializable>
		implements Serializable {
	private static final long serialVersionUID = -2875752547435437706L;

	private List<S> sourceValue;
	private List<T> targetValue;
	private Set<S> sourceSelection;
	private Set<T> targetSelection;
	private List<S> converterValue;
	private boolean source;

	public List<S> getSourceValue() {
		return sourceValue;
	}

	public void setSourceValue(List<S> sourceValue) {
		this.sourceValue = sourceValue;
	}

	public List<T> getTargetValue() {
		return targetValue;
	}

	public void setTargetValue(List<T> targetValue) {
		this.targetValue = targetValue;
	}

	public Set<S> getSourceSelection() {
		return sourceSelection;
	}

	public void setSourceSelection(Set<S> sourceSelection) {
		this.sourceSelection = sourceSelection;
	}

	public Set<T> getTargetSelection() {
		return targetSelection;
	}

	public void setTargetSelection(Set<T> targetSelection) {
		this.targetSelection = targetSelection;
	}

	public List<S> getConverterValue() {
		return converterValue;
	}

	public void setConverterValue(List<S> converterValue) {
		this.converterValue = converterValue;
	}

	public boolean isSource() {
		return source;
	}

	public void setSource(boolean source) {
		this.source = source;
	}
}