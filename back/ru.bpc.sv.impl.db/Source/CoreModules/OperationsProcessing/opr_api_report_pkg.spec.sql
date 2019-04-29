create or replace package opr_api_report_pkg is

    procedure clearing_messages_card_absent (
        o_xml                   out clob
        , i_network_id          in com_api_type_pkg.t_tiny_id
        , i_inst_id             in com_api_type_pkg.t_inst_id := null
        , i_start_date          in date
        , i_end_date            in date
        , i_lang                in com_api_type_pkg.t_dict_value
    );

    procedure merchant_purchase_totals(
        o_xml                 out clob
      , i_network_id        in    com_api_type_pkg.t_network_id
      , i_start_date        in    date                             default null
      , i_end_date          in    date                             default null
      , i_lang              in     com_api_type_pkg.t_dict_value
    );

    procedure merchant_purchase_details(
        o_xml                 out clob
      , i_network_id        in    com_api_type_pkg.t_network_id
      , i_start_date        in    date                             default null
      , i_end_date          in    date                             default null
      , i_bin               in    com_api_type_pkg.t_bin
      , i_lang              in    com_api_type_pkg.t_dict_value
    );

end;
/
