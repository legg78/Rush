/*
 * SGAModel.java
 * Copyright 2016 BPC Group Banking Technologies
 */
package ru.bpc.sv2.jmx.oracle.model;

import ru.bpc.sv2.jmx.utils.JSON;

import java.io.Serializable;

/**
 * <p>SGAModel class.</p>
 *
 * @author Ilya Yushin
 * @version $Id: 22f8bd359a5b93c4caba0fb9fa3b1d99095afa4b $
 */
public final class SGAModel implements Serializable {
    private static final long serialVersionUID = 84573345781153913L;

    /** Constant <code>NULL</code> */
    public static final SGAModel NULL = createNullModel();

    private final long javaPoolSize, javaPoolFreeSize, largePoolSize, largePoolFreeSize,
        dictionaryCacheSize, libraryCacheSize, sqlAreaSize, sharedPoolSize, sharedPoolFreeSize,
        bufferCacheSize, fixedSgaSize, logBufferSize;

    /**
     * <p>Constructor for SGAModel.</p>
     *
     * @param javaPoolSize a long.
     * @param javaPoolFreeSize a long.
     * @param largePoolSize a long.
     * @param largePoolFreeSize a long.
     * @param dictionaryCacheSize a long.
     * @param libraryCacheSize a long.
     * @param sqlAreaSize a long.
     * @param sharedPoolSize a long.
     * @param sharedPoolFreeSize a long.
     * @param bufferCacheSize a long.
     * @param fixedSgaSize a long.
     * @param logBufferSize a long.
     */
    public SGAModel(long javaPoolSize, long javaPoolFreeSize, long largePoolSize,
        long largePoolFreeSize, long dictionaryCacheSize, long libraryCacheSize, long sqlAreaSize,
        long sharedPoolSize, long sharedPoolFreeSize, long bufferCacheSize, long fixedSgaSize,
        long logBufferSize) {

        this.javaPoolSize = javaPoolSize;
        this.javaPoolFreeSize = javaPoolFreeSize;
        this.largePoolSize = largePoolSize;
        this.largePoolFreeSize = largePoolFreeSize;
        this.dictionaryCacheSize = dictionaryCacheSize;
        this.libraryCacheSize = libraryCacheSize;
        this.sqlAreaSize = sqlAreaSize;
        this.sharedPoolSize = sharedPoolSize;
        this.sharedPoolFreeSize = sharedPoolFreeSize;
        this.bufferCacheSize = bufferCacheSize;
        this.fixedSgaSize = fixedSgaSize;
        this.logBufferSize = logBufferSize;
    }

    private static SGAModel createNullModel() {
        return new SGAModel(-1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L, -1L);
    }

    /**
     * <p>Getter for the field <code>javaPoolSize</code>.</p>
     *
     * @return a long.
     */
    public long getJavaPoolSize() {
        return javaPoolSize;
    }

    /**
     * <p>Getter for the field <code>javaPoolFreeSize</code>.</p>
     *
     * @return a long.
     */
    public long getJavaPoolFreeSize() {
        return javaPoolFreeSize;
    }

    /**
     * <p>Getter for the field <code>largePoolSize</code>.</p>
     *
     * @return a long.
     */
    public long getLargePoolSize() {
        return largePoolSize;
    }

    /**
     * <p>Getter for the field <code>largePoolFreeSize</code>.</p>
     *
     * @return a long.
     */
    public long getLargePoolFreeSize() {
        return largePoolFreeSize;
    }

    /**
     * <p>Getter for the field <code>dictionaryCacheSize</code>.</p>
     *
     * @return a long.
     */
    public long getDictionaryCacheSize() {
        return dictionaryCacheSize;
    }

    /**
     * <p>Getter for the field <code>libraryCacheSize</code>.</p>
     *
     * @return a long.
     */
    public long getLibraryCacheSize() {
        return libraryCacheSize;
    }

    /**
     * <p>Getter for the field <code>sqlAreaSize</code>.</p>
     *
     * @return a long.
     */
    public long getSqlAreaSize() {
        return sqlAreaSize;
    }

    /**
     * <p>Getter for the field <code>sharedPoolSize</code>.</p>
     *
     * @return a long.
     */
    public long getSharedPoolSize() {
        return sharedPoolSize;
    }

    /**
     * <p>Getter for the field <code>sharedPoolFreeSize</code>.</p>
     *
     * @return a long.
     */
    public long getSharedPoolFreeSize() {
        return sharedPoolFreeSize;
    }

    /**
     * <p>Getter for the field <code>bufferCacheSize</code>.</p>
     *
     * @return a long.
     */
    public long getBufferCacheSize() {
        return bufferCacheSize;
    }

    /**
     * <p>Getter for the field <code>fixedSgaSize</code>.</p>
     *
     * @return a long.
     */
    public long getFixedSgaSize() {
        return fixedSgaSize;
    }

    /**
     * <p>Getter for the field <code>logBufferSize</code>.</p>
     *
     * @return a long.
     */
    public long getLogBufferSize() {
        return logBufferSize;
    }

    /** {@inheritDoc} */
    @Override
    public int hashCode() {
        final int prime = 31;
        int result = 1;
        result = prime * result + (int) (bufferCacheSize ^ bufferCacheSize >>> 32);
        result = prime * result + (int) (dictionaryCacheSize ^ dictionaryCacheSize >>> 32);
        result = prime * result + (int) (fixedSgaSize ^ fixedSgaSize >>> 32);
        result = prime * result + (int) (javaPoolSize ^ javaPoolSize >>> 32);
        result = prime * result + (int) (javaPoolFreeSize ^ javaPoolFreeSize >>> 32);
        result = prime * result + (int) (largePoolSize ^ largePoolSize >>> 32);
        result = prime * result + (int) (largePoolFreeSize ^ largePoolFreeSize >>> 32);
        result = prime * result + (int) (libraryCacheSize ^ libraryCacheSize >>> 32);
        result = prime * result + (int) (logBufferSize ^ logBufferSize >>> 32);
        result = prime * result + (int) (sharedPoolFreeSize ^ sharedPoolFreeSize >>> 32);
        result = prime * result + (int) (sharedPoolSize ^ sharedPoolSize >>> 32);
        result = prime * result + (int) (sqlAreaSize ^ sqlAreaSize >>> 32);
        return result;
    }

    /** {@inheritDoc} */
    @Override
    public boolean equals(Object obj) {
        if (this == obj) {
            return true;
        }
        if (obj == null) {
            return false;
        }
        if (getClass() != obj.getClass()) {
            return false;
        }
        final SGAModel other = (SGAModel) obj;
        if (bufferCacheSize != other.bufferCacheSize) {
            return false;
        }
        if (dictionaryCacheSize != other.dictionaryCacheSize) {
            return false;
        }
        if (fixedSgaSize != other.fixedSgaSize) {
            return false;
        }
        if (javaPoolSize != other.javaPoolSize) {
            return false;
        }
        if (javaPoolFreeSize != other.javaPoolFreeSize) {
            return false;
        }
        if (largePoolSize != other.largePoolSize) {
            return false;
        }
        if (largePoolFreeSize != other.largePoolFreeSize) {
            return false;
        }
        if (libraryCacheSize != other.libraryCacheSize) {
            return false;
        }
        if (logBufferSize != other.logBufferSize) {
            return false;
        }
        if (sharedPoolFreeSize != other.sharedPoolFreeSize) {
            return false;
        }
        if (sharedPoolSize != other.sharedPoolSize) {
            return false;
        }
        if (sqlAreaSize != other.sqlAreaSize) {
            return false;
        }
        return true;
    }

    /** {@inheritDoc} */
    @Override
    public String toString() {
        return JSON.toJsonString(this);
    }
}
