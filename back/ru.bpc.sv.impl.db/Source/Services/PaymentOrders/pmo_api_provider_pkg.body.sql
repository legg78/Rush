create or replace package body pmo_api_provider_pkg as
/************************************************************
 * API for service provider<br />
 * Created by Alalykin A.(alalykin@bpc.ru) at 07.06.2014  <br />
 * Last changed by $Author: alalykin $ <br />
 * $LastChangedDate:: 2014-06-06 17:20:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 36740 $ <br />
 * Module: PMO_API_PROVIDER_PKG <br />
 * @headcom
 ************************************************************/

/************************************************************
 * Returns true if provider with the identifier <i_id> is actually a group provider.
 ************************************************************/
function is_provider_group(
    i_id                in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    l_id                       com_api_type_pkg.t_short_id;
begin
    begin
        select pg.id
          into l_id
          from pmo_provider_group pg
         where pg.id = i_id;
    exception
        when no_data_found then
            l_id := null;
    end;

    return case when l_id is null then com_api_type_pkg.FALSE else com_api_type_pkg.TRUE end;
end is_provider_group;

/************************************************************
 * Returns TRUE if provider <i_id> exists.
 ************************************************************/
function provider_exists(
    i_id                in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
    l_found                    com_api_type_pkg.t_boolean;
begin
    begin
        select com_api_type_pkg.TRUE
          into l_found
          from pmo_provider
         where id = i_id;
    exception
        when no_data_found then
            l_found := com_api_type_pkg.FALSE;
    end;
    return l_found;
end provider_exists;

/************************************************************
 * Clones all purposes and parameters from source provider to destination one (both of them should exist).
 * @param i_src_provider_id    source provider identifier
 * @param i_dst_provider_id    destination provider identifier (it should be created previously)
 * @throws e_application_error if source provider doesn't exist (a) or destination one has its own purposes or parameters (b)
 ************************************************************/
procedure clone_purposes_and_params(
    i_src_provider_id   in     com_api_type_pkg.t_short_id
  , i_dst_provider_id   in     com_api_type_pkg.t_short_id
) is
    LOG_PREFIX        constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.clone_purposes_and_params';
    l_purpose_id               com_api_type_pkg.t_short_id;
    l_count                    com_api_type_pkg.t_count := 0;

    procedure clone_purpose_formatters(
        i_src_purpose_id    in     com_api_type_pkg.t_short_id
      , i_dst_purpose_id    in     com_api_type_pkg.t_short_id
    ) is
        l_id                       com_api_type_pkg.t_short_id;
        l_count                    com_api_type_pkg.t_count := 0;
    begin
        trc_log_pkg.debug(LOG_PREFIX || '->clone_purpose_formatters, i_src_purpose_id [' || i_src_purpose_id ||
                                                                 '], i_dst_purpose_id [' || i_dst_purpose_id || ']');
        for pf in (
            select id
                 , seqnum
                 , purpose_id
                 , standard_id
                 , version_id
                 , paym_aggr_msg_type
                 , formatter
              from pmo_purpose_formatter t
             where t.purpose_id = i_src_purpose_id
        ) loop
            l_count := l_count + 1;
            l_id := pmo_purpose_formatter_seq.nextval;
            insert into pmo_purpose_formatter(
                id
              , seqnum
              , purpose_id
              , standard_id
              , version_id
              , paym_aggr_msg_type
              , formatter
            ) values (
                l_id
              , 1
              , i_dst_purpose_id
              , pf.standard_id
              , pf.version_id
              , pf.paym_aggr_msg_type
              , pf.formatter
            );
        end loop;
        trc_log_pkg.debug(LOG_PREFIX || '->clone_purpose_formatters, ' || l_count || ' records have been cloned');
    end clone_purpose_formatters;

    procedure clone_purpose_parameters(
        i_src_purpose_id    in     com_api_type_pkg.t_short_id
      , i_dst_purpose_id    in     com_api_type_pkg.t_short_id
    ) is
        l_id                       com_api_type_pkg.t_short_id;
        l_count                    com_api_type_pkg.t_count := 0;
    begin
        trc_log_pkg.debug(LOG_PREFIX || '->clone_purpose_parameters, i_src_purpose_id [' || i_src_purpose_id ||
                                                                 '], i_dst_purpose_id [' || i_dst_purpose_id || ']');
        for pp in (
            select id
                 , seqnum
                 , param_id
                 , purpose_id
                 , order_stage
                 , display_order
                 , is_mandatory
                 , is_template_fixed
                 , is_editable
                 , default_value
              from pmo_purpose_parameter t
             where t.purpose_id = i_src_purpose_id
        ) loop
            l_count := l_count + 1;

            l_id := pmo_purpose_parameter_seq.nextval;
            insert into pmo_purpose_parameter(
                id
              , seqnum
              , param_id
              , purpose_id
              , order_stage
              , display_order
              , is_mandatory
              , is_template_fixed
              , is_editable
              , default_value
            ) values (
                l_id
              , 1
              , pp.param_id
              , i_dst_purpose_id
              , pp.order_stage
              , pp.display_order
              , pp.is_mandatory
              , pp.is_template_fixed
              , pp.is_editable
              , pp.default_value
            );

            trc_log_pkg.debug('coping records from pmo_purp_param_value for l_id [' || l_id || ']');
            insert into pmo_purp_param_value(
                id
              , purp_param_id
              , entity_type
              , object_id
              , param_value
            )
            select pmo_purp_param_value_seq.nextval
                 , l_id
                 , pv.entity_type
                 , pv.object_id
                 , pv.param_value
              from pmo_purp_param_value pv
             where purp_param_id = pp.param_id;

            trc_log_pkg.debug(nvl(sql%rowcount, 0) || ' records have been copied');
        end loop;
        trc_log_pkg.debug(LOG_PREFIX || '->clone_purpose_parameters, ' || l_count || ' parameters have been cloned');
    end clone_purpose_parameters;

begin
    trc_log_pkg.debug(LOG_PREFIX || ': i_src_provider_id [' || i_src_provider_id ||
                                   '], i_dst_provider_id [' || i_dst_provider_id || ']');
    for p in (
        select *
          from pmo_purpose t
         where t.provider_id = i_src_provider_id
    ) loop
        -- Clone the purpose for destination provider
        l_purpose_id := pmo_purpose_seq.nextval;
        insert into pmo_purpose(
            id
          , provider_id
          , service_id
          , host_algorithm
          , oper_type
          , terminal_id
          , mcc
          , purpose_number
          , zero_order_status
        ) values (
            l_purpose_id
          , i_dst_provider_id
          , p.service_id
          , p.host_algorithm
          , p.oper_type
          , p.terminal_id
          , p.mcc
          , p.purpose_number
          , p.zero_order_status
        );
        -- Child records should be cloned too
        clone_purpose_formatters(
            i_src_purpose_id => p.id
          , i_dst_purpose_id => l_purpose_id
        );
        clone_purpose_parameters(
            i_src_purpose_id => p.id
          , i_dst_purpose_id => l_purpose_id
        );
        l_count := l_count + 1;
    end loop;
    trc_log_pkg.info(LOG_PREFIX || ': ' || l_count || ' purposes have been copied from source provider ['
                                || i_src_provider_id || '] to destination provider [' || i_dst_provider_id || ']');
end clone_purposes_and_params;

function get_provider_id(
    i_provider_number       in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id
is
    l_provider_id           com_api_type_pkg.t_short_id;
begin
    begin
        begin
            select p.id
              into l_provider_id
              from pmo_provider p
             where p.provider_number = i_provider_number;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'PROVIDER_NOT_FOUND'
                  , i_env_param1  => i_provider_number
                  , i_env_param2  => i_inst_id
                  , i_mask_error  => i_mask_error
                );
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error       => 'TOO_MANY_RECORDS_FOUND'
                  , i_mask_error  => i_mask_error
                );
        end;
    exception
        when com_api_error_pkg.e_application_error then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                raise;
            end if;
    end;

    return l_provider_id;
end get_provider_id;

function get_provider_id(
    i_purpose_id            in     com_api_type_pkg.t_short_id
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id
is
    l_provider_id           com_api_type_pkg.t_short_id;
begin
    begin
        begin
            select p.provider_id
              into l_provider_id
              from pmo_purpose p
             where p.id = i_purpose_id;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'PROVIDER_NOT_FOUND'
                  , i_env_param1  => i_purpose_id
                  , i_env_param2  => i_inst_id
                  , i_mask_error  => i_mask_error
                );
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error       => 'TOO_MANY_RECORDS_FOUND'
                  , i_mask_error  => i_mask_error
                );
        end;
    exception
        when com_api_error_pkg.e_application_error then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                raise;
            end if;
    end;

    return l_provider_id;
end get_provider_id;

function get_purpose_id(
    i_purpose_number        in     com_api_type_pkg.t_name
  , i_inst_id               in     com_api_type_pkg.t_inst_id    default null
  , i_mask_error            in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) return com_api_type_pkg.t_short_id
is
    l_purpose_id           com_api_type_pkg.t_short_id;
begin
    begin
        begin
            select p.id
              into l_purpose_id
              from pmo_purpose p
             where p.purpose_number = i_purpose_number;
        exception
            when no_data_found then
                com_api_error_pkg.raise_error(
                    i_error       => 'PAYMENT_PURPOSE_NOT_FOUND'
                  , i_env_param1  => i_purpose_number
                  , i_env_param2  => i_inst_id
                  , i_mask_error  => i_mask_error
                );
            when too_many_rows then
                com_api_error_pkg.raise_error(
                    i_error       => 'TOO_MANY_RECORDS_FOUND'
                  , i_mask_error  => i_mask_error
                );
        end;
    exception
        when com_api_error_pkg.e_application_error then
            if nvl(i_mask_error, com_api_const_pkg.TRUE) = com_api_const_pkg.FALSE then
                raise;
            end if;
    end;

    return l_purpose_id;
end get_purpose_id;


end;
/
