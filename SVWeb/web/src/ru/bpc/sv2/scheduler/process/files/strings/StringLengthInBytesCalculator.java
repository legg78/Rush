package ru.bpc.sv2.scheduler.process.files.strings;

import java.nio.ByteBuffer;
import java.nio.CharBuffer;
import java.nio.charset.Charset;
import java.nio.charset.CharsetEncoder;
import java.nio.charset.CoderResult;
import java.util.HashMap;
import java.util.Map;

public abstract class StringLengthInBytesCalculator {
    private static final int BUFFER_SIZE = 100;
    private static ThreadLocal<Map<Charset, CharsetEncoder>> encoderMap = new ThreadLocal<Map<Charset, CharsetEncoder>>() {
        @Override
        protected Map<Charset, CharsetEncoder> initialValue() {
            return new HashMap<Charset, CharsetEncoder>();
        }
    };
    private static ThreadLocal<ByteBuffer> buffer = new ThreadLocal<ByteBuffer>() {
        @Override
        protected ByteBuffer initialValue() {
            return ByteBuffer.allocate(BUFFER_SIZE);
        }
    };

    public static int calcLengthBytes(String str, Charset charset) {
        if (str == null || str.length() == 0) {
            return 0;
        }
        if (isSingleBytePerChar(charset)) {
            return str.length();
        }
        CharsetEncoder encoder = getEncoder(charset);
        CharBuffer charBuf = CharBuffer.wrap(str);
        ByteBuffer byteBuf = buffer.get();
        int result = 0;
        while (true) {
            byteBuf.position(0);
            CoderResult cr = encoder.encode(charBuf, byteBuf, true);
            result += byteBuf.position();
            if (cr.isOverflow()) {
                continue;
            }
            break;
        }
        return result;
    }

    public static boolean isSingleBytePerChar(Charset charset) {
        return getEncoder(charset).maxBytesPerChar() == 1.0f;
    }

    private static CharsetEncoder getEncoder(Charset charset) {
        CharsetEncoder encoder = encoderMap.get().get(charset);
        if (encoder == null) {
            encoder = charset.newEncoder();
            encoderMap.get().put(charset, encoder);
        }
        return encoder;
    }

    private StringLengthInBytesCalculator() {
    }
}
