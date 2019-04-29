package ru.bpc.sv2.utils;

import java.util.concurrent.BlockingQueue;

public interface CloseableBlockingQueue<T> extends BlockingQueue<T> {
	boolean isClosed();

	boolean isClosedAndEmpty();

	void close();

	void closeAndClear();
}
