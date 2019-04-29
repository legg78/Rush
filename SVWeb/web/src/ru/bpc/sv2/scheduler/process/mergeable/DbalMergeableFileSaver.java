package ru.bpc.sv2.scheduler.process.mergeable;

import com.bpcbt.sv.camel.converters.DbalConverter;
import com.bpcbt.sv.camel.converters.StreamConverter;
import ru.bpc.sv2.scheduler.process.mergeable.BTLVMergeableFileSaver;

public class DbalMergeableFileSaver extends BTLVMergeableFileSaver {
    @Override
    protected StreamConverter getStreamConverter() {
        return new DbalConverter();
    }
    @Override
    protected String getOriginalTrailer() {
        return "</accounts>";
    }
    @Override
    protected String getOriginalHeader() {
        return "<account ";
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
