package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.codec.binary.Hex;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.ps.jcb.JcbAddendum;
import ru.bpc.sv2.ps.jcb.JcbFile;
import ru.bpc.sv2.ps.jcb.JcbFinMessage;


import java.util.*;

/**
 * Session Bean implementation class VisaDao
 */
@SuppressWarnings("unchecked")
public class JcbDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("PROCESSES");


	public List<LinkedHashMap> getFinMessages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<LinkedHashMap>>() {
			@Override
			public List<LinkedHashMap> doInSession(SqlMapSession ssn) throws Exception {
				List<LinkedHashMap> list = ssn.queryForList("jcb.get-fin-messages", convertQueryParams(params));
				for (LinkedHashMap map : list) {
					boolean keep = false;
					for (Iterator i = map.keySet().iterator(); i.hasNext(); ) {
						Object key = i.next();
						if (key.toString().equalsIgnoreCase("MTI")) {
							keep = true;
						} else if (key.toString().equalsIgnoreCase("LANG")) {
							keep = false;
						}
						if (!keep) {
							i.remove();
						} else {
							Object val = map.get(key);
							if (val instanceof byte[]) {
								map.put(key, new String(Hex.encodeHex((byte[]) val)));
							}
						}
					}
				}
				return list;
			}
		});
	}


	public void registerFile(final Long userSessionId, final Long sessionFileId, final boolean incoming, final Integer networkId, final Integer instId, final boolean rejected) {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Object>() {
			@Override
			public Object doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> params = new HashMap<String, Object>();
				params.put("session_file_id", sessionFileId);
				params.put("is_incoming", incoming ? 1 : 0);
				params.put("network_id", networkId);
				params.put("inst_id", instId);
				params.put("file_date", new java.sql.Timestamp(new Date().getTime()));
				params.put("is_rejected", rejected ? 1 : 0);
				ssn.update("jcb.register-file", params);
				return null;
			}
		});
	}


	public JcbFinMessage[] getJcbFinMessages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<JcbFinMessage[]>() {
			@Override
			public JcbFinMessage[] doInSession(SqlMapSession ssn) throws Exception {
				List<JcbFinMessage> items = ssn.queryForList("jcb.get-jcb-fin-messages", convertQueryParams(params));
				return items.toArray(new JcbFinMessage[items.size()] );
			}
		});
	}


	public int getJcbFinMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("jcb.get-jcb-fin-messages-count", convertQueryParams(params));
			}
		});
	}


	public JcbAddendum[] getJcbAddendums(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<JcbAddendum[]>() {
			@Override
			public JcbAddendum[] doInSession(SqlMapSession ssn) throws Exception {
				List<JcbAddendum>items = ssn.queryForList("jcb.get-jcb-addendums", convertQueryParams(params));
				return items.toArray(new JcbAddendum[items.size()]);
			}
		});
	}


	public int getJcbAddendumsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("jcb.get-jcb-addendums-count", convertQueryParams(params));
			}
		});
	}


	public JcbFile[] getJcbFiles( Long userSessionId, final SelectionParams params ) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<JcbFile[]>() {
			@Override
			public JcbFile[] doInSession(SqlMapSession ssn) throws Exception {
				List<JcbFile> items = ssn.queryForList("jcb.get-jcb-files", convertQueryParams(params));
				return items.toArray(new JcbFile[items.size()]);
			}
		});
	}


	public int getJcbFilesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("jcb.get-jcb-files-count", convertQueryParams(params));
			}
		});
	}


	public JcbFinMessage[] getJcbFileFinMessages( Long userSessionId, final SelectionParams params ) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<JcbFinMessage[]>() {
			@Override
			public JcbFinMessage[] doInSession(SqlMapSession ssn) throws Exception {
				List<JcbFinMessage> items = ssn.queryForList("jcb.get-jcb-file-fin-messages", convertQueryParams(params));
				return items.toArray(new JcbFinMessage[items.size()] );
			}
		});
	}


	public int getJcbFileFinMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("jcb.get-jcb-file-fin-messages-count", convertQueryParams(params));
			}
		});
	}
}
