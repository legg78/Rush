package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.Config;
import com.bpcbt.sv.camel.converters.mapping.BlockAddressingString;
import com.bpcbt.sv.camel.converters.mapping.ByteAddressingStringStreamReader;
import com.bpcbt.sv.camel.converters.transform.TransformUtils;
import com.bpcbt.sv.camel.converters.transform.model.TransformationMap;
import oracle.jdbc.OracleTypes;
import org.xml.sax.InputSource;
import ru.bpc.sv2.scheduler.process.AbstractFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.UserException;

import javax.xml.bind.JAXBContext;
import javax.xml.bind.JAXBElement;
import javax.xml.bind.Unmarshaller;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.math.BigDecimal;
import java.nio.charset.Charset;
import java.sql.CallableStatement;
import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.Future;

@SuppressWarnings("unused")
public class LoadSvfeCardStatusesSaver extends AbstractFileSaver {
    private static final String CREF_DIRECTORY = "cref";

    protected TransformationMap transformationMap;
    protected Map<String, Map<String, String>> referencesMap;

    @Override
    public void save() throws Exception {
        setupTracelevel();
        CallableStatement cstmt = con.prepareCall("{ call com_ui_user_env_pkg.set_user_context( " +
                                                          "  i_user_name   => ?" +
                                                          ", io_session_id => ?" +
                                                          ", i_ip_address  => ?)}");
        cstmt.setString(1, userName);
        cstmt.setObject(2, sessionId, OracleTypes.BIGINT);
        cstmt.setObject(3, null, OracleTypes.VARCHAR);
        cstmt.registerOutParameter(2, OracleTypes.BIGINT);
        cstmt.executeUpdate();
        cstmt.close();

        RegisterCardStatusesJdbc registerCS = new RegisterCardStatusesJdbc(params, con);
        SettingsCache settingParamsCache = SettingsCache.getInstance();
        BigDecimal threadsNumberParam = settingParamsCache.getParameterNumberValue(SettingsConstants.PARALLEL_DEGREE);
        Integer THREAD_NUMBER = (process.getParallelDegree() != null) ? process.getParallelDegree() :
                                (threadsNumberParam != null ? threadsNumberParam.intValue() : 1);

        AbstractFeUnloadFileSaver.setupConverterConfigPath(getFileAttributes());
        Charset inputCharset = Config.getFrontEndCharset();
        ByteAddressingStringStreamReader isr;
        BlockAddressingString line = null;

        SvfeCrefParser[] svfeCrefParser = new SvfeCrefParser[THREAD_NUMBER];
        Future[] futures = new Future[THREAD_NUMBER];
        ExecutorService pool = Executors.newCachedThreadPool();

        initTransformationMap();
        for(int i = 0; i < THREAD_NUMBER; i++) {
            svfeCrefParser[i] = new SvfeCrefParser();
            svfeCrefParser[i].setTransformationMap(transformationMap);
            svfeCrefParser[i].setReferencesMap(referencesMap);
        }

        isr = new ByteAddressingStringStreamReader(inputStream, inputCharset);
        Integer lineNo = 0;
        Integer currThread = 0;
        boolean interrupt = false;
        Exception exception = null;
        try {
            while ((line = isr.readLine()) != null && !interrupt) {
                lineNo ++;
                if(currThread >= THREAD_NUMBER){
                    currThread = 0;
                    interrupt = false;
                    for (int i = 0; i < THREAD_NUMBER; i++) {
                        if (interrupt && !futures[i].isDone()) {
                            futures[i].cancel(true);
                            if (futures[i].isCancelled()) {
                                debug("Process stopped. Thread " + i);
                            }
                            continue;
                        }
                        Object result = futures[i].get();
                        if (result instanceof Exception) {
                            if (process.isInterruptThreads()) {
                                interrupt = true;
                            }
                            exception = (Exception) result;
                            error("Error in line:" + (lineNo - THREAD_NUMBER + i));
                        } else {
                            registerCS.insert((List<String>) result);
                        }
                    }
                }

                svfeCrefParser[currThread].setLine(line);
                futures[currThread] = pool.submit(svfeCrefParser[currThread]);
                currThread++;
            }
            debug("Processed " + lineNo + " lines");

            if (currThread > 0) {
                for (int i = 0; i < currThread; i++) {
                    if (interrupt && !futures[i].isDone()) {
                        futures[i].cancel(true);
                        if (futures[i].isCancelled()) {
                            debug("Process stopped. Thread " + i);
                        }
                        continue;
                    }
                    Object result = futures[i].get();
                    if (result instanceof Exception) {
                        if (process.isInterruptThreads()) {
                            interrupt = true;
                        }
                        exception = (Exception) result;
                        error("Error in line:" + (lineNo - currThread + i));
                    } else {
                        registerCS.insert((List<String>) result);
                    }
                }
            }
            if (interrupt) {
                throw exception;
            } else if (exception != null) {
                error(exception);
                loggerDB.error(exception);
            }
            registerCS.setSessionFileId(fileAttributes);
            registerCS.flush();
        }catch (Exception e) {
	        String errorMessage = String.format("%s -> ERROR parsing line %d: %s", e.getMessage(), lineNo, line);
	        error(errorMessage);
	        throw new UserException(errorMessage, e);
        } finally {
            try {
                isr.close();
            } catch (IOException ioe) {}
        }
    }

    public TransformationMap initTransformationMap() {
        if (transformationMap == null) {
            try {
                JAXBContext jaxbContext = JAXBContext.newInstance("com.bpcbt.sv.camel.converters.transform.model");
                Unmarshaller unmarshaller = jaxbContext.createUnmarshaller();
                InputStream is = getFileInputStream(CREF_DIRECTORY + "/" + "cref_upload_mapping.xml", false);
                JAXBElement<TransformationMap> mapElement = (JAXBElement<TransformationMap>) unmarshaller.unmarshal(is);
                transformationMap = mapElement.getValue();
                referencesMap = createReferencesMap(transformationMap.getReferencesProps());
            } catch (Exception e) {
                error(e);
            }
        }
        return transformationMap;
    }

    private Map<String, Map<String, String>> createReferencesMap(String propertiesFile) {
        HashMap<String, Map<String, String>> map = new HashMap<String, Map<String, String>>();
        if (propertiesFile != null && !propertiesFile.isEmpty()) {
            try {
                Properties properties = new Properties();
                properties.load(getFileInputStream(propertiesFile, isFullPaths()));
                Enumeration keys = properties.propertyNames();
                if (keys != null) {
                    while (keys.hasMoreElements()) {
                        String refName = (String) keys.nextElement();
                        String refFile = properties.getProperty(refName);
                        info("Mapping field:  " + refName + " = " + refFile);
                        Map<String, String> refMap = TransformUtils.parse(new InputSource(getFileInputStream(refFile, isFullPaths())));
                        if (refMap == null) {
                            refMap = new HashMap<String, String>(0);
                        }
                        map.put(refName, refMap);
                    }
                }
            } catch (Exception e) {
                error(e);
            }
        }
        return map;
    }

    private Boolean isFullPaths() {
        return transformationMap != null && (transformationMap.getIsFullPaths() == null || transformationMap.getIsFullPaths());
    }

    private InputStream getFileInputStream(String configFile, boolean isFullPath) throws FileNotFoundException {
        if (isFullPath) {
            return new FileInputStream(configFile);
        }else {
            return Config.getInputSteam(Config.getConfigPath() + configFile);
        }
    }
}
