create or replace package cst_api_report_pkg is
/*********************************************************
 *  Customs reports API <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 05.10.2013 <br />
 *  Last changed by $Author: melkonyan $ <br />
 *  Module: cst_api_report_pkg <br />
 *  @headcom
 **********************************************************/

c_mc_sv2sv_nspk_network     constant com_api_type_pkg.t_tiny_id := 7014;

function get_transfers(
    i_begin_oper_id        in com_api_type_pkg.t_rate
  , i_end_oper_id          in com_api_type_pkg.t_rate
  , i_inst_id              in com_api_type_pkg.t_inst_id
  , i_split_status         in com_api_type_pkg.t_boolean default com_api_type_pkg.TRUE
) return cst_transfers_tpt pipelined;

procedure transfers(
    o_xml                    out    clob
  , i_begin_oper_date            in date                            default null
  , i_end_oper_date              in date                            default null
  , i_lang                       in com_api_type_pkg.t_dict_value   default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id
  , i_split_status               in com_api_type_pkg.t_boolean      default com_api_type_pkg.TRUE
);

procedure act_transactions(
    i_begin_oper_date            in date                            default null
  , i_end_oper_date              in date                            default null
  , i_lang                       in com_api_type_pkg.t_dict_value   default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id      default null
);

procedure act_transactions_group(
    o_xml                    out    clob
  , i_launching_mode             in number
  , i_lang                       in com_api_type_pkg.t_dict_value   default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id      default null
);

procedure act_rendered_services(
    o_xml                    out    clob
  , i_lang                       in com_api_type_pkg.t_dict_value   default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id      default null
  , i_begin_oper_date            in date                            default null
  , i_end_oper_date              in date                            default null
  , i_auth_price                 in com_api_type_pkg.t_rate         default 0
  , i_sms_notif_price            in com_api_type_pkg.t_rate         default 1
  , i_reb_card_percent           in com_api_type_pkg.t_rate         default 0
  , i_other_card_percent         in com_api_type_pkg.t_rate         default 0
  , i_e_commerce_percent         in com_api_type_pkg.t_rate         default 0
);

procedure nonexist_cards_operations(
    o_xml                    out    clob
  , i_oper_date                  in date default null
  , i_lang                       in com_api_type_pkg.t_dict_value default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id    default null
);

procedure account_statement (
    o_xml                    out    clob
  , i_account_number             in com_api_type_pkg.t_account_number
  , i_start_date                 in date
  , i_end_date                   in date
  , i_lang                       in com_api_type_pkg.t_dict_value
);

procedure check_operations(
    o_xml                    out    clob
  , i_begin_oper_date            in date default null
  , i_end_oper_date              in date default null
  , i_network_id                 in com_api_type_pkg.t_network_id
  , i_sttl_date                  in com_api_type_pkg.t_tiny_id default null
  , i_file_id                    in com_api_type_pkg.t_long_id default null
  , i_lang                       in com_api_type_pkg.t_dict_value default null
  , i_inst_id                    in com_api_type_pkg.t_inst_id
);

-- convert number to varchar2 with format 'xx xxx.xx'
function format(i_number in number) return varchar2;

function get_payment_code(
    i_op_id       in     number
  , i_op_id_preu  in     number
)return varchar2;


-- Mastercard settlement report in RUR
procedure master_card_settl_rub(
    o_xml            out clob
  , i_report_date in     date default null
  , i_lang        in     com_api_type_pkg.t_dict_value default null
  , i_inst_id     in     com_api_type_pkg.t_inst_id    default null
);

-- Mastercard settlement report in USD
procedure master_card_settl_usd(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
);

-- Mastercard settlement report in EUR
procedure master_card_settl_eur(
    o_xml            out clob
  , i_report_date in     date default null
  , i_lang        in     com_api_type_pkg.t_dict_value default null
  , i_inst_id     in     com_api_type_pkg.t_inst_id    default null
);

-- MasterCard transactions report  - acq
procedure master_card_transactions_acq(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
);

-- MasterCard transactions report - iss
procedure master_card_transactions_iss(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
);

-- Report MasterCard - USD ( with crearing cycles 5->6->1->2->3->4 )
procedure mc_settl_usd(
    o_xml               out clob
    , i_report_date  in     date default null
    , i_lang         in     com_api_type_pkg.t_dict_value default null
    , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
);

-- Report MasterCard - EUR ( with crearing cycles 5->6->1->2->3->4 )
procedure mc_settl_eur(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
);

-- MasterCard transactions report
procedure mc_transactions(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
);

-- Visa report  RUB
procedure visa_settl_rub(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
);

-- Visa report USD
procedure visa_settl_usd(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
);

-- Visa report EUR
procedure visa_settl_eur(
    o_xml             out  clob
  , i_report_date  in      date default null
  , i_lang         in      com_api_type_pkg.t_dict_value default null
  , i_inst_id      in      com_api_type_pkg.t_inst_id    default null
);

-- MIR settlement in RUR report
procedure mup_settl_rub(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
);

-- MIR report transactions - acq
procedure mup_transactions_acq(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
);

-- MIR report transactions - iss
procedure mup_transactions_iss(
    o_xml             out clob
  , i_report_date  in     date default null
  , i_lang         in     com_api_type_pkg.t_dict_value default null
  , i_inst_id      in     com_api_type_pkg.t_inst_id    default null
);

procedure check_entry_c_in_ctf (
    o_xml                   out clob
  , i_session_id_ctf_1   in     com_api_type_pkg.t_long_id
  , i_session_id_ctf_2   in     com_api_type_pkg.t_long_id default null
  , i_session_id_ctf_3   in     com_api_type_pkg.t_long_id default null
  , i_session_id_ctf_4   in     com_api_type_pkg.t_long_id default null
  , i_session_id_ctf_5   in     com_api_type_pkg.t_long_id default null
  , i_session_id_ctf_6   in     com_api_type_pkg.t_long_id default null
  , i_session_id_c       in     com_api_type_pkg.t_long_id
  , i_lang               in     com_api_type_pkg.t_dict_value default null
  , i_inst_id            in     com_api_type_pkg.t_inst_id
);

end cst_api_report_pkg;
/
