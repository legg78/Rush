package ru.bpc.sv2.scheduler.process;

import java.io.BufferedReader;

import java.io.IOException;
import java.io.InputStreamReader;

import org.apache.log4j.Logger;

import ru.bpc.sv2.process.btrt.NodeItem;
import ru.bpc.sv2.scheduler.process.external.btrt.BTRTReader;
import ru.bpc.sv2.utils.SystemException;

public class BTRTFileLoader extends AbstractFileSaver {

	private static final Logger logger = Logger.getLogger("PROCESSES");
	
	@Override
	public void save() throws Exception {
		setupTracelevel();
		String btrtSource = retriveBTRTSource();
		BTRTReader reader = new BTRTReader(btrtSource);
		NodeItem btrtTree = reader.read();
		
	}

	private String retriveBTRTSource() throws SystemException{
		BufferedReader bf = new BufferedReader(new InputStreamReader(inputStream));
		String line = null;
		StringBuilder sb = new StringBuilder();
		try {
			while ((line = bf.readLine()) != null){
				sb.append(line);
			}
		} catch (IOException e){
			logger.error(e);
			throw new SystemException(e);
		} finally {
			if (bf != null) try {bf.close();} catch (Exception e) {}
		}
		return sb.toString();
	}

}
