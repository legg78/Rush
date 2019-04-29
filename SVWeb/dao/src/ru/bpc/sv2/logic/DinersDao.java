package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import org.apache.commons.codec.binary.Hex;
import org.apache.log4j.Logger;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.logic.utility.db.IbatisSessionCallback;
import ru.bpc.sv2.ps.diners.*;


import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Timestamp;
import java.util.*;

/**
 * Session Bean implementation class VisaDao
 */
@SuppressWarnings("unchecked")
public class DinersDao extends IbatisAware {
	private static final Logger logger = Logger.getLogger("PROCESSES");


	public void loadDinBinRanges(Long userSessionId, final Long procSessionId, final List<DinBinRange> binRanges, final boolean cleanupNetworkBins) {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Object>() {
			@Override
			public Object doInSession(SqlMapSession ssn) throws Exception {
				Connection con = ssn.getCurrentConnection();
				PreparedStatement ps = con.prepareStatement("select nvl(max(id)+1, 1) from DIN_BIN");
				ResultSet rs = ps.executeQuery();
				rs.next();
				long id = rs.getLong(1);
				ps.close();
				if (cleanupNetworkBins) {
					ps = con.prepareStatement("delete from DIN_BIN");
					ps.executeUpdate();
					ps.close();
				}
				final String sql = "insert into DIN_BIN (id, agent_code, agent_name, bin_length, country, country_code, start_bin, end_bin, session_id) " +
						"values (?,?,?,?,?,?,?,?,?)";
				ps = con.prepareStatement(sql);
				for (DinBinRange binRange : binRanges) {
					ps.setLong(1, id++);
					ps.setString(2, binRange.getAgentCode());
					ps.setString(3, binRange.getAgentName());
					ps.setInt(4, binRange.getPanLength());
					ps.setString(5, binRange.getCountryName());
					ps.setString(6, binRange.getCountry());
					ps.setString(7, binRange.getPanLow());
					ps.setString(8, binRange.getPanHigh());
					ps.setLong(9, procSessionId);
					ps.addBatch();
				}
				ps.executeBatch();
				ps.close();
				return null;
			}
		});
	}


	public List<LinkedHashMap> getFinMessages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<LinkedHashMap>>() {
			@Override
			public List<LinkedHashMap> doInSession(SqlMapSession ssn) throws Exception {
				List<LinkedHashMap> list = ssn.queryForList("diners.get-fin-messages", convertQueryParams(params));
				for (LinkedHashMap map : list) {
					boolean keep = false;
					for (Iterator i = map.keySet().iterator(); i.hasNext(); ) {
						Object key = i.next();
						if (key.toString().equalsIgnoreCase("CURKY")) {
							keep = true;
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


	public int getFinMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("diners.get-fin-messages-count", convertQueryParams(params));
			}
		});
	}


	public void registerFile(final Long userSessionId, final Long sessionFileId, final boolean incoming,
							 final Integer networkId, final Integer instId, final boolean rejected) {
		executeWithSession(userSessionId, logger, new IbatisSessionCallback<Object>() {
			@Override
			public Object doInSession(SqlMapSession ssn) throws Exception {
				Map<String, Object> params = new HashMap<String, Object>();
				params.put("id", sessionFileId);
				params.put("is_incoming", incoming ? 1 : 0);
				params.put("network_id", networkId);
				params.put("inst_id", instId);
				params.put("file_date", new Timestamp(new Date().getTime()));
				params.put("is_rejected", rejected ? 1 : 0);
				ssn.update("diners.register-file", params);
				return null;
			}
		});
	}


	public DinersFinMessage[] getDinFinMessages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<DinersFinMessage[]>() {
			@Override
			public DinersFinMessage[] doInSession(SqlMapSession ssn) throws Exception {
				List<DinersFinMessage> items = ssn.queryForList("diners.get-din-fin-messages", convertQueryParams(params));
				return items.toArray(new DinersFinMessage[items.size()] );
			}
		});
	}


	public int getDinFinMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("diners.get-din-fin-messages-count", convertQueryParams(params));
			}
		});
	}


	public DinersAddendum[] getDinAddendums(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<DinersAddendum[]>() {
			@Override
			public DinersAddendum[] doInSession(SqlMapSession ssn) throws Exception {
				List<DinersAddendum>items = ssn.queryForList( "diners.get-din-addendums", convertQueryParams( params ) );
				return items.toArray(new DinersAddendum[items.size()]);
			}
		});
	}


	public int getDinAddendumsCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("diners.get-din-addendums-count", convertQueryParams(params));
			}
		});
	}


	public List<DinersAddendumField> getDinAddendumFields(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<List<DinersAddendumField>>() {
			@Override
			public List<DinersAddendumField> doInSession(SqlMapSession ssn) throws Exception {
				return ssn.queryForList("diners.get-din-addendum-fields", convertQueryParams(params));
			}
		});
	}


	public DinersFee[] getDinFees(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<DinersFee[]>() {
			@Override
			public DinersFee[] doInSession(SqlMapSession ssn) throws Exception {
				List<DinersFee> items = ssn.queryForList("diners.get-din-fees", convertQueryParams(params));
				return items.toArray(new DinersFee[items.size()]);
			}
		});
	}


	public int getDinFeesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer) ssn.queryForObject("diners.get-din-fees-count", convertQueryParams(params));
			}
		});
	}


	public DinersFile[] getDinFiles(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<DinersFile[]>() {
			@Override
			public DinersFile[] doInSession(SqlMapSession ssn) throws Exception {
				List<DinersFile> items = ssn.queryForList("diners.get-din-files", convertQueryParams(params));
				return items.toArray(new DinersFile[items.size()]);
			}
		});
	}


	public int getDinFilesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("diners.get-din-files-count", convertQueryParams(params));
			}
		});
	}


	public DinersFinMessage[] getDinFileFinMessages(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<DinersFinMessage[]>() {
			@Override
			public DinersFinMessage[] doInSession(SqlMapSession ssn) throws Exception {
				List<DinersFinMessage> items = ssn.queryForList("diners.get-din-file-fin-messages", convertQueryParams(params));
				return items.toArray(new DinersFinMessage[items.size()] );
			}
		});
	}


	public int getDinFileFinMessagesCount(Long userSessionId, final SelectionParams params) {
		return executeWithSession(userSessionId, logger, new IbatisSessionCallback<Integer>() {
			@Override
			public Integer doInSession(SqlMapSession ssn) throws Exception {
				return (Integer)ssn.queryForObject("diners.get-din-file-fin-messages-count", convertQueryParams(params));
			}
		});
	}
}
