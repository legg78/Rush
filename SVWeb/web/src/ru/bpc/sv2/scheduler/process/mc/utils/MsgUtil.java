package ru.bpc.sv2.scheduler.process.mc.utils;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.nio.charset.Charset;
import java.util.ArrayList;
import java.util.List;

import ru.bpc.sv2.scheduler.process.mc.entity.MCFieldsConfig;

public class MsgUtil {
	
	public static byte[] readByteArray(InputStream strm, int readLength, OutputStream baus)
		    throws IOException
	{
		byte[] readBytes = new byte[readLength];
		int alreadyRead = 0;
		int lastRead = 0;
		if (readLength > 0) {
			while (true)
			{
				lastRead = strm.read(readBytes, alreadyRead, readLength - alreadyRead);
				alreadyRead += lastRead;

				if (alreadyRead == readLength)
				{
					break;
				}
				else if (lastRead == -1)
				{
					throw new IOException("Unexpected EOF while reading " + readLength + " bytes from stream");
				}

				try
				{
					Thread.sleep(10);
				} catch (InterruptedException e)
				{
				}
			}
		}
		baus.write(readBytes);
		return readBytes;
	}
	
	public static byte [] getType(InputStream is, MCFieldsConfig fields, OutputStream baus) throws IOException{
		byte [] b = readByteArray(is, fields.getEncodeSpec().getEncodedLength(4), baus);
		String messageType = new String(b, fields.getEncodeSpec().getCharset());
		return b;
	}
	
	public static byte[] readBitMask(InputStream strm, OutputStream baus) throws IOException
	{
		byte[] nextBitMask = null;
		List<byte[]> bitMasks = new ArrayList<byte[]>();

		do
		{
			nextBitMask = readByteArray(strm, 8, baus);
			bitMasks.add(nextBitMask);
		} while ((nextBitMask[0] & 128) == 128); //128 = 1000 0000

		return weldArrays(bitMasks.toArray(new byte[bitMasks.size()][8]));
	}
	
	public static byte[] weldArrays(byte[][] arrays)
	{
		int cumulativeLength = 0;
		int arraysCount = arrays.length;
		for (int i = 0; i < arraysCount; i++)
		{
			if (arrays[i] != null)
			{
				cumulativeLength += arrays[i].length;
			}
		}

		byte[] weldedArray = new byte[cumulativeLength];

		int lastPos = 0;
		for (int i = 0; i < arraysCount; i++)
		{
			if (arrays[i] != null)
			{
				int weldingArrayLength = arrays[i].length;
				System.arraycopy(arrays[i], 0, weldedArray, lastPos, weldingArrayLength);
				lastPos += weldingArrayLength;
			}
		}

		return weldedArray;
	}
	
	public static int[] decodeFullBitmask(byte[] msg)
		    throws Exception
	{
		int maskLength = msg.length / 8;
		int[][] splittedBlocks = new int[maskLength][8];
		for (int i = 0; i < maskLength; i++)
		{
			splittedBlocks[i] = decodeBitMask(msg, i * 8, i);
		}

		return weldArrays(splittedBlocks);
	}
	
	public static int[] decodeBitMask(byte[] bitMask, int offset, int maskPow)
	{
		int indexesOffset = maskPow * 64;
		int step = 1; // ignore first bit in bitmaskBlock since it is a control bit
		              // and doesn't affect fields decoding process directly
		List<Integer> blocks = new ArrayList<Integer>();
		while ((step < 64))
		{
			if (((bitMask[(step / 8) + offset] << (step % 8)) & 128) == 128) //128 = 1000 0000
			{
				blocks.add(Integer.valueOf(step + indexesOffset + 1)); //+1 since field numbers start from 1
			}
			step++;
		}

		return integerListToIntArray(blocks);
	}
	
	public static int[] weldArrays(int[][] arrays)
	{
		int cumulativeLength = 0;
		int arraysCount = arrays.length;
		for (int i = 0; i < arraysCount; i++)
		{
			if (arrays[i] != null)
			{
				cumulativeLength += arrays[i].length;
			}
		}

		int[] weldedArray = new int[cumulativeLength];

		int lastPos = 0;
		for (int i = 0; i < arraysCount; i++)
		{
			if (arrays[i] != null)
			{
				int weldingArrayLength = arrays[i].length;
				System.arraycopy(arrays[i], 0, weldedArray, lastPos, weldingArrayLength);
				lastPos += weldingArrayLength;
			}
		}

		return weldedArray;
	}
	
	private static int[] integerListToIntArray(List<Integer> listOfIntegers)
	{
		int listLen = listOfIntegers.size();
		int[] intArray = new int[listLen];
		for (int i = 0; i < listLen; i++)
		{
			intArray[i] = (listOfIntegers.get(i)).intValue();
		}

		return intArray;
	}
	
	public static byte[] readByteArrayWithLength(InputStream strm, int lengthBlockSize, EncodingSpec lenEncSpec,
            EncodingSpec fieldEncSpec, OutputStream baus) throws Exception
	{
		byte[] blockLengthField = readByteArray(strm, lenEncSpec.getEncodedLength(lengthBlockSize), baus);
		int blockLength = decodeBlockLength(blockLengthField, lenEncSpec.getEncodedLength(lengthBlockSize),
		lenEncSpec.getCharset());
		
		byte[] data = readByteArray(strm, fieldEncSpec.getEncodedLength(blockLength), baus);
		return data;
	}
	
	public static int decodeBlockLength(byte[] msg, int segmentLength, Charset charset) throws Exception {
		return decodeBlockLength(msg, segmentLength, 0, charset);
	}
	
	public static int decodeBlockLength(byte[] msg, int segmentLength, int offset, Charset charset) throws Exception {
		String unparsedNum = new String(msg, offset, segmentLength, charset);
		try
		{
			return Integer.parseInt(unparsedNum);
		} catch (NumberFormatException nfe)
		{
			throw new Exception("Cannot parse \"" + unparsedNum + "\" string as integer", nfe);
		}
	}


}
