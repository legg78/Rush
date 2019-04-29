package ru.bpc.sv2.scheduler.process.svng;

import com.bpcbt.sv.camel.converters.StreamLoader;

import java.io.InputStream;

/**
 * Created by Gasanov on 24.08.2016.
 */
public class ResourceStreamLoader implements StreamLoader {
    @Override
    public InputStream getStream(String s) {
        return getClass().getClassLoader().getResourceAsStream(s);
    }
}
