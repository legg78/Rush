create or replace package body atm_ui_scenario_pkg as
/*******************************************************************
*  API for application's structure <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 13.09.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_api_structure_pkg <br />
*  @headcom
******************************************************************/
procedure add_scenario(
    o_id              out  com_api_type_pkg.t_tiny_id
  , i_luno         in      com_api_type_pkg.t_medium_id
  , i_atm_type     in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
  , i_lang         in      com_api_type_pkg.t_dict_value   default null
) is
begin
    select atm_scenario_seq.nextval
      into o_id
      from dual;
      
    insert into atm_scenario_vw(
        id
      , luno
      , atm_type
    ) values (
        o_id
      , i_luno
      , i_atm_type
    );
    
    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'atm_scenario'
          , i_column_name  => 'label'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'atm_scenario'
          , i_column_name   => 'description'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure modify_scenario(
    i_id           in      com_api_type_pkg.t_tiny_id
  , i_luno         in      com_api_type_pkg.t_medium_id
  , i_atm_type     in      com_api_type_pkg.t_dict_value
  , i_label        in      com_api_type_pkg.t_name
  , i_description  in      com_api_type_pkg.t_full_desc
  , i_lang         in      com_api_type_pkg.t_dict_value   default null
) is
begin
    update atm_scenario_vw
       set luno     = i_luno
         , atm_type = i_atm_type 
     where id       = i_id;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'atm_scenario'
          , i_column_name  => 'label'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'atm_scenario'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;
end;

procedure remove_scenario(
    i_id  in      com_api_type_pkg.t_tiny_id
) is
begin
    delete from atm_scenario_vw
    where id = i_id;
    
    com_api_i18n_pkg.remove_text(
        i_table_name  =>  'atm_scenario'
      , i_object_id   =>  i_id
    );
end;

procedure add_scenario_config(
    o_id                   out  com_api_type_pkg.t_tiny_id
  , i_scenario_id       in      com_api_type_pkg.t_medium_id
  , i_config_type       in      com_api_type_pkg.t_dict_value
  , i_config_source     in out nocopy clob
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_file_name         in      com_api_type_pkg.t_name
) is
begin
    o_id := atm_scenario_config_seq.nextval;

    insert into atm_scenario_config_vw(
        id
      , atm_scenario_id
      , config_type
      , config_source
      , file_name
    ) values (
        o_id
      , i_scenario_id
      , i_config_type
      , i_config_source
      , i_file_name
    );

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'atm_scenario_config'
          , i_column_name  => 'label'
          , i_object_id    => o_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'atm_scenario_config'
          , i_column_name   => 'description'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure modify_scenario_config(
    i_id                in      com_api_type_pkg.t_tiny_id
  , i_config_type       in      com_api_type_pkg.t_dict_value
  , i_config_source     in out nocopy clob
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc
  , i_lang              in      com_api_type_pkg.t_dict_value   default null
  , i_file_name         in      com_api_type_pkg.t_name
) is
begin
    update atm_scenario_config_vw
    set    config_type    =  i_config_type
         , config_source  =  i_config_source
         , file_name      =  i_file_name
    where id = i_id;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'atm_scenario_config'
          , i_column_name  => 'label'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'atm_scenario_config'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;

end modify_scenario_config;

procedure remove_scenario_config(
    i_id  in      com_api_type_pkg.t_tiny_id
) is
begin
    delete from atm_scenario_config_vw
    where id = i_id;
    
    com_api_i18n_pkg.remove_text(
        i_table_name  =>  'atm_scenario_config'
      , i_object_id   =>  i_id
    
    );
end remove_scenario_config;

end atm_ui_scenario_pkg;
/
