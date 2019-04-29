create or replace package acq_api_report_pkg is

procedure list_of_cash_sale (
        o_xml              out clob
        , i_lang           in com_api_type_pkg.t_dict_value
        , i_date_start     in date
        , i_date_end       in date
        , i_inst_id        in com_api_type_pkg.t_inst_id  default null
        , i_merchant_id    in com_api_type_pkg.t_short_id default null
        , i_terminal_id    in com_api_type_pkg.t_short_id default null
        , i_mode           in com_api_type_pkg.t_sign
);

procedure list_of_terminal
        ( o_xml          out clob
        , i_lang         in com_api_type_pkg.t_dict_value
        , i_inst_id      in com_api_type_pkg.t_tiny_id default null
        ) ;

procedure list_of_unconfirmed_auth (
    o_xml                   out clob
  , i_date_start             in date                           default null
  , i_date_end               in date                           default null
  , i_inst_id                in com_api_type_pkg.t_tiny_id     default null
  , i_agent_id               in com_api_type_pkg.t_short_id    default null
  , i_imprn                  in com_api_type_pkg.t_boolean     default 1
  , i_pos                    in com_api_type_pkg.t_boolean     default 1
  , i_atm                    in com_api_type_pkg.t_boolean     default 1
  , i_epos                   in com_api_type_pkg.t_boolean     default 1
  , i_lang                   in com_api_type_pkg.t_dict_value  default null
);

procedure list_of_chargeback
        ( o_xml          out clob
        , i_lang         in com_api_type_pkg.t_dict_value
        , i_date_start   in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_date_end     in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_network_id   in com_api_type_pkg.t_network_id
        , i_inst_id      in com_api_type_pkg.t_tiny_id
        );

procedure cash_payment_sum
        ( o_xml          out clob
        , i_lang         in com_api_type_pkg.t_dict_value
        , i_date_start   in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_date_end     in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_network_id   in com_api_type_pkg.t_network_id
        , i_inst_id      in com_api_type_pkg.t_tiny_id
        ) ;

procedure list_of_internet_shop
        ( o_xml          out clob
        , i_lang         in com_api_type_pkg.t_dict_value
        , i_date_start   in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_date_end     in date   default trunc(com_api_sttl_day_pkg.get_sysdate)
        , i_inst_id      in com_api_type_pkg.t_tiny_id  default null
        ) ;

procedure fin_chargeback (
    o_xml             out clob
    , i_lang           in com_api_type_pkg.t_dict_value
    , i_start_date     in date              default null
    , i_end_date       in date              default null
    , i_inst_id        in com_api_type_pkg.t_inst_id
    , i_network_id     in com_api_type_pkg.t_short_id
);

procedure list_of_unconmerchanted_auth(
    o_xml         out clob
  , i_lang         in com_api_type_pkg.t_dict_value
  , i_date_start   in date                              default null
  , i_date_end     in date                              default null
  , i_inst_id      in com_api_type_pkg.t_inst_id        default null
  , i_agent_id     in com_api_type_pkg.t_agent_id       default null
  , i_cash         in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_sale         in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_imprn        in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_pos          in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_atm          in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_epos         in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_unconmerch   in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
  , i_unprocess    in com_api_type_pkg.t_boolean        default com_api_const_pkg.TRUE
);

procedure aggregate_stat_bin_range_used(
    o_xml              out clob
  , i_lang              in com_api_type_pkg.t_dict_value    default null
  , i_year              in com_api_type_pkg.t_tiny_id
  , i_quarter           in com_api_type_pkg.t_sign
  , i_network_id        in com_api_type_pkg.t_network_id
  , i_inst_id           in com_api_type_pkg.t_inst_id
  , i_bin_range_start   in com_api_type_pkg.t_short_id
  , i_bin_range_end     in com_api_type_pkg.t_short_id
);

procedure acquiring_activity_report( 
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_customer_number   in     com_api_type_pkg.t_name
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value  default null
);

function get_merchant_data(
    i_merchant_id          com_api_type_pkg.t_short_id
) return varchar2;

procedure acq_merchant_activity_report(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_merchant_number   in     com_api_type_pkg.t_name        default null
  , i_start_date        in     date
  , i_end_date          in     date
  , i_lang              in     com_api_type_pkg.t_dict_value  default null
);

end acq_api_report_pkg;
/
