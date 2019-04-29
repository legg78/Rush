package ru.bpc.sv.ws.svng;

import com.bpcbt.sv.config.message.v1.*;
import com.bpcbt.sv.config.message.v1.Void;
import com.bpcbt.sv.config.service.v1.*;
import org.apache.cxf.jaxws.JaxWsProxyFactoryBean;

import java.util.List;

public class CamelConfigClient {
	private ConfigPortType client;

	public CamelConfigClient(String url) throws Exception {
		JaxWsProxyFactoryBean factory = new JaxWsProxyFactoryBean();
		factory.setServiceClass(ConfigPortType.class);
		factory.setAddress(url);
		client = (ConfigPortType)factory.create();
	}

	public List<String> getFiles() {
		return client.getFiles(new Void()).getFile();
	}

	public String getConfig(String file) {
		return getConfig(file, false);
	}

	public String getConfig(String file, boolean isAbsPath) {
		Config request = new Config();
		request.setFilename(file);
		request.setEncoding("UTF-8");
		request.setAbsPath(isAbsPath);
		return client.getConfig(request).getConfig().toString();
	}

	public void saveConfig(String file, String config) throws Exception {
		Config request = new Config();
		request.setFilename(file);
		request.setEncoding("UTF-8");
		request.setConfig(config);
		SaveResult result = client.saveConfig(request);
		if (!result.isResult()) {
			throw new Exception(result.getErrorMessage());
		}
	}

	public RemapResult remapConfigs(String configsDir, String configsDirExtIn) throws Exception {
		Remap request = new Remap();
		request.setConfDir(configsDir);
		request.setConfDirExt(configsDirExtIn);
		RemapResult result = client.remapConfigs(request);
		if(!result.getResult().equals("Ok")) {
			throw new Exception(result.getResult());
		}
		return result;
	}
}
