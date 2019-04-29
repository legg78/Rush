package ru.bpc.sv2.scheduler.cbs;

import org.apache.commons.lang3.tuple.ImmutablePair;
import org.apache.commons.lang3.tuple.Pair;
import org.apache.log4j.Logger;
import ru.bpc.sv.ws.cbs.WsClient;
import ru.bpc.sv2.logic.utility.JndiUtils;
import ru.bpc.sv2.settings.constants.SettingsConstants;
import ru.bpc.sv2.ui.utils.cache.SettingsCache;
import ru.bpc.sv2.utils.DBUtils;
import ru.bpc.svap.LinkInfo;
import ru.bpc.svap.LinksInfo;
import ru.bpc.svap.integration.SendCardAccountLinksResponse;

import javax.xml.datatype.DatatypeConfigurationException;
import javax.xml.datatype.DatatypeFactory;
import javax.xml.datatype.XMLGregorianCalendar;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

/**
 * BPC Group 2018 (c) All Rights Reserved
 */
public class MultiCbsReporter {
	private static final long MIN_POLL_INTERVAL_MILLIS = 10000;
	private static final Logger logger = Logger.getLogger("CBS_SYNC");
	private final Thread reporterThread;
	private boolean active;

	private static final String GET_EVENTS_QUERY = "select t.id data_id, d.element_value customer_number from app_ui_data_vw d, itf_data_transmission_vw t " +
			"where t.object_id = d.appl_id and t.is_sent = 0 and name = 'CUSTOMER_NUMBER' and rownum < 11 order by t.id";

	private static final String GET_CARDS_QUERY = "select /*+ ordered use_nl(pcu pco ic icn ici) */" +
			"  ic.id as card_id" +
			", iss_api_token_pkg.decode_card_number(icn.card_number) as card_number" +
			", ici.iss_date" +
			", ici.expir_date " +
			"from prd_customer pcu" +
			", prd_contract pco" +
			", iss_card ic" +
			", iss_card_number icn" +
			", (select ci.card_id" +
			"       , ci.iss_date" +
			"       , ci.expir_date" +
			"       , row_number() over(partition by ci.card_id order by ci.seq_number desc) as rng" +
			"    from iss_card_instance ci" +
			" ) ici " +
			"where pcu.customer_number = ? " +
			"and pco.customer_id = pcu.id " +
			"and ic.contract_id = pco.id " +
			"and icn.card_id = ic.id " +
			"and ici.card_id = ic.id " +
			"and ici.rng = 1";

	private static final String GET_LINKED_ACCOUNTS_QUERY = "select a.id as account_id" +
			", a.account_number " +
			", a.inst_id " +
			", a.account_type " +
			"from acc_account_object ao" +
			", acc_account a " +
			"where ao.entity_type = 'ENTTCARD' " +
			"and ao.object_id = ? " +
			"and a.id = ao.account_id";

	private static final String UPDATE_EVENT_QUERY = "update itf_data_transmission_vw set is_sent = 1 where id = ?";

	private static final String GET_HOSTS_AND_DEVICES_QUERY = "select a.id device_id, " +
			"n.host_member_id " +
			"from cmn_device a, " +
			"cmn_standard b, " +
			"cmn_standard_object os, " +
			"net_device n " +
			"where a.id = os.object_id " +
			"and os.entity_type = 'ENTTCMDV' " +
			"and os.standard_type in ('STDT0001', 'STDT0002') " +
			"and os.standard_id = b.id " +
			"and a.is_enabled = 1 " +
			"and b.id = 1057 " +
			"and a.communication_plugin = 'CMPLWSRV' " +
			"and n.device_id = a.id";

	private static final String GET_DESTINATION_URLS_QUERY = "select v.param_value " +
			"from cmn_parameter p, " +
			"cmn_parameter_value v " +
			"where p.name = 'LINKAGE_REPORTER_URL' " +
			"and p.standard_id = 1057 " +
			"and v.param_id = p.id " +
			"and v.entity_type = 'ENTTCMDV' " +
			"and v.object_id = ?";

	private static final String GET_INSTS_AND_IFACES_QUERY = "select m.inst_id, i.id " +
			"from net_interface i, " +
			"net_member m " +
			"where i.host_member_id = ? " +
			"and i.consumer_member_id = m.id";

