create or replace package body dpp_api_instalment_pkg as
/*********************************************************
*  API for DPP instalment <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: DPP_API_INSTALMENT_PKG <br />
*  @headcom
**********************************************************/

procedure add_instalment(
    o_id                         out com_api_type_pkg.t_long_id
  , i_dpp_id                  in     com_api_type_pkg.t_long_id
  , i_instalment_number       in     com_api_type_pkg.t_tiny_id
  , i_instalment_date         in     date
  , i_instalment_amount       in     com_api_type_pkg.t_money
  , i_payment_amount          in     com_api_type_pkg.t_money
  , i_interest_amount         in     com_api_type_pkg.t_money
  , i_macros_id               in     com_api_type_pkg.t_long_id
  , i_macros_intr_id          in     com_api_type_pkg.t_long_id  
  , i_acceleration_type       in     com_api_type_pkg.t_dict_value
  , i_split_hash              in     com_api_type_pkg.t_tiny_id
  , i_fee_id                  in     com_api_type_pkg.t_short_id    default null
  , i_acceleration_reason     in     com_api_type_pkg.t_dict_value  default null
) is
begin
    o_id := com_api_id_pkg.get_id(
                i_seq        => dpp_instalment_seq.nextval
              , i_object_id  => i_dpp_id
            );

    insert into dpp_instalment(
        id
      , dpp_id
      , instalment_number
      , instalment_date
      , instalment_amount
      , payment_amount
      , interest_amount
      , macros_id
      , macros_intr_id
      , acceleration_type
      , split_hash
      , fee_id
      , acceleration_reason
    ) values (
        o_id
      , i_dpp_id
      , i_instalment_number
      , i_instalment_date
      , i_instalment_amount
      , i_payment_amount
      , i_interest_amount
      , i_macros_id
      , i_macros_intr_id
      , i_acceleration_type
      , i_split_hash
      , i_fee_id
      , i_acceleration_reason
    );
end add_instalment;

function get_last_paid_instalm_number(
    i_dpp_id                  in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_tiny_id is
    l_last_instalment_number          com_api_type_pkg.t_tiny_id;
begin
    select nvl(max(instalment_number), 0)
      into l_last_instalment_number
      from dpp_instalment
     where dpp_id = i_dpp_id
       and macros_id is not null;

    return l_last_instalment_number;
end get_last_paid_instalm_number;

end;
/
