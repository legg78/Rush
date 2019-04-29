package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.XmlUnloadProcess;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.svng.DataTypes;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Types;
import java.util.Calendar;
import java.util.Date;
import java.util.Map;

public class DbalUnloadProcess extends XmlUnloadProcess {
	private boolean fullExport = false;
	private String dateType;
	private Date startDate;
	private Date endDate;
	private String balanceType;
	private boolean unloadLimits;
	private Integer shiftFrom;
	private Integer shiftTo;

	//<editor-fold desc="Incremental query">
	private String incrSql =
			"SELECT f.account_id, f.currency, f.account_currency, f.account_type, f.status, f.account_number, f.balance_type, " +
					"f.balance_id, f.debits_amount, f.credits_amount, f.debits_count, f.credits_count" +
					"                 , nvl(f.incoming_balance, 0) as incoming_balance" +
					"                 , nvl(f.outgoing_balance, 0) as outgoing_balance" +
					"                 , (select " +
					"                        nvl(sum (" +
					"                            case" +
					"                                when f.account_currency = b.currency then t.aval_impact * b.balance" +
					"                                else t.aval_impact * com_api_rate_pkg.convert_amount(b.balance, b.currency, f.account_currency, t.rate_type, f.inst_id, ?)" +
					"                            end" +
					"                        ), 0)                  \n" +
					"                      from acc_balance_type t\n" +
					"                         , acc_balance b\n" +
					"                     where b.split_hash   = f.split_hash  \n" +
					"                       and b.account_id   = f.account_id\n" +
					"                       and t.account_type = f.account_type\n" +
					"                       and t.inst_id      = f.inst_id\n" +
					"                       and t.aval_impact != 0\n" +
					"                       and b.balance_type = t.balance_type\n" +
					"                 ) aval_balance               \n" +
					"                 , f.split_hash\n" +
					"                 , f.inst_id\n" +
					"            from (\n" +
					"                select aa.id as account_id\n" +
					"                     , ab.id as balance_id\n" +
					"                     , ab.balance_type     \n" +
					"                     , ab.currency\n" +
					"                     , aa.currency account_currency\n" +
					"                     , aa.account_type\n" +
					"                     , aa.status\n" +
					"                     , aa.account_number\n" +
					"                     , nvl(sum(case ae.balance_impact when -1 then ae.amount end),0)  debits_amount\n" +
					"                     , nvl(sum(case ae.balance_impact when 1 then ae.amount end), 0) credits_amount\n" +
					"                     , count(case ae.balance_impact when -1 then 1 else null end) debits_count\n" +
					"                     , count(case ae.balance_impact when 1 then 1 else null end) credits_count\n" +
					"                     , min(ae.balance - ae.balance_impact * ae.amount) keep ( dense_rank first order by ae.posting_order asc ) as incoming_balance\n" +
					"                     , min(ae.balance) keep ( dense_rank first order by ae.posting_order desc ) as outgoing_balance\n" +
					"                     , ab.split_hash                                              \n" +
					"                     , aa.inst_id\n" +
					"                  from evt_event_object o\n" +
					"                     , acc_entry ae                     \n" +
					"                     , acc_account aa\n" +
					"                     , acc_balance ab\n" +
					"                 where o.split_hash in (select split_hash from com_api_split_map_vw)\n" +
					"                   and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'\n" +
					"                   and o.eff_date      <= get_sysdate \n" +
					"                   and o.inst_id        = ?\n" +
					"                   and o.split_hash     = ae.split_hash \n" +
					"                   and o.entity_type    = 'ENTTENTR'\n" +
					"                   and o.object_id      = ae.id \n" +
					"                   and o.split_hash     = aa.split_hash     \n" +
					"                   and ae.account_id    = aa.id\n" +
					"                   and o.split_hash     = ab.split_hash\n" +
					"                   and aa.id            = ab.account_id\n" +
					"                   and aa.inst_id       = ?\n" +
					"                   and (ae.status       <> 'ENTRCNCL' or ae.status is null)                        \n" +
					"                   and exists(select 1 from acc_account_object ao where ao.account_id = ae.account_id and ao.entity_type = 'ENTTCARD')\n" +
					"                   and(\n" +
					"                            (? is not null\n" +
					"                            and \n" +
					"                            (? = '%' or ab.balance_type = ?)\n" +
					"                            )\n" +
					"                        or\n" +
					"                            (\n" +
					"                            ? is null\n" +
					"                            and ab.balance_type in (select element_value from com_array_element where array_id = 12)\n" +
					"                            )\n" +
					"                    )\n" +
					"                 group by\n" +
					"                    aa.id, ab.id\n" +
					"                  , ab.balance_type                                                   \n" +
					"                  , ab.currency\n" +
					"                  , aa.currency\n" +
					"                  , aa.account_type\n" +
					"                  , aa.status\n" +
					"                  , aa.account_number\n" +
					"                  , ab.split_hash                                              \n" +
					"                  , aa.inst_id\n" +
					"              ) f\n" +
					"            union             \n" +
					"            select a.id account_id\n" +
					"                 , b.currency\n" +
					"                 , a.currency account_currency\n" +
					"                 , a.account_type\n" +
					"                 , a.status\n" +
					"                 , a.account_number\n" +
					"                 , b.balance_type\n" +
					"                 , b.id balance_id\n" +
					"                 , 0 debits_amount\n" +
					"                 , 0 credits_amount\n" +
					"                 , 0 debits_count\n" +
					"                 , 0 credits_count\n" +
					"                 , 0 incoming_balance\n" +
					"                 , 0 outgoing_balance\n" +
					"                 , (\n" +
					"                    select \n" +
					"                        nvl(sum (\n" +
					"                            case\n" +
					"                                when a.currency = b.currency then t.aval_impact * b.balance\n" +
					"                                else t.aval_impact * com_api_rate_pkg.convert_amount(b.balance, b.currency, a.currency, t.rate_type, a.inst_id, ?)\n" +
					"                            end\n" +
					"                        ), 0)                  \n" +
					"                      from acc_balance_type t\n" +
					"                         , acc_balance b\n" +
					"                     where b.split_hash   = o.split_hash  \n" +
					"                       and b.account_id   = a.id\n" +
					"                       and t.account_type = a.account_type\n" +
					"                       and t.inst_id      = a.inst_id\n" +
					"                       and t.aval_impact != 0\n" +
					"                       and b.balance_type = t.balance_type\n" +
					"                 ) aval_balance               \n" +
					"                 , b.split_hash\n" +
					"                 , a.inst_id\n" +
					"              from evt_event_object o\n" +
					"                 , acc_account a                 \n" +
					"                 , acc_balance b\n" +
					"             where o.split_hash in (select split_hash from com_api_split_map_vw)\n" +
					"               and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'\n" +
					"               and o.eff_date      <= get_sysdate \n" +
					"               and o.inst_id       = ?\n" +
					"               and o.entity_type    = 'ENTTACCT'\n" +
					"               and o.object_id      = a.id\n" +
					"               and o.split_hash     = a.split_hash\n" +
					"               and exists(select 1 from acc_account_object ao where ao.account_id = a.id and ao.entity_type = 'ENTTCARD')                \n" +
					"               and a.id = b.account_id ORDER BY account_id";
	//</editor-fold>

