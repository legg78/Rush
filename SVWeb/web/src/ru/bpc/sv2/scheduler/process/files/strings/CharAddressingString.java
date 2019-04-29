package ru.bpc.sv2.scheduler.process.files.strings;

import org.apache.commons.lang3.StringUtils;
import java.nio.charset.Charset;

public class CharAddressingString extends BlockAddressingString {
    private final String target;
    private final Charset charset;

    CharAddressingString(byte[] target, Charset charset) {
        this.target = new String(target, charset);
        this.charset = charset;
    }

    CharAddressingString(String target, Charset charset) {
        this.target = target;
        this.charset = charset;
    }

    @Override
    public BlockAddressingString substringChars(int beginIndex) {
        return new CharAddressingString(target.substring(beginIndex), charset);
    }

    @Override
    public BlockAddressingString substringChars(int beginIndex, int endIndex) {
        return new CharAddressingString(target.substring(beginIndex, endIndex), charset);
    }

    @Override
    public BlockAddressingString substringBlocks(int beginIndexInBlocks, int endIndexInBlocks) {
        return substringChars(beginIndexInBlocks, endIndexInBlocks);
    }

    @Override
    public BlockAddressingString substringBlocks(int beginIndexInBlocks) {
        return substringChars(beginIndexInBlocks);
    }

    @Override
    public boolean startsWith(String prefix) {
        return target.startsWith(prefix);
    }

    @Override
    public int getLengthInBlocks() {
        return target.length();
    }

    @Override
    public boolean hasText() {
        return !StringUtils.isBlank(target);
    }

    @Override
    public boolean hasNoText() {
        return !hasText();
    }

    @Override
    public CharAddressingString trim() {
        return new CharAddressingString(target.trim(), charset);
    }

    @Override
    public String getTarget() {
        return target;
    }

    @Override
    public CharAddressingString concat(String str) {
        return new CharAddressingString(target + str, charset);
    }

    @Override
    public Charset getCharset() {
        return charset;
    }

    @Override
    public boolean isEmpty() {
        return getTarget() == null || getTarget().isEmpty();
    }

    @Override
    public String toString() {
        return target;
    }

    @Override
    public boolean equals(Object obj) {
        boolean result = super.equals(obj);
        if (!result && obj instanceof String) {
            return getTarget().equals(obj);
        }
        return result;
    }
}

