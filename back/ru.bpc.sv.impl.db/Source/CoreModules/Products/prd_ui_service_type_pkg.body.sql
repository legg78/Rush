create or replace package body prd_ui_service_type_pkg is
/**********************************************************
*  UI for service types <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 15.11.2010 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
*  Revision: $LastChangedRevision: 8281 $ <br />
*  Module: PRD_UI_SERVICE_TYPE_PKG <br />
*  @headcom
***********************************************************/
procedure add_service_type (
    o_id                    out com_api_type_pkg.t_short_id
    , o_seqnum              out com_api_type_pkg.t_seqnum
    , i_product_type        in com_api_type_pkg.t_dict_value
    , i_entity_type         in com_api_type_pkg.t_dict_value
    , i_enable_event_type   in com_api_type_pkg.t_dict_value
    , i_disable_event_type  in com_api_type_pkg.t_dict_value
    , i_lang                in com_api_type_pkg.t_dict_value
    , i_label               in com_api_type_pkg.t_name
    , i_description         in com_api_type_pkg.t_full_desc
    , i_is_initial          in com_api_type_pkg.t_boolean
    , i_external_code       in com_api_type_pkg.t_name      default null
) is
begin
    o_id := com_parameter_seq.nextval;
    o_seqnum := 1;

    insert into prd_service_type_vw (
        id
        , seqnum
        , product_type
        , entity_type
        , is_initial
        , enable_event_type
        , disable_event_type
        , external_code
    ) values (
        o_id
        , o_seqnum
        , i_product_type
        , i_entity_type
        , i_is_initial
        , i_enable_event_type
        , i_disable_event_type
        , i_external_code
    );

    com_api_i18n_pkg.add_text (
        i_table_name     => 'prd_service_type'
        , i_column_name  => 'label'
        , i_object_id    => o_id
        , i_lang         => i_lang
        , i_text         => i_label
        , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text (
        i_table_name     => 'prd_service_type'
        , i_column_name  => 'description'
        , i_object_id    => o_id
        , i_lang         => i_lang
        , i_text         => i_description
    );
end;

procedure modify_service_type (
    i_id                    in com_api_type_pkg.t_short_id
    , io_seqnum             in out com_api_type_pkg.t_seqnum
    , i_product_type        in com_api_type_pkg.t_dict_value
    , i_entity_type         in com_api_type_pkg.t_dict_value
    , i_enable_event_type   in com_api_type_pkg.t_dict_value
    , i_disable_event_type  in com_api_type_pkg.t_dict_value
    , i_lang                in com_api_type_pkg.t_dict_value
    , i_label               in com_api_type_pkg.t_name
    , i_description         in com_api_type_pkg.t_full_desc
    , i_is_initial          in com_api_type_pkg.t_boolean
    , i_external_code       in com_api_type_pkg.t_name      default null
) is
begin
    update
        prd_service_type_vw a
    set
        a.seqnum = io_seqnum
      , a.product_type = i_product_type
      , a.entity_type = i_entity_type
      , a.is_initial = i_is_initial
      , a.enable_event_type = i_enable_event_type
      , a.disable_event_type = i_disable_event_type
      , a.external_code = i_external_code
    where
        id = i_id;

    io_seqnum := io_seqnum + 1;

    com_api_i18n_pkg.add_text (
        i_table_name     => 'prd_service_type'
        , i_column_name  => 'label'
        , i_object_id    => i_id
        , i_lang         => i_lang
        , i_text         => i_label
        , i_check_unique => com_api_type_pkg.TRUE
    );

    com_api_i18n_pkg.add_text (
        i_table_name     => 'prd_service_type'
        , i_column_name  => 'description'
        , i_object_id    => i_id
        , i_lang         => i_lang
        , i_text         => i_description
    );
end;

procedure remove_service_type (
    i_id                    in com_api_type_pkg.t_short_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
) is
    l_count                 com_api_type_pkg.t_tiny_id;
begin
    select
        count(*)
    into
        l_count
    from (        select service_type_id from prd_service_vw
        union all select service_type_id from prd_attribute_vw
    )
    where
        service_type_id = i_id;

    if l_count > 0 then
        com_api_error_pkg.raise_error (
            i_error         => 'SERVICE_TYPE_IS_ALREADY_USED'
            , i_env_param1  => i_id
        );
    end if;

    com_api_i18n_pkg.remove_text (
        i_table_name   => 'prd_service_type'
        , i_object_id  => i_id
    );

    update
        prd_service_type_vw
    set
        seqnum = i_seqnum
    where
        id = i_id;

    delete from
        prd_service_type_vw
    where
        id = i_id;
end;

end;
/