	//<editor-fold desc="Full query">
	private String fullSql = "select\n" +
			"                f.account_id\n" +
			"              , f.currency balance_currency\n" +
			"              , f.account_type\n" +
			"              , f.status\n" +
			"              , f.account_number\n" +
			"              , f.balance_type\n" +
			"              , f.balance_id\n" +
			"              , (\n" +
			"                select \n" +
			"                    nvl(sum (\n" +
			"                        case\n" +
			"                            when f.account_currency = b.currency then t.aval_impact * b.balance\n" +
			"                            else t.aval_impact * com_api_rate_pkg.convert_amount(b.balance, b.currency, f.account_currency, t.rate_type, f.inst_id, ?)\n" +
			"                        end\n" +
			"                    ), 0)                  \n" +
			"                  from acc_balance_type t\n" +
			"                     , acc_balance b\n" +
			"                 where b.split_hash in (select split_hash from com_api_split_map_vw) \n" +
			"                   and b.account_id   = f.account_id\n" +
			"                   and t.account_type = f.account_type\n" +
			"                   and t.inst_id      = f.inst_id\n" +
			"                   and t.aval_impact != 0\n" +
			"                   and b.balance_type = t.balance_type\n" +
			"              ) aval_balance               \n" +
			"              , f.split_hash\n" +
			"              , f.inst_id account_inst_id\n" +
			"              , f.account_currency\n" +
			"			   , f.outgoing_balance" +
			"            from (\n" +
			"                        select\n" +
			"                             ab.id as balance_id\n" +
			"                           , ab.account_id  \n" +
			"                           , ab.split_hash\n" +
			"                           , ab.balance_type  \n" +
			"                           , ab.currency                                                  \n" +
			"                           , a.currency account_currency\n" +
			"                           , a.account_type\n" +
			"                           , a.status\n" +
			"                           , a.account_number \n" +
			"                           , a.inst_id\n" +
			"							, ab.balance outgoing_balance" +
			"                         from\n" +
			"                             acc_balance ab\n" +
			"                           , acc_account a\n" +
			"                           , acc_account_object ao\n" +
			"                         where ab.split_hash in (select split_hash from com_api_split_map_vw) \n" +
			"                           and ab.split_hash = a.split_hash                                \n" +
			"                           and ab.account_id = a.id \n" +
			"                           and ao.account_id = ab.account_id \n" +
			"                           and ao.entity_type= 'ENTTCARD'\n" +
			"                           and ao.split_hash = a.split_hash \n" +
			"                           and (a.inst_id = ? or nvl(?, 9999) = 9999)    \n" +
			"                         and (\n" +
			"                                (? is not null\n" +
			"                                and \n" +
			"                                (? = '%' or ab.balance_type = ?)\n" +
			"                                )\n" +
			"                            or\n" +
			"                                (\n" +
			"                                ? is null\n" +
			"                                and\n" +
			"                                ab.balance_type in (select element_value from com_array_element where array_id = 12)\n" +
			"                                )\n" +
			"                           )                             \n" +
			"                 ) f  \n" +
			"             order by f.account_id";
	//</editor-fold>

