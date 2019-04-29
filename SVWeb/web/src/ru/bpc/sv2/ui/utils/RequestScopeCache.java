package ru.bpc.sv2.ui.utils;

import ru.bpc.sv2.ui.utils.model.PhaseListenerSupport;
import ru.bpc.sv2.utils.ArrayMap;

import javax.faces.event.PhaseEvent;
import javax.faces.event.PhaseId;
import javax.faces.event.PhaseListener;
import javax.servlet.http.HttpServletRequest;
import java.io.Serializable;
import java.util.Collections;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.UUID;

public class RequestScopeCache<T> implements PhaseListener {
	private static final String REQUEST_ID_ATTR = RequestScopeCache.class.getName() + ".id";
	private static final long MAX_TIME_TO_LIVE = 60000;
	private Map<UUID, CacheMapEntry<T>> cache = Collections.synchronizedMap(new CacheMap<T>());

	public RequestScopeCache() {
		PhaseListenerSupport.registerPhaseListener(this);
	}

	public T getValue(Object[] key, LoadCallback<T> loadCallback) {
		T result = null;
		UUID requestId = getRequestId();
		if (requestId == null) {
			result = loadCallback.loadDict(key);
		} else {
			CacheMapEntry<T> entry = cache.get(requestId);
			ArrayMap<T> map = entry != null ? entry.value : null;
			if (map != null) {
				result = map.get(key);
			}
			if (result == null) {
				result = loadCallback.loadDict(key);
			}
			if (map == null) {
				map = new ArrayMap<T>();
				cache.put(requestId, new CacheMapEntry<T>(map));
			}
			map.put(key, result);
		}
		return result;
	}

	public interface LoadCallback<T> {
		T loadDict(Object[] key);
	}

	@Override
	public PhaseId getPhaseId() {
		return PhaseId.ANY_PHASE;
	}

	@Override
	public void afterPhase(PhaseEvent event) {
		if (event.getPhaseId() == PhaseId.RENDER_RESPONSE) {
			UUID requestId = getRequestId();
			if (requestId != null) {
				cache.remove(requestId);
			}
		}
	}

	@Override
	public void beforePhase(PhaseEvent event) {
		if (event.getPhaseId() == PhaseId.RESTORE_VIEW) {
			HttpServletRequest request = RequestContextHolder.getRequest();
			if (request != null) {
				request.setAttribute(REQUEST_ID_ATTR, UUID.randomUUID());
			}
		}
	}

	private UUID getRequestId() {
		HttpServletRequest request = RequestContextHolder.getRequest();
		return request != null ? (UUID) request.getAttribute(REQUEST_ID_ATTR) : null;
	}

	private static class CacheMap<T> extends LinkedHashMap<UUID, CacheMapEntry<T>> {
		@Override
		protected boolean removeEldestEntry(Map.Entry<UUID, CacheMapEntry<T>> eldest) {
			return System.currentTimeMillis() - eldest.getValue().timestamp > MAX_TIME_TO_LIVE;
		}
	}

	private static class CacheMapEntry<T> implements Serializable {
		private long timestamp;
		private ArrayMap<T> value;

		public CacheMapEntry(ArrayMap<T> value) {
			this.timestamp = System.currentTimeMillis();
			this.value = value;
		}
	}
}
