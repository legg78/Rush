create or replace package body acq_ui_terminal_templ_pkg as
/*********************************************************
 *  UI for terminal templates  <br />
 *  Created by Filimonov A.(filimonov@bpcbt.com)  at 18.08.2009 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: acq_ui_terminal_templ_pkg <br />
 *  @headcom
 **********************************************************/
procedure add_template(
    o_template_id               out  com_api_type_pkg.t_short_id
  , i_terminal_type          in      com_api_type_pkg.t_dict_value
  , i_standard_id            in      com_api_type_pkg.t_tiny_id
  , i_card_data_input_cap    in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_cap          in      com_api_type_pkg.t_dict_value
  , i_card_capture_cap       in      com_api_type_pkg.t_dict_value
  , i_term_operating_env     in      com_api_type_pkg.t_dict_value
  , i_crdh_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_input_mode   in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_method       in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_entity       in      com_api_type_pkg.t_dict_value
  , i_card_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_term_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_pin_capture_cap        in      com_api_type_pkg.t_dict_value
  , i_cat_level              in      com_api_type_pkg.t_dict_value
  , i_status                 in      com_api_type_pkg.t_dict_value
  , i_is_mac                 in      com_api_type_pkg.t_boolean
  , i_gmt_offset             in      com_api_type_pkg.t_tiny_id
  , i_name                   in      com_api_type_pkg.t_full_desc    default null
  , i_description            in      com_api_type_pkg.t_full_desc    default null
  , i_lang                   in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id                in      com_api_type_pkg.t_boolean
  , i_cash_dispenser_present in      com_api_type_pkg.t_boolean
  , i_payment_possibility    in      com_api_type_pkg.t_boolean
  , i_use_card_possibility   in      com_api_type_pkg.t_boolean
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_available_network      in      com_api_type_pkg.t_short_id
  , i_available_operation    in      com_api_type_pkg.t_short_id
  , i_available_currency     in      com_api_type_pkg.t_short_id
  , i_mcc_template_id        in      com_api_type_pkg.t_medium_id
  , i_terminal_profile       in      com_api_type_pkg.t_medium_id    default null
  , i_pin_block_format       in      com_api_type_pkg.t_dict_value   default null
  , i_pos_batch_support      in      com_api_type_pkg.t_dict_value   default null
) is
    l_com_i18n_id                    com_api_type_pkg.t_medium_id;
