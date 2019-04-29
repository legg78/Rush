create or replace package body acc_ui_selection_priority_pkg is
/*********************************************************
 *  UI for Account selection priority <br />
 *  Created by Khougaev A.(khougaev@bpcbt.com)  at 20.09.2011 <br />
 *  Module: ACC_UI_SELECTION_PRIORITY_PKG <br />
 *  @headcom
 **********************************************************/

procedure add(
    o_id                  out  com_api_type_pkg.t_tiny_id
  , o_seqnum              out  com_api_type_pkg.t_seqnum
  , i_priority         in      com_api_type_pkg.t_tiny_id
  , i_inst_id          in      com_api_type_pkg.t_dict_value
  , i_oper_type        in      com_api_type_pkg.t_dict_value
  , i_account_type     in      com_api_type_pkg.t_dict_value
  , i_account_status   in      com_api_type_pkg.t_dict_value
  , i_party_type       in      com_api_type_pkg.t_dict_value
  , i_msg_type         in      com_api_type_pkg.t_dict_value
  , i_mod_id           in      com_api_type_pkg.t_dict_value    default null
  , i_account_currency in      com_api_type_pkg.t_curr_code     default null
) is
begin
    o_id     := acc_selection_priority_seq.nextval;
    o_seqnum := 1;

    insert into acc_selection_priority_vw (
        id
      , seqnum
      , inst_id
      , oper_type
      , account_type
      , account_status
      , priority
      , party_type
      , msg_type
      , mod_id
      , account_currency
    ) values (
        o_id
      , o_seqnum
      , i_inst_id
      , i_oper_type
      , i_account_type
      , i_account_status
      , i_priority
      , i_party_type
      , i_msg_type
      , i_mod_id
      , i_account_currency
    );
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATED_ACC_SELECTION_PRIORITY'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_oper_type
          , i_env_param3 => i_account_type
          , i_env_param4 => i_account_status
          , i_env_param5 => i_party_type
          , i_env_param6 => i_msg_type
        );
end add;

procedure modify(
    i_id               in      com_api_type_pkg.t_tiny_id
  , io_seqnum          in out  com_api_type_pkg.t_seqnum
  , i_priority         in      com_api_type_pkg.t_tiny_id
  , i_inst_id          in      com_api_type_pkg.t_dict_value
  , i_oper_type        in      com_api_type_pkg.t_dict_value
  , i_account_type     in      com_api_type_pkg.t_dict_value
  , i_account_status   in      com_api_type_pkg.t_dict_value
  , i_party_type       in      com_api_type_pkg.t_dict_value
  , i_msg_type         in      com_api_type_pkg.t_dict_value
  , i_mod_id           in      com_api_type_pkg.t_dict_value    default null
  , i_account_currency in      com_api_type_pkg.t_curr_code     default null
) is
begin
    update acc_selection_priority_vw
       set seqnum           = io_seqnum
         , inst_id          = i_inst_id
         , oper_type        = i_oper_type
         , account_type     = i_account_type
         , account_status   = i_account_status
         , priority         = i_priority
         , party_type       = i_party_type
         , msg_type         = i_msg_type
         , mod_id           = i_mod_id
         , account_currency = i_account_currency
     where id               = i_id;

    io_seqnum := io_seqnum + 1;
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATED_ACC_SELECTION_PRIORITY'
          , i_env_param1 => i_inst_id
          , i_env_param2 => i_oper_type
          , i_env_param3 => i_account_type
          , i_env_param4 => i_account_status
          , i_env_param5 => i_party_type
          , i_env_param6 => i_msg_type
        );
end modify;

procedure delete(
    i_id          in     com_api_type_pkg.t_tiny_id
  , i_seqnum      in     com_api_type_pkg.t_seqnum
) is
begin
    update acc_selection_priority_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete from acc_selection_priority_vw
     where id     = i_id;
end;

end;
/
