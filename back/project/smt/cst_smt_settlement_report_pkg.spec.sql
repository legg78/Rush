CREATE OR REPLACE PACKAGE cst_smt_settlement_report_pkg is
/*********************************************************
 *  Settlement reports API <br />
 *  Module: cst_smt_settlement_report_pkg <br />
 *  @headcom
 **********************************************************/

function get_sttl_day(i_sttl_date date)
return com_api_type_pkg.t_tiny_id;

function is_operation_valid(i_status com_api_type_pkg.t_dict_value)
return number result_cache;

function get_operation_type(i_oper_type com_api_type_pkg.t_dict_value
                            , i_msg_type com_api_type_pkg.t_dict_value
                            , i_type number default 0)
return number
result_cache;

-- REJECTED TRANSACTIONS REPORT BY ACQUIRER BANK
procedure acq_rejected_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id  
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- PROCESSED ACQUIRER TRANSACTIONS STATISTICS FOR SMT IN THAT BUSINESS DATE
procedure acq_transaction_statistic(
    o_xml   out clob
  , i_date  in  date
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- CIRRUS / MAESTRO TRANSACTIONS REPORT BY ACQUIRER BANK
procedure mc_acq_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- GENERAL ACQUIRED TRANSACTIONS REPORT IN RELATION TO ISSUERS
procedure acq_general_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- NATIONAL INCOMING CLEARING REPORT BY BANK (ISSUING).
procedure iss_national_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- NATIONAL OUTGOING CLEARING REPORT BY BANK (ACQUIRING)
procedure acq_national_transaction(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- STATISTICS INTERNATIONAL OUTGOING REPORT FOR SMT IN THAT BUSINESS DATE
procedure outgoing_international_trnx(
    o_xml   out clob
  , i_date  in  date
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- CENTRAL BANK SUMMARY CLEARING REPORT
procedure central_bank_summary_clearing(
    o_xml   out clob
  , i_date  in  date
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- SUMMARY MERCHANT REMITTANCE BY NETWORK
procedure summary_merchant_remittance(
    o_xml   out clob
  , i_date  in  date
  , i_inst  in  com_api_type_pkg.t_tiny_id
  , i_lang  in  com_api_type_pkg.t_dict_value   default null
);

-- DISPUTES TRANSACTIONS REJECTION REPORT BY BANK INITIATOR

end cst_smt_settlement_report_pkg;
/
