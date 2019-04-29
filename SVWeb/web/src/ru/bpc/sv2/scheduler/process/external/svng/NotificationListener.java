package ru.bpc.sv2.scheduler.process.external.svng;

import java.util.Map;

public interface NotificationListener {
	void notify(Map<String,Object> value);
}