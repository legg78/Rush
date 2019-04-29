create or replace package body acq_ui_reimb_channel_pkg as

procedure add_channel(
    o_channel_id           out  com_api_type_pkg.t_tiny_id
  , i_channel_number    in      com_api_type_pkg.t_name
  , i_payment_mode      in      com_api_type_pkg.t_dict_value
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_channel_name      in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) is
begin
    select acq_reimb_channel_seq.nextval into o_channel_id from dual;

    insert into acq_reimb_channel_vw(
        id
      , channel_number
      , payment_mode
      , currency
      , inst_id
      , seqnum
    ) values (
        o_channel_id
      , i_channel_number
      , i_payment_mode
      , i_currency
      , i_inst_id
      , 1
    );

    if i_channel_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name        => 'acq_reimb_channel'
          , i_column_name       => 'name'
          , i_object_id         => o_channel_id
          , i_text              => i_channel_name
          , i_lang              => i_lang
        );
    end if;
end;

procedure modify_channel(
    i_channel_id        in      com_api_type_pkg.t_tiny_id
  , i_channel_number    in      com_api_type_pkg.t_name
  , i_payment_mode      in      com_api_type_pkg.t_dict_value
  , i_currency          in      com_api_type_pkg.t_curr_code
  , i_seqnum            in      com_api_type_pkg.t_seqnum
  , i_channel_name      in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) is
begin
    update acq_reimb_channel_vw
       set channel_number = i_channel_number
         , payment_mode   = i_payment_mode
         , currency       = i_currency
         , seqnum         = i_seqnum
     where id             = i_channel_id;

    if i_channel_name is not null then
        com_api_i18n_pkg.add_text(
            i_table_name        => 'acq_reimb_channel'
          , i_column_name       => 'name'
          , i_object_id         => i_channel_id
          , i_text              => i_channel_name
          , i_lang              => i_lang
        );
    end if;
end;

procedure remove_channel(
    i_channel_id        in      com_api_type_pkg.t_tiny_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    update acq_reimb_channel_vw
       set seqnum         = i_seqnum
     where id             = i_channel_id;

    delete from acq_reimb_channel_vw
     where id             = i_channel_id;

    com_api_i18n_pkg.remove_text(
        i_table_name        => 'acq_reimb_channel'
      , i_object_id         => i_channel_id
    );
end;

end;
/
