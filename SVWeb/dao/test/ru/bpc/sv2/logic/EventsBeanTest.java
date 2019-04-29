package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapClient;
import com.ibatis.sqlmap.client.SqlMapClientBuilder;
import org.apache.ibatis.io.Resources;
import org.junit.Assert;
import org.junit.BeforeClass;
import org.junit.Test;
import ru.bpc.sv2.common.events.EventConstants;
import ru.bpc.sv2.common.events.RegisteredEvent;
import ru.bpc.sv2.constants.EntityNames;
import java.io.Reader;
import java.sql.SQLException;
import java.util.Date;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class EventsBeanTest {

    static SqlMapClient client = null;

    @BeforeClass
    public static void setUp() throws Exception {
        Reader reader = Resources.getResourceAsReader("ru/bpc/sv2/logic/config.xml");
        client = SqlMapClientBuilder.buildSqlMapClient(reader);
        reader.close();
    }

    @Test
    public void registerEventTest() throws SQLException {
        Long sessionId = 111111111111L;
        RegisteredEvent event = new RegisteredEvent(EventConstants.SUCCESSFULL_FILE_TRANSMISSION, new Date(), EntityNames.SESSION, sessionId);
        int i = client.update("events.register-event", event);
        Assert.assertNotNull(i);
    }

}
