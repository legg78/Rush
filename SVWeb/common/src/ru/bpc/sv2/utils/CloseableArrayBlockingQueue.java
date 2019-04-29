package ru.bpc.sv2.utils;

import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.TimeUnit;

public class CloseableArrayBlockingQueue<T> extends ArrayBlockingQueue<T> implements CloseableBlockingQueue<T> {
	private boolean closed;

	public CloseableArrayBlockingQueue(int capacity) {
		super(capacity);
	}

	@Override
	public boolean add(T t) {
		checkClosedOnAdd();
		return super.add(t);
	}

	@SuppressWarnings("NullableProblems")
	@Override
	public boolean offer(T t) {
		checkClosedOnAdd();
		return super.offer(t);
	}

	@Override
	public void put(T t) throws InterruptedException {
		checkClosedOnAdd();
		super.put(t);
	}

	@SuppressWarnings("NullableProblems")
	@Override
	public boolean offer(T t, long timeout, TimeUnit unit) throws InterruptedException {
		checkClosedOnAdd();
		return super.offer(t, timeout, unit);
	}

	@Override
	public T take() throws InterruptedException {
		if (isClosedAndEmpty())
			return null;
		return super.take();
	}

	@SuppressWarnings("NullableProblems")
	@Override
	public T poll(long timeout, TimeUnit unit) throws InterruptedException {
		if (isClosedAndEmpty())
			return null;
		return super.poll(timeout, unit);
	}

	@Override
	public synchronized boolean isClosed() {
		return closed;
	}

	@Override
	public synchronized boolean isClosedAndEmpty() {
		return isEmpty() && closed;
	}

	@Override
	public synchronized void close() {
		closed = true;
	}

	@Override
	public synchronized void closeAndClear() {
		closed = true;
		clear();
	}

	private void checkClosedOnAdd() {
		if (closed)
			throw new IllegalStateException("Queue is closed, no more additions is allowed");
	}
}
