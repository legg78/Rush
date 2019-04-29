package util.servlet.listener;


import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;

import org.apache.log4j.Logger;

import ru.bpc.sv2.logic.ProcessDao;
import ru.bpc.sv2.scheduler.WebSchedule;

public class ShedulerInitializedListener implements ServletContextListener{
	private static final Logger logger = Logger.getLogger("SYSTEM");
	
	private ProcessDao _processDao = new ProcessDao();

	@Override
	public void contextInitialized(ServletContextEvent sce) {
		Boolean running = _processDao.isRunning();
		if (running){
			WebSchedule schedule = WebSchedule.getInstance();
			try {
				schedule.restart();
			} catch (Exception e) {
				logger.error("", e);
			}
		}
	}

	@Override
	public void contextDestroyed(ServletContextEvent sce) {
		// TODO Auto-generated method stub
		
	}

}
