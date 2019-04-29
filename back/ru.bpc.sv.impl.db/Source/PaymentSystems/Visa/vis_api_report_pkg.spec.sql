create or replace package vis_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Kolodkina J.(kolodkina@bpcbt.com)  at 20.03.2013 <br />
 *  Last changed by $Author: kolodkina $ <br />
 *  $LastChangedDate:: 2013-03-20 15:00:44 +0400#$ <br />
 *  Revision: $LastChangedRevision: 25841 $ <br />
 *  Module: vis_api_report_pkg <br />
 *  @headcom
 **********************************************************/

    function get_header (
        i_inst_id                      in com_api_type_pkg.t_inst_id
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    ) return xmltype;

   function get_header (
        i_inst_id                      in com_api_type_pkg.t_inst_id
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
        , i_count                      in com_api_type_pkg.t_short_id
   ) return xmltype;

   function get_header (
        i_inst_id                      in com_api_type_pkg.t_inst_id
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_currency                   in com_api_type_pkg.t_curr_code
        , i_mcc                        in com_api_type_pkg.t_mcc default null
        , i_country                    in com_api_type_pkg.t_country_code default null
        , i_sum                        in number
        , i_lang                       in com_api_type_pkg.t_dict_value
   ) return xmltype;

    procedure total_auth (
        o_xml                      out clob
        , i_start_date             in date
        , i_end_date               in date
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_card_network_id        in com_api_type_pkg.t_network_id default null
        , i_mcc                    in com_api_type_pkg.t_mcc default null
        , i_merchant_number        in com_api_type_pkg.t_merchant_number default null
        , i_merchant_country       in com_api_type_pkg.t_country_code default null
        , i_count                  in com_api_type_pkg.t_short_id
        , i_report_type            in com_api_type_pkg.t_name
        , i_lang                   in com_api_type_pkg.t_dict_value default null
    );
    
    procedure total_auth (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value default null
        , i_count                  in com_api_type_pkg.t_short_id
    );

    procedure total_auth_mcc (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                   in com_api_type_pkg.t_dict_value default null
        , i_mcc                        in com_api_type_pkg.t_mcc default null
        , i_count                      in com_api_type_pkg.t_short_id
    );

    procedure total_auth_merchant (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                   in com_api_type_pkg.t_dict_value default null
        , i_merchant_id                in com_api_type_pkg.t_merchant_number default null
        , i_count                      in com_api_type_pkg.t_short_id
    );

    procedure total_auth_country (
        o_xml                      out clob
        , i_inst_id                in com_api_type_pkg.t_inst_id default null
        , i_netw_id                in com_api_type_pkg.t_network_id default null
        , i_start_date             in date
        , i_end_date               in date
        , i_lang                   in com_api_type_pkg.t_dict_value default null
        , i_country                in com_api_type_pkg.t_country_code default null
        , i_count                  in com_api_type_pkg.t_short_id
    );

    procedure total_invalid_pin (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
        , i_count                      in com_api_type_pkg.t_short_id
    );

    procedure total_pos_mode_02 (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
        , i_count                      in com_api_type_pkg.t_short_id
    );

    procedure total_amount_auths (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_currency                   in com_api_type_pkg.t_curr_code
        , i_lang                       in com_api_type_pkg.t_dict_value
        , i_mcc                        in com_api_type_pkg.t_mcc default null
        , i_country                    in com_api_type_pkg.t_country_code default null
        , i_sum                        in number
    );

    procedure total_amount_individual (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_currency                   in com_api_type_pkg.t_curr_code
        , i_lang                       in com_api_type_pkg.t_dict_value
        , i_mcc                        in com_api_type_pkg.t_mcc default null
        , i_country                    in com_api_type_pkg.t_country_code default null
        , i_sum                        in number
    );

   procedure total_auths_of_country (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

   procedure auths_high_amount (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_currency                   in com_api_type_pkg.t_curr_code
        , i_interval                   in number
        , i_percent                    in number
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

   procedure auths_manual_input (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_percent                    in number
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

   procedure percent_use_balance (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_netw_id                    in com_api_type_pkg.t_network_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_currency                   in com_api_type_pkg.t_curr_code
        , i_algorithm                  in com_api_type_pkg.t_dict_value  
        , i_percent                    in number
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

   procedure operation_visa_on_us (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

   procedure rejected_opr_visa_on_us (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

   procedure reject_opr_us_on_us (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

   procedure general_opr_us_on_us (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id default null
        , i_start_date                 in date
        , i_end_date                   in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

   procedure vss_reconciliation (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id
        , i_reconciliation_date        in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

    procedure visa_unmatched_presentments (
        o_xml            out clob
      , i_inst_id     in     com_api_type_pkg.t_inst_id
      , i_date_start  in     date
      , i_date_end    in     date
      , i_lang        in     com_api_type_pkg.t_dict_value
    );

end;
/
