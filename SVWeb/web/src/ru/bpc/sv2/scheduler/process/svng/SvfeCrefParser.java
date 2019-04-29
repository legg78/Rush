package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.mapping.BlockAddressingString;
import com.bpcbt.sv.camel.converters.mapping.file.CardsMapper;
import com.bpcbt.sv.camel.converters.transform.model.TransformationMap;
import org.apache.log4j.Logger;
import org.dom4j.Node;
import ru.bpc.sv2.svng.CardStatus;
import ru.bpc.sv2.svng.CardStatusGenerate;

import javax.xml.transform.OutputKeys;
import javax.xml.transform.Transformer;
import javax.xml.transform.TransformerFactory;
import javax.xml.transform.dom.DOMSource;
import javax.xml.transform.stream.StreamResult;
import java.io.StringWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.concurrent.Callable;

public class SvfeCrefParser implements Callable<List<String>> {
    private static final Logger logger = Logger.getLogger("PROCESSES");

    private TransformationMap transformationMap;
    protected Map<String, Map<String, String>> referencesMap;
    private CardsMapper cm;
    private BlockAddressingString line;

    public SvfeCrefParser(){
        cm = new CardsMapper(null, false);
    }

    @Override
    public List<String> call() throws Exception {
        List<String> cards = new ArrayList<String>();
        cm.setTransformationMap(transformationMap);
        cm.setReferencesMap(referencesMap);
        List<Node> elements = cm.parse(line);
        if (elements != null ) {
            for (Node element : elements) {
                cards.add(element.asXML());
            }
        }
        return cards;
    }

    public void setTransformationMap(TransformationMap transformationMap) {
        this.transformationMap = transformationMap;
    }

    public void setReferencesMap(Map<String, Map<String, String>> referencesMap) {
        this.referencesMap = referencesMap;
    }

    public void setLine(BlockAddressingString line) {
        this.line = line;
    }
}
