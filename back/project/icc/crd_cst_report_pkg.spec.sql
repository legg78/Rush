create or replace package crd_cst_report_pkg as

GRACE_PERIOD_ENDING_CYCLE                constant   com_api_type_pkg.t_dict_value := 'CYTP5101';
CUSTOMER_BIRTHDAY_CYCLE                  constant   com_api_type_pkg.t_dict_value := 'CYTP5102';
CUSTOMER_MARRIAGE_DAY_CYCLE              constant   com_api_type_pkg.t_dict_value := 'CYTP5103';
EXCEED_MAIN_PART_LIMIT_EVENT             constant   com_api_type_pkg.t_dict_value := 'EVNT5102';

function get_additional_amounts(
    i_account_id            in        com_api_type_pkg.t_account_id
  , i_invoice_id            in        com_api_type_pkg.t_medium_id
  , i_split_hash            in        com_api_type_pkg.t_tiny_id
  , i_product_id            in        com_api_type_pkg.t_short_id  
  , i_service_id            in        com_api_type_pkg.t_short_id
  , i_eff_date              in        date
)return xmltype;

function get_subject(
    i_account_id            in        com_api_type_pkg.t_account_id
  , i_eff_date              in        date
) return com_api_type_pkg.t_name;

function credit_statement_invoice_data(
    i_account_id            in      com_api_type_pkg.t_account_id
  , i_eff_date              in      date
  , i_currency              in      com_api_type_pkg.t_curr_code
  , i_invoice_id            in      com_api_type_pkg.t_medium_id
  , i_split_hash            in      com_api_type_pkg.t_tiny_id
) return xmltype;

procedure credit_card_statement(
    o_xml                  out        clob
  , i_inst_id               in        com_api_type_pkg.t_inst_id
  , i_agent_id              in        com_api_type_pkg.t_agent_id     default null
  , i_eff_date              in        date
  , i_product_id            in        com_api_type_pkg.t_short_id
  , i_contract_number       in        com_api_type_pkg.t_name         default null
  , i_customer_number       in        com_api_type_pkg.t_name         default null
  , i_currency              in        com_api_type_pkg.t_curr_code    default null
  , i_introduced_by         in        com_api_type_pkg.t_name         default null
  , i_lang                  in        com_api_type_pkg.t_dict_value   default null
);

procedure over_six_months_statement(
    o_xml                  out        clob
  , i_inst_id               in        com_api_type_pkg.t_inst_id
  , i_agent_id              in        com_api_type_pkg.t_agent_id     default null
  , i_star_date             in        date
  , i_end_date              in        date
  , i_product_id            in        com_api_type_pkg.t_short_id
  , i_contract_number       in        com_api_type_pkg.t_name         default null
  , i_customer_number       in        com_api_type_pkg.t_name         default null
  , i_currency              in        com_api_type_pkg.t_curr_code    default null
  , i_introduced_by         in        com_api_type_pkg.t_name         default null
  , i_lang                  in        com_api_type_pkg.t_dict_value   default null
);

procedure report_for_collectors(
    o_xml                      out    clob
  , i_inst_id               in        com_api_type_pkg.t_inst_id
  , i_collector_name        in        com_api_type_pkg.t_name
  , i_lang                  in        com_api_type_pkg.t_dict_value   default null
);

function get_cards_data(
    i_account_id            in        com_api_type_pkg.t_account_id
  , i_lang                  in        com_api_type_pkg.t_dict_value   default null
) return xmltype;

function get_invoice_acc_iss_data(
    i_account_id            in        com_api_type_pkg.t_account_id
  , i_lang                  in        com_api_type_pkg.t_dict_value   default null
) return xmltype;

procedure report_for_notification(
    o_xml                   out       clob
  , i_event_type            in        com_api_type_pkg.t_dict_value
  , i_eff_date              in        date
  , i_entity_type           in        com_api_type_pkg.t_dict_value 
  , i_object_id             in        com_api_type_pkg.t_long_id 
  , i_inst_id               in        com_api_type_pkg.t_inst_id 
  , i_lang                  in        com_api_type_pkg.t_dict_value   default null
);

end;
/
