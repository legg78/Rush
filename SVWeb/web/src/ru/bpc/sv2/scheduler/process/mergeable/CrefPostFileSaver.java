package ru.bpc.sv2.scheduler.process.mergeable;

import com.bpcbt.sv.camel.converters.CrefConverter;
import com.bpcbt.sv.camel.converters.StreamConverter;

public class CrefPostFileSaver extends CrefMergeableFileSaver {
    @Override
    public void save() throws Exception {
        super.save(false);
    }
}
