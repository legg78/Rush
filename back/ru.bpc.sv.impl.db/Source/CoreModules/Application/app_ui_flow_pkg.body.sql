create or replace package body app_ui_flow_pkg as
/*******************************************************************
*  API for application's flow <br />
*  Created by Fomichev A.(fomichev@bpc.ru)  at 03.08.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: app_ui_flow_pkg <br />
*  @headcom
******************************************************************/

procedure add(
    o_id                    out  com_api_type_pkg.t_tiny_id
  , o_seqnum                out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in       com_api_type_pkg.t_dict_value
  , i_inst_id           in       com_api_type_pkg.t_tiny_id
  , i_template_appl_id  in       com_api_type_pkg.t_long_id
  , i_is_customer_exist in       com_api_type_pkg.t_boolean
  , i_is_contract_exist in       com_api_type_pkg.t_boolean
  , i_customer_type     in       com_api_type_pkg.t_dict_value
  , i_contract_type     in       com_api_type_pkg.t_dict_value
  , i_mod_id            in       com_api_type_pkg.t_tiny_id
  , i_xslt_source       in      clob
  , i_xsd_source        in      clob
  , i_label             in       com_api_type_pkg.t_name
  , i_description       in       com_api_type_pkg.t_full_desc   default null
  , i_lang              in       com_api_type_pkg.t_dict_value  default null
) is
begin
    select app_flow_seq.nextval
          ,1
      into o_id
         , o_seqnum
      from dual;

    insert into app_flow_vw (
        id
      , seqnum
      , appl_type
      , inst_id
      , template_appl_id
      , is_customer_exist
      , is_contract_exist
      , customer_type
      , contract_type
      , mod_id
      , xslt_source
      , xsd_source
    ) values (
        o_id
      , o_seqnum
      , i_appl_type
      , i_inst_id
      , i_template_appl_id
      , i_is_customer_exist
      , i_is_contract_exist
      , i_customer_type
      , i_contract_type
      , i_mod_id
      , i_xslt_source
      , i_xsd_source
    );

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'app_flow'
          , i_column_name   => 'label'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name    => 'app_flow'
          , i_column_name   => 'description'
          , i_object_id     => o_id
          , i_lang          => i_lang
          , i_text          => i_description
        );
    end if;
end;

procedure modify(
    i_id                in       com_api_type_pkg.t_tiny_id
  , io_seqnum           in  out  com_api_type_pkg.t_tiny_id
  , i_appl_type         in       com_api_type_pkg.t_dict_value
  , i_inst_id           in       com_api_type_pkg.t_tiny_id
  , i_template_appl_id  in       com_api_type_pkg.t_long_id
  , i_is_customer_exist in       com_api_type_pkg.t_boolean
  , i_is_contract_exist in       com_api_type_pkg.t_boolean
  , i_customer_type     in       com_api_type_pkg.t_dict_value
  , i_contract_type     in       com_api_type_pkg.t_dict_value
  , i_mod_id            in       com_api_type_pkg.t_tiny_id
  , i_xslt_source       in      clob
  , i_xsd_source        in      clob
  , i_label             in       com_api_type_pkg.t_name
  , i_description       in       com_api_type_pkg.t_full_desc   default null
  , i_lang              in       com_api_type_pkg.t_dict_value  default null
) is
begin
    update app_flow_vw
    set seqnum            = io_seqnum
      , appl_type         = i_appl_type
      , inst_id           = i_inst_id
      , template_appl_id  = i_template_appl_id
      , is_customer_exist = i_is_customer_exist
      , is_contract_exist = i_is_contract_exist
      , customer_type     = i_customer_type
      , contract_type     = i_contract_type
      , mod_id            = i_mod_id
      , xslt_source       = i_xslt_source
      , xsd_source        = i_xsd_source
    where id = i_id;

    io_seqnum := io_seqnum + 1;

    if i_label is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'app_flow'
          , i_column_name  => 'label'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_label
        );
    end if;

    if i_description is not null then
        com_api_i18n_pkg.add_text(
            i_table_name   => 'app_flow'
          , i_column_name  => 'description'
          , i_object_id    => i_id
          , i_lang         => i_lang
          , i_text         => i_description
        );
    end if;
end;

procedure remove( 
    i_id      in  com_api_type_pkg.t_short_id
  , i_seqnum  in  com_api_type_pkg.t_tiny_id
) is
begin
    update app_flow_vw
    set seqnum  = i_seqnum
    where    id = i_id;

    delete from app_flow_vw
    where id = i_id;

    com_api_i18n_pkg.remove_text(
        i_table_name   => 'app_flow'
      , i_object_id    => i_id
    );
end;

procedure get_flow_source(
    i_flow_id           in      com_api_type_pkg.t_tiny_id
  , o_xslt_source          out  clob
  , o_xsd_source           out  clob
) is
begin
    select xslt_source
         , xsd_source
      into o_xslt_source
         , o_xsd_source
      from app_flow
     where id = i_flow_id;
     
exception
    when no_data_found then
        com_api_error_pkg.raise_error(
            i_error       => 'APPLICATION_FLOW_NOT_FOUND'
          , i_env_param1  => i_flow_id
        );
end;

end;
/