	//<editor-fold desc="Limits query">
	private String limitsQuery = "select *\n" +
			"   from (     \n" +
			"      select  \n" +
			"              l.limit_type\n" +
			"            , nvl(l.sum_limit, 0) sum_limit\n" +
			"            , nvl(l.count_limit, 0) count_limit     \n" +
			"            , nvl(fcl_api_limit_pkg.get_limit_sum_curr(l.limit_type, 'ENTTACCT', ?, l.id), 0) sum_current\n" +
			"            , l.currency\n" +
			"            , case when b.next_date > get_sysdate or b.next_date is null then b.next_date\n" +
			"                   else fcl_api_cycle_pkg.calc_next_date(b.cycle_type, r.entity_type, r.object_id, r.split_hash, get_sysdate)\n" +
			"              end  next_date\n" +
			"            , c.length_type\n" +
			"            , c.cycle_length\n" +
			"       from (     \n" +
			"            select\n" +
			"                 distinct a.object_type limit_type\n" +
			"              from prd_attribute a\n" +
			"                 , prd_service_type t \n" +
			"             where t.entity_type     = 'ENTTACCT'\n" +
			"               and a.service_type_id = t.id\n" +
			"               and a.entity_type     = 'ENTTLIMT'\n" +
			"         ) x\n" +
			"         , fcl_limit l\n" +
			"         , fcl_cycle c\n" +
			"         , fcl_limit_counter r\n" +
			"         , fcl_cycle_counter b\n" +
			"     where l.id = prd_api_product_pkg.get_limit_id (\n" +
			"              i_entity_type      => 'ENTTACCT'\n" +
			"            , i_object_id        => ?\n" +
			"            , i_limit_type       => x.limit_type\n" +
			"            , i_split_hash       => ?\n" +
			"            , i_inst_id          => ?\n" +
			"            , i_mask_error       => 1\n" +
			"          ) \n" +
			"       and r.split_hash(+)  = ?  \n" +
			"       and r.limit_type(+)  = x.limit_type \n" +
			"       and r.entity_type(+) = 'ENTTACCT'\n" +
			"       and r.object_id(+)   = ?\n" +
			"       and c.id(+)          = l.cycle_id\n" +
			"       and b.cycle_type(+)  = c.cycle_type  \n" +
			"       and b.entity_type(+) = 'ENTTACCT'\n" +
			"       and b.object_id(+)   = ?) l";
	//</editor-fold>

