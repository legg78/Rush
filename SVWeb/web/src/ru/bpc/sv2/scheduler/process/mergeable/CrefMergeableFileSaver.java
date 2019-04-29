package ru.bpc.sv2.scheduler.process.mergeable;

import com.bpcbt.sv.camel.converters.CrefConverter;
import com.bpcbt.sv.camel.converters.StreamConverter;
import ru.bpc.sv2.scheduler.process.mergeable.BTLVMergeableFileSaver;

public class CrefMergeableFileSaver extends BTLVMergeableFileSaver {
    @Override
    protected StreamConverter getStreamConverter() {
        return new CrefConverter();
    }
    @Override
    protected String getOriginalTrailer() {
        return "</cards_info>";
    }
    @Override
    protected String getOriginalHeader() {
        return "<card_info";
    }
    @Override
    protected String getConvertedTrailer() {
        return "FF46";
    }
    @Override
    protected String getConvertedHeader() {
        return "\n";
    }
}
