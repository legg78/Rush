package ru.bpc.sv2.utils;

import java.util.Arrays;
import java.util.HashMap;

public class ArrayMap<V> extends HashMap<ArrayMap.ArrayMapKey, V> {

	public V get(Object[] key) {
		return super.get(new ArrayMapKey(key));
	}

	public V put(Object[] key, V value) {
		return super.put(new ArrayMapKey(key), value);
	}

	public static class ArrayMapKey {
		private Object[] key;

		public ArrayMapKey(Object[] key) {
			if (key == null)
				throw new IllegalArgumentException("Key should not be null");
			if (key.length == 0)
				throw new IllegalArgumentException("Key should not be empty");
			this.key = key;
		}

		@Override
		public boolean equals(Object o) {
			if (this == o) return true;
			if (o == null || getClass() != o.getClass()) return false;

			ArrayMapKey that = (ArrayMapKey) o;

			return Arrays.equals(key, that.key);
		}

		@Override
		public int hashCode() {
			return Arrays.hashCode(key);
		}
	}
}
