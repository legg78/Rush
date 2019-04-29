package ru.bpc.sv2.process.filereader;

public abstract class ItemReader<T> {
	public abstract T next() throws ItemReaderException;
}
