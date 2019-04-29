package ru.bpc.sv2.scheduler.process.files.strings;

import java.nio.charset.Charset;
import java.util.Arrays;

public class ByteAddressingString extends BlockAddressingString {
    private final String target;
    private final boolean singleBytePerChar;
    private final byte[] originalCharsetBytes;
    private final Charset charset;
    private final int lengthInBytes;

    ByteAddressingString( byte[] target, Charset charset ){
        this.target = new String(target, charset);
        this.charset = charset;
        singleBytePerChar = StringLengthInBytesCalculator.isSingleBytePerChar(charset);
        lengthInBytes = target.length;
        originalCharsetBytes = target;
    }
    ByteAddressingString( String target, Charset charset ){
        this.target = target;
        this.charset = charset;
        singleBytePerChar = StringLengthInBytesCalculator.isSingleBytePerChar(charset);
        originalCharsetBytes = singleBytePerChar || target.isEmpty() ? null : target.getBytes(charset);
        lengthInBytes = singleBytePerChar ? target.length() : (originalCharsetBytes == null ? 0 : originalCharsetBytes.length);
    }

    @Override
    public ByteAddressingString substringChars( int beginIndex ){
        return new ByteAddressingString(target.substring(beginIndex), charset);
    }

    @Override
    public ByteAddressingString substringChars( int beginIndex, int endIndex ){
        return new ByteAddressingString(target.substring(beginIndex, endIndex), charset);
    }

    @Override
    public ByteAddressingString substringBlocks( int beginIndexInBytes, int endIndexInBytes ){
        if (singleBytePerChar) {
            return new ByteAddressingString(target.substring(beginIndexInBytes, endIndexInBytes), charset);
        }
        return new ByteAddressingString(new String(originalCharsetBytes, beginIndexInBytes, endIndexInBytes - beginIndexInBytes, charset), charset);
    }

    @Override
    public ByteAddressingString substringBlocks( int beginIndexInBytes ){
        return substringBlocks(beginIndexInBytes, getLengthInBlocks());
    }

    @Override
    public boolean startsWith( String prefix ){
        return getTarget().startsWith(prefix);
    }

    @Override
    public int getLengthInBlocks(){
        return lengthInBytes;
    }

    @Override
    public boolean hasText(){
        if (getLengthInBlocks() != 0) {
            int strLen = getTarget().length();
            for (int i = 0; i < strLen; i++) {
                if (!Character.isWhitespace(getTarget().charAt(i))) {
                    return true;
                }
            }
        }
        return false;
    }

    @Override
    public boolean hasNoText(){
        return !hasText();
    }

    @Override
    public ByteAddressingString trim(){
        if (getLengthInBlocks() == 0) {
            return this;
        }
        String target = getTarget();
        int charLen = target.length();
        int firstNonSpace = 0;
        int lastNonSpace = charLen - 1;
        while (firstNonSpace < charLen && Character.isWhitespace(target.charAt(firstNonSpace))) {
            firstNonSpace++;
        }
        while (lastNonSpace >= firstNonSpace && Character.isWhitespace(target.charAt(lastNonSpace))) {
            lastNonSpace--;
        }
        if (firstNonSpace == 0 && lastNonSpace == charLen - 1) {
            return this;
        }
        return new ByteAddressingString(target.substring(firstNonSpace, lastNonSpace + 1), charset);
    }

    @Override
    public String getTarget(){
        return target;
    }

    @Override
    public ByteAddressingString concat( String str ){
        if (singleBytePerChar) {
            return new ByteAddressingString(target + str, charset);
        }
        byte[] strBytes = str.getBytes(charset);
        byte[] newStr = Arrays.copyOf(originalCharsetBytes, originalCharsetBytes.length + strBytes.length);
        System.arraycopy(strBytes, 0, newStr, originalCharsetBytes.length, strBytes.length);
        return new ByteAddressingString(newStr, charset);
    }

    @Override
    public Charset getCharset(){
        return charset;
    }

    @Override
    public boolean isEmpty(){
        return getTarget() == null || getTarget().isEmpty();
    }

    @Override
    public String toString(){
        return target;
    }

    @Override
    public boolean equals( Object obj ){
        boolean result = super.equals(obj);
        if (!result && obj instanceof String) {
            return getTarget().equals(obj);
        }
        return result;
    }
}
