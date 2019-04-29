package ru.bpc.sv2.scheduler.process.svng;

import ru.bpc.sv2.XmlUnloadProcess;
import ru.bpc.sv2.constants.schedule.ProcessConstants;
import ru.bpc.sv2.svng.DataTypes;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class CrefUnloadProcess extends XmlUnloadProcess {

	private String fullSql = "select cn.card_number       \n" +
			"              , c.card_mask          \n" +
			"              , c.id                card_id\n" +
			"              , ci.start_date       card_iss_date\n" +
			"              , ci.start_date       card_start_date\n" +
			"              , ci.expir_date       expiration_date\n" +
			"              , ci.id               instance_id\n" +
			"              , ci.preceding_card_instance_id as  preceding_instance_id\n" +
			"              , ci.seq_number                 sequential_number\n" +
			"              , ci.status                     card_status\n" +
			"              , case\n" +
			"                    when qwc.question is not null then\n" +
			"                         qwc.question  \n" +
			"                    else\n" +
			"                         qwch.question \n" +
			"                end     as secret_question\n" +
			"              , case\n" +
			"                    when qwc.question is not null then\n" +
			"                         qwc.word      \n" +
			"                    else\n" +
			"                         qwch.word    \n" +
			"                end as secret_answer\n" +
			"              , case\n" +
			"                    when pm.pin_verify_method = 'PNVM0010'\n" +
			"                    then cd.pvv\n" +
			"                end                           as pvv \n" +
			"              , case\n" +
			"                    when pm.pin_verify_method in ('PNVM0040', 'PNVM0020')\n" +
			"                    then cd.pvv\n" +
			"                end                           as pin_offset\n" +
			"              , 0 as pin_update_flag      \n" +
			"              , c.card_type_id                as card_type_id\n" +
			"              , cnp.card_number               as prev_card_number\n" +
			"              , (select a.agent_number\n" +
			"                   from ost_agent a\n" +
			"                  where a.id = ci.agent_id)   as agent_number\n" +
			"              , nvl(pr.product_number, pr.id) as product_number\n" +
			"              , m.customer_number             as customer_number\n" +
			"              , m.category                    as customer_category\n" +
			"              , m.relation                    as customer_relation\n" +
			"              , m.resident                    as resident\n" +
			"              , m.nationality                 as nationality\n" +
			"              , m.credit_rating               as credit_rating\n" +
			"              , m.money_laundry_risk          as money_laundry_risk\n" +
			"              , m.money_laundry_reason        as money_laundry_reason\n" +
			"              , h.cardholder_number           as cardholder_number\n" +
			"              , h.cardholder_name             as cardholder_name\n" +
			"              , p.surname                     as surname\n" +
			"              , p.first_name                  as first_name\n" +
			"              , p.second_name                 as second_name\n" +
			"              , p.suffix                      as suffix\n" +
			"              , p.birthday                    as birthday\n" +
			"              , p.place_of_birth              as place_of_birth\n" +
			"              , p.gender                      as gender\n" +
			"              , p.lang                        as lang  \n" +
			"              , ac.account_number             as account_number\n" +
			"              , ac.currency                   as currency\n" +
			"              , ac.account_type               as account_type\n" +
			"              , ac.status                     as account_status\n" +
			"              , io.id_type                    as id_type\n" +
			"              , io.id_series                  as id_series\n" +
			"              , io.id_number                  as id_number\n" +
			"              , io.id_issuer                  as id_issuer\n" +
			"              , io.id_issue_date              as id_issue_date\n" +
			"              , io.id_expire_date             as id_expire_date\n" +
			"              , com_ui_id_object_pkg.get_id_card_desc(\n" +
			"                    i_entity_type     => 'ENTTPERS'\n" +
			"                  , i_object_id       => p.id\n" +
			"                  , i_lang            => p.lang\n" +
			"                )                           as id_desc        \n" +
			"              , o.address_type\n" +
			"              , a.street\n" +
			"              , a.city\n" +
			"              , a.country\n" +
			"              , a.house\n" +
			"              , a.region\n" +
			"              , a.region_code\n" +
			"              , a.postal_code\n" +
			"              , a.apartment\n" +
			"              , a.place_code\n" +
			"              , a.latitude\n" +
			"              , a.longitude\n" +
			"              , o.entity_type\n" +
			"              , a.lang addr_lang\n" +
			"          from iss_card c\n" +
			"             , iss_card_number_vw cn\n" +
			"             , prd_contract ct\n" +
			"             , prd_product pr\n" +
			"             , prd_customer m\n" +
			"             , iss_cardholder h\n" +
			"             , com_person p\n" +
			"             , iss_card_instance ci\n" +
			"             , iss_card_instance_data cd\n" +
			"             , prs_method pm\n" +
			"             , iss_card_instance cip \n" +
			"             , iss_card_number_vw cnp\n" +
			"             , sec_question_word_vw qwc\n" +
			"             , sec_question_word_vw qwch\n" +
			"             , acc_account ac\n" +
			"             , acc_account_object ao   \n" +
			"             , com_id_object io        \n" +
			"             , com_address_object o\n" +
			"             , com_address a               \n" +
			"         where ci.split_hash in (select split_hash from com_api_split_map_vw)\n" +
			"           and ci.id in (select max(ci.id) from iss_card_instance ci where ci.split_hash in (select split_hash from com_api_split_map_vw)\n" +
			"                            group by ci.card_id)\n" +
			"           and c.id = ci.card_id\n" +
			"           and ci.split_hash = c.split_hash\n" +
			"           and c.inst_id = ?\n" +
			"           and c.id = cn.card_id\n" +
			"           and ct.id = c.contract_id\n" +
			"           and pr.id = ct.product_id\n" +
			"           and m.id = c.customer_id\n" +
			"           and c.cardholder_id = h.id(+)\n" +
			"           and h.person_id = p.id(+)\n" +
			"           and p.lang(+) = 'LANGENG'\n" +
			"           and cd.card_instance_id(+) = ci.id\n" +
			"           and pm.id(+) = ci.perso_method_id\n" +
			"           and cip.id(+) = ci.preceding_card_instance_id\n" +
			"           and cnp.card_id(+) = cip.card_id\n" +
			"           and qwc.entity_type(+)  = 'ENTTCARD'\n" +
			"           and qwc.object_id(+)    = c.id\n" +
			"           and (qwc.question(+) is null or qwc.question(+) = 'SEQUWORD')\n" +
			"           and qwch.entity_type(+) = 'ENTTCRDH'\n" +
			"           and qwch.object_id(+)   = c.cardholder_id\n" +
			"           and (qwch.question(+) is null or qwch.question(+) = 'SEQUWORD')\n" +
			"           and ac.id(+) = ao.account_id\n" +
			"           and ao.entity_type(+) = 'ENTTCARD'\n" +
			"           and ao.object_id(+) = c.id\n" +
			"           and io.entity_type(+) = 'ENTTPERS'\n" +
			"           and io.object_id(+) = p.id\n" +
			"           and a.id = o.address_id\n" +
			"           and (o.entity_type, o.object_id) in (\n" +
			"                       ('ENTTCRDH', h.id)\n" +
			"                     , ('ENTTCUST', m.id))";

	private String fullCntSql = "select count(1)\n" +
			"          from iss_card c\n" +
			"             , iss_card_number_vw cn\n" +
			"             , prd_contract ct\n" +
			"             , prd_product pr\n" +
			"             , prd_customer m\n" +
			"             , iss_card_instance ci\n" +
			"         where c.id = ci.card_id\n" +
			"           and ci.split_hash in (select split_hash from com_api_split_map_vw)\n" +
			"           and ci.split_hash = c.split_hash\n" +
			"           and c.inst_id = ?\n" +
			"           and c.id = cn.card_id\n" +
			"           and ct.id = c.contract_id\n" +
			"           and pr.id = ct.product_id\n" +
			"           and m.id = c.customer_id\n" +
			"           and ci.id in (select max(ci.id) from iss_card_instance ci where ci.split_hash in (select split_hash from com_api_split_map_vw)\n" +
			"                            group by ci.card_id)";

	@Override
	public String getRootTag() {
		return "cards_info";
	}

	@Override
	public String getItemTag() {
		return "card_info";
	}

	@Override
	public String getNamespace() {
		return "http://bpc.ru/sv/SVXP/card_info";
	}

	@Override
	public DataTypes getDataType() {
		return DataTypes.CREF;
	}

	@Override
	public void writeStartTags() throws Exception {
		writeTag("file_type", ProcessConstants.FILE_TYPE_CREF_UNLOAD);
		writeTag("inst_id", instId);
	}

	@Override
	public int getTotal(Connection conn) throws Exception {
		PreparedStatement pstm = null;
		ResultSet rs = null;
		try {
			pstm = conn.prepareStatement(fullCntSql);
			pstm.setLong(1, instId);
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
		PreparedStatement pstm = conn.prepareStatement(fullSql);
		pstm.setInt(1, instId);
		return pstm;
	}

	@Override
	protected boolean writeContent(ResultSet rs) throws Exception {
		String cardNumber = rs.getString("card_number");
		writeTag("card_number", cardNumber);
		writeTag("card_mask", rs.getString("card_mask"));
		writeTag("card_id", rs.getString("card_id"));
		writeTag("card_iss_date", rs.getTimestamp("card_iss_date"));
		writeTag("card_start_date", rs.getTimestamp("card_start_date"));
		writeTag("expiration_date", rs.getTimestamp("expiration_date"));
		writeTag("instance_id", rs.getString("instance_id"));
		writeTag("preceding_instance_id", rs.getString("preceding_instance_id"));
		writeTag("sequential_number", rs.getString("sequential_number"));
		writeTag("card_status", rs.getString("card_status"));
		writer.writeStartElement("sec_word");
		writeTag("secret_question", rs.getString("secret_question"));
		writeTag("secret_answer", rs.getString("secret_answer"));
		writer.writeEndElement();
		writeTag("pvv", rs.getString("pvv"));
		writeTag("pin_offset", rs.getString("pin_offset"));
		writeTag("card_type_id", rs.getString("card_type_id"));
		writeTag("prev_card_number", rs.getString("prev_card_number"));
		writeTag("agent_number", rs.getString("agent_number"));
		writeTag("product_number", rs.getString("product_number"));
		writer.writeStartElement("customer");
		writeTag("customer_number", rs.getString("customer_number"));
		writeTag("customer_category", rs.getString("customer_category"));
		writeTag("customer_relation", rs.getString("customer_relation"));
		writeTag("resident", rs.getString("resident"));
		writeTag("nationality", rs.getString("nationality"));
		writeTag("credit_rating", rs.getString("credit_rating"));
		writeTag("money_laundry_risk", rs.getString("money_laundry_risk"));
		writeTag("money_laundry_reason", rs.getString("money_laundry_reason"));
		writer.writeEndElement();
		writer.writeStartElement("cardholder");
		writeTag("cardholder_number", rs.getString("cardholder_number"));
		writeTag("cardholder_name", rs.getString("cardholder_name"));
		writer.writeStartElement("person");
		writer.writeStartElement("person_name");
		writer.writeAttribute("language", rs.getString("lang"));
		writeTag("surname", rs.getString("surname"));
		writeTag("first_name", rs.getString("first_name"));
		writeTag("second_name", rs.getString("second_name"));
		writer.writeEndElement();
		writeTag("suffix", rs.getString("suffix"));
		writeTag("birthday", rs.getTimestamp("birthday"));
		writeTag("place_of_birth", rs.getString("place_of_birth"));
		writeTag("gender", rs.getString("gender"));

		writer.writeStartElement("identity_card");
		writeTag("id_type", rs.getString("id_type"));
		writeTag("id_series", rs.getString("id_series"));
		writeTag("id_number", rs.getString("id_number"));
		writeTag("id_issuer", rs.getString("id_issuer"));
		writeTag("id_issue_date", rs.getTimestamp("id_issue_date"));
		writeTag("id_expire_date", rs.getTimestamp("id_expire_date"));
		writer.writeEndElement();

		writer.writeStartElement("address");
		writeTag("address_type", rs.getString("address_type"));
		writeTag("country", rs.getString("country"));
		writer.writeStartElement("address_name");
		writer.writeAttribute("language", rs.getString("addr_lang"));
		writeTag("region", rs.getString("region"));
		writeTag("city", rs.getString("city"));
		writeTag("street", rs.getString("street"));
		writer.writeEndElement();
		writeTag("house", rs.getString("house"));
		writeTag("apartment", rs.getString("apartment"));
		writeTag("postal_code", rs.getString("postal_code"));
		writeTag("place_code", rs.getString("place_code"));
		writeTag("region_code", rs.getString("region_code"));
		writeTag("latitude", rs.getString("latitude"));
		writeTag("longitude", rs.getString("longitude"));
		writer.writeEndElement();

		writer.writeEndElement();
		writer.writeEndElement();
		boolean exit = true;
		do {
			String newCardNumber = rs.getString("card_number");
			if (!cardNumber.equalsIgnoreCase(newCardNumber)) {
				exit = false;
				break;
			}
			writer.writeStartElement("account");
			writeTag("account_number", rs.getString("account_number"));
			writeTag("currency", rs.getString("currency"));
			writeTag("account_type", rs.getString("account_type"));
			writeTag("account_status", rs.getString("account_status"));
			writer.writeEndElement();
		} while (rs.next());
		return exit;
	}
}
