create or replace package body rul_ui_name_base_param_pkg is
/*********************************************************
*  UI for naming base parameters <br />
*  Created by Khougaev A.(khougaev@bpc.ru)  at 14.05.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: RUL_UI_NAME_BASE_PARAM_PKG <br />
*  @headcom
**********************************************************/ 
procedure add (
    o_id                 out com_api_type_pkg.t_short_id
  , i_entity_type     in     com_api_type_pkg.t_dict_value
  , i_name            in     com_api_type_pkg.t_name
  , i_lang            in     com_api_type_pkg.t_dict_value
  , i_description     in     com_api_type_pkg.t_text
) is
begin
    o_id := rul_name_base_param_seq.nextval;

    insert into rul_name_base_param_vw (
        id
        , entity_type
        , name
    ) values (
        o_id
        , i_entity_type
        , i_name
    );

    com_api_i18n_pkg.add_text (
        i_table_name   => 'rul_name_base_param' 
      , i_column_name  => 'description' 
      , i_object_id    => o_id
      , i_lang         => i_lang
      , i_text         => i_description
    );
end add;

end rul_ui_name_base_param_pkg;
/
