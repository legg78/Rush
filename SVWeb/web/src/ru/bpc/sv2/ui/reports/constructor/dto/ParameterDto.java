package ru.bpc.sv2.ui.reports.constructor.dto;

import java.io.Serializable;
import java.util.Map;

import ru.jtsoft.dynamicreports.ReportingDataModel;
import ru.jtsoft.dynamicreports.model.Parameter;

import com.google.common.base.Function;

public final class ParameterDto implements Serializable {
	
	private static final long serialVersionUID = 5625660684710780092L;

	private String id;
	private String label;
	private String type;
	private Map<?, ?> dictionary;
	private boolean hasDictionary;

	public String getId() {
		return id;
	}

	public void setId(String id) {
		this.id = id;
	}

	public String getLabel() {
		return label;
	}

	public void setLabel(String label) {
		this.label = label;
	}

	public String getType() {
		return type;
	}

	public void setType(String type) {
		this.type = type;
	}

	public Map<?, ?> getDictionary() {
		return dictionary;
	}

	public void setDictionary(Map<?, ?> dictionary) {
		this.dictionary = dictionary;
	}
	
	public boolean isHasDictionary() {
		return hasDictionary;
	}

	public void setHasDictionary(boolean hasDictionary) {
		this.hasDictionary = hasDictionary;
	}

	@Override
	public int hashCode() {
		final int prime = 31;
		int result = 1;
		result = prime * result + ((id == null) ? 0 : id.hashCode());
		return result;
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		ParameterDto other = (ParameterDto) obj;
		if (id == null) {
			if (other.id != null)
				return false;
		} else if (!id.equals(other.id))
			return false;
		return true;
	}

	@Override
	public String toString() {
		return new StringBuilder().append('[').append(getLabel()).append(']')
				.toString();
	}

	public static final Function<Parameter, ParameterDto> converter (ReportingDataModel reportingDataModel) {
		return ConverterHolder.CONVERTER;
	}
	
	private static class ConverterHolder {
		protected static Function<Parameter, ParameterDto> CONVERTER = new Function<Parameter, ParameterDto>() {
			@Override
			public ParameterDto apply(Parameter input) {
				final ParameterDto output;
				if (null == input) {
					output = null;
				} else {
					output = new ParameterDto();
					output.setId(input.getId());
					output.setLabel(input.getLocalizedLabel());
					output.setType(input.getType().getName());
					output.setDictionary(input.getType().getDictionary());
					output.setHasDictionary(input.getType().hasDictionary());
				}
				return output;
			}
		};
	}
}