	//<editor-fold desc="Full count query">
	private String fullCountQuery = "select count(1)\n" +
			"  from ( \n" +
			"      select count(1)\n" +
			"           , ab.account_id   \n" +
			"         from\n" +
			"             acc_balance ab\n" +
			"           , acc_account a\n" +
			"         where ab.split_hash in (select split_hash from com_api_split_map_vw) \n" +
			"           and ab.split_hash = a.split_hash                                \n" +
			"           and ab.account_id = a.id \n" +
			"           and exists(select 1 from acc_account_object ao where ao.account_id = ab.account_id and ao.entity_type = 'ENTTCARD')             \n" +
			"           and (a.inst_id = ? or nvl(?, 9999) = 9999)    \n" +
			"           and (\n" +
			"                (? is not null\n" +
			"                and \n" +
			"                (? = '%' or ab.balance_type = ?)\n" +
			"                )\n" +
			"            or\n" +
			"                (\n" +
			"                ? is null\n" +
			"                and\n" +
			"                ab.balance_type in (select element_value from com_array_element where array_id = 12)\n" +
			"                )\n" +
			"           )                         \n" +
			"    group by ab.account_id)   ";
	//</editor-fold>

	//<editor-fold desc="Incremental count query">
	private String incrCountSql = "select count(1)\n" +
			"      from ( \n" +
			"        select ae.account_id \n" +
			"             , 'ENTTACCT'\n" +
			"             , o.inst_id\n" +
			"          from evt_event_object o\n" +
			"             , acc_entry ae                     \n" +
			"             , acc_balance ab\n" +
			"         where o.split_hash in (select split_hash from com_api_split_map_vw)\n" +
			"           and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'\n" +
			"           and o.eff_date      <= get_sysdate \n" +
			"           and o.inst_id        = ?\n" +
			"           and o.split_hash     = ae.split_hash \n" +
			"           and o.entity_type    = 'ENTTENTR'\n" +
			"           and o.object_id      = ae.id \n" +
			"           and (ae.status       <> 'ENTRCNCL' or ae.status is null)                        \n" +
			"           and o.split_hash     = ab.split_hash\n" +
			"           and ae.account_id      = ab.account_id\n" +
			"           and exists(select 1 from acc_account_object ao where ao.account_id = ae.account_id and ao.entity_type = 'ENTTCARD')\n" +
			"           and(\n" +
			"                    (? is not null\n" +
			"                    and \n" +
			"                    (? = '%' or ab.balance_type = ?)\n" +
			"                    )\n" +
			"                or\n" +
			"                    (\n" +
			"                    ? is null\n" +
			"                    and ab.balance_type in (select element_value from com_array_element where array_id = 12)\n" +
			"                    )\n" +
			"            )\n" +
			"         group by\n" +
			"            ae.account_id\n" +
			"            , o.inst_id\n" +
			"    union\n" +
			"    select distinct object_id\n" +
			"         , entity_type\n" +
			"         , inst_id\n" +
			"      from evt_event_object o\n" +
			"     where o.split_hash in (select split_hash from com_api_split_map_vw)\n" +
			"       and decode(o.status, 'EVST0001', o.procedure_name, null) = 'ITF_PRC_ACCOUNT_EXPORT_PKG.PROCESS_UNLOAD_TURNOVER'\n" +
			"       and o.eff_date      <= get_sysdate \n" +
			"       and o.inst_id       = ?\n" +
			"       and o.entity_type    = 'ENTTACCT'\n" +
			"       and exists(select 1 from acc_account_object ao where ao.account_id = o.object_id and ao.entity_type = 'ENTTCARD')                \n" +
			"  )";
	//</editor-fold>