begin
    l_com_i18n_id := com_i18n_seq.nextval;

    if substr(to_char(l_com_i18n_id), 1, 1) = '1' then
        o_template_id := acq_terminal_seq.nextval;
    else
        select nvl(max(id), to_number(rpad(substr(to_char(l_com_i18n_id), 1, 1), 8, '0'))) + 1
          into o_template_id
          from acq_terminal_vw
         where substr(to_char(id), 1, 1) =  substr(to_char(l_com_i18n_id), 1, 1);
    end if;

    insert into acq_terminal_vw(
        id
      , terminal_type
      , card_data_input_cap
      , crdh_auth_cap
      , card_capture_cap
      , term_operating_env
      , crdh_data_present
      , card_data_present
      , card_data_input_mode
      , crdh_auth_method
      , crdh_auth_entity
      , card_data_output_cap
      , term_data_output_cap
      , pin_capture_cap
      , cat_level
      , status
      , is_mac
      , gmt_offset
      , seqnum
      , inst_id
      , is_template
      , split_hash
      , cash_dispenser_present
      , payment_possibility
      , use_card_possibility
      , cash_in_present
      , available_network
      , available_operation
      , available_currency
      , mcc_template_id
      , terminal_profile
      , pin_block_format
      , pos_batch_support
    ) values (
        o_template_id
      , i_terminal_type
      , i_card_data_input_cap
      , i_crdh_auth_cap
      , i_card_capture_cap
      , i_term_operating_env
      , i_crdh_data_present
      , i_card_data_present
      , i_card_data_input_mode
      , i_crdh_auth_method
      , i_crdh_auth_entity
      , i_card_data_output_cap
      , i_term_data_output_cap
      , i_pin_capture_cap
      , i_cat_level
      , i_status
      , i_is_mac
      , i_gmt_offset
      , 1
      , i_inst_id
      , com_api_type_pkg.TRUE
      , com_api_hash_pkg.get_split_hash(o_template_id)
      , i_cash_dispenser_present
      , i_payment_possibility
      , i_use_card_possibility
      , i_cash_in_present
      , i_available_network
      , i_available_operation
      , i_available_currency
      , i_mcc_template_id
      , i_terminal_profile
      , i_pin_block_format
      , i_pos_batch_support
    );

    cmn_ui_standard_object_pkg.add_standard_object (
        i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id      => o_template_id
      , i_standard_id    => i_standard_id
    );

    if i_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'acq_terminal'
          , i_column_name   => 'name'
          , i_object_id     => o_template_id
          , i_lang          => i_lang
          , i_text          => i_name
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'acq_terminal'
          , i_column_name   => 'description'
          , i_object_id     => o_template_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure modify_template(
    i_template_id            in      com_api_type_pkg.t_short_id
  , i_standard_id            in      com_api_type_pkg.t_tiny_id
  , i_card_data_input_cap    in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_cap          in      com_api_type_pkg.t_dict_value
  , i_card_capture_cap       in      com_api_type_pkg.t_dict_value
  , i_term_operating_env     in      com_api_type_pkg.t_dict_value
  , i_crdh_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_present      in      com_api_type_pkg.t_dict_value
  , i_card_data_input_mode   in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_method       in      com_api_type_pkg.t_dict_value
  , i_crdh_auth_entity       in      com_api_type_pkg.t_dict_value
  , i_card_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_term_data_output_cap   in      com_api_type_pkg.t_dict_value
  , i_pin_capture_cap        in      com_api_type_pkg.t_dict_value
  , i_cat_level              in      com_api_type_pkg.t_dict_value
  , i_status                 in      com_api_type_pkg.t_dict_value
  , i_is_mac                 in      com_api_type_pkg.t_boolean
  , i_gmt_offset             in      com_api_type_pkg.t_tiny_id
  , i_name                   in      com_api_type_pkg.t_full_desc    default null
  , i_description            in      com_api_type_pkg.t_full_desc    default null
  , i_lang                   in      com_api_type_pkg.t_dict_value   default null
  , i_cash_dispenser_present in      com_api_type_pkg.t_boolean
  , i_payment_possibility    in      com_api_type_pkg.t_boolean
  , i_use_card_possibility   in      com_api_type_pkg.t_boolean
  , i_cash_in_present        in      com_api_type_pkg.t_boolean
  , i_available_network      in      com_api_type_pkg.t_short_id
  , i_available_operation    in      com_api_type_pkg.t_short_id
  , i_available_currency     in      com_api_type_pkg.t_short_id
  , i_mcc_template_id        in      com_api_type_pkg.t_medium_id
  , i_terminal_profile       in      com_api_type_pkg.t_medium_id    default null
  , i_pin_block_format       in      com_api_type_pkg.t_dict_value   default null
  , i_pos_batch_support      in      com_api_type_pkg.t_dict_value   default null
) is
begin
    update acq_terminal_vw
       set card_data_input_cap    = i_card_data_input_cap
         , crdh_auth_cap          = i_crdh_auth_cap
         , card_capture_cap       = i_card_capture_cap
         , term_operating_env     = i_term_operating_env
         , crdh_data_present      = i_crdh_data_present
         , card_data_present      = i_card_data_present
         , card_data_input_mode   = i_card_data_input_mode
         , crdh_auth_method       = i_crdh_auth_method
         , crdh_auth_entity       = i_crdh_auth_entity
         , card_data_output_cap   = i_card_data_output_cap
         , term_data_output_cap   = i_term_data_output_cap
         , pin_capture_cap        = i_pin_capture_cap
         , cat_level              = i_cat_level
         , status                 = i_status
         , is_mac                 = i_is_mac
         , gmt_offset             = i_gmt_offset
         , cash_dispenser_present = i_cash_dispenser_present
         , payment_possibility    = i_payment_possibility
         , use_card_possibility   = i_use_card_possibility
         , cash_in_present        = i_cash_in_present
         , available_network      = i_available_network
         , available_operation    = i_available_operation
         , available_currency     = i_available_currency
         , mcc_template_id        = i_mcc_template_id
         , terminal_profile       = i_terminal_profile
         , pin_block_format       = i_pin_block_format
         , pos_batch_support      = i_pos_batch_support
     where id                     = i_template_id
       and is_template            = com_api_type_pkg.TRUE;

    cmn_ui_standard_object_pkg.add_standard_object (
        i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id      => i_template_id
      , i_standard_id    => i_standard_id
    );

    if i_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'acq_terminal'
          , i_column_name   => 'name'
          , i_object_id     => i_template_id
          , i_lang          => i_lang
          , i_text          => i_name
          , i_check_unique  => com_api_type_pkg.TRUE
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'acq_terminal'
          , i_column_name   => 'description'
          , i_object_id     => i_template_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure remove_template(
    i_template_id           in      com_api_type_pkg.t_short_id
) is
begin
    cmn_ui_standard_object_pkg.remove_standard_object (
        i_entity_type    => acq_api_const_pkg.ENTITY_TYPE_TERMINAL
      , i_object_id      => i_template_id
    );

    delete from acq_terminal_vw
     where id          = i_template_id
       and is_template = com_api_type_pkg.TRUE;

    com_api_i18n_pkg.remove_text(
        i_table_name        => 'acq_terminal'
      , i_object_id         => i_template_id
    );

end;

end;
/
