package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.AbstractXmlStreamConverter;
import com.bpcbt.sv.camel.converters.CompaniesConverter;

@SuppressWarnings("unused")
public class CompaniesFEUnloadFileSaver extends AbstractFeUnloadFileSaver {
    @Override
    protected AbstractXmlStreamConverter createStreamConverter() {
        return new CompaniesConverter();
    }
}
