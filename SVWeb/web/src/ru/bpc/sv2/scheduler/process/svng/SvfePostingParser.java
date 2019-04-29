package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.mapping.BlockAddressingString;
import com.bpcbt.sv.camel.converters.mapping.file.PostingMapper;
import com.bpcbt.sv.camel.converters.transform.model.TransformationMap;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;
import org.dom4j.Node;
import ru.bpc.sv2.svng.AuthDataParser;
import ru.bpc.sv2.svng.ClearingOperation;
import ru.bpc.sv2.svng.ClearingOperationGenerate;

/**
 * Created by Gasanov on 16.08.2016.
 */
public class SvfePostingParser implements Callable<List<ClearingOperation>> {
    private TransformationMap transformationMap;
    protected Map<String, Map<String, String>> referencesMap;
    private PostingMapper pm;
    private BlockAddressingString line;
    private Integer lineNo;
    private AuthDataParser adp = new AuthDataParser();

    public SvfePostingParser(){
        pm = new PostingMapper(null, false);
    }

    @Override
    public List<ClearingOperation> call() throws Exception {
        List<ClearingOperation> operations = new ArrayList<ClearingOperation>();
        pm.setTransformationMap(transformationMap);
        pm.setReferencesMap(referencesMap);
        List<Node> elements = pm.parse(line);
        if (elements != null) {
            for (Node element : elements) {
                ClearingOperation clearingOperation = new ClearingOperation();
                if (ClearingOperationGenerate.generate(element, clearingOperation, new StringBuilder())) {
                    clearingOperation.setOperIdBatch(lineNo.longValue());
                    clearingOperation.setAuthDataObject(adp.parse(clearingOperation.getAuthData(), clearingOperation.getId()));
                    clearingOperation.setAuthData(null);
                    operations.add(clearingOperation);
                }
            }
        }

        return operations;
    }

    public void setTransformationMap(TransformationMap transformationMap) {
        this.transformationMap = transformationMap;
    }

    public void setReferencesMap(Map<String, Map<String, String>> referencesMap) {
        this.referencesMap = referencesMap;
    }

    public void setLine(BlockAddressingString line, Integer lineNo) {
        this.line = line;
        this.lineNo = lineNo;
    }
}
