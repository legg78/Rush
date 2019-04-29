create or replace package body acq_ui_mcc_selection_pkg as
/*********************************************************
 *  UI for MCC selection <br />
 *  Created by Krukov E.(krukov@bpcbt.com)  at 13.12.2011 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: ACQ_UI_MCC_SELECTION_PKG  <br />
 *  @headcom
 **********************************************************/

procedure add (
    o_id                        out com_api_type_pkg.t_medium_id
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_priority                in com_api_type_pkg.t_tiny_id
    , i_mcc                     in com_api_type_pkg.t_mcc
    , i_mcc_template_id         in com_api_type_pkg.t_medium_id
    , i_purpose_id              in com_api_type_pkg.t_short_id
    , i_oper_reason             in com_api_type_pkg.t_dict_value
    , i_merchant_name_spec      in clob
    , i_terminal_id             in com_api_type_pkg.t_medium_id
) is
begin
    o_id := acq_mcc_selection_seq.nextval;
    
    insert into acq_mcc_selection_vw (
        id
        , oper_type
        , priority
        , mcc
        , mcc_template_id
        , purpose_id
        , oper_reason
        , merchant_name_spec
        , terminal_id
    ) values (
        o_id
        , i_oper_type
        , i_priority
        , i_mcc
        , i_mcc_template_id
        , i_purpose_id
        , i_oper_reason
        , i_merchant_name_spec
        , i_terminal_id
    );
exception
    when dup_val_on_index then -- the unique constraint: (oper_type, mcc, purpose_id, oper_reason)
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_MCC_SELECTION'
          , i_env_param1 => i_mcc
          , i_env_param2 => i_oper_type
          , i_env_param3 => i_purpose_id
          , i_env_param4 => i_oper_reason
        );
end;

procedure modify (
    i_id                        in com_api_type_pkg.t_medium_id
    , i_oper_type               in com_api_type_pkg.t_dict_value
    , i_priority                in com_api_type_pkg.t_tiny_id
    , i_mcc                     in com_api_type_pkg.t_mcc
    , i_mcc_template_id         in com_api_type_pkg.t_medium_id
    , i_purpose_id              in com_api_type_pkg.t_short_id
    , i_oper_reason             in com_api_type_pkg.t_dict_value
    , i_merchant_name_spec      in clob
    , i_terminal_id             in com_api_type_pkg.t_medium_id
) is
begin
    update
        acq_mcc_selection_vw
    set
        oper_type = i_oper_type
        , priority = i_priority
        , mcc = i_mcc
        , mcc_template_id = i_mcc_template_id
        , purpose_id = i_purpose_id
        , oper_reason = i_oper_reason
        , merchant_name_spec = i_merchant_name_spec
        , terminal_id = i_terminal_id
    where
        id = i_id;
exception
    when dup_val_on_index then -- the unique constraint: (oper_type, mcc, purpose_id, oper_reason)
        com_api_error_pkg.raise_error(
            i_error      => 'DUPLICATE_MCC_SELECTION'
          , i_env_param1 => i_mcc
          , i_env_param2 => i_oper_type
          , i_env_param3 => i_purpose_id
          , i_env_param4 => i_oper_reason
        );
end;

procedure remove (
    i_id                        in com_api_type_pkg.t_medium_id
) is
begin
    delete from
        acq_mcc_selection_vw
    where
        id = i_id;
end;

end;
/
