package ru.bpc.sv2.utils;

import javax.xml.bind.annotation.adapters.XmlAdapter;

public class BooleanAdapter extends XmlAdapter<Integer, Boolean>
{
    @Override
    public Boolean unmarshal( Integer s )
    {
        return s == null ? false : s == 1;
    }

    @Override
    public Integer marshal( Boolean c )
    {
        return c == null ? 0 : c ? 1 : 0;
    }
}