	private static final String GET_ACCOUNT_TYPES_ARRAYS_IDS_QUERY = "select v.param_value " +
			"from cmn_parameter p, " +
			"cmn_parameter_value v " +
			"where p.name = 'LINKAGE_REPORTER_TYPES' " +
			"and p.standard_id = 1057 " +
			"and v.param_id = p.id " +
			"and v.entity_type = 'ENTTNIFC' " +
			"and v.object_id = ?";

	private static final String GET_ACCOUNT_TYPES_QUERY = "select element_char_value " +
			"from COM_UI_ARRAY_ELEMENT_VW " +
			"where array_id = ? " +
			"and lang = 'LANGENG'";

	private static final String GET_ALL_ACCOUNTS_QUERY = "select a.id as account_id " +
			", a.account_number " +
			", a.inst_id " +
			", a.account_type " +
			"from acc_account a " +
			", prd_customer c " +
			"where a.customer_id = c.id " +
			"and a.split_hash = c.split_hash " +
			"and c.customer_number = ?";

	private class Runner implements Runnable {

		public Runner() {
			super();
		}

		@Override
		public void run() {
			while (isActive() && !Thread.currentThread().isInterrupted()) {
				Connection c = null;
				Router router = null;
				try {
					Thread.sleep(MIN_POLL_INTERVAL_MILLIS);
					if (isMultiCbsSyncEnabled()) {
						c = JndiUtils.getConnection();
						List<DataTuple> tuples = new DataProvider().getData(c);
						if (!tuples.isEmpty()) {
							router = new Router().configure(c);
						}
						for (DataTuple tuple : tuples) {
							try {
								router.send(tuple);
								updateEvent(c, tuple.getEventId());
							}
							catch (Exception e) {
								logger.error(e);
							}
						}
					}
				}
				catch (Exception e) {
					logger.error(e);
				}
				finally {
					DBUtils.close(c);
				}
			}
		}
	}

	public MultiCbsReporter() {
		super();
		reporterThread = new Thread(new Runner(), "MultiCBS-reporter-thread");
	}

	public boolean isActive() {
		return active;
	}

	public void start() {
		if (isActive()) {
			logger.warn("MultiCBS reporter thread is already started");
		}
		else {
			active = true;
			reporterThread.start();
			logger.info("MultiCBS reporter thread started");
		}
	}

	public void stop() {
		if (isActive()) {
			active = false;
			try {
				reporterThread.join();
				logger.info("MultiCBS reporter thread stopped");
			}
			catch (InterruptedException ie) {
				logger.error(ie);
			}
		}
		else {
			logger.warn("MultiCBS reporter thread is already stopped");
		}
	}

