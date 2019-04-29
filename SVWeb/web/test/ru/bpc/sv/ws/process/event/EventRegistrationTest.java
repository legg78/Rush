package ru.bpc.sv.ws.process.event;

import com.bpcbt.sv.sv_sync.SyncResponseHeadType;
import com.bpcbt.sv.sv_sync.SyncResultType;
import org.junit.BeforeClass;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.modules.junit4.PowerMockRunner;
import org.powermock.reflect.Whitebox;

import static org.junit.Assert.assertEquals;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */

@RunWith(PowerMockRunner.class)
public class EventRegistrationTest {

    private static final SyncResponseHeadType response1 = new SyncResponseHeadType();
    private static final SyncResponseHeadType response2 = new SyncResponseHeadType();
    private static final SyncResponseHeadType response3 = new SyncResponseHeadType();
    private static final SyncResponseHeadType response4 = new SyncResponseHeadType();
    private static final SyncResponseHeadType response5 = new SyncResponseHeadType();



    @BeforeClass
    public static void setup() {
        SyncResultType resultType1 = new SyncResultType();
        resultType1.setCode(101);
        response1.setResult(resultType1);

        SyncResultType resultType2 = new SyncResultType();
        resultType2.setCode(100);
        response2.setResult(resultType2);

        SyncResultType resultType3 = new SyncResultType();
        resultType3.setCode(200);
        response3.setResult(resultType3);

        SyncResultType resultType4 = new SyncResultType();
        resultType4.setCode(400);
        response4.setResult(resultType4);

        SyncResultType resultType5 = new SyncResultType();
        resultType5.setCode(0);
        response5.setResult(resultType5);
    }

    @Test
    public void isFilesTransferredTest100() throws Exception {
        boolean result = Whitebox.invokeMethod(new EventRegistration(), "isFilesTransferred", response2);
        assertEquals(true, result);
    }

    @Test
    public void isFilesTransferredTest101() throws Exception {
        boolean result = Whitebox.invokeMethod(new EventRegistration(), "isFilesTransferred", response1);
        assertEquals(false, result);
    }

    @Test
    public void isFilesTransferredTest200() throws Exception {
        boolean result = Whitebox.invokeMethod(new EventRegistration(), "isFilesTransferred", response3);
        assertEquals(true, result);
    }

    @Test
    public void isFilesTransferredTest400() throws Exception {
        boolean result = Whitebox.invokeMethod(new EventRegistration(), "isFilesTransferred", response4);
        assertEquals(false, result);
    }

    @Test
    public void isFilesTransferredTest500() throws Exception {
        boolean result = Whitebox.invokeMethod(new EventRegistration(), "isFilesTransferred", response5);
        assertEquals(true, result);
    }

}
