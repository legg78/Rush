create or replace package iss_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 04.12.2012 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: iss_api_report_pkg <br />
 *  @headcom
 **********************************************************/

procedure account_statement (
    o_xml                         out clob
  , i_inst_id                      in com_api_type_pkg.t_inst_id
  , i_account_number               in com_api_type_pkg.t_account_number
  , i_start_date                   in date
  , i_end_date                     in date
  , i_lang                         in com_api_type_pkg.t_dict_value
);

procedure account_statement_for_batch(
    o_xml                         out clob
  , i_inst_id                      in com_api_type_pkg.t_inst_id
  , i_entity_type                  in com_api_type_pkg.t_dict_value
  , i_object_id                    in com_api_type_pkg.t_long_id
  , i_start_date                   in date
  , i_end_date                     in date
  , i_lang                         in com_api_type_pkg.t_dict_value
);

procedure issued_card_by_network(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure issued_card_by_agent(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure register_card_by_agent(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure register_pin_by_agent(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure unconfirmed_auth_by_inst(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure issued_card_by_company(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_company_id                   in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure expired_card(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure average_balance(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_company_id                   in     com_api_type_pkg.t_agent_id      default null
  , i_cardholder_number            in     com_api_type_pkg.t_name          default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure card_balances(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure active_cards(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure reissued_cards(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure cards_exceed_limit(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure corporate_cards(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure out_balances_by_cards(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure account_out_balances (
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

procedure financial_transaction (
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

function get_header (
    i_inst_id                      in     com_api_type_pkg.t_inst_id       default 0
  , i_agent_id                     in     com_api_type_pkg.t_agent_id      default 0
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
) return xmltype;

function get_header (
    i_inst_id                      in     com_api_type_pkg.t_inst_id       default 0
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
) return xmltype;

procedure iss_objects(
    o_xml                             out clob
  , i_lang                         in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
);

procedure iss_customers_stat(
    o_xml                             out clob
  , i_lang                         in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
);

procedure iss_accounts_stat(
    o_xml                             out clob
  , i_lang                         in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
);

procedure iss_cards_stat(
    o_xml                             out clob
  , i_lang                         in     com_api_type_pkg.t_dict_value    default null
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
);

procedure cards_being_deleted(
    o_xml                             out clob
  , i_inst_id                      in     com_api_type_pkg.t_inst_id       default null
  , i_start_date                   in     date
  , i_end_date                     in     date
  , i_lang                         in     com_api_type_pkg.t_dict_value
);

end;
/
