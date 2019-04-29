create or replace package com_api_i18n_pkg as

function get_text(
    i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_column_name       in      com_api_type_pkg.t_oracle_name
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_text;

procedure add_text(
    i_table_name    in      com_api_type_pkg.t_oracle_name
  , i_column_name   in      com_api_type_pkg.t_oracle_name
  , i_object_id     in      com_api_type_pkg.t_long_id
  , i_text          in      com_api_type_pkg.t_text
  , i_lang          in      com_api_type_pkg.t_dict_value   default null
  , i_check_unique  in      com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE 
);

procedure remove_text(
    i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_object_id         in      com_api_type_pkg.t_long_id
);

procedure remove_text(
    i_table_name        in      com_api_type_pkg.t_oracle_name
  , i_column_name       in      com_api_type_pkg.t_oracle_name
  , i_object_id         in      com_api_type_pkg.t_long_id
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
);

/*
 * Function returns TRUE if text <i_text> already exists for (i_table_name, i_column_name, i_inst_id) in COM_I18N.
 * Despite of procedure <add_text> in the package with flag i_check_unique => TRUE, 
 * this function provides checking only within the institute <i_inst_id> if it is defined.
 * Otherwise it executes the same check as used in <add_text> one. 
 */
function text_is_present(
    i_table_name    in      com_api_type_pkg.t_oracle_name
  , i_column_name   in      com_api_type_pkg.t_oracle_name
  , i_inst_id       in      com_api_type_pkg.t_inst_id
  , i_text          in      com_api_type_pkg.t_text
  , i_lang          in      com_api_type_pkg.t_dict_value   default null
) return com_api_type_pkg.t_boolean;

procedure check_text_for_latin(
    i_text                  in com_api_type_pkg.t_text
);

procedure load_translation(
    i_src_lang      in     com_api_type_pkg.t_dict_value -- Source language
  , i_dst_lang      in     com_api_type_pkg.t_dict_value -- Destination language
  , i_text_trans    in     com_text_trans_tpt            -- Translation text
);

end;
/
