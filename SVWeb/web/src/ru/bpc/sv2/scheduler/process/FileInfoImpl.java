package ru.bpc.sv2.scheduler.process;

import java.net.URI;
import java.nio.charset.Charset;
import java.nio.charset.IllegalCharsetNameException;

/**
 * Created by Gasanov on 17.03.2016.
 */
public class FileInfoImpl implements ExecutionContext.FileInfo {
    private URI path;
    private Charset charset;
    private String charsetName;

    public FileInfoImpl() {
    }

    public FileInfoImpl(URI path, String charset) {
        this.path = path;
        if (charset == null)
            throw new IllegalCharsetNameException("Charset is null");

        this.charset = Charset.forName(charset);
        this.charsetName = this.charset.name();
    }

    @Override
    public URI getPath() {
        return path;
    }

    public void setPath(URI path) {
        this.path = path;
    }

    @Override
    public Charset getCharset() {
        return charset;
    }

    public void setCharset(Charset charset) {
        this.charset = charset;
    }

    @Override
    public String getCharsetName() {
        return charsetName;
    }

    public void setCharsetName(String charsetName) {
        this.charsetName = charsetName;
    }
}
