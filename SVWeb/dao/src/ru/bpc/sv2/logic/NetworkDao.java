package ru.bpc.sv2.logic;

import com.ibatis.sqlmap.client.SqlMapSession;
import ru.bpc.sv2.common.CommonParamRec;
import ru.bpc.sv2.invocation.Filter;
import ru.bpc.sv2.invocation.SelectionParams;
import ru.bpc.sv2.logic.controller.CommonController;
import ru.bpc.sv2.logic.utility.db.IbatisAware;
import ru.bpc.sv2.net.*;
import ru.bpc.sv2.utils.AuditParamUtil;

import ru.bpc.sv2.logic.utility.db.DataAccessException;

import java.sql.SQLException;
import java.util.List;

/**
 * Session Bean implementation class NetworkDao
 */
public class NetworkDao extends IbatisAware {

	private static final String user = "ADMIN";

	@SuppressWarnings("unchecked")
	public BinRange[] getBinRanges(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_BIN_RANGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_BIN_RANGE);
			List<BinRange> bins = ssn.queryForList("net.get-bin-ranges", convertQueryParams(params, limitation));
			return bins.toArray(new BinRange[bins.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getBinRangesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_BIN_RANGE, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_BIN_RANGE);
			return (Integer) ssn.queryForObject("net.get-bin-ranges-count",
					convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Network[] getNetworks(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_NETWORK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_NETWORK);
			List<Network> nets = ssn.queryForList("net.get-networks", convertQueryParams(params, limitation));
			return nets.toArray(new Network[nets.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getNetworksCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_NETWORK, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_NETWORK);
			return (Integer) ssn.queryForObject("net.get-networks-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Network[] getNetworksForDropdown(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			List<Network> nets = ssn.queryForList("net.get-networks-for-dropdown", convertQueryParams(params));
			return nets.toArray(new Network[nets.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Network addNetwork(Long userSessionId, Network network) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(network.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_NETWORK, paramArr);

			ssn.update("net.add-network", network);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(network.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(network.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Network) ssn.queryForObject("net.get-networks", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Network editNetwork(Long userSessionId, Network network) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(network.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_NETWORK, paramArr);

			ssn.update("net.edit-network", network);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(network.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(network.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Network) ssn.queryForObject("net.get-networks", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNetwork(Long userSessionId, Network network) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(network.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_NETWORK, paramArr);

			ssn.delete("net.delete-network", network);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public NetworkMember[] getNetworkMembers(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, params.getPrivilege() != null ? params.getPrivilege() : NetPrivConstants.VIEW_NETWORK_MEMBER, paramArr);

			List<NetworkMember> members = ssn.queryForList("net.get-network-members", convertQueryParams(params));
			return members.toArray(new NetworkMember[members.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getNetworkMembersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, params.getPrivilege() != null ? params.getPrivilege() : NetPrivConstants.VIEW_NETWORK_MEMBER, paramArr);
			return (Integer) ssn.queryForObject("net.get-network-members-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public NetworkMember[] getHosts(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_NETWORK_MEMBER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_NETWORK_MEMBER);
			List<NetworkMember> members = ssn.queryForList("net.get-hosts", convertQueryParams(params, limitation));
			return members.toArray(new NetworkMember[members.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getHostsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_NETWORK_MEMBER, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_NETWORK_MEMBER);
			return (Integer) ssn.queryForObject("net.get-hosts-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NetworkMember addNetworkMember(Long userSessionId, NetworkMember member) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(member.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_NETWORK_MEMBER_INST, paramArr);

			ssn.update("net.add-network-member", member);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(member.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(member.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NetworkMember) ssn.queryForObject("net.get-network-members", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NetworkMember editNetworkMember(Long userSessionId, NetworkMember member) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(member.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_NETWORK_MEMBER_INST, paramArr);

			ssn.update("net.edit-network-member", member);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(member.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(member.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NetworkMember) ssn.queryForObject("net.get-network-members", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNetworkMember(Long userSessionId, NetworkMember member) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(member.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_NETWORK_MEMBER_INST, paramArr);

			ssn.delete("net.delete-network-member", member);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NetworkMember addHost(Long userSessionId, NetworkMember host) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(host.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_NETWORK_MEMBER_INST, paramArr);

			ssn.update("net.add-host", host);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(host.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(host.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NetworkMember) ssn.queryForObject("net.get-hosts", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NetworkMember editHost(Long userSessionId, NetworkMember host) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(host.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_NETWORK_MEMBER_INST, paramArr);

			ssn.update("net.edit-host", host);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(host.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(host.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NetworkMember) ssn.queryForObject("net.get-hosts", convertQueryParams(params));

		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteHost(Long userSessionId, NetworkMember host) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(host.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_NETWORK_MEMBER_INST, paramArr);

			ssn.delete("net.delete-host", host);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public NetworkMember[] getHostOwners(Long userSessionId, SelectionParams params) {

		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_NETWORK_MEMBER);
			List<NetworkMember> owners = ssn
					.queryForList("net.get-host-owners", convertQueryParams(params, limitation));
			return owners.toArray(new NetworkMember[owners.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public Consumer[] getConsumers(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_NETWORK_INTERFACES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_NETWORK_INTERFACES);
			List<Consumer> consumers = ssn.queryForList("net.get-consumers", convertQueryParams(params, limitation));
			return consumers.toArray(new Consumer[consumers.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getConsumersCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_NETWORK_INTERFACES, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_NETWORK_INTERFACES);
			return (Integer) ssn.queryForObject("net.get-consumers-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Consumer addConsumer(Long userSessionId, Consumer consumer) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(consumer.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_NETWORK_INTERFACE, paramArr);

			ssn.update("net.add-consumer", consumer);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(consumer.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(consumer.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Consumer) ssn.queryForObject("net.get-consumers", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public Consumer editConsumer(Long userSessionId, Consumer consumer) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(consumer.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_NETWORK_INTERFACE, paramArr);

			ssn.update("net.edit-consumer", consumer);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(consumer.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(consumer.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (Consumer) ssn.queryForObject("net.get-consumers", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteConsumer(Long userSessionId, Consumer consumer) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(consumer.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_NETWORK_INTERFACE, paramArr);

			ssn.delete("net.delete-consumer", consumer);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public LocalBinRange[] getLocalBinRanges(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_LOCAL_BIN_RANGE, paramArr);

			List<LocalBinRange> bins = ssn.queryForList("net.get-local-bin-ranges", convertQueryParams(params));
			return bins.toArray(new LocalBinRange[bins.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getLocalBinRangesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_LOCAL_BIN_RANGE, paramArr);
			return (Integer) ssn.queryForObject("net.get-local-bin-ranges-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LocalBinRange addLocalBinRange(Long userSessionId, LocalBinRange binRange) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(binRange.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_LOCAL_BIN_RANGE, paramArr);

			ssn.update("net.add-local-bin-range", binRange);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(binRange.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(binRange.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (LocalBinRange) ssn.queryForObject("net.get-local-bin-ranges", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public LocalBinRange editLocalBinRange(Long userSessionId, LocalBinRange binRange) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(binRange.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_LOCAL_BIN_RANGE, paramArr);

			ssn.update("net.edit-local-bin-range", binRange);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(binRange.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(binRange.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (LocalBinRange) ssn.queryForObject("net.get-local-bin-ranges", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteLocalBinRange(Long userSessionId, LocalBinRange binRange) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(binRange.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_LOCAL_BIN_RANGE, paramArr);

			ssn.delete("net.delete-local-bin-range", binRange);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CardType[] getCardTypes(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_CARD_TYPE, paramArr);

			List<CardType> cards = ssn.queryForList("net.get-card-types-hier", convertQueryParams(params));
			return cards.toArray(new CardType[cards.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CardType[] getCardTypesList(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_CARD_TYPE, paramArr);

			List<CardType> cards = ssn.queryForList("net.get-card-types", convertQueryParams(params));
			return cards.toArray(new CardType[cards.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CardType addCardType(Long userSessionId, CardType cardType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_CARD_TYPE, paramArr);

			ssn.update("net.add-card-type", cardType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cardType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(cardType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CardType) ssn.queryForObject("net.get-card-types", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CardType modifyCardType(Long userSessionId, CardType cardType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_CARD_TYPE, paramArr);

			ssn.update("net.modify-card-type", cardType);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cardType.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(cardType.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CardType) ssn.queryForObject("net.get-card-types", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCardType(Long userSessionId, CardType cardType) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardType.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_CARD_TYPE, paramArr);

			ssn.delete("net.remove-card-type", cardType);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CardTypeMap[] getCardTypeMaps(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_CARD_TYPE_MAPPING, paramArr);

			List<CardTypeMap> cards = ssn.queryForList("net.get-card-types-map", convertQueryParams(params));
			return cards.toArray(new CardTypeMap[cards.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCardTypeMapsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_CARD_TYPE_MAPPING, paramArr);
			return (Integer) ssn.queryForObject("net.get-card-types-map-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CardTypeMap addCardTypeMap(Long userSessionId, CardTypeMap cardTypeMap, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardTypeMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_CARD_TYPE_MAPPING, paramArr);

			ssn.update("net.add-card-type-map", cardTypeMap);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cardTypeMap.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CardTypeMap) ssn.queryForObject("net.get-card-types-map", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CardTypeMap modifyCardTypeMap(Long userSessionId, CardTypeMap cardTypeMap, String lang) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardTypeMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_CARD_TYPE_MAPPING, paramArr);
			ssn.update("net.modify-card-type-map", cardTypeMap);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(cardTypeMap.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(lang);

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CardTypeMap) ssn.queryForObject("net.get-card-types-map", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCardTypeMap(Long userSessionId, CardTypeMap cardTypeMap) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardTypeMap.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_CARD_TYPE_MAPPING, paramArr);

			ssn.delete("net.remove-card-type-map", cardTypeMap);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public NetDevice[] getNetDevices(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_NET_DEVICE, paramArr);

			List<NetDevice> devices = ssn.queryForList("net.get-network-devices", convertQueryParams(params));
			return devices.toArray(new NetDevice[devices.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public int getNetDevicesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_NET_DEVICE, paramArr);
			return (Integer) ssn.queryForObject("net.get-network-devices-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}


	public NetDevice addNetDevice(Long userSessionId, NetDevice device) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_NET_DEVICE, paramArr);

			ssn.update("net.add-device", device);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("deviceId");
			filters[0].setValue(device.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(device.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NetDevice) ssn.queryForObject("net.get-network-devices", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public NetDevice editNetDevice(Long userSessionId, NetDevice device) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_NET_DEVICE, paramArr);

			ssn.update("net.edit-device", device);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(device.getId().toString());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(device.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (NetDevice) ssn.queryForObject("net.get-network-devices", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteNetDevice(Long userSessionId, NetDevice device) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(device.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_NET_DEVICE, paramArr);

			ssn.delete("net.delete-device", device);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public SttlMap[] getSttlMaps(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_SETTLEMENT_MAPPING, paramArr);

			List<SttlMap> maps = ssn.queryForList("net.get-sttl-maps", convertQueryParams(params));
			return maps.toArray(new SttlMap[maps.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getSttlMapsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_SETTLEMENT_MAPPING, paramArr);
			return (Integer) ssn.queryForObject("net.get-sttl-maps-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SttlMap addSttlMap(Long userSessionId, SttlMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_SETTLEMENT_MAPPING, paramArr);

			ssn.update("net.add-sttl-map", map);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(map.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (SttlMap) ssn.queryForObject("net.get-sttl-maps", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public SttlMap editSttlMap(Long userSessionId, SttlMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_SETTLEMENT_MAPPING, paramArr);

			ssn.update("net.edit-sttl-map", map);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(map.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (SttlMap) ssn.queryForObject("net.get-sttl-maps", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteSttlMap(Long userSessionId, SttlMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_SETTLEMENT_MAPPING, paramArr);

			ssn.delete("net.delete-sttl-map", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void synchronizeLocalBein(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionFE(userSessionId);

			ssn.update("net.sync-local-bins");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}

	@SuppressWarnings("unchecked")
	public String[] getInterfaceParameterValues(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, user);
			List<String> values = ssn.queryForList("net.get-interface-parameter", convertQueryParams(params));
			return values.toArray(new String[values.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public String[] getInterfaceParameterValues(SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSessionNoContext();
			List<String> values = ssn.queryForList("net.get-interface-parameter", convertQueryParams(params));
			return values.toArray(new String[values.size()]);
		} catch (SQLException e) {
			throw new DataAccessException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public CardTypeFeature[] getCardTypeFeatures(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_CARD_FEATURE, paramArr);

			List<CardTypeFeature> features = ssn.queryForList("net.get-card-type-feature", convertQueryParams(params));
			return features.toArray(new CardTypeFeature[features.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getCardTypeFeaturesCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_CARD_FEATURE, paramArr);
			return (Integer) ssn.queryForObject("net.get-card-type-feature-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CardTypeFeature addCardTypeFeatures(Long userSessionId, CardTypeFeature cardTypeFeature) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardTypeFeature.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_CARD_FEATURE, paramArr);

			ssn.update("net.add-card-type-feature", cardTypeFeature);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("cardTypeId");
			filters[0].setValue(cardTypeFeature.getCardTypeId().toString());
			/*
			 * filters[1] = new Filter(); filters[1].setElement("lang");
			 * filters[1].setValue(cardTypeFeature.getLang());
			 */

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CardTypeFeature) ssn.queryForObject("net.get-card-type-feature", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public CardTypeFeature editCardTypeFeatures(Long userSessionId, CardTypeFeature cardTypeFeature) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardTypeFeature.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_CARD_FEATURE, paramArr);

			ssn.update("net.modify-card-type-feature", cardTypeFeature);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter();
			filters[0].setElement("cardTypeId");
			filters[0].setValue(cardTypeFeature.getCardTypeId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (CardTypeFeature) ssn.queryForObject("net.get-card-type-feature", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteCardTypeFeatures(Long userSessionId, CardTypeFeature cardTypeFeature) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(cardTypeFeature.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_CARD_FEATURE, paramArr);

			ssn.delete("net.remove-card-type-feature", cardTypeFeature);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}

	@SuppressWarnings("unchecked")
	public HostSubstitution[] getHostSubstitutions(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_HOST_SUBSTITUTION, paramArr);

			List<HostSubstitution> features = ssn
					.queryForList("net.get-host-substitutions", convertQueryParams(params));
			return features.toArray(new HostSubstitution[features.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getHostSubstitutionsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_HOST_SUBSTITUTION, paramArr);
			return (Integer) ssn.queryForObject("net.get-host-substitutions-count", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HostSubstitution addHostSubstitution(Long userSessionId, HostSubstitution hostSubstitution) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(hostSubstitution.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_HOST_SUBSTITUTION, paramArr);

			ssn.update("net.add-host-substitution", hostSubstitution);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(hostSubstitution.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(hostSubstitution.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HostSubstitution) ssn.queryForObject("net.get-host-substitutions", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public HostSubstitution editHostSubstitution(Long userSessionId, HostSubstitution hostSubstitution) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(hostSubstitution.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_HOST_SUBSTITUTION, paramArr);

			ssn.update("net.modify-host-substitution", hostSubstitution);

			Filter[] filters = new Filter[2];
			filters[0] = new Filter();
			filters[0].setElement("id");
			filters[0].setValue(hostSubstitution.getId());
			filters[1] = new Filter();
			filters[1].setElement("lang");
			filters[1].setValue(hostSubstitution.getLang());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (HostSubstitution) ssn.queryForObject("net.get-host-substitutions", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void deleteHostSubstitution(Long userSessionId, HostSubstitution hostSubstitution) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(hostSubstitution.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_HOST_SUBSTITUTION, paramArr);

			ssn.delete("net.remove-host-substitution", hostSubstitution);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}

	}

	@SuppressWarnings("unchecked")
	public OperTypeMap[] getOperTypeMaps(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_OPERATION_TYPE_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_OPERATION_TYPE_MAPPING);
			List<OperTypeMap> maps = ssn.queryForList("net.get-oper-type-maps", convertQueryParams(params, limitation));
			return maps.toArray(new OperTypeMap[maps.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getOperTypeMapsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_OPERATION_TYPE_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_OPERATION_TYPE_MAPPING);
			return (Integer) ssn.queryForObject("net.get-oper-type-maps-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public OperTypeMap addOperTypeMap(Long userSessionId, OperTypeMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_OPERATION_TYPE_MAPPING, paramArr);

			ssn.update("net.add-oper-type-map", map);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter("id", map.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (OperTypeMap) ssn.queryForObject("net.get-oper-type-maps", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public OperTypeMap modifyOperTypeMap(Long userSessionId, OperTypeMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_OPERATION_TYPE_MAPPING, paramArr);

			ssn.update("net.modify-oper-type-map", map);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter("id", map.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (OperTypeMap) ssn.queryForObject("net.get-oper-type-maps", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeOperTypeMap(Long userSessionId, OperTypeMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_OPERATION_TYPE_MAPPING, paramArr);

			ssn.delete("net.remove-oper-type-map", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}

	@SuppressWarnings("unchecked")
	public MsgTypeMap[] getMsgTypeMaps(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_MESSAGE_TYPE_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_MESSAGE_TYPE_MAPPING);
			List<MsgTypeMap> maps = ssn.queryForList("net.get-msg-type-maps", convertQueryParams(params, limitation));
			return maps.toArray(new MsgTypeMap[maps.size()]);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public int getMsgTypeMapsCount(Long userSessionId, SelectionParams params) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(params.getFilters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.VIEW_MESSAGE_TYPE_MAPPING, paramArr);
			String limitation = CommonController.getLimitationByPriv(ssn, NetPrivConstants.VIEW_MESSAGE_TYPE_MAPPING);
			return (Integer) ssn.queryForObject("net.get-msg-type-maps-count", convertQueryParams(params, limitation));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MsgTypeMap addMsgTypeMap(Long userSessionId, MsgTypeMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.ADD_MESSAGE_TYPE_MAPPING, paramArr);

			ssn.update("net.add-msg-type-map", map);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter("id", map.getId());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MsgTypeMap) ssn.queryForObject("net.get-msg-type-maps", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public MsgTypeMap modifyMsgTypeMap(Long userSessionId, MsgTypeMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.MODIFY_MESSAGE_TYPE_MAPPING, paramArr);

			ssn.update("net.modify-msg-type-map", map);

			Filter[] filters = new Filter[1];
			filters[0] = new Filter("id", map.getId().toString());

			SelectionParams params = new SelectionParams();
			params.setFilters(filters);

			return (MsgTypeMap) ssn.queryForObject("net.get-msg-type-maps", convertQueryParams(params));
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void removeMsgTypeMap(Long userSessionId, MsgTypeMap map) {
		SqlMapSession ssn = null;
		try {
			CommonParamRec[] paramArr = AuditParamUtil.getCommonParamRec(map.getAuditParameters());
			ssn = getIbatisSession(userSessionId, null, NetPrivConstants.REMOVE_MESSAGE_TYPE_MAPPING, paramArr);

			ssn.delete("net.remove-msg-type-map", map);
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void loadBinRanges(Long userSessionId, List<? extends BinRange> binRanges, Integer cleanupBinsNetworkId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, null, null);

			if (cleanupBinsNetworkId != null) {
				ssn.update("net.cleanup-network-bins", cleanupBinsNetworkId);
			}

			final int batchSize = 100;
			ssn.startBatch();
			int index = 1;
			for (BinRange binRange : binRanges) {
				ssn.update("net.add-bin-range", binRange);
				if (index++ % batchSize == 0) {
					ssn.executeBatch();
					ssn.startBatch();
				}
			}
			ssn.executeBatch();
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}


	public void rebuildBinIndex(Long userSessionId) {
		SqlMapSession ssn = null;
		try {
			ssn = getIbatisSession(userSessionId, null, null, null);
			ssn.update("net.rebuild-bin-index");
		} catch (SQLException e) {
			throw createDaoException(e);
		} finally {
			close(ssn);
		}
	}
}
