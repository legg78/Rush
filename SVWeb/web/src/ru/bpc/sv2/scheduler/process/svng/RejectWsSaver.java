package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.svng.DataTypes;

/**
 * Created by Gasanov on 26.10.2015.
 */
public class RejectWsSaver extends LoadWsSaver {

    @Override
    protected DataTypes getDataType() {
        return DataTypes.REJECT;
    }

    @Override
    public String getStatusSessionFile(){
        return ProcessConstants.FILE_STATUS_POSTPROCESSING;
    }

    @Override
    protected boolean sendPrepareRequest() throws Exception {
        return true;
    }
}