	//<editor-fold desc="Limits full query">
	private String limitsFullSql = "select t.account_id \n" +
			"       , t.limit_type\n" +
			"       , nvl(t.sum_limit, 0) sum_limit\n" +
			"       , nvl(t.count_limit, 0) count_limit                            \n" +
			"       , nvl(fcl_api_limit_pkg.get_limit_sum_curr(t.limit_type, 'ENTTACCT', t.account_id , t.id), 0) sum_current\n" +
			"       , t.currency\n" +
			"       , case when b.next_date > get_sysdate or b.next_date is null then b.next_date\n" +
			"              else fcl_api_cycle_pkg.calc_next_date(b.cycle_type, r.entity_type, r.object_id, r.split_hash, get_sysdate)\n" +
			"         end  next_date\n" +
			"       , t.length_type\n" +
			"       , t.cycle_length\n" +
			"    from (    \n" +
			"        select a.account_id\n" +
			"             , a.split_hash\n" +
			"             , l.*\n" +
			"             , c.cycle_type\n" +
			"             , c.length_type\n" +
			"             , c.cycle_length\n" +
			"          from acc_account_object a\n" +
			"             , (     \n" +
			"               select\n" +
			"                    distinct a.object_type limit_type\n" +
			"                 from prd_attribute a\n" +
			"                    , prd_service_type t \n" +
			"                where t.entity_type     = 'ENTTACCT'\n" +
			"                  and a.service_type_id = t.id\n" +
			"                  and a.entity_type     = 'ENTTLIMT'\n" +
			"             ) x \n" +
			"             , fcl_limit l     \n" +
			"             , fcl_cycle c\n" +
			"        where a.split_hash in (select split_hash from com_api_split_map_vw)\n" +
			"          and a.entity_type = 'ENTTCARD'\n" +
			"          and l.limit_type  = x.limit_type \n" +
			"          and l.id          = prd_api_product_pkg.get_limit_id (\n" +
			"                                    i_entity_type      => 'ENTTACCT'\n" +
			"                                  , i_object_id        => a.account_id\n" +
			"                                  , i_limit_type       => x.limit_type\n" +
			"                                  , i_split_hash       => a.split_hash \n" +
			"                                  , i_inst_id          => ? \n" +
			"                                  , i_mask_error       => 1\n" +
			"                                ) \n" +
			"          and c.id(+)          = l.cycle_id                                   \n" +
			"    ) t \n" +
			"    , fcl_limit_counter r\n" +
			"    , fcl_cycle_counter b\n" +
			"where r.split_hash(+)  = t.split_hash                                 \n" +
			"  and r.limit_type(+)  = t.limit_type \n" +
			"  and r.entity_type(+) = 'ENTTACCT'\n" +
			"  and r.object_id(+)   = t.account_id\n" +
			"  and b.split_hash(+)  = t.split_hash \n" +
			"  and b.cycle_type(+)  = t.cycle_type  \n" +
			"  and b.entity_type(+) = 'ENTTACCT'\n" +
			"  and b.object_id(+)   = t.account_id";
	//</editor-fold>


	private PreparedStatement createIncrStatement(Connection connection) throws Exception {
		PreparedStatement pstm = connection.prepareStatement(incrSql);
		if (endDate != null) {
			pstm.setDate(1, new java.sql.Date(endDate.getTime()));
		} else {
			pstm.setNull(1, Types.DATE);
		}
		pstm.setInt(2, instId);
		pstm.setInt(3, instId);
		if (balanceType != null) {
			pstm.setString(4, balanceType);
			pstm.setString(5, balanceType);
			pstm.setString(6, balanceType);
			pstm.setString(7, balanceType);
		} else {
			pstm.setNull(4, Types.VARCHAR);
			pstm.setNull(5, Types.VARCHAR);
			pstm.setNull(6, Types.VARCHAR);
			pstm.setNull(7, Types.VARCHAR);
		}
		if (endDate != null) {
			pstm.setDate(8, new java.sql.Date(endDate.getTime()));
		} else {
			pstm.setNull(8, Types.DATE);
		}
		pstm.setInt(9, instId);
		return pstm;
	}

