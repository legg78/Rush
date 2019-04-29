create or replace package body com_ui_array_conv_elem_pkg is
/*********************************************************
*  UI for array conversion_elements<br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 01.07.2011 <br />
*  Last changed by $Author: fomichev$ <br />
*  $LastChangedDate:: 2011-07-01 13:31:16 +0400#$ <br />
*  Revision: $LastChangedRevision: 10600 $ <br />
*  Module: com_ui_array_conv_elem_pkg <br />
*  @headcom
**********************************************************/
procedure add_array_conv_elem (
    o_id                   out  com_api_type_pkg.t_short_id
  , i_conv_id           in      com_api_type_pkg.t_tiny_id
  , i_in_element_value  in      com_api_type_pkg.t_name
  , i_out_element_value in      com_api_type_pkg.t_name
) is
begin
    o_id := com_array_conv_elem_seq.nextval;

    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.add_array_conv_elem: '
                     || 'o_id [#4], i_conv_id [#1], i_in_element_value [#2], i_out_element_value [#3]'
      , i_env_param1 => i_conv_id
      , i_env_param2 => i_in_element_value
      , i_env_param3 => i_out_element_value
      , i_env_param4 => o_id
    );

    insert into com_array_conv_elem_vw (
        id
      , conv_id
      , in_element_value
      , out_element_value
    ) values (
        o_id
      , i_conv_id
      , i_in_element_value
      , i_out_element_value
    );
    
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error         => 'DUPLICATE_CONVERSION_ELEMENT'
          , i_env_param1    => i_conv_id
          , i_env_param2    => i_in_element_value
        );
end;

procedure modify_array_conv_elem (
    i_id                in      com_api_type_pkg.t_short_id
  , i_conv_id           in      com_api_type_pkg.t_tiny_id
  , i_in_element_value  in      com_api_type_pkg.t_name
  , i_out_element_value in      com_api_type_pkg.t_name
) is
begin
    trc_log_pkg.debug(
        i_text       => lower($$PLSQL_UNIT) || '.add_array_conv_elem: '
                     || 'i_id [#4], i_conv_id [#1], i_in_element_value [#2], i_out_element_value [#3]'
      , i_env_param1 => i_conv_id
      , i_env_param2 => i_in_element_value
      , i_env_param3 => i_out_element_value
      , i_env_param4 => i_id
    );

    update com_array_conv_elem_vw
       set conv_id           = i_conv_id
         , in_element_value  = i_in_element_value
         , out_element_value = i_out_element_value
     where id                = i_id;
    
exception
    when dup_val_on_index then
        com_api_error_pkg.raise_error(
            i_error         => 'DUPLICATE_CONVERSION_ELEMENT'
          , i_env_param1    => i_conv_id
          , i_env_param2    => i_in_element_value
        );
end;

procedure remove_array_conv_elem (
    i_id      in      com_api_type_pkg.t_short_id
) is
begin
    delete from com_array_conv_elem_vw
     where id = i_id;
end;

end;
/
