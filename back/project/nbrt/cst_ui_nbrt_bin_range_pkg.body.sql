create or replace package body cst_ui_nbrt_bin_range_pkg as

procedure add_nbrt_bin_range(
    o_nbrt_bin_range_id    out  com_api_type_pkg.t_short_id
  , i_pan_low           in      com_api_type_pkg.t_bin
  , i_pan_high          in      com_api_type_pkg.t_bin
  , i_pan_length        in      com_api_type_pkg.t_tiny_id
  , i_priority          in      com_api_type_pkg.t_tiny_id
  , i_country           in      com_api_type_pkg.t_country_code
  , i_iss_network_id    in      com_api_type_pkg.t_network_id
  , i_label             in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) is
begin
    o_nbrt_bin_range_id := cst_nbrt_bin_range_seq.nextval;

    insert into cst_nbrt_bin_range (
        id
      , pan_low
      , pan_high
      , pan_length
      , priority
      , country
      , iss_network_id
    ) values (
        o_nbrt_bin_range_id
      , i_pan_low
      , i_pan_high
      , i_pan_length
      , i_priority
      , i_country
      , i_iss_network_id
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'cst_nbrt_bin_range'
      , i_column_name  => 'label'
      , i_object_id    => o_nbrt_bin_range_id
      , i_lang         => i_lang
      , i_text         => i_label
    );
end add_nbrt_bin_range;

procedure modify_nbrt_bin_range(
    i_nbrt_bin_range_id in      com_api_type_pkg.t_short_id
  , i_label             in      com_api_type_pkg.t_name
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_pan_low           in      com_api_type_pkg.t_bin
  , i_pan_high          in      com_api_type_pkg.t_bin
  , i_pan_length        in      com_api_type_pkg.t_tiny_id
  , i_priority          in      com_api_type_pkg.t_tiny_id
  , i_country           in      com_api_type_pkg.t_country_code
  , i_iss_network_id    in      com_api_type_pkg.t_network_id
) is
begin
    update cst_nbrt_bin_range
       set pan_low = coalesce(i_pan_low, pan_low)
         , pan_high = coalesce(i_pan_high, pan_high)
         , pan_length = coalesce(i_pan_length, pan_length)
         , priority = coalesce(i_priority, priority)
         , country = coalesce(i_country, country)
         , iss_network_id = coalesce(i_iss_network_id, iss_network_id)
     where id = i_nbrt_bin_range_id;

    com_api_i18n_pkg.add_text (
        i_table_name   => 'cst_nbrt_bin_range'
      , i_column_name  => 'label'
      , i_object_id    => i_nbrt_bin_range_id
      , i_lang         => i_lang
      , i_text         => i_label
    );
end modify_nbrt_bin_range;

procedure remove_nbrt_bin_range(
    i_nbrt_bin_range_id in      com_api_type_pkg.t_short_id
) is
begin
    delete from cst_nbrt_bin_range
     where id = i_nbrt_bin_range_id;
    
    com_api_i18n_pkg.remove_text (
        i_table_name   => 'cst_nbrt_bin_range'
        , i_object_id  => i_nbrt_bin_range_id
    );
end remove_nbrt_bin_range;

end;
/
