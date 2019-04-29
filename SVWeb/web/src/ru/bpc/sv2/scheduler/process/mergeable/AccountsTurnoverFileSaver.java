package ru.bpc.sv2.scheduler.process.mergeable;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.codec.binary.Hex;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.tuple.MutablePair;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.commons.vfs.FileObject;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;
import ru.bpc.sv2.process.ProcessBO;
import ru.bpc.sv2.process.ProcessFileAttribute;
import ru.bpc.sv2.scheduler.process.converter.FileConverter;
import ru.bpc.sv2.scheduler.process.mergeable.MergeableFileSaver;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.trace.TraceLogInfo;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.CloseableArrayBlockingQueue;
import ru.bpc.sv2.utils.CloseableBlockingQueue;
import ru.bpc.sv2.utils.SystemException;

import javax.xml.bind.DatatypeConverter;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

public class AccountsTurnoverFileSaver extends PostFileSaver {
    @Override
    protected String getOriginalTrailer() {
        return "</clearing>";
    }
    @Override
    protected String getOriginalHeader() {
        return "<operation";
    }
    @Override
    protected String getConvertedTrailer() {
        return "</clearing>";
    }
    @Override
    protected String getConvertedHeader() {
        return "<operation";
    }
    @Override
    protected String convert(String raw) throws Exception {
        return raw;
    }
    @Override
    public void save() throws Exception {
        super.save(true);
    }
}
