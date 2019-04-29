create or replace package body dpp_api_attribute_value_pkg is
/*********************************************************
*  API for mod attribute values <br />
*  Created by  E. Kryukov(krukov@bpc.ru)  at 07.09.2011 <br />
*  Module: DPP_API_ATTRIBUTE_VALUE_PKG <br />
*  @headcom
**********************************************************/

procedure add(
    i_dpp_id        in     com_api_type_pkg.t_long_id
  , i_attr_id       in     com_api_type_pkg.t_short_id
  , i_mod_id        in     com_api_type_pkg.t_tiny_id
  , i_value         in     com_api_type_pkg.t_name
  , i_split_hash    in     com_api_type_pkg.t_tiny_id
) is
    l_id                   com_api_type_pkg.t_long_id;
begin
    l_id := com_api_id_pkg.get_id(
                i_seq        => dpp_attribute_value_seq.nextval
              , i_object_id  => i_dpp_id
            );

    insert into dpp_attribute_value_vw(
        id
      , dpp_id
      , attr_id
      , mod_id
      , value
      , split_hash
    ) values (
        l_id
      , i_dpp_id
      , i_attr_id
      , i_mod_id
      , i_value
      , i_split_hash
    );
end add;

procedure save_attribute_values(
    i_dpp          in     dpp_api_type_pkg.t_dpp_program
) as

    procedure save_value(
        i_attr_name    in     com_api_type_pkg.t_attr_name
      , i_attr_value   in     com_api_type_pkg.t_name
    ) as
    begin
        if i_attr_value is not null then
            dpp_api_attribute_value_pkg.add(
                i_dpp_id     => i_dpp.dpp_id
              , i_attr_id    => prd_api_attribute_pkg.get_attribute(
                                    i_attr_name  => i_attr_name
                                  , i_mask_error => com_api_const_pkg.FALSE
                                ).id
              , i_mod_id     => null
              , i_value      => i_attr_value
              , i_split_hash => i_dpp.split_hash
            );
        end if;
    end;

begin
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_INSTALMENT_COUNT
      , i_attr_value => to_char(i_dpp.instalment_count, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_FIRST_CYCLE_ID
      , i_attr_value => to_char(i_dpp.first_cycle_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_MAIN_CYCLE_ID
      , i_attr_value => to_char(i_dpp.main_cycle_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_FEE_ID
      , i_attr_value => to_char(i_dpp.fee_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_ALGORITHM
      , i_attr_value => i_dpp.calc_algorithm
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_FIXED_INSTALMENTS
      , i_attr_value => to_char(i_dpp.fixed_instalment, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_ACCEL_FEE_ID
      , i_attr_value => to_char(i_dpp.accel_fee_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_MIN_EARLY_REPAYMENT
      , i_attr_value => to_char(i_dpp.min_early_repayment, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_CANCEL_FEE_ID
      , i_attr_value => to_char(i_dpp.cancel_fee_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_LIMIT
      , i_attr_value => to_char(i_dpp.dpp_limit, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_MACROS_TYPE_ID
      , i_attr_value => to_char(i_dpp.macros_type_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_MACROS_INTR_TYPE_ID
      , i_attr_value => to_char(i_dpp.macros_intr_type_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_REPAY_MACROS_TYPE_ID
      , i_attr_value => to_char(i_dpp.repay_macros_type_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_CANCEL_M_TYPE_ID
      , i_attr_value => to_char(i_dpp.cancel_m_type_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_CANCEL_M_INTR_TYPE_ID
      , i_attr_value => to_char(i_dpp.cancel_m_intr_type_id, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_RATE_ALGORITHM
      , i_attr_value => i_dpp.rate_algorithm
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_CREDIT_MACROS_TYPE
      , i_attr_value => to_char(i_dpp.credit_macros_type, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_CREDIT_MACROS_INTR_TYPE
      , i_attr_value => to_char(i_dpp.credit_macros_intr_type, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_CREDIT_REPAY_MACROS_TYPE
      , i_attr_value => to_char(i_dpp.credit_repay_macros_type, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_CANCEL_CREDIT_M_TYPE
      , i_attr_value => to_char(i_dpp.cancel_credit_m_type, com_api_const_pkg.NUMBER_FORMAT)
    );
    save_value(
        i_attr_name  => dpp_api_const_pkg.ATTR_CANCEL_INTR_CREDIT_M_TYPE
      , i_attr_value => to_char(i_dpp.cancel_intr_credit_m_type, com_api_const_pkg.NUMBER_FORMAT)
    );
end save_attribute_values;

end;
/
