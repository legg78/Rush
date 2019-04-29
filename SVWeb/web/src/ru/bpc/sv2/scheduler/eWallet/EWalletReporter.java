package ru.bpc.sv2.scheduler.eWallet;

import org.apache.commons.lang3.StringUtils;
import org.apache.log4j.Logger;
import ru.bpc.sv.ws.ewallet.EWalletClient;
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
import java.util.ArrayList;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.List;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class EWalletReporter {
    private static final long MIN_POLL_INTERVAL_MILLIS = 10000;;
    private static final Logger logger = Logger.getLogger("EWALLET_SYNC");
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

    private static final String GET_ACCOUNTS_QUERY = "select a.id as account_id" +
            ", a.account_number " +
            "from acc_account_object ao" +
            ", acc_account a " +
            "where ao.entity_type = 'ENTTCARD' " +
            "and ao.object_id = ? " +
            "and a.id = ao.account_id";

    private static final String UPDATE_EVENT_QUERY = "update itf_data_transmission_vw set is_sent = 1 where id = ?";

    private class Runner implements Runnable {

        public Runner() {
            super();
        }

        @Override
        public void run() {
            while (isActive() && !Thread.currentThread().isInterrupted()) {
                Connection c = null;
                EWalletClient wsClient = null;
                try {
                    Thread.sleep(MIN_POLL_INTERVAL_MILLIS);
                    if (isEWalletSyncEnabled()) {
                        c = JndiUtils.getConnection();
                        List<EWalletReporter.DataTuple> tuples = getEvents(c);
                        if (!tuples.isEmpty()) {
                            wsClient = new EWalletClient(getEWalletWsUrl());
                        }
                        for (EWalletReporter.DataTuple tuple : tuples) {
                            try {
                                if (logger.isDebugEnabled()) {
                                    logger.debug("Processing customer number [" + tuple.getCustomerNumber() + "]");
                                }
                                processCards(c, tuple);
                                if (logger.isDebugEnabled()) {
                                    logger.debug("Found a total of [" + tuple.getLinks().size() + "] cards");
                                }
                                for (int i = 0; i < tuple.getCardIds().size(); i++) {
                                    if (logger.isDebugEnabled()) {
                                        logger.debug("Processing card ID [" + tuple.getCardIds().get(i) + "]");
                                    }
                                    tuple.getLinks().get(i).getAccountNumber().addAll(getAccounts(c, tuple.getCardIds().get(i)));
                                    if (logger.isDebugEnabled()) {
                                        logger.debug("Found a total of [" + tuple.getLinks().get(i).getAccountNumber().size() + "] accounts linked to this card");
                                    }
                                }
                                SendCardAccountLinksResponse scalr = wsClient.sendCardAccountLinks(tuple.toLinksInfo());
                                if (scalr != null) {
                                    logger.info("eWallet reporter thread: data transmitted, response received [" + scalr.getResponseCode() + "]");
                                }
                                updateEvent(c, tuple.getEventId());
                            }
                            catch (Exception e) {
                                logger.error("", e);
                            }
                        }
                    }
                }
                catch (Exception e) {
                    logger.error("", e);
                }
                finally {
                    DBUtils.close(c);
                }
            }
        }
    }

    public EWalletReporter() {
        super();
        reporterThread = new Thread(new Runner(), "eWallet-reporter-thread");
    }

    public boolean isActive() {
        return active;
    }

    public void start() {
        if (isActive()) {
            logger.warn("eWallet reporter thread is already started");
        }
        else {
            active = true;
            reporterThread.start();
            logger.info("eWallet reporter thread started");
        }
    }

    public void stop() {
        if (isActive()) {
            active = false;
            try {
                reporterThread.join();
                logger.info("eWallet reporter thread stopped");
            }
            catch (InterruptedException ie) {
                logger.error(ie);
            }
        }
        else {
            logger.warn("eWallet reporter thread is already stopped");
        }
    }

    private boolean isEWalletSyncEnabled() {
        try {
            return (BigDecimal.ONE.equals(SettingsCache.getInstance().getParameterNumberValue(SettingsConstants.ENABLE_EWALLET_SYNC)));
        } catch (Exception e) {
            logger.error(e.getMessage(), e);
            return false;
        }
    }

    private String getEWalletWsUrl() throws IllegalArgumentException {
        String s = SettingsCache.getInstance().getParameterStringValue(SettingsConstants.EWALLET_SVAPINT_WS_URL);
        if (StringUtils.isNotEmpty(s)) {
            return (s);
        }
        else {
            throw new IllegalArgumentException("eWallet integration webservice URL parameter is not set");
        }
    }

    private class DataTuple {
        private final String eventId;
        private final String customerNumber;
        private final List<LinkInfo> links;
        private final List<String> cardIds;

        public DataTuple(String eventId, String customerNumber) {
            super();
            this.eventId = eventId;
            this.customerNumber = customerNumber;
            this.links = new ArrayList<LinkInfo>(10);
            this.cardIds = new ArrayList<String>(10);
        }

        public String getEventId() {
            return eventId;
        }

        public String getCustomerNumber() {
            return customerNumber;
        }

        public List<LinkInfo> getLinks() {
            return links;
        }

        public List<String> getCardIds() {
            return cardIds;
        }

        public LinksInfo toLinksInfo() {
            return (new LinksInfo() {{
                setCustomerId(getCustomerNumber());
                getLinkInfo().addAll(getLinks());
            }});
        }
    }

    private List<EWalletReporter.DataTuple> getEvents(Connection c) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<EWalletReporter.DataTuple> tuples = new ArrayList<EWalletReporter.DataTuple>(10);
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

    private void processCards(Connection c, final DataTuple tuple) throws SQLException, DatatypeConfigurationException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        DatatypeFactory df = DatatypeFactory.newInstance();
        try {
            ps = c.prepareStatement(GET_CARDS_QUERY);
            ps.setString(1, tuple.customerNumber);
            rs = ps.executeQuery();
            while (rs.next()) {
                LinkInfo li = new LinkInfo();
                li.setCardNumber(rs.getString("card_number"));
                li.setCardIssueDate(toXMLGregorianCalendar(df, rs.getDate("iss_date")));
                li.setCardExpirationDate(toXMLGregorianCalendar(df, rs.getDate("expir_date")));
                tuple.getCardIds().add(rs.getString("card_id"));
                tuple.getLinks().add(li);
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

    private List<String> getAccounts(Connection c, String cardId) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<String> output = new ArrayList<String>(10);
        try {
            ps = c.prepareStatement(GET_ACCOUNTS_QUERY);
            ps.setString(1, cardId);
            rs = ps.executeQuery();
            while (rs.next()) {
                output.add(rs.getString("account_number"));
            }
            return (output);
        }
        finally {
            DBUtils.close(rs);
            DBUtils.close(ps);
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
