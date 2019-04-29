create or replace package body com_api_object_pkg as
/*********************************************************
*  Common object <br />
*  Created by Nick (filimonov@bpcbt.com)  at 13.03.2019 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: com_api_object_pkg <br />
*  @headcom
**********************************************************/

function get_object_number(
    i_entity_type       in com_api_type_pkg.t_dict_value
  , i_object_id         in com_api_type_pkg.t_long_id
  , i_mask_error        in com_api_type_pkg.t_boolean             default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_name
is
    l_number       com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => 'get_object_number: i_entity_type [#1], i_object_id [#2]'
      , i_env_param1 => i_entity_type
      , i_env_param2 => i_object_id
    );

    l_number :=
    case i_entity_type
        when acc_api_const_pkg.ENTITY_TYPE_ACCOUNT
        then
            acc_api_account_pkg.get_account_number(
                i_account_id => i_object_id
              , i_mask_error  => i_mask_error
            )
        when acq_api_const_pkg.ENTITY_TYPE_TERMINAL
        then
            acq_api_terminal_pkg.get_terminal_number(
                i_terminal_id => i_object_id
              , i_mask_error  => i_mask_error
            )
        when acq_api_const_pkg.ENTITY_TYPE_MERCHANT
        then
            acq_api_merchant_pkg.get_merchant_number(
                i_merchant_id => i_object_id
              , i_mask_error  => i_mask_error
            )
        when iss_api_const_pkg.ENTITY_TYPE_CARD
        then
            iss_api_card_pkg.get_card_number(
                i_card_id     => i_object_id
              , i_mask_error  => i_mask_error
            )
        when prd_api_const_pkg.ENTITY_TYPE_CUSTOMER
        then
            prd_api_customer_pkg.get_customer_number(
                i_customer_id => i_object_id
              , i_mask_error  => i_mask_error
            )
        else i_object_id
    end;

    return l_number;
exception
    when no_data_found then
        trc_log_pkg.debug(
            i_text       => 'get_object_number: object number is not found'
        );
        return l_number;
end get_object_number;

end com_api_object_pkg;
/
