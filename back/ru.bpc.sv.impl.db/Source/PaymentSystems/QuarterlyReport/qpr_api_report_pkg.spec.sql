create or replace package qpr_api_report_pkg
is

--MASTERCARD quarter reports
procedure mc_issuing(
    o_xml                       out clob
    , i_card_type_id            in  com_api_type_pkg.t_tiny_id
    , i_program_categories      in  com_api_type_pkg.t_name
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
);

procedure mc_issuing_maestro(
    o_xml                       out clob
    , i_card_type_id            in  com_api_type_pkg.t_tiny_id
    , i_program_categories      in  com_api_type_pkg.t_name
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
);

procedure mc_acquiring(
    o_xml                       out clob
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
);

procedure mc_acquiring_maestro(
    o_xml                       out clob
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
);

procedure mc_acquiring_cirrus(
    o_xml                       out clob
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
);

procedure mc_machine_readable(
    o_xml                       out clob
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
    , i_lang                    in  com_api_type_pkg.t_dict_value
);

----------------------------------------------------------
--VISA quarter reports

procedure vs_mrc_inform(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_mrc_mcc(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_cash_acquiring(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_co_brand(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_issuing(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_card_type_id            in  com_api_type_pkg.t_tiny_id
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_acquiring_v_pay(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_acquiring_contactless(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_acquiring(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_acquiring_ecommerce(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_acquiring_vmt(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_cemea(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_year                    in  com_api_type_pkg.t_tiny_id
    , i_quarter                 in  com_api_type_pkg.t_sign
    , i_inst_id                 in  com_api_type_pkg.t_inst_id
);

procedure vs_acquiring_cross_border(
    o_xml                       out clob
  , i_lang                      in  com_api_type_pkg.t_dict_value
  , i_year                      in  com_api_type_pkg.t_tiny_id
  , i_quarter                   in  com_api_type_pkg.t_sign
  , i_inst_id                   in  com_api_type_pkg.t_inst_id
);

procedure vs_acquiring_bai(
    o_xml                       out clob
  , i_lang                      in  com_api_type_pkg.t_dict_value
  , i_year                      in  com_api_type_pkg.t_tiny_id
  , i_quarter                   in  com_api_type_pkg.t_sign
  , i_inst_id                   in  com_api_type_pkg.t_inst_id
);

---------------------------
procedure monthly_report_by_network(
    o_xml                       out clob
    , i_lang                    in  com_api_type_pkg.t_dict_value
    , i_network_id              in  com_api_type_pkg.t_inst_id
    , i_start_date              in  date
    , i_end_date                in  date
    , i_dest_curr               in  com_api_type_pkg.t_curr_code
    , i_rate_type               in  com_api_type_pkg.t_dict_value
);

end qpr_api_report_pkg;
/