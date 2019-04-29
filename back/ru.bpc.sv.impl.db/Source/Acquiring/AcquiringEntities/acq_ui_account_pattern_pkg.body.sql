create or replace package body acq_ui_account_pattern_pkg as


procedure add_account_pattern(
    o_id                  out  com_api_type_pkg.t_medium_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_scheme_id        in      com_api_type_pkg.t_tiny_id
  , i_oper_type        in      com_api_type_pkg.t_dict_value
  , i_oper_reason      in      com_api_type_pkg.t_dict_value
  , i_sttl_type        in      com_api_type_pkg.t_dict_value
  , i_terminal_type    in      com_api_type_pkg.t_dict_value
  , i_currency         in      com_api_type_pkg.t_curr_code
  , i_oper_sign        in      com_api_type_pkg.t_boolean
  , i_merchant_type    in      com_api_type_pkg.t_dict_value
  , i_account_type     in      com_api_type_pkg.t_dict_value
  , i_account_currency in      com_api_type_pkg.t_curr_code
  , i_priority         in      com_api_type_pkg.t_tiny_id
) is
begin
    o_id     := acq_account_pattern_seq.nextval;
    o_seqnum := 1;

    insert into acq_account_pattern_vw(
        id
      , seqnum
      , scheme_id
      , oper_type
      , oper_reason
      , sttl_type
      , terminal_type
      , currency
      , oper_sign
      , merchant_type
      , account_type
      , account_currency
      , priority
    ) values (
        o_id
      , o_seqnum
      , i_scheme_id
      , i_oper_type
      , i_oper_reason
      , i_sttl_type
      , i_terminal_type
      , i_currency
      , i_oper_sign
      , i_merchant_type
      , i_account_type
      , i_account_currency
      , i_priority
    );
end;

procedure modify_account_pattern(
    i_id               in      com_api_type_pkg.t_medium_id
  , io_seqnum          in out  com_api_type_pkg.t_seqnum
  , i_scheme_id        in      com_api_type_pkg.t_tiny_id
  , i_oper_type        in      com_api_type_pkg.t_dict_value
  , i_oper_reason      in      com_api_type_pkg.t_dict_value
  , i_sttl_type        in      com_api_type_pkg.t_dict_value
  , i_terminal_type    in      com_api_type_pkg.t_dict_value
  , i_currency         in      com_api_type_pkg.t_curr_code
  , i_oper_sign        in      com_api_type_pkg.t_boolean
  , i_merchant_type    in      com_api_type_pkg.t_dict_value
  , i_account_type     in      com_api_type_pkg.t_dict_value
  , i_account_currency in      com_api_type_pkg.t_curr_code
  , i_priority         in      com_api_type_pkg.t_tiny_id
) is
begin
    update acq_account_pattern_vw
       set seqnum           = io_seqnum
         , scheme_id        = i_scheme_id
         , oper_type        = i_oper_type
         , oper_reason      = i_oper_reason
         , sttl_type        = i_sttl_type
         , terminal_type    = i_terminal_type
         , currency         = i_currency
         , oper_sign        = i_oper_sign
         , merchant_type    = i_merchant_type
         , account_type     = i_account_type
         , account_currency = i_account_currency
         , priority         = i_priority
     where id               = i_id;

    io_seqnum   := io_seqnum + 1;
end;

procedure remove_account_pattern (
    i_id               in      com_api_type_pkg.t_medium_id
  , i_seqnum           in      com_api_type_pkg.t_seqnum
) is
begin
    update acq_account_pattern_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from acq_account_pattern_vw
     where id     = i_id;
end;

end;
/
