package ru.bpc.sv.ws.process.event;

import com.bpcbt.sv.sv_sync.SyncResponseHeadType;
import org.apache.log4j.Logger;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.common.events.RegisteredEvent;
import ru.bpc.sv2.constants.EntityNames;
import ru.bpc.sv2.logic.EventsDao;
import ru.bpc.sv2.scheduler.process.utils.ResponseResultCodes;

import java.util.Date;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class EventRegistration {

    private static final Logger logger = Logger.getLogger("PROCESSES");

    public EventRegistration() {
    }

    private boolean isFilesTransferred(SyncResponseHeadType parameters) {
        String code = String.valueOf(parameters.getResult().getCode());
        if (code.equals(String.valueOf(ResponseResultCodes.INVALID_SESSION_ID.getCode())) || code.startsWith(ResponseResultCodes.SIGN_4XX.getText())) {
            return false;
        }
        else if (code.startsWith(ResponseResultCodes.SIGN_1XX.getText()) && !code.equals(String.valueOf(ResponseResultCodes.INVALID_SESSION_ID.getCode()))) {
            return true;
        }
        else if (code.startsWith(ResponseResultCodes.SIGN_2XX.getText())) {
            return true;
        }
        else if (code.equals(String.valueOf(ResponseResultCodes.SUCCESS.getCode()))) {
            return true;
        }
        else {
            return false;
        }
    }

    public void register(SyncResponseHeadType parameters) {
        try {
        	EventsDao eventsDao = new EventsDao();
            if (isFilesTransferred(parameters)) {
                RegisteredEvent event = new RegisteredEvent(EventConstants.SUCCESSFULL_FILE_TRANSMISSION, new Date(), EntityNames.SESSION, Long.valueOf(parameters.getSessionId()));
	            eventsDao.registerEvent(event, Long.valueOf(parameters.getSessionId()));
            } else {
                RegisteredEvent event = new RegisteredEvent(EventConstants.UNSUCCESSFULL_FILE_TRANSMISSION, new Date(), EntityNames.SESSION, Long.valueOf(parameters.getSessionId()));
	            eventsDao.registerEvent(event, Long.valueOf(parameters.getSessionId()));
            }
        } catch (Exception e) {
            logger.error("Information about transmission event files not saved, for session = "+ parameters.getSessionId());
            logger.error(e.getMessage(), e);
        }
    }
}
