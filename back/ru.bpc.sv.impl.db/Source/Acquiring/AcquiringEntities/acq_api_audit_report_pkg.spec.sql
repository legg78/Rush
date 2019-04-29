create or replace package acq_api_audit_report_pkg is

  function get_prev_oper_date (
            i_terminal_id in com_api_type_pkg.t_short_id
          , i_oper_date   in date
          )
  return date;

  function get_trans_count_post_inactive (
            i_terminal_id in com_api_type_pkg.t_short_id
          , i_start_date  in date
          , i_end_date    in date
          )
  return com_api_type_pkg.t_short_id ;

procedure total_avg_term_auth (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
);

procedure total_avg_term_chargeback (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        ) ;

procedure total_avg_term_credit (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        ) ;

procedure total_avg_term_manual (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        ) ;

procedure total_avg_term_below_floor_lmt (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        ) ;

procedure get_list_of_transactions (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        , i_mode           in com_api_type_pkg.t_sign
        ) ;

procedure total_avg_card_term_auth (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        ) ;

procedure total_avg_bin_term_auth (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        ) ;

procedure get_list_of_card_bin_trans (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        , i_currency       in com_api_type_pkg.t_curr_name  default '643'
        , i_threshold      in com_api_type_pkg.t_short_id   default 1
        , i_mode           in com_api_type_pkg.t_sign
        ) ;

procedure get_term_active_after_closing (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        ) ;

procedure get_term_inactive (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_end       in date
        ) ;

procedure get_term_active_after_inactive (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_inst_id        in com_api_type_pkg.t_inst_id    default null
        , i_network_id     in com_api_type_pkg.t_network_id default null
        , i_date_start     in date
        , i_date_end       in date
        ) ;

procedure percent_of_below_floor_limit(
    o_xml          out clob
  , i_lang          in com_api_type_pkg.t_dict_value
  , i_inst_id       in com_api_type_pkg.t_inst_id       default null
  , i_date_start    in date                             default null
  , i_date_end      in date                             default null
  , i_threshold     in com_api_type_pkg.t_short_id      default 1
);

end acq_api_audit_report_pkg;
/
