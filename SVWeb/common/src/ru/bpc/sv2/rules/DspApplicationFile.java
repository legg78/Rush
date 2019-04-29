package ru.bpc.sv2.rules;

import ru.bpc.sv2.invocation.ModelIdentifiable;
import ru.bpc.sv2.reports.RptDocument;

import java.io.InputStream;
import java.io.Serializable;

/**
 * Created by Gasanov on 19.07.2016.
 */
public class DspApplicationFile implements Serializable, ModelIdentifiable, Cloneable {
    private String type;
    private String name;
    private boolean newFile;
    private String savePath;
    private byte[] bytes;

    public DspApplicationFile() {}
    public DspApplicationFile(RptDocument doc) {
        fromRptDocument(doc);
    }

    public String getType() {
        return type;
    }
    public void setType(String type) {
        this.type = type;
    }

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    public byte[] getBytes() {
        return bytes;
    }
    public void setBytes(byte[] bytes) {
        this.bytes = bytes;
    }

    public boolean isNewFile() {
        return newFile;
    }
    public void setNewFile(boolean newFile) {
        this.newFile = newFile;
    }

    public String getSavePath() {
        return savePath;
    }
    public void setSavePath(String savePath) {
        this.savePath = savePath;
    }

    @Override
    public Object clone() throws CloneNotSupportedException {
        return super.clone();
    }
    @Override
    public Object getModelId() {
        return name + type;
    }

    public void fromRptDocument(RptDocument doc) {
        if (doc != null) {
            type = doc.getDocumentType();
            name = doc.getFileName();
            savePath = doc.getSavePath();
        }
    }
}
