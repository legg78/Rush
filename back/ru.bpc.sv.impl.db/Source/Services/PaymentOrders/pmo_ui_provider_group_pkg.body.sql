create or replace package body pmo_ui_provider_group_pkg as
/************************************************************
 * UI for provider groups<br />
 * Created by Alalykin A.(alalykin@bpc.ru) at 09.06.2014 <br />
 * Last changed by $Author: alalykin $ <br />
 * $LastChangedDate:: 2014-06-09 14:00:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 36740 $ <br />
 * Module: PMO_UI_PROVIDER_GROUP_PKG <br />
 * @headcom
 ************************************************************/

procedure add(
    o_id                         out com_api_type_pkg.t_short_id
  , o_seqnum                     out com_api_type_pkg.t_seqnum
  , i_parent_id               in     com_api_type_pkg.t_short_id
  , i_region_code             in     com_api_type_pkg.t_region_code
  , i_provider_group_number   in     com_api_type_pkg.t_name        default null
  , i_logo_path               in     com_api_type_pkg.t_name
  , i_label                   in     com_api_type_pkg.t_short_desc
  , i_description             in     com_api_type_pkg.t_full_desc
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_short_name              in     com_api_type_pkg.t_name
  , i_inst_id                 in     com_api_type_pkg.t_inst_id     default null
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.add: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX 
               || 'i_parent_id [' || i_parent_id || 
               '], i_region_code [' || i_region_code || 
               '], i_label [' || i_label || 
               '], i_short_name [' || i_short_name || 
               '], i_lang [' || i_lang ||
               '], i_description [' || i_description || ']'
    );

    o_id := pmo_provider_seq.nextval;
    o_seqnum := 1;
    insert into pmo_provider_group_vw(
        id
      , seqnum
      , parent_id
      , region_code
      , provider_group_number
      , logo_path
      , inst_id
    ) values (
        o_id
      , o_seqnum
      , i_parent_id
      , i_region_code
      , i_provider_group_number
      , i_logo_path
      , nvl(i_inst_id, ost_api_const_pkg.DEFAULT_INST)
    );

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider_group'
      , i_column_name  => 'label'
      , i_object_id    => o_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider_group'
      , i_column_name  => 'description'
      , i_object_id    => o_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider_group'
      , i_column_name  => 'short_name'
      , i_object_id    => o_id
      , i_text         => i_short_name
      , i_lang         => com_api_const_pkg.DEFAULT_LANGUAGE
      , i_check_unique => com_api_type_pkg.TRUE
    );
    
    trc_log_pkg.debug(LOG_PREFIX || 'o_id [' || o_id || ']');
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX 
                   || 'o_id [' || o_id ||
                   '], i_parent_id [' || i_parent_id || 
                   '], i_region_code [' || i_region_code || 
                   '], i_label [' || i_label || 
                   '], i_short_name [' || i_short_name || 
                   '], i_lang [' || i_lang ||
                   '], i_description [' || i_description || ']'
        );
        raise;
end add;

procedure modify(
    i_id                      in     com_api_type_pkg.t_short_id
  , io_seqnum                 in out com_api_type_pkg.t_seqnum
  , i_parent_id               in     com_api_type_pkg.t_short_id
  , i_region_code             in     com_api_type_pkg.t_region_code
  , i_provider_group_number   in     com_api_type_pkg.t_name        default null
  , i_logo_path               in     com_api_type_pkg.t_name
  , i_label                   in     com_api_type_pkg.t_short_desc
  , i_description             in     com_api_type_pkg.t_full_desc
  , i_lang                    in     com_api_type_pkg.t_dict_value
  , i_short_name              in     com_api_type_pkg.t_name
  , i_inst_id                 in     com_api_type_pkg.t_inst_id     default null
) is
    LOG_PREFIX              constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.modify: ';
begin
    trc_log_pkg.debug(
        i_text => LOG_PREFIX 
               || 'i_id [' || i_id ||
               '], i_parent_id [' || i_parent_id || 
               '], i_region_code [' || i_region_code || 
               '], i_label [' || i_label || 
               '], i_short_name [' || i_short_name || 
               '], i_lang [' || i_lang ||
               '], i_description [' || i_description || ']'
    );

    update pmo_provider_group_vw a
       set seqnum                   = io_seqnum
         , parent_id                = nvl(i_parent_id, parent_id) 
         , region_code              = nvl(i_region_code, region_code)
         , provider_group_number    = nvl(i_provider_group_number, provider_group_number)
         , logo_path                = nvl(i_logo_path, logo_path)
         , inst_id                  = nvl(i_inst_id, inst_id)
     where id = i_id;

    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider_group'
      , i_column_name  => 'label'
      , i_object_id    => i_id
      , i_text         => i_label
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider_group'
      , i_column_name  => 'description'
      , i_object_id    => i_id
      , i_text         => i_description
      , i_lang         => i_lang
      , i_check_unique => com_api_type_pkg.TRUE
    );
    com_api_i18n_pkg.add_text(
        i_table_name   => 'pmo_provider_group'
      , i_column_name  => 'short_name'
      , i_object_id    => i_id
      , i_text         => i_short_name
      , i_lang         => com_api_const_pkg.DEFAULT_LANGUAGE
      , i_check_unique => com_api_type_pkg.TRUE
    );

    io_seqnum := io_seqnum + 1;
exception
    when others then
        trc_log_pkg.debug(
            i_text => LOG_PREFIX 
                   || 'i_id [' || i_id ||
                   '], i_parent_id [' || i_parent_id || 
                   '], i_region_code [' || i_region_code || 
                   '], i_label [' || i_label || 
                   '], i_short_name [' || i_short_name || 
                   '], i_lang [' || i_lang ||
                   '], i_description [' || i_description || ']'
        );
        raise;
end modify;

procedure remove(
    i_id                      in     com_api_type_pkg.t_short_id
  , i_seqnum                  in     com_api_type_pkg.t_seqnum
) is
    l_group_is_empty                 com_api_type_pkg.t_boolean;
begin
    -- Prevent deleting the provider group if it contains child providers or groups 
    begin
        select com_api_type_pkg.FALSE
          into l_group_is_empty
          from dual
         where exists (select * from pmo_provider_vw where parent_id = i_id)
            or exists (select * from pmo_provider_group_vw where parent_id = i_id);
    exception
        when no_data_found then
            l_group_is_empty := com_api_type_pkg.TRUE;
    end;

    if l_group_is_empty = com_api_type_pkg.FALSE then
        com_api_error_pkg.raise_error(
            i_error      => 'CANNOT_DELETE_NON_EMPTY_PROVIDER_GROUP'
          , i_env_param1 => i_id
        );
    end if;
    
    update pmo_provider_group_vw
       set seqnum = i_seqnum
     where id     = i_id;

    delete pmo_provider_group_vw
     where id     = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name => 'pmo_provider_group'
      , i_object_id  => i_id
    );
end remove;

end pmo_ui_provider_group_pkg;
/