	private PreparedStatement createIncrCntStatement(Connection connection) throws Exception {
		PreparedStatement pstm = connection.prepareStatement(incrCountSql);
		pstm.setInt(1, instId);
		if (balanceType != null) {
			pstm.setString(2, balanceType);
			pstm.setString(3, balanceType);
			pstm.setString(4, balanceType);
			pstm.setString(5, balanceType);
		} else {
			pstm.setNull(2, Types.VARCHAR);
			pstm.setNull(3, Types.VARCHAR);
			pstm.setNull(4, Types.VARCHAR);
			pstm.setNull(5, Types.VARCHAR);
		}
		pstm.setInt(6, instId);
		return pstm;
	}

	private PreparedStatement createFullStatement(Connection connection) throws Exception {
		PreparedStatement pstm = connection.prepareStatement(fullSql);
		if (endDate != null) {
			java.sql.Date sqlDate = new java.sql.Date(endDate.getTime());
			pstm.setDate(1, sqlDate);
		} else {
			pstm.setNull(1, Types.DATE);
		}
		if (instId != null) {
			pstm.setInt(2, instId);
			pstm.setInt(3, instId);
		} else {
			pstm.setNull(2, Types.NUMERIC);
			pstm.setNull(3, Types.NUMERIC);
		}
		if (balanceType != null) {
			pstm.setString(4, balanceType);
			pstm.setString(5, balanceType);
			pstm.setString(6, balanceType);
			pstm.setString(7, balanceType);
		} else {
			pstm.setNull(4, Types.VARCHAR);
			pstm.setNull(5, Types.VARCHAR);
			pstm.setNull(6, Types.VARCHAR);
			pstm.setNull(7, Types.VARCHAR);
		}
		return pstm;
	}

	private PreparedStatement createFullCntStatement(Connection connection) throws Exception {
		PreparedStatement pstm = connection.prepareStatement(fullCountQuery);
		pstm.setInt(1, instId);
		pstm.setInt(2, instId);
		if (balanceType != null) {
			pstm.setString(3, balanceType);
			pstm.setString(4, balanceType);
			pstm.setString(5, balanceType);
			pstm.setString(6, balanceType);
		} else {
			pstm.setNull(3, Types.VARCHAR);
			pstm.setNull(4, Types.VARCHAR);
			pstm.setNull(5, Types.VARCHAR);
			pstm.setNull(6, Types.VARCHAR);
		}
		return pstm;
	}

	private PreparedStatement createFullLimitsStatement(Connection connection) throws Exception {
		PreparedStatement pstm = connection.prepareStatement(limitsFullSql);
		pstm.setInt(1, instId);
		return pstm;
	}

//	private void getLimits(String accountId, WriteContentListener listener) throws Exception {
//
//		if (limitsRs == null) {
//			limitsConn = ssn.getCurrentConnection();
//			limitsPstm = createFullLimitsStatement(ssn.getCurrentConnection());
//			limitsRs = limitsPstm.executeQuery();
//			limitsRs.next();
//		}
//		do {
//			String limitAccId = limitsRs.getString("account_id");
//			if (!limitAccId.equals(accountId)) {
//				break;
//			}
//			listener.writeContent(limitsRs);
//		} while (limitsRs.next());
//	}

	@Override
	public void setParameters(Map<String, Object> parameters) {
		super.setParameters(parameters);
		startDate = (Date) parameters.get("I_START_DATE");
		endDate = (Date) parameters.get("I_END_DATE");
		dateType = (String) parameters.get("I_DATE_TYPE");
		fullExport = ((String) parameters.get("I_MODE")).equalsIgnoreCase("EXMDFULL");
		balanceType = (String) parameters.get("I_BALANCE_TYPE");
		if (parameters.get("I_UNLOAD_LIMITS") != null) {
			unloadLimits = ((BigDecimal) parameters.get("I_UNLOAD_LIMITS")).intValue() == 1;
		}
		if (parameters.get("I_SHIFT_FROM") != null) {
			shiftFrom = ((BigDecimal) parameters.get("I_SHIFT_FROM")).intValue();
		}
		if (parameters.get("I_SHIFT_TO") != null) {
			shiftTo = ((BigDecimal) parameters.get("I_SHIFT_TO")).intValue();
		}
		if (shiftFrom != null && startDate != null) {
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(startDate);
			calendar.set(Calendar.DAY_OF_YEAR, calendar.get(Calendar.DAY_OF_YEAR) + shiftFrom);
			startDate = calendar.getTime();
		}
		if (shiftTo != null && endDate != null) {
			Calendar calendar = Calendar.getInstance();
			calendar.setTime(endDate);
			calendar.set(Calendar.DAY_OF_YEAR, calendar.get(Calendar.DAY_OF_YEAR) + shiftTo);
			endDate = calendar.getTime();
		}
	}

