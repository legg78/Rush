package ru.bpc.jsf;

import org.ajax4jsf.cache.*;
import org.ajax4jsf.webapp.CacheContent;

import java.util.Map;

/**
 * Cache factory that is supposed to deal with a4j resource caching bug that results in existence of "empty" version of
 * resource (css, js etc) in a cache map. Then, that empty resource is served to client instead of original one
 * and never invalidated.
 */
public class A4JResourceCacheFactory implements CacheFactory {
	@Override
	public Cache createCache(Map env, CacheLoader cacheLoader, CacheConfigurationLoader cacheConfigurationLoader) throws CacheException {
		String size = (String) env.get(LRUMapCacheFactory.CACHE_SIZE_PARAMETER);
		if (size == null || size.length() == 0) {
			return new Cache(cacheLoader);
		} else {
			int parsedSize = Integer.parseInt(size);
			return new Cache(cacheLoader, parsedSize);
		}
	}

	public static final class Cache extends LRUMapCache {
		public Cache(CacheLoader cacheLoader, int initialSize) {
			super(cacheLoader, initialSize);
		}

		public Cache(CacheLoader cacheLoader) {
			super(cacheLoader);
		}

		@Override
		public synchronized Object get(Object key, Object context) throws CacheException {
			Object result = super.get(key, context);
			if (result instanceof CacheContent) {
				CacheContent content = (CacheContent) result;
				if (isEmpty(content)) {
					// Content is assumed to be empty. Evicting it from cache and reload
					remove(key);
					content = (CacheContent) super.get(key, context);
					if (isEmpty(content)) {
						// If reloaded content is still empty, make it uncacheable in browser
						content.setHeader("Cache-Control", "no-cache");
						content.setHeader("Pragma", "no-cache");
					}
					return content;
				}
			}
			return result;
		}

		private boolean isEmpty(CacheContent content) {
			if (content.getContentType() == null) {
				try {
					content.getContentLength();
				} catch (IllegalStateException e) {
					return true;
				}
			}
			return false;
		}
	}
}
