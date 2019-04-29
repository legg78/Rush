package ru.bpc.sv2.mastercom.api.format;

public interface MasterComValueFormatter<T> {
	T parse(Object value);
	Object format(T value);
}
