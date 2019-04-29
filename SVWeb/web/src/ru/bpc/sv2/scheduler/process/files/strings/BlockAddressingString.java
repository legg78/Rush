package ru.bpc.sv2.scheduler.process.files.strings;

import java.nio.charset.Charset;

public abstract class BlockAddressingString {
    public static BlockAddressingString create(byte[] target, Charset charset) {
        if (target == null) {
            return null;
        }
        return isByteAddressing() ? new ByteAddressingString(target, charset)
                                  : new CharAddressingString(target, charset);
    }
    public static BlockAddressingString create(String target, Charset charset) {
        if (target == null) {
            return null;
        }
        return isByteAddressing() ? new ByteAddressingString(target, charset)
                                  : new CharAddressingString(target, charset);
    }

    public static BlockAddressingString emptyString(Charset charset) {
        return create("", charset);
    }

    public static boolean isByteAddressing() {
        // TODO get parameter from configuration or process parameter
        return false;
    }

    public abstract BlockAddressingString substringChars(int beginIndex);
    public abstract BlockAddressingString substringChars(int beginIndex, int endIndex);

    public abstract BlockAddressingString substringBlocks(int beginIndexInBytes, int endIndexInBytes);
    public abstract BlockAddressingString substringBlocks(int beginIndexInBytes);

    public abstract boolean startsWith(String prefix);

    public abstract int getLengthInBlocks();

    public abstract boolean hasText();

    public abstract boolean hasNoText();

    public abstract BlockAddressingString trim();

    public abstract String getTarget();

    public abstract BlockAddressingString concat(String str);

    public abstract Charset getCharset();

    public abstract boolean isEmpty();
}