	private boolean isMultiCbsSyncEnabled() {
		try {
			return (BigDecimal.ONE.equals(SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.ENABLE_LINKAGE_REPORTING))
					&& BigDecimal.ONE.equals(SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.ENABLE_MULTI_CBS_SYNC)));
		}
		catch (Exception e) {
			logger.error(e.getMessage(), e);
			return false;
		}
	}

	private class Account {
		private final Long accountId;
		private final String accountNumber;
		private final Long instId;
		private final String accountType;

		public Account(Long accountId, String accountNumber, Long instId, String accountType) {
			super();
			this.accountId = accountId;
			this.accountNumber = accountNumber;
			this.instId = instId;
			this.accountType = accountType;
		}

		public Long getAccountId() {
			return accountId;
		}

		public String getAccountNumber() {
			return accountNumber;
		}

		public Long getInstId() {
			return instId;
		}

		public String getAccountType() {
			return accountType;
		}
	}

	private class Card {
		private final String cardNumber;
		private final String cardId;
		private final XMLGregorianCalendar cardIssueDate;
		private final XMLGregorianCalendar cardExpirationDate;
		private final List<Account> accounts;

		public Card(String cardNumber, String cardId, XMLGregorianCalendar cardIssueDate, XMLGregorianCalendar cardExpirationDate) {
			super();
			this.cardNumber = cardNumber;
			this.cardId = cardId;
			this.cardIssueDate = cardIssueDate;
			this.cardExpirationDate = cardExpirationDate;
			this.accounts = new ArrayList<>(10);
		}

		public String getCardNumber() {
			return cardNumber;
		}

		public XMLGregorianCalendar getCardIssueDate() {
			return cardIssueDate;
		}

		public XMLGregorianCalendar getCardExpirationDate() {
			return cardExpirationDate;
		}

		public List<Account> getAccounts() {
			return accounts;
		}

		public String getCardId() {
			return cardId;
		}
	}

	private class DataTuple {
		private final String eventId;
		private final String customerNumber;
		private final List<Card> cards;
		private final List<Account> accounts;

		public DataTuple(String eventId, String customerNumber) {
			super();
			this.eventId = eventId;
			this.customerNumber = customerNumber;
			this.cards = new ArrayList<>(10);
			this.accounts = new ArrayList<>(10);
		}

		public String getEventId() {
			return eventId;
		}

		public String getCustomerNumber() {
			return customerNumber;
		}

		public List<Card> getCards() {
			return cards;
		}

		public List<Account> getAccounts() {
			return accounts;
		}
	}

	private class Destination {
		private final Long deviceId;
		private final Long hostId;
		private final List<ImmutablePair<Long, Long>> instsIfaces;
		private final List<ImmutablePair<Long, Long>> instsArrays;
		private final Map<Long, List<String>> instsAccountTypes;

		private String url;
		private WsClient wsClient;

		public Destination(Long deviceId, Long hostId) {
			super();
			this.deviceId = deviceId;
			this.hostId = hostId;
			this.instsIfaces = new ArrayList<>(10);
			this.instsArrays = new ArrayList<>(10);
			this.instsAccountTypes = new HashMap<>(10);
		}

		public Long getDeviceId() {
			return deviceId;
		}

		public Long getHostId() {
			return hostId;
		}

		public String getUrl() {
			return url;
		}

		public void setUrl(String url) {
			this.url = url;
		}

		public List<ImmutablePair<Long, Long>> getInstsIfaces() {
			return instsIfaces;
		}

		public List<ImmutablePair<Long, Long>> getInstsArrays() {
			return instsArrays;
		}

		public Map<Long, List<String>> getInstsAccountTypes() {
			return instsAccountTypes;
		}

		public WsClient getWsClient() {
			return wsClient;
		}

		public void setWsClient(WsClient wsClient) {
			this.wsClient = wsClient;
		}

		public String toString() {
			StringBuilder sb = new StringBuilder("[Card-account linkage reporting destination: deviceId=" + getDeviceId() + ", hostId=" + getHostId() + ", URL=" + getUrl() + ", institutions:");
			for (Long instId : instsAccountTypes.keySet()) {
				sb.append(" id=" + instId + " account types: [");
				for (String s : instsAccountTypes.get(instId)) {
					sb.append(s + ",");
				}
				sb.append("]");
			}
			return (sb.toString());
		}
	}

	private class DataProvider {

		public DataProvider() {
			super();
		}

		public List<DataTuple> getData(Connection c) throws SQLException, DatatypeConfigurationException {
			List<DataTuple> tuples = getEvents(c);
			for (DataTuple tuple : tuples) {
				if (logger.isDebugEnabled()) {
					logger.debug("Processing customer number [" + tuple.getCustomerNumber() + "]");
				}
				processCards(c, tuple);
				if (logger.isDebugEnabled()) {
					logger.debug("Found a total of [" + tuple.getCards().size() + "] cards");
				}
				processCustomerAccounts(c, tuple);
				if (logger.isDebugEnabled()) {
					logger.debug("Found a total of [" + tuple.getAccounts().size() + "] customer accounts");
				}
				for (Card card : tuple.getCards()) {
					if (logger.isDebugEnabled()) {
						logger.debug("Processing card ID [" + card.getCardId() + "]");
					}
					processLinkedAccounts(c, card);
					if (logger.isDebugEnabled()) {
						logger.debug("Found a total of [" + card.getAccounts().size() + "] accounts linked to this card");
					}
				}
			}
			return (tuples);
		}

		private List<DataTuple> getEvents(Connection c) throws SQLException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			List<DataTuple> tuples = new ArrayList<>(30);
			try {
				ps = c.prepareStatement(GET_EVENTS_QUERY);
				rs = ps.executeQuery();
				while (rs.next()) {
					tuples.add(new DataTuple(rs.getString("data_id"), rs.getString("customer_number")));
				}
				return (tuples);
			}
			finally {
				DBUtils.close(rs);
				DBUtils.close(ps);
			}
		}

		private void processCards(Connection c, DataTuple tuple) throws SQLException, DatatypeConfigurationException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			DatatypeFactory df = DatatypeFactory.newInstance();
			try {
				ps = c.prepareStatement(GET_CARDS_QUERY);
				ps.setString(1, tuple.getCustomerNumber());
				rs = ps.executeQuery();
				while (rs.next()) {
					tuple.getCards().add(new Card(rs.getString("card_number"),
							rs.getString("card_id"),
							toXMLGregorianCalendar(df, rs.getDate("iss_date")),
							toXMLGregorianCalendar(df, rs.getDate("expir_date"))));
				}
			}
			finally {
				DBUtils.close(rs);
				DBUtils.close(ps);
			}
		}

		private XMLGregorianCalendar toXMLGregorianCalendar(DatatypeFactory df, java.sql.Date d) {
			if (d == null) {
				return (null);
			}
			else {
				Date date = new Date(d.getTime());
				GregorianCalendar gregorianCalendar = new GregorianCalendar();
				gregorianCalendar.setTime(date);
				return (df.newXMLGregorianCalendar(gregorianCalendar));
			}
		}

		private void processCustomerAccounts(Connection c, DataTuple tuple) throws SQLException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			try {
				ps = c.prepareStatement(GET_ALL_ACCOUNTS_QUERY);
				ps.setString(1, tuple.getCustomerNumber());
				rs = ps.executeQuery();
				while (rs.next()) {
					tuple.getAccounts().add(new Account(rs.getLong("account_id"),
							rs.getString("account_number"),
							rs.getLong("inst_id"),
							rs.getString("account_type")));
				}
			}
			finally {
				DBUtils.close(rs);
				DBUtils.close(ps);
			}
		}

		private void processLinkedAccounts(Connection c, Card card) throws SQLException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			try {
				ps = c.prepareStatement(GET_LINKED_ACCOUNTS_QUERY);
				ps.setString(1, card.getCardId());
				rs = ps.executeQuery();
				while (rs.next()) {
					card.getAccounts().add(new Account(rs.getLong("account_id"),
							rs.getString("account_number"),
							rs.getLong("inst_id"),
							rs.getString("account_type")));
				}
			}
			finally {
				DBUtils.close(rs);
				DBUtils.close(ps);
			}
		}
	}

	private class Router {

		private final Map<String, List<Destination>> routes;

		public Router() {
			super();
			this.routes = new HashMap<>(10);
		}

		public Router configure(Connection c) throws SQLException {
			List<Destination> destinations = getAccountTypes(
					getInstsAndArrays(
							getInstsAndIfaces(
									getDestinationUrls(
											getHostsAndDevices(new ArrayList<Destination>(10), c),
											c),
									c),
							c),
					c);
			for (Destination d : destinations) {
				d.setWsClient(new WsClient(d.getUrl()));
				if (logger.isDebugEnabled()) {
					logger.debug(d.toString());
				}
				for (Long instId : d.getInstsAccountTypes().keySet()) {
					for (String accountType : d.getInstsAccountTypes().get(instId)) {
						List<Destination> l = getRoutes().get(instId.toString() + accountType);
						if (l == null) {
							l = new ArrayList<>(10);
							getRoutes().put(instId.toString() + accountType, l);
						}
						l.add(d);
					}
				}
			}
			return (this);
		}

		public Map<String, List<Destination>> getRoutes() {
			return routes;
		}

		public void send(final DataTuple tuple) throws Exception {

			/* Select all required destinations for all existing accounts of this customer */
			Set<Destination> destinations = new HashSet<>(10);
			for (Account a : tuple.getAccounts()) {
				List<Destination> list = getRoutes().get(a.getInstId().toString() + a.getAccountType());
				if (list == null) {
					logger.warn("No destination is defined for institution ID [" + a.getInstId() + "] account type [" + a.getAccountType() + "], ignoring");
				}
				else {
					destinations.addAll(list);
				}
			}

			/* Initialize outgoing data for each destination */
			Map<Destination, LinksInfo> map = new HashMap<>(10);
			for (Destination d : destinations) {
				LinksInfo linksInfo = new LinksInfo() {{
					setCustomerId(tuple.getCustomerNumber());
					for (int i = 0; i < tuple.getCards().size(); i++) {
						LinkInfo li = new LinkInfo();
						li.setCardNumber(tuple.getCards().get(i).getCardNumber());
						li.setCardExpirationDate(tuple.getCards().get(i).getCardExpirationDate());
						li.setCardIssueDate(tuple.getCards().get(i).getCardIssueDate());
						getLinkInfo().add(li);
					}
				}};
				map.put(d, linksInfo);
			}

			/* Fill appropriate linked accounts for each destination */
			for (int i = 0; i < tuple.getCards().size(); i++) {
				for (Account a : tuple.getCards().get(i).getAccounts()) {
					List<Destination> list = getRoutes().get(a.getInstId().toString() + a.getAccountType());
					if (list == null) {
						logger.warn("No destination is defined for institution ID [" + a.getInstId() + "] account type [" + a.getAccountType() + "], ignoring");
					}
					else {
						for (Destination d : list) {
							map.get(d).getLinkInfo().get(i).getAccountNumber().add(a.getAccountNumber());
						}
					}
				}
			}

			for (Destination d : map.keySet()) {
				logger.info("MultiCBS reporter thread: sending to destintation URL [" + d.getUrl() + "]");
				SendCardAccountLinksResponse scalr = d.getWsClient().sendCardAccountLinks(map.get(d));
				if (scalr != null) {
					logger.info("MultiCBS reporter thread: data transmitted, response received [" + scalr.getResponseCode() + "]");
				}
			}
		}

		private List<Destination> getHostsAndDevices(List<Destination> destinations, Connection c) throws SQLException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			try {
				ps = c.prepareStatement(GET_HOSTS_AND_DEVICES_QUERY);
				rs = ps.executeQuery();
				while (rs.next()) {
					destinations.add(new Destination(rs.getLong("device_id"), rs.getLong("host_member_id")));
				}
				return (destinations);
			}
			finally {
				DBUtils.close(rs);
				DBUtils.close(ps);
			}
		}

		private List<Destination> getDestinationUrls(List<Destination> destinations, Connection c) throws SQLException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			for (Destination d : destinations) {
				try {
					ps = c.prepareStatement(GET_DESTINATION_URLS_QUERY);
					ps.setLong(1, d.getDeviceId());
					rs = ps.executeQuery();
					while (rs.next()) {
						d.setUrl(rs.getString("param_value"));
					}
				}
				finally {
					DBUtils.close(rs);
					DBUtils.close(ps);
				}
			}
			return (destinations);
		}

		private List<Destination> getInstsAndIfaces(List<Destination> destinations, Connection c) throws SQLException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			for (Destination d : destinations) {
				try {
					ps = c.prepareStatement(GET_INSTS_AND_IFACES_QUERY);
					ps.setLong(1, d.getHostId());
					rs = ps.executeQuery();
					while (rs.next()) {
						d.getInstsIfaces().add(new ImmutablePair<>(rs.getLong("inst_id"), rs.getLong("id")));
					}
				}
				finally {
					DBUtils.close(rs);
					DBUtils.close(ps);
				}
			}
			return (destinations);
		}

		private List<Destination> getInstsAndArrays(List<Destination> destinations, Connection c) throws SQLException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			for (Destination d : destinations) {
				for (Pair<Long, Long> p : d.getInstsIfaces()) {
					try {
						ps = c.prepareStatement(GET_ACCOUNT_TYPES_ARRAYS_IDS_QUERY);
						ps.setLong(1, p.getRight());
						rs = ps.executeQuery();
						while (rs.next()) {
							d.getInstsArrays().add(new ImmutablePair<>(p.getLeft(), rs.getLong("param_value")));
						}
					}
					finally {
						DBUtils.close(rs);
						DBUtils.close(ps);
					}
				}
			}
			return (destinations);
		}

		private List<Destination> getAccountTypes(List<Destination> destinations, Connection c) throws SQLException {
			PreparedStatement ps = null;
			ResultSet rs = null;
			for (Destination d : destinations) {
				for (Pair<Long, Long> p : d.getInstsArrays()) {
					try {
						ps = c.prepareStatement(GET_ACCOUNT_TYPES_QUERY);
						ps.setLong(1, p.getRight());
						rs = ps.executeQuery();
						List<String> list = new ArrayList<>(10);
						while (rs.next()) {
							list.add(rs.getString("element_char_value"));
						}
						d.getInstsAccountTypes().put(p.getLeft(), list);
					}
					finally {
						DBUtils.close(rs);
						DBUtils.close(ps);
					}
				}
			}
			return (destinations);
		}
	}

	private void updateEvent(Connection c, String eventId) throws SQLException {
		PreparedStatement ps = null;
		try {
			ps = c.prepareStatement(UPDATE_EVENT_QUERY);
			ps.setString(1, eventId);
			ps.executeUpdate();
		}
		finally {
			DBUtils.close(ps);
		}
	}

}
