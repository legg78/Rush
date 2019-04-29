package ru.bpc.sv2.scheduler.process.mc.utils;

import java.nio.charset.Charset;

public class EncodingSpec
{
    private Charset _charset;
    private int _charsPerByte;

    public EncodingSpec( Charset charset, int charsPerByte )
    {
        _charset = charset;
        _charsPerByte = charsPerByte;
    }

    public Charset getCharset()
    {
        return _charset;
    }

    public int getEncodedLength( int decodedLength )
    {
        return (int)Math.ceil( (double)decodedLength / _charsPerByte );
    }

    public int getDencodedLength( int encodedLength )
    {
        return encodedLength * _charsPerByte;
    }
}
