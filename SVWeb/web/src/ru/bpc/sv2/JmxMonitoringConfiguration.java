package ru.bpc.sv2;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Lazy;
import org.springframework.jmx.export.MBeanExporter;
import org.springframework.jmx.export.assembler.InterfaceBasedMBeanInfoAssembler;
import org.springframework.jmx.support.MBeanServerFactoryBean;
import ru.bpc.sv2.jmx.MonitoringScheduler;
import ru.bpc.sv2.jmx.MonitoringServer;
import ru.bpc.sv2.jmx.oracle.services.*;
import ru.bpc.sv2.jmx.svbo.services.SvboBeanNamingService;
import ru.bpc.sv2.jmx.svbo.services.SvboContainerMonitor;
import ru.bpc.sv2.jmx.svbo.services.SvboProcessMonitor;
import ru.bpc.sv2.jmx.utils.MonitoringSettings;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;


@Configuration
public class JmxMonitoringConfiguration {
    private static final Logger logger = LoggerFactory.getLogger("MONITORING");

    @Bean
    public String settingName() {
        return SettingsConstants.JMX_MONITORING;
    }

    @Bean
    public MBeanServerFactoryBean mBeanServerFactoryBean() {
        MBeanServerFactoryBean server = new MBeanServerFactoryBean();
        return server;
    }

    @Bean
    public MBeanExporter beanExporter(MBeanServerFactoryBean mBeanServerFactoryBean) {
        final MBeanExporter exporter = new MBeanExporter();
        exporter.setAutodetect(false);
        exporter.setAssembler(new InterfaceBasedMBeanInfoAssembler());
        exporter.setServer(mBeanServerFactoryBean.getObject());
        return exporter;
    }


    @Bean
    public MonitoringSettings settings() {
        return new MonitoringSettings() {
            @Override
            public Object get(String name) {
                return SettingsCache.getInstance().getParameterValue(name);
            }
        };
    }


    @Bean
    public MonitoringScheduler monitoringScheduler() {
        return new MonitoringScheduler();
    }


    //
    // SVBO monitor services:
    //

    @Bean
    @Lazy
    public SvboProcessMonitor svboProcessMonitor() {
        return new SvboProcessMonitor();
    }

    @Bean
    @Lazy
    public SvboContainerMonitor svboContainerMonitor() {
        return new SvboContainerMonitor();
    }


    @Bean
    @Lazy
    public MonitoringServer monitoringServer() {
        return new MonitoringServer();
    }

    @Bean
    @Lazy
    public SvboBeanNamingService svboNamingService() {
        return new SvboBeanNamingService();
    }


    //
    // Oracle monitor services:
    //

    @Bean
    @Lazy
    public OracleBeanNamingService oracleNamingService() {
        return new OracleBeanNamingService();
    }

    @Bean
    @Lazy
    public DatabaseMonitor oracleDatabaseMonitor() {
        return new DatabaseMonitor();
    }

    @Bean
    @Lazy
    public TablespaceMonitor oracleTablespaceMonitor() {
        return new TablespaceMonitor();
    }

    @Bean
    @Lazy
    public SessionMonitor oracleSessionMonitor() {
        return new SessionMonitor();
    }

    @Bean
    @Lazy
    public ProcessMonitor oracleProcessMonitor() {
        return new ProcessMonitor();
    }

    @Bean
    @Lazy
    public LibraryCacheMonitor oracleLibraryCacheMonitor() {
        return new LibraryCacheMonitor();
    }

    @Bean
    @Lazy
    public WaitEventsMonitor oracleWaitEventsMonitor() {
        return new WaitEventsMonitor();
    }

    @Bean
    @Lazy
    public SystemIOMonitor oracleSystemIOMonitor() {
        return new SystemIOMonitor();
    }

    @Bean
    @Lazy
    public SGAMonitor oracleSgaMonitor() {
        return new SGAMonitor();
    }

    @Bean
    @Lazy
    public PGAMonitor oraclePgaMonitor() {
        return new PGAMonitor();
    }
}