	@Override
	public String getRootTag() {
		return "accounts";
	}

	@Override
	public String getItemTag() {
		return "account";
	}

	@Override
	public String getNamespace() {
		return "http://sv.bpc.in/SVXP";
	}

	@Override
	public DataTypes getDataType() {
		return DataTypes.DBAL;
	}

	@Override
	public void writeStartTags() throws Exception {
		writeTag("file_type", ProcessConstants.FILE_TYPE_TURNOVER_ACCOUNTS);
		writeTag("date_purpose", "0001");
		writeTag("start_date", timestampSdf.format(startDate == null ? new Date() : startDate));
		writeTag("end_date", timestampSdf.format(endDate == null ? new Date() : endDate));
	}

	@Override
	public int getTotal(Connection conn) throws Exception {
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			if (fullExport) {
				pstm = createFullCntStatement(conn);
			} else {
				pstm = createIncrCntStatement(conn);
			}
			rs = pstm.executeQuery();
			if (rs.next()) {
				return rs.getInt(1);
			}
		} finally {
			closeResources(pstm, rs);
		}
		return 0;
	}

	@Override
	public PreparedStatement getItemsStatement(Connection conn) throws Exception {
		if (fullExport) {
			return createFullStatement(conn);
		}
		return createIncrStatement(conn);
	}

	@Override
	protected boolean writeContent(ResultSet rs) throws Exception {
		String accountId = rs.getString("account_id");
		writer.writeAttribute("id", accountId);
		writeTag("account_number", rs.getString("account_number"));
		writeTag("currency", rs.getString("account_currency"));
		writeTag("account_type", rs.getString("account_type"));
		writeTag("account_status", rs.getString("status"));
		writeTag("aval_balance", rs.getLong("aval_balance"));

		boolean exit = true;
		do {
			String newAccountId = rs.getString("account_id");
			if (!accountId.equalsIgnoreCase(newAccountId)) {
				exit = false;
				break;
			}
			writer.writeStartElement("balance");
			writer.writeAttribute("id", rs.getString("balance_id"));
			writeTag("balance_type", rs.getString("balance_type"));
			writer.writeStartElement("turnover");
//			writeTag("incoming_balance", rs.getLong("incoming_balance"));
//			writeTag("debits_amount", rs.getLong("debits_amount"));
//			writeTag("debits_count", rs.getLong("debits_count"));
//			writeTag("credits_amount", rs.getLong("credits_amount"));
//			writeTag("credits_count", rs.getLong("credits_count"));
			writeTag("outgoing_balance", rs.getLong("outgoing_balance"));
			writer.writeEndElement();
			writer.writeEndElement();
		} while (rs.next());

		if (unloadLimits) {
//			writer.writeStartElement("limits");
//			getLimits(accountId, new WriteContentListener() {
//				@Override
//				public void writeContent(ResultSet rs) throws Exception {
//					writer.writeStartElement("limit");
//					writeTag("limit_type", rs.getString("limit_type"));
//					writeTag("sum_limit", rs.getLong("sum_limit"));
//					writeTag("count_limit", rs.getLong("count_limit"));
//					writeTag("sum_current", rs.getLong("sum_current"));
//					writeTag("currency", rs.getString("currency"));
//					Date nextDate = rs.getDate("next_date");
//					if (nextDate != null) {
//						writeTag("next_date", timestampSdf.format(nextDate));
//					}
//					writeTag("length_type", rs.getString("length_type"));
//					writeTag("cycle_length", rs.getLong("cycle_length"));
//					writer.writeEndElement();
//				}
//			});
//			writer.writeEndElement();
		}
		return exit;
	}
}
