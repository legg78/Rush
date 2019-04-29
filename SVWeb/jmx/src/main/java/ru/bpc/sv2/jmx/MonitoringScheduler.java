package ru.bpc.sv2.jmx;


import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.ApplicationContext;
import org.springframework.scheduling.concurrent.ThreadPoolTaskScheduler;
import org.springframework.stereotype.Component;
import ru.bpc.sv2.jmx.oracle.services.OracleMonitor;
import ru.bpc.sv2.jmx.svbo.services.SvboMonitor;
import ru.bpc.sv2.jmx.utils.MonitoringSettings;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

@Component
public class MonitoringScheduler {
    private static final Logger logger = LoggerFactory.getLogger("MONITORING");
    private boolean running;

    private ThreadPoolTaskScheduler threadPoolTaskScheduler;

    @Autowired
    private MonitoringServer monitoringServer;

    @Autowired
    private ApplicationContext applicationContext;

    @Autowired
    private MonitoringSettings settings;

    /**
     * setting name for monitoring On/Off detection
     */
    @Value("#{settingName}")
    private String settingName;

    public void start() {
        if (running) return;

        try {
            if (!settings.getBoolean(settingName)) return;

            logger.info("Starting monitoring scheduler...");

            int delay = settings.getInteger(MonitoringSettings.DELAY, 10000);
            int port = settings.getInteger(MonitoringSettings.PORT, 9026);
            int poolSize = settings.getInteger(MonitoringSettings.POOL_SIZE, 10);

            if (!monitoringServer.start(port)) {
                logger.warn("Cancel scheduler because server is not started");
                return;
            }

            if (threadPoolTaskScheduler == null) {
                threadPoolTaskScheduler = new ThreadPoolTaskScheduler();
                threadPoolTaskScheduler.setBeanName("MonitoringScheduler");
                threadPoolTaskScheduler.setWaitForTasksToCompleteOnShutdown(false);
                threadPoolTaskScheduler.setAwaitTerminationSeconds(delay / 1000 + 30);
                threadPoolTaskScheduler.setPoolSize(poolSize);
                threadPoolTaskScheduler.initialize();
            }

            if (settings.getBoolean(MonitoringSettings.SVBO_ON)) {
                runMonitorForType(SvboMonitor.class, delay);
            }

            if (settings.getBoolean(MonitoringSettings.ORACLE_ON)) {
                runMonitorForType(OracleMonitor.class, delay);
            }

            logger.info("Monitoring scheduler started...");

            running = true;
        } catch(Exception e) {
            logger.error("Error while starting monitoring scheduler", e);
            stop();
        }
    }

    public void stop() {
        logger.info("Stopping monitoring scheduler...");

        try {
            if (threadPoolTaskScheduler != null) {
                threadPoolTaskScheduler.shutdown();
                threadPoolTaskScheduler = null;
            }

            monitoringServer.stop();

            logger.info("Monitoring scheduler stopped...");
        } catch(Exception e) {
            logger.error("Error while stopping scheduler", e);
        } finally {
            running = false;
        }
    }

    public void runMonitorForType(Class<?> type, int delay) {
        String[] names = applicationContext.getBeanNamesForType(type, false, true);
        for (String name: names) {
            Runnable bean = getRunnableBean(name);
            if (bean == null) continue;
            logger.info("Add bean '" + name + "' to schedule");
            threadPoolTaskScheduler.scheduleWithFixedDelay(bean, delay);
        }
    }

    private Runnable getRunnableBean(String name) {
        try {
            return (Runnable) applicationContext.getBean(name);
        } catch (Exception e) {
            logger.error("Can't find bean by name: " + name, e);
        }
        return null;
    }

    public void restart() {
        stop();
        start();
    }


    @PostConstruct
    public void postConstruct() {
        start();
    }

    @PreDestroy
    public void preDestroy() {
        stop();
    }
}
