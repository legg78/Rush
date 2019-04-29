package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.AbstractXmlStreamConverter;
import com.bpcbt.sv.camel.converters.PersonsConverter;

@SuppressWarnings("unused")
public class PersonsFEUnloadFileSaver extends AbstractFeUnloadFileSaver {
    @Override
    protected AbstractXmlStreamConverter createStreamConverter() {
        return new PersonsConverter();
    }
}
