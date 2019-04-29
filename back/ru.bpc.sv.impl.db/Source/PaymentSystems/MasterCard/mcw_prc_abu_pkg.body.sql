create or replace package body mcw_prc_abu_pkg as

BULK_LIMIT        constant pls_integer                     := 400;
C_ISS_SUBSCRIBER_NAME constant com_api_type_pkg.t_name         := 'MCW_PRC_ABU_PKG.EXPORT_FORMAT_R274';
C_ACQ_SUBSCRIBER_NAME constant com_api_type_pkg.t_name         := 'MCW_PRC_ABU_PKG.EXPORT_FORMAT_R625';

type t_mcw_abu_file_rec is record(
    id                   com_api_type_pkg.t_long_id
  , inst_id              com_api_type_pkg.t_inst_id
  , network_id           com_api_type_pkg.t_tiny_id
  , file_type            com_api_type_pkg.t_dict_value
  , proc_date            date
  , is_incoming          com_api_type_pkg.t_boolean
  , business_ica         com_api_type_pkg.t_region_code
  , reason_code          com_api_type_pkg.t_one_char
  , original_file_date   date
  , total_msg_count      number(7)
  , total_add_count      number(7)
  , total_changed_count  number(7)
  , total_error_count    number(7)
  , record_count         number(9)
);

type t_mcw_abu_iss_msg_rec is record(
    id                   com_api_type_pkg.t_long_id
  , split_hash           com_api_type_pkg.t_tiny_id
  , status               com_api_type_pkg.t_dict_value
  , inst_id              com_api_type_pkg.t_tiny_id
  , network_id           com_api_type_pkg.t_tiny_id
  , proc_date            date
  , file_id              com_api_type_pkg.t_long_id
  , event_object_id      com_api_type_pkg.t_long_id
  , confirm_file_id      com_api_type_pkg.t_long_id
  , issuer_ica           varchar2(11)
  , old_card_number      varchar2(19)
  , old_expiration_date  date
  , new_card_number      varchar2(19)
  , new_expiration_date  date
  , reason_code          com_api_type_pkg.t_one_char
  , error_code_1         varchar2(3)
  , error_code_2         varchar2(3)
  , error_code_3         varchar2(3)
  , error_code_4         varchar2(3)
  , error_code_5         varchar2(3)
);
type t_mcw_abu_iss_detail_tab is table of t_mcw_abu_iss_msg_rec;

type t_mcw_abu_acq_msg_rec is record(
    id               com_api_type_pkg.t_long_id
  , split_hash       com_api_type_pkg.t_tiny_id
  , status           com_api_type_pkg.t_dict_value
  , inst_id          com_api_type_pkg.t_tiny_id
  , network_id       com_api_type_pkg.t_tiny_id
  , request_date     date
  , file_id          com_api_type_pkg.t_long_id
  , event_object_id  com_api_type_pkg.t_long_id
  , confirm_file_id  com_api_type_pkg.t_long_id
  , acquirer_ica     varchar2(11)
  , request_type     com_api_type_pkg.t_one_char
  , merchant_number  com_api_type_pkg.t_merchant_number
  , merchant_name    varchar2(25)
  , mcc              com_api_type_pkg.t_mcc
  , error_code_1     varchar2(3)
  , error_code_2     varchar2(3)
  , error_code_3     varchar2(3)
  , error_code_4     varchar2(3)
  , error_code_5     varchar2(3)
  , error_code_6     varchar2(3)
  , error_code_7     varchar2(3)
  , error_code_8     varchar2(3)
);

type t_mcw_abu_acq_detail_tab is table of t_mcw_abu_acq_msg_rec;

cursor cur_file_raw_data(i_session_file_id in    com_api_type_pkg.t_long_id) is
select trim(raw_data) as raw_data
     , record_number
  from prc_file_raw_data rd
 where rd.session_file_id = i_session_file_id
order by record_number;

function find_value_owner(
    i_standard_id    in      com_api_type_pkg.t_tiny_id
  , i_entity_type    in      com_api_type_pkg.t_dict_value
  , i_object_id      in      com_api_type_pkg.t_long_id
  , i_param_name     in      com_api_type_pkg.t_name
  , i_value          in      com_api_type_pkg.t_name
  , i_requested_type in      com_api_type_pkg.t_dict_value
  , i_mask_error     in      com_api_type_pkg.t_boolean      := com_api_type_pkg.FALSE
  , i_masked_level   in      com_api_type_pkg.t_tiny_id      := null
) return com_api_type_pkg.t_inst_id is
    l_result                    com_api_type_pkg.t_inst_id;
    l_data_type                 com_api_type_pkg.t_dict_value;
    l_param_id                  com_api_type_pkg.t_short_id;
begin
    begin
        select id
             , data_type
          into l_param_id
             , l_data_type
          from cmn_parameter
         where name        = upper(i_param_name)
           and standard_id = i_standard_id;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error         => 'STANDARD_PARAM_NOT_EXISTS'
                , i_env_param1  => upper(i_param_name)
                , i_env_param2  => i_standard_id
            );
    end;

    if l_data_type != i_requested_type then
        com_api_error_pkg.raise_error (
            i_error         => 'INCORRECT_PARAM_VALUE_DATA_TYPE'
            , i_env_param1  => i_requested_type
            , i_env_param2  => l_data_type
        );
    end if;

    if i_entity_type = net_api_const_pkg.ENTITY_TYPE_HOST then
        select t.inst_id
          into l_result
          from (
              select m.inst_id
                from net_api_interface_param_val_vw v
                   , net_member m
               where v.standard_id                = i_standard_id
                 and v.host_member_id             = i_object_id
                 and v.param_name                 = i_param_name
                 and lpad(v.param_value, 11, '0') = i_value
                 and m.id                         = v.consumer_member_id
               order by decode(v.msp_member_id, null, 0, 1), m.inst_id
          ) t
         where rownum = 1;
    else
        null;
    end if;

    trc_log_pkg.debug (
        i_text          => 'Returning requested value of [#1]=[#2]'
        , i_env_param1  => i_param_name
        , i_env_param2  => l_result
    );
    
    return l_result;
exception
    when no_data_found then
        if i_mask_error       = com_api_type_pkg.TRUE
           and i_masked_level = trc_config_pkg.DEBUG
        then
            trc_log_pkg.debug (
                i_text          => 'Cmn param value not found: param_name [#1] value [#2] standard_id [#3] entity_type [#4] object_id [#5]'
              , i_env_param1   => i_param_name
              , i_env_param2   => i_value
              , i_env_param3   => i_standard_id
              , i_env_param4   => i_entity_type
              , i_env_param5   => i_object_id
            );
            return null;
        else
            com_api_error_pkg.raise_error (
                i_error          => 'NOT_FOUND_VALUE_OWNER'
              , i_env_param1   => i_param_name
              , i_env_param2   => i_value
              , i_env_param3   => i_standard_id
              , i_env_param4   => i_entity_type
              , i_env_param5   => i_object_id
              , i_mask_error   => i_mask_error
            );
        end if;
    when too_many_rows then
        com_api_error_pkg.raise_error (
            i_error          => 'TOO_MANY_VALUE_OWNERS'
          , i_env_param1   => i_param_name
          , i_env_param2   => i_value
          , i_env_param3   => i_standard_id
          , i_env_param4   => i_entity_type
          , i_env_param5   => i_object_id
        );
end;

function get_network_by_type(
    i_card_type_id      in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_tiny_id  deterministic is
begin
    for tab in (
        select network_id
          from net_card_type
         where id = i_card_type_id
    ) loop
        return tab.network_id;
    end loop;
    return null;
end;

procedure add_mcw_abu_file(
    i_file in     t_mcw_abu_file_rec
) is
begin
    insert into mcw_abu_file(
        id
      , inst_id
      , network_id
      , file_type
      , proc_date
      , is_incoming
      , business_ica
      , reason_code
      , original_file_date
      , total_msg_count
      , total_add_count
      , total_changed_count
      , total_error_count
      , record_count
    ) values (
        i_file.id
      , i_file.inst_id
      , i_file.network_id
      , i_file.file_type
      , i_file.proc_date
      , i_file.is_incoming
      , i_file.business_ica
      , i_file.reason_code
      , i_file.original_file_date
      , i_file.total_msg_count
      , i_file.total_add_count
      , i_file.total_changed_count
      , i_file.total_error_count
      , i_file.record_count
    );
end;

procedure export_format_r274(
    i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_full_export in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
) is
    LOG_PREFIX  constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.export_format_r274: ';
    l_processed_count    com_api_type_pkg.t_count        := 0;
    l_excepted_count     com_api_type_pkg.t_long_id      := 0;
    l_estimated_count    com_api_type_pkg.t_long_id;
    l_full_export        com_api_type_pkg.t_boolean      := nvl(i_full_export, com_api_type_pkg.FALSE);
    l_session_file_id    com_api_type_pkg.t_long_id      := null;
    l_params             com_api_type_pkg.t_param_tab;
    l_host_id            com_api_type_pkg.t_tiny_id;
    l_standard_id        com_api_type_pkg.t_tiny_id;
    l_network_id         com_api_type_pkg.t_tiny_id      := mcw_api_const_pkg.MCW_NETWORK_ID;
    l_sysdate            date                            := com_api_sttl_day_pkg.get_sysdate;
    l_file_number        com_api_type_pkg.t_long_id      := 1;
    l_rec_raw            com_api_type_pkg.t_raw_tab;
    l_rec_num            com_api_type_pkg.t_integer_tab;
    l_cmid               com_api_type_pkg.t_cmid;
    l_file_type          com_api_type_pkg.t_dict_value;
    l_file               t_mcw_abu_file_rec;
    l_msg_tab            t_mcw_abu_iss_detail_tab;
    l_eo_tab             com_api_type_pkg.t_number_tab;

    cursor cu_iss_full(i_inst_id in    com_api_type_pkg.t_inst_id) is
    select null           as id
         , c.split_hash   as split_hash
         , null           as status
         , i_inst_id      as inst_id
         , l_network_id   as network_id
         , l_sysdate      as proc_date
         , null           as file_id
         , null           as event_object_id
         , null           as confirm_file_id
         , null           as issuer_ica
         , rpad(trim(substr(cn.card_number, 1, 19)), 19) as old_card_number
         , ci.expir_date  as old_expiration_date
         , null           as new_card_number
         , null           as new_expiration_date
         , 'I'            as reason_code
         , null           as error_code_1
         , null           as error_code_2
         , null           as error_code_3
         , null           as error_code_4
         , null           as error_code_5
      from iss_card c
      join iss_card_number   cn on c.id  = cn.card_id
      join iss_card_instance ci on c.id  = ci.card_id
                               and c.split_hash = ci.split_hash
                               and ci.state     = iss_api_const_pkg.CARD_STATE_ACTIVE
                               and ci.inst_id   = i_inst_id
      join net_card_type ct     on ct.id = c.card_type_id
     where ct.network_id = mcw_api_const_pkg.MCW_NETWORK_ID;
-------------------
    cursor cu_iss_incremental(i_inst_id in   com_api_type_pkg.t_inst_id) is
    select null             as id
         , split_hash       as split_hash
         , null             as status
         , i_inst_id        as inst_id
         , l_network_id     as network_id
         , l_sysdate        as proc_date
         , null             as file_id
         , event_obj_id     as event_object_id
         , null             as confirm_file_id
         , null             as issuer_ica
         , rpad(trim(substr(prev_card_number, 1, 19)), 19) as old_card_number
         , prev_expir_date  as old_expiration_date
         , rpad(trim(substr(card_number, 1, 19)), 19)      as new_card_number
         , expir_date       as new_expiration_date
         , reason_code      as reason_code
         , null             as error_code_1
         , null             as error_code_2
         , null             as error_code_3
         , null             as error_code_4
         , null             as error_code_5
     from (
        select ci.split_hash
             , cn.card_number as card_number
             , ci.expir_date  as expir_date
             , null           as prev_card_number
             , null           as prev_expir_date,
               case
                   when ci.preceding_card_instance_id is null       -- for optimizer
                        or not exists(select 1
                                         from iss_card_instance ci2
                                        where ci2.id = ci.preceding_card_instance_id
                                       )
                   then 'N'
                   else '-' --  disable unload, update status
               end            as reason_code
             , eo.id          as event_obj_id   -- id for updating
          from iss_card_instance ci
          join iss_card_number  cn on ci.card_id = cn.card_id
          join evt_event_object eo on ci.card_id = eo.object_id
                                 and ci.split_hash = eo.split_hash
                                 and eo.inst_id = i_inst_id
                                 and eo.event_id in (select id
                                                       from evt_event
                                                      where event_type in (iss_api_const_pkg.EVENT_TYPE_CARD_CREATION))
                                 and eo.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                 and decode(eo.status, 'EVST0001', procedure_name, null) = C_ISS_SUBSCRIBER_NAME
                                 and eo.eff_date   <=  l_sysdate
         where ci.split_hash in (select split_hash from com_api_split_map_vw)
           and ci.inst_id = i_inst_id
         union all
        select ci.split_hash
             , null           as card_number
             , null           as expir_date
             , cn.card_number as prev_card_number
             , null           as prev_expir_date,
               case
                   when not exists (
                       select id
                         from iss_card_instance ic2 
                        where ic2.preceding_card_instance_id = ci.id
                          and state = iss_api_const_pkg.CARD_STATE_ACTIVE  --  'CSTE0200'
                   ) then 'C'
                   else '-' --   disable unload, update status
               end as reason_code
             , eo.id as event_obj_id   -- id for updating
          from iss_card_instance ci
          join iss_card_number  cn on ci.card_id = cn.card_id
          join evt_event_object eo on ci.card_id = eo.object_id
                                  and ci.split_hash = eo.split_hash
                                  and eo.inst_id = i_inst_id
                                  and eo.event_id in (select id
                                                        from evt_event
                                                       where event_type in (iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT))
                                  and eo.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                  and decode(eo.status, 'EVST0001', procedure_name, null) = C_ISS_SUBSCRIBER_NAME
                                  and eo.eff_date   <=  l_sysdate
         where ci.split_hash in (select split_hash from com_api_split_map_vw)
           and ci.inst_id = i_inst_id
         union all
        select c.split_hash
             , cn_next.card_number  as card_number
             , ci_next.expir_date   as expir_date
             , cn.card_number       as prev_card_number
             , ci.expir_date        as prev_expir_date
             , case
               when ci.state = ISS_API_CONST_PKG.CARD_STATE_CLOSED
                 or ci.status in (select e.element_value
                                    from com_array_element e
                                   where array_id = mcw_api_const_pkg.ABU_BLOCKED_STATUS_ARRAY
                                 )
               then
                   case
                   when ci_next.id is null     -- new instance NOT exists
                   then '+'                --  disable unload + DO NOT update status
                   when c.card_type_id != c_next.card_type_id
                   then 'P'
                   when c.id != c_next.id
                   then 'R'
                   else 'E'
                   end
               else '-' --  disable unload, update status
               end as reason_code
             , eo.id as event_obj_id
          from iss_card_instance ci
          left join iss_card_instance ci_next on
                        (ci.state = ISS_API_CONST_PKG.CARD_STATE_CLOSED
                            or ci.status in (select element_value
                                               from com_array_element
                                              where array_id = mcw_api_const_pkg.ABU_BLOCKED_STATUS_ARRAY)
                        )
                        and ci_next.preceding_card_instance_id = ci.id
          left join iss_card c_next on ci_next.card_id = c_next.id
                                   and ci_next.split_hash = c_next.split_hash
          left join iss_card_number cn_next on cn_next.card_id = c_next.id
    ---- main data
          join iss_card c on c.id = ci.card_id
                         and c.split_hash = ci.split_hash
          join iss_card_number  cn on ci.card_id = cn.card_id
          join evt_event_object eo on case
                                      when eo.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD
                                      then ci.card_id
                                      when eo.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                      then ci.id
                                      else null
                                      end = eo.object_id
                                  and ci.split_hash = eo.split_hash
                                  and eo.inst_id = i_inst_id
                                  and event_id in (select xe.id from evt_event xe
                                                        , evt_event_type xet
                                                    where xe.event_type = xet.event_type
                                                      and xet.entity_type in (
                                                          iss_api_const_pkg.ENTITY_TYPE_CARD
                                                        , iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE)
                                                      and xet.event_type not in (
                                                          iss_api_const_pkg.EVENT_TYPE_CARD_CREATION
                                                        , iss_api_const_pkg.EVENT_TYPE_CARD_DESTRUCT)
                                                   )
                                  and eo.entity_type in (
                                      iss_api_const_pkg.ENTITY_TYPE_CARD
                                    , iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
                                  )
                                  and decode(eo.status, 'EVST0001', eo.procedure_name, null) = C_ISS_SUBSCRIBER_NAME
                                  and eo.eff_date   <= l_sysdate
         where ci.split_hash in (select sm.split_hash from com_api_split_map_vw sm)
           and ci.inst_id = i_inst_id
    ) order by prev_card_number nulls last, event_obj_id;

    function format_r274_header(i_cmid in com_api_type_pkg.t_cmid) return com_api_type_pkg.t_text is
        l_string com_api_type_pkg.t_raw_data;
    begin
        l_string := 'H' || lpad(i_cmid, 11, '0')
                        || lpad(' ', 46)
                        || 'I'
                        || lpad(' ', 11);
        return l_string;
    end;
    
    procedure add_abu_iss_msg_bulk(i_msg_tab in     t_mcw_abu_iss_detail_tab) is
    begin
        forall i in indices of i_msg_tab
            insert into mcw_abu_iss_msg(
                id
              , split_hash
              , status
              , inst_id
              , network_id
              , proc_date
              , file_id
              , event_object_id
              , confirm_file_id
              , issuer_ica
              , old_card_number
              , old_expiration_date
              , new_card_number
              , new_expiration_date
              , reason_code
              , error_code_1
              , error_code_2
              , error_code_3
              , error_code_4
              , error_code_5
            ) values(
                nvl(i_msg_tab(i).id, com_api_id_pkg.get_id(i_seq => mcw_abu_iss_msg_seq.nextval,i_date => l_sysdate))
              , i_msg_tab(i).split_hash
              , mcw_api_const_pkg.ABU_MSG_STATUS_UPLOADED
              , i_inst_id
              , l_network_id
              , l_sysdate
              , l_session_file_id
              , i_msg_tab(i).event_object_id
              , null
              , l_cmid
              , iss_api_token_pkg.encode_card_number(i_card_number => substr(i_msg_tab(i).old_card_number, 1, 19))
              , i_msg_tab(i).old_expiration_date
              , iss_api_token_pkg.encode_card_number(i_card_number => substr(i_msg_tab(i).new_card_number, 1, 19))
              , i_msg_tab(i).new_expiration_date
              , i_msg_tab(i).reason_code
              , null
              , null
              , null
              , null
              , null
            );
    end;

    function format_r274(
        i_msg  in     t_mcw_abu_iss_msg_rec
    ) return com_api_type_pkg.t_raw_data is
        l_line  com_api_type_pkg.t_raw_data;
    begin
        l_line := 
            'D' || lpad(l_cmid, 11, '0')
                || rpad(nvl(iss_api_token_pkg.decode_card_number(i_card_number => substr(i_msg.old_card_number, 1, 19)), ' '), 19, ' ')
                || case when i_msg.old_expiration_date is not null then to_char(i_msg.old_expiration_date, 'MMYY') else '0000' end
                || rpad(nvl(iss_api_token_pkg.decode_card_number(i_card_number => substr(i_msg.new_card_number, 1, 19)), ' '), 19, ' ')
                || case when i_msg.new_expiration_date is not null then to_char(i_msg.new_expiration_date, 'MMYY') else '0000' end
                || nvl(substr(i_msg.reason_code, 1, 1), ' ')
                || lpad(' ', 11);
        trc_log_pkg.debug(l_line);
        return l_line;
    end;

    procedure create_file(
        i_inst_id in     com_api_type_pkg.t_inst_id
    ) is
        LOG_PREFIX     constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.export_format_r274.create_file: ';
    begin
        trc_log_pkg.debug(i_text => LOG_PREFIX || 'START: i_inst_id ' || i_inst_id );

        rul_api_param_pkg.set_param(
            i_name    => 'INST_ID'
          , i_value   => to_char(i_inst_id)
          , io_params => l_params
        );
        -- query cm_id
        l_cmid :=
            cmn_api_standard_pkg.get_varchar_value(
                i_inst_id     => i_inst_id
              , i_standard_id => l_standard_id
              , i_object_id   => l_host_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name  => mcw_api_const_pkg.CMID
              , i_param_tab   => l_params
            );

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params       => l_params
          , i_file_type     => mcw_api_const_pkg.FILE_TYPE_ABU_R274
        );

        trc_log_pkg.debug(i_text => LOG_PREFIX || 'l_session_file_id=' || l_session_file_id ||', l_full_export=' || l_full_export );

        if l_full_export = com_api_type_pkg.TRUE then
            l_processed_count := 0;
            l_estimated_count := 1; -- header
            open cu_iss_full(i_inst_id => i_inst_id);
            loop
                fetch cu_iss_full bulk collect into l_msg_tab limit BULK_LIMIT;
                exit when l_msg_tab.count = 0;
                l_estimated_count := nvl(l_estimated_count, 0) + l_msg_tab.count;
                trc_log_pkg.debug('fetched ' || l_msg_tab.count || ' records');
                prc_api_stat_pkg.log_estimation(
                    i_estimated_count => l_estimated_count
                  , i_measure         => iss_api_const_pkg.ENTITY_TYPE_CARD
                );

                l_eo_tab.delete();
                l_rec_raw.delete();
                l_rec_num.delete();

                for i in 1 .. l_msg_tab.count() loop
                    if l_processed_count = 0 then
                        l_processed_count := l_processed_count + 1;
                        l_rec_raw(l_rec_raw.count() + 1)    := format_r274_header(i_cmid => l_cmid);
                        l_rec_num(l_rec_num.count() + 1)    := l_processed_count;
                    end if;

                    l_processed_count := l_processed_count + 1;
                    l_rec_raw(l_rec_raw.count() + 1) := format_r274( i_msg  => l_msg_tab(i) );
                    l_rec_num(l_rec_num.count() + 1) := l_processed_count;
                end loop;

                add_abu_iss_msg_bulk(i_msg_tab => l_msg_tab);

                prc_api_file_pkg.put_bulk(
                    i_sess_file_id => l_session_file_id
                  , i_raw_tab      => l_rec_raw
                  , i_num_tab      => l_rec_num
                );

                prc_api_stat_pkg.log_current (
                    i_current_count   => l_processed_count
                  , i_excepted_count  => 0
                );
               exit when cu_iss_full%notfound;
           end loop;
            close cu_iss_full;
        else
            open cu_iss_incremental(i_inst_id => i_inst_id);
            loop
                fetch cu_iss_incremental bulk collect into l_msg_tab limit BULK_LIMIT;
                exit when l_msg_tab.count=0;
                trc_log_pkg.debug('fetched ' || l_msg_tab.count || ' records');
                l_estimated_count := nvl(l_estimated_count, 0) + l_msg_tab.count;

                l_eo_tab.delete();
                l_rec_raw.delete();
                l_rec_num.delete();
                for i in 1 .. l_msg_tab.count() loop
                    trc_log_pkg.debug('cu_incremental:  id=' || l_msg_tab(i).id
                                   || ', evnt_obj_id=' || l_msg_tab(i).event_object_id
                                   || ', reason_code=' || l_msg_tab(i).reason_code
                    );
                    if nvl(l_processed_count,0) = 0 then
                        l_processed_count := l_processed_count + 1;
                        l_rec_raw(l_rec_raw.count() + 1) := format_r274_header(i_cmid => l_cmid);
                        l_rec_num(l_rec_num.count() + 1) := l_processed_count;
                        l_estimated_count := l_estimated_count + 1;
                        prc_api_stat_pkg.log_estimation(
                            i_estimated_count => l_estimated_count
                          , i_measure         => iss_api_const_pkg.ENTITY_TYPE_CARD
                        );
                    end if;

                    if l_msg_tab(i).reason_code not in ('-', '+') then
                        l_processed_count := l_processed_count + 1;

                        l_rec_raw(l_rec_raw.count() + 1) := format_r274( i_msg  => l_msg_tab(i) );
                        l_rec_num(l_rec_num.count() + 1) := l_processed_count;
                    end if;

                    if l_msg_tab(i).reason_code != '+' then
                        l_eo_tab(l_eo_tab.count() + 1) := l_msg_tab(i).event_object_id;
                    end if;
                end loop;

                add_abu_iss_msg_bulk(i_msg_tab => l_msg_tab);

                prc_api_file_pkg.put_bulk(
                    i_sess_file_id  => l_session_file_id
                  , i_raw_tab       => l_rec_raw
                  , i_num_tab       => l_rec_num
                );

                evt_api_event_pkg.process_event_object(
                    i_event_object_id_tab   => l_eo_tab
                );

                prc_api_stat_pkg.log_current (
                    i_current_count   => l_processed_count
                  , i_excepted_count  => 0
                );
                exit when cu_iss_incremental%notfound;
            end loop;

            close cu_iss_incremental;
        end if;

        l_file.id                  := l_session_file_id;
        l_file.inst_id             := i_inst_id;
        l_file.network_id          := l_network_id;
        l_file.file_type           := l_file_type;
        l_file.proc_date           := l_sysdate;
        l_file.is_incoming         := com_api_type_pkg.FALSE;
        l_file.business_ica        := l_cmid;
        l_file.reason_code         := null;
        l_file.original_file_date  := l_sysdate;
        l_file.total_msg_count     := null;
        l_file.total_add_count     := null;
        l_file.total_changed_count := null;
        l_file.total_error_count   := null;
        l_file.record_count        := l_processed_count;

        select file_type
          into l_file.file_type
          from prc_session_file
         where id = l_session_file_id;
        
        add_mcw_abu_file(i_file => l_file);

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_processed_count
        );
        l_session_file_id := null;

        if l_full_export = com_api_const_pkg.TRUE then
            update evt_event_object eo
               set status          = evt_api_const_pkg.EVENT_STATUS_PROCESSED
                 , proc_session_id = get_session_id
             where decode(eo.status, 'EVST0001', eo.procedure_name, null) = C_ISS_SUBSCRIBER_NAME;
        end if;

        if l_estimated_count is null then
            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_processed_count + l_excepted_count
              , i_measure         => iss_api_const_pkg.ENTITY_TYPE_CARD
            );
        end if;

        prc_api_stat_pkg.log_current(
            i_current_count   => l_processed_count
          , i_excepted_count  => l_excepted_count
        );

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'END: processed_count [#1]'
          , i_env_param1 => l_processed_count
        );
    exception
        when others then
            trc_log_pkg.debug(i_text => LOG_PREFIX || 'FAILED ' || sqlerrm );

            if l_session_file_id is not null then
                prc_api_file_pkg.close_file(
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;
            raise;
    end;

begin
    prc_api_stat_pkg.log_start;
    savepoint sp_export_format_r274;

    l_host_id := net_api_network_pkg.get_default_host(l_network_id);

    l_standard_id := net_api_network_pkg.get_offline_standard(
        i_host_id       => l_host_id
    );
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' host_id [#1], standard_id [#2], inst_id [#3], full_export [#4]'
      , i_env_param1 => l_host_id
      , i_env_param2 => l_standard_id
      , i_env_param3 => i_inst_id
      , i_env_param4 => i_full_export
    );

    rul_api_param_pkg.set_param(
        i_name     => 'NETWORK_ID'
      , i_value    => l_network_id
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'HOST_ID'
      , i_value    => l_host_id
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'STANDARD_ID'
      , i_value    => l_standard_id
      , io_params  => l_params
    );

    rul_api_param_pkg.set_param(
        i_name     => 'FILE_NUMBER'
      , i_value    => l_file_number
      , io_params  => l_params
    );

    if i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST then
        for tab in (
            select ci.inst_id
              from iss_card_instance ci
                 , iss_card c
                 , net_card_type ct
             where ci.inst_id is not null
               and ci.card_id    = c.id
               and ci.split_hash = c.split_hash
               and ct.id         = c.card_type_id
               and ci.state      = iss_api_const_pkg.CARD_STATE_ACTIVE
               and ct.network_id = mcw_api_const_pkg.MCW_NETWORK_ID
             group by ci.inst_id
        ) loop
            create_file(i_inst_id => tab.inst_id);
        end loop;
    else
        create_file(i_inst_id => i_inst_id);
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total => l_processed_count
      , i_excepted_total  => l_excepted_count
    );

    trc_log_pkg.debug(
        i_text            => LOG_PREFIX || 'END: processed_count [#1]'
      , i_env_param1      => l_processed_count
    );

exception
    when others then
        trc_log_pkg.debug(i_text => LOG_PREFIX || 'FAILED: '|| substr(sqlerrm, 1, 1000) );

        rollback to sp_export_format_r274;

        prc_api_stat_pkg.log_end(i_result_code => prc_api_const_pkg.PROCESS_RESULT_FAILED);
        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;
        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error       => 'UNHANDLED_EXCEPTION'
              , i_env_param1  => sqlerrm
            );
        end if;

        raise;
end;

procedure import_format_t275 is
    l_network_id         com_api_type_pkg.t_tiny_id := mcw_api_const_pkg.MCW_NETWORK_ID;
    l_host_id            com_api_type_pkg.t_tiny_id;
    l_standard_id        com_api_type_pkg.t_tiny_id;
    l_inst_id            com_api_type_pkg.t_inst_id;
    l_estimated_count    com_api_type_pkg.t_long_id := 0;
    l_current_count      com_api_type_pkg.t_long_id := 0;
    l_total_count        com_api_type_pkg.t_long_id := 0;
    l_excepted_count     com_api_type_pkg.t_long_id := 0;
    l_total_excepted_cnt com_api_type_pkg.t_long_id := 0;
    l_session_file_id    com_api_type_pkg.t_long_id;
    l_string_tab         com_api_type_pkg.t_desc_tab;
    l_record_number_tab  com_api_type_pkg.t_short_tab;
    l_string_limit       com_api_type_pkg.t_short_id := 1000;
    l_file_rec           t_mcw_abu_file_rec;
    l_header             com_api_type_pkg.t_raw_data;
    l_str                com_api_type_pkg.t_raw_data;
    l_orig_detail_rec    com_api_type_pkg.t_raw_data;
    l_sysdate            date := com_api_sttl_day_pkg.get_sysdate();
    l_orig_rec           t_mcw_abu_iss_msg_rec;
    l_session_id         com_api_type_pkg.t_long_id := get_session_id;
begin
    savepoint import_format_r275_start;

    trc_log_pkg.info(i_text => 'Process MCW Issuer Account Change Confirmation File (T275)');

    l_host_id := net_api_network_pkg.get_default_host(l_network_id);

    l_standard_id := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);
    select count(1)
      into l_estimated_count
      from prc_file_raw_data rd
         , prc_session_file sf
         , prc_file_attribute a
         , prc_file f
     where sf.session_id      = l_session_id
       and rd.session_file_id = sf.id
       and sf.file_attr_id    = a.id
       and f.id               = a.file_id
       and f.file_type        = mcw_api_const_pkg.FILE_TYPE_ABU_T275;

    prc_api_stat_pkg.log_start;

    prc_api_stat_pkg.log_estimation(
        i_estimated_count       => l_estimated_count
    );

    for f in (
        select s.id
             , s.file_name
             , s.file_type
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id   = l_session_id
           and s.file_attr_id = a.id
           and f.id           = a.file_id
           and f.file_type    = mcw_api_const_pkg.FILE_TYPE_ABU_T275
    ) loop
        l_current_count  := 0;
        l_excepted_count := 0;
        trc_log_pkg.info(
            i_text       => 'Start process file [#1]'
          , i_env_param1 => f.file_name
        );

        l_session_file_id   := f.id;

        open cur_file_raw_data(i_session_file_id => l_session_file_id);
        loop
            fetch cur_file_raw_data
             bulk collect into 
                  l_string_tab
                , l_record_number_tab 
            limit l_string_limit;

            trc_log_pkg.info(
                i_text       => '[#1] records fetched'
              , i_env_param1 => l_string_tab.count
            );
            
            if l_record_number_tab(1) = 1 then
                l_header := l_string_tab(1);

                if substr(l_header, 1, 1) = 'H' then
                    -- header, try to find inst_id with issuer_ica 
                    l_file_rec.business_ica := substr(l_header, 2, 11);
                    
                    trc_log_pkg.debug('l_issuer_ica = ' || l_file_rec.business_ica);
                    begin
                        l_inst_id :=
                            find_value_owner(
                                i_standard_id    => l_standard_id
                              , i_entity_type    => net_api_const_pkg.ENTITY_TYPE_HOST
                              , i_object_id      => l_host_id
                              , i_param_name     => mcw_api_const_pkg.CMID
                              , i_requested_type => com_api_const_pkg.DATA_TYPE_CHAR
                              , i_value          => lpad(l_file_rec.business_ica, 11, '0')
                              , i_mask_error     => com_api_const_pkg.FALSE
                            );
                    exception
                        when others then
                            --Error in #1: wrong value; [#2] [#3]
                            com_api_error_pkg.raise_error(
                                i_error        => 'MCW_ERROR_WRONG_VALUE'
                              , i_env_param1   => 'ISSUER_ICA'
                              , i_env_param2   => l_file_rec.business_ica
                              , i_env_param3   => substr(sqlerrm, 1, 100)
                            );
                    end;
                else
                    com_api_error_pkg.raise_error(
                        i_error        => 'MCW_ERROR_WRONG_VALUE'
                      , i_env_param1   => 'HEADER'
                      , i_env_param2   => l_header
                      , i_env_param3   => 'Invalid file header'
                    );
                end if;

                l_file_rec.id                  := f.id;
                l_file_rec.inst_id             := l_inst_id;
                l_file_rec.network_id          := l_network_id;
                l_file_rec.file_type           := f.file_type;
                l_file_rec.proc_date           := l_sysdate;
                l_file_rec.is_incoming         := com_api_const_pkg.TRUE;
                l_file_rec.reason_code         := substr(l_header, 59, 1);
                l_file_rec.original_file_date  := null;
                l_file_rec.total_msg_count     := to_number(substr(l_header, 14, 7), com_api_const_pkg.XML_NUMBER_FORMAT);
                l_file_rec.total_add_count     := to_number(substr(l_header, 22, 7), com_api_const_pkg.XML_NUMBER_FORMAT);
                l_file_rec.total_changed_count := to_number(substr(l_header, 30, 7), com_api_const_pkg.XML_NUMBER_FORMAT);
                l_file_rec.total_error_count   := to_number(substr(l_header, 38, 7), com_api_const_pkg.XML_NUMBER_FORMAT);
                l_file_rec.record_count        := l_estimated_count - 1;

                add_mcw_abu_file(
                    i_file  => l_file_rec
                );
                l_current_count := nvl(l_current_count, 0) + 1;
            end if;

            for i in 1 .. l_string_tab.count loop
                savepoint process_string_start;
                begin
                    if l_record_number_tab(i) > 1 then
                        l_str                          := l_string_tab(i);
                        l_orig_rec.error_code_1        := substr(l_str, 71, 3);
                        l_orig_rec.error_code_2        := substr(l_str, 74, 3);
                        l_orig_rec.error_code_3        := substr(l_str, 77, 3);
                        l_orig_rec.error_code_4        := substr(l_str, 80, 3);
                        l_orig_rec.error_code_5        := substr(l_str, 83, 3);
                        
                        l_orig_detail_rec              := substr(l_str, 1, 70);
                        l_orig_rec.old_card_number     := trim(iss_api_token_pkg.encode_card_number(substr(l_orig_detail_rec, 13, 19)));
                        l_orig_rec.old_expiration_date := case when substr(l_orig_detail_rec, 32, 4) not in ('0000', '    ')
                                                               then to_date(substr(l_orig_detail_rec, 32, 4), 'MMYY')
                                                          end;
                        l_orig_rec.new_card_number     := trim(iss_api_token_pkg.encode_card_number(substr(l_orig_detail_rec, 36, 19)));
                        l_orig_rec.new_expiration_date := case when substr(l_orig_detail_rec, 55, 4) not in ('0000', '    ')
                                                               then to_date(substr(l_orig_detail_rec, 55, 4), 'MMYY')
                                                          end;
                        l_orig_rec.reason_code         := substr(l_orig_detail_rec, 59, 1);

                        for rec in (
                            select max(m.id) as id
                              from mcw_abu_iss_msg m
                             where m.old_card_number      = l_orig_rec.old_card_number
                               and (m.old_expiration_date = l_orig_rec.old_expiration_date or l_orig_rec.old_expiration_date is null)
                               and (m.new_card_number     = l_orig_rec.new_card_number or l_orig_rec.new_card_number is null or length(l_orig_rec.new_card_number) = 0)
                               and (m.new_expiration_date = l_orig_rec.new_expiration_date or l_orig_rec.new_expiration_date is null)
                               and m.reason_code          = l_orig_rec.reason_code
                        ) loop
                            if rec.id is not null then
                                update mcw_abu_iss_msg m
                                   set m.error_code_1    = l_orig_rec.error_code_1
                                     , m.error_code_2    = l_orig_rec.error_code_2
                                     , m.error_code_3    = l_orig_rec.error_code_3
                                     , m.error_code_4    = l_orig_rec.error_code_4
                                     , m.error_code_5    = l_orig_rec.error_code_5
                                     , m.status          = mcw_api_const_pkg.ABU_MSG_STATUS_REJECTED -- ABUS0020
                                     , m.confirm_file_id = f.id
                                 where id                = rec.id;

                                trc_log_pkg.info(
                                    i_text        => 'MCW ABU iss message [#1] updated: error_code_1 [#2] error_code_2 [#3] error_code_3 [#4] error_code_4 [#5] error_code_5 [#6]'
                                  , i_env_param1  => rec.id
                                  , i_env_param2  => l_orig_rec.error_code_1
                                  , i_env_param3  => l_orig_rec.error_code_2
                                  , i_env_param4  => l_orig_rec.error_code_3
                                  , i_env_param5  => l_orig_rec.error_code_4
                                  , i_env_param6  => l_orig_rec.error_code_5
                                  , i_inst_id     => l_inst_id
                                );
                                l_current_count := nvl(l_current_count, 0) + 1;
                            else
                                -- original message not found
                                trc_log_pkg.error(
                                    i_text      => 'MCW ABU issuing message not found: old_card_number [#1] '
                                                || 'old_expiration_date [#2] new_card_number [#3] '
                                                || 'new_expiration_date [#4] reason_code [#5]'
                                  , i_env_param1 => iss_api_card_pkg.get_card_mask(l_orig_rec.old_card_number)
                                  , i_env_param2 => l_orig_rec.old_expiration_date
                                  , i_env_param3 => iss_api_card_pkg.get_card_mask(l_orig_rec.new_card_number)
                                  , i_env_param4 => l_orig_rec.new_expiration_date
                                  , i_env_param5 => l_orig_rec.reason_code
                                  , i_inst_id    => l_inst_id
                                );
                                l_excepted_count := l_excepted_count + 1;
                            end if;
                        end loop;
                    end if;
                exception
                    when others then
                        rollback to savepoint process_string_start;
                        if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                            l_excepted_count := l_excepted_count + 1;
                        else
                            close cur_file_raw_data;
                            raise;

                        end if;
                end;

                if mod(l_current_count, 100) = 0 then
                    prc_api_stat_pkg.log_current (
                        i_current_count     => l_current_count
                      , i_excepted_count    => l_excepted_count
                    );
                end if;
            end loop;

            prc_api_stat_pkg.log_current (
                i_current_count     => l_current_count
              , i_excepted_count    => l_excepted_count
            );

            l_total_count        := nvl(l_total_count, 0)        + nvl(l_current_count, 0);
            l_total_excepted_cnt := nvl(l_total_excepted_cnt, 0) + nvl(l_excepted_count, 0);

            exit when cur_file_raw_data%notfound;
        end loop;

        close cur_file_raw_data;
        prc_api_file_pkg.close_file(
            i_sess_file_id => f.id
          , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count => nvl(l_current_count, 0) + nvl(l_excepted_count, 0)
        );
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => nvl(l_total_count, 0)
      , i_excepted_total    => nvl(l_total_excepted_cnt, 0)
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
     when others then
        rollback to savepoint import_format_r275_start;
        if cur_file_raw_data%isopen then
            close cur_file_raw_data;
        end if;

        prc_api_stat_pkg.log_end (
            i_processed_total => nvl(l_total_count, 0)
          , i_excepted_total  => nvl(l_total_excepted_cnt, 0)
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

        raise;
end;

procedure export_format_r625(
    i_inst_id  in        com_api_type_pkg.t_inst_id
) is
    l_total_count        com_api_type_pkg.t_long_id;
    l_total_excepted_cnt com_api_type_pkg.t_long_id;

    LOG_PREFIX     constant com_api_type_pkg.t_name         := lower($$PLSQL_UNIT) || '.export_format_r274: ';
    l_processed_count       com_api_type_pkg.t_long_id;
    l_excepted_count        com_api_type_pkg.t_long_id      := 0;
    l_estimated_count       com_api_type_pkg.t_long_id;
    l_session_file_id       com_api_type_pkg.t_long_id      := null;
    l_params                com_api_type_pkg.t_param_tab;
    l_host_id               com_api_type_pkg.t_tiny_id;
    l_standard_id           com_api_type_pkg.t_tiny_id;
    l_network_id            com_api_type_pkg.t_tiny_id      := mcw_api_const_pkg.MCW_NETWORK_ID;
    l_sysdate               date                            := com_api_sttl_day_pkg.get_sysdate;
    l_file_number           com_api_type_pkg.t_long_id      := 1;
    l_rec_raw               com_api_type_pkg.t_raw_tab;
    l_rec_num               com_api_type_pkg.t_integer_tab;
    l_cmid                  com_api_type_pkg.t_cmid;
    l_file_type             com_api_type_pkg.t_dict_value;
    l_file                  t_mcw_abu_file_rec;
    l_msg_tab               t_mcw_abu_acq_detail_tab;
    l_eo_tab                com_api_type_pkg.t_number_tab;

    cursor cu_acq_incremental(i_inst_id in   com_api_type_pkg.t_inst_id) is
    select null              id
         , m.split_hash      split_hash
         , mcw_api_const_pkg.ABU_MSG_STATUS_UPLOADED status
         , m.inst_id         inst_id
         , l_network_id      network_id
         , max(eo.eff_date)  keep(dense_rank last order by eo.id) request_date
         , l_session_file_id file_id
         , max(eo.id) as     event_object_id
         , null       as     confirm_file_id
         , l_cmid     as     acquirer_ica
         , decode(e.event_type, 'EVNT0275', 'R', 'EVNT0276', 'D' ) request_type
         , m.merchant_number
         , m.merchant_name
         , m.mcc
         , null              error_code_1
         , null              error_code_2
         , null              error_code_3
         , null              error_code_4
         , null              error_code_5
         , null              error_code_6
         , null              error_code_7
         , null              error_code_8
      from acq_merchant m
      join evt_event e on e.event_type in ('EVNT0275', 'EVNT0276')
      join evt_event_object eo on m.id           = eo.object_id
                              and m.split_hash   = eo.split_hash
                              and (eo.inst_id    = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST or i_inst_id is null)
                              and eo.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                              and decode(eo.status, 'EVST0001', procedure_name, null) = C_ACQ_SUBSCRIBER_NAME
                              and eo.eff_date   <= sysdate
                              and eo.event_id    = e.id
      where m.split_hash in (select x.split_hash from com_api_split_map_vw x )
   group by e.event_type
          , m.split_hash
          , m.inst_id
          , m.merchant_number
          , m.merchant_name
          , m.mcc
   order by 8
          , 6;

    procedure add_abu_acq_msg_bulk(i_msg_tab in     t_mcw_abu_acq_detail_tab) is
    begin
        forall i in indices of i_msg_tab
            insert into mcw_abu_acq_msg(
                id
              , split_hash
              , status
              , inst_id
              , network_id
              , request_date
              , file_id
              , event_object_id
              , confirm_file_id
              , acquirer_ica
              , request_type
              , merchant_number
              , merchant_name
              , mcc
              , error_code_1
              , error_code_2
              , error_code_3
              , error_code_4
              , error_code_5
              , error_code_6
              , error_code_7
              , error_code_8
            ) values(
                nvl(i_msg_tab(i).id, com_api_id_pkg.get_id(i_seq => mcw_abu_acq_msg_seq.nextval, i_date => l_sysdate))
              , i_msg_tab(i).split_hash
              , i_msg_tab(i).status
              , i_msg_tab(i).inst_id
              , i_msg_tab(i).network_id
              , i_msg_tab(i). request_date
              , i_msg_tab(i).file_id
              , i_msg_tab(i).event_object_id
              , i_msg_tab(i).confirm_file_id
              , i_msg_tab(i).acquirer_ica
              , i_msg_tab(i).request_type
              , i_msg_tab(i).merchant_number
              , i_msg_tab(i).merchant_name
              , i_msg_tab(i).mcc
              , i_msg_tab(i).error_code_1
              , i_msg_tab(i).error_code_2
              , i_msg_tab(i).error_code_3
              , i_msg_tab(i).error_code_4
              , i_msg_tab(i).error_code_5
              , i_msg_tab(i).error_code_6
              , i_msg_tab(i).error_code_7
              , i_msg_tab(i).error_code_8
            );
    end;
    
    function format_r625_header return com_api_type_pkg.t_text is
        l_string com_api_type_pkg.t_raw_data;
    begin
        l_string := '1' || lpad(l_cmid, 11, '0')
                        || to_char(l_sysdate, 'DDMMYYYY')
                        || lpad(' ', 14)
                        || lpad(' ', 46);
        return l_string;
    end;

    -- Detail Record for the Acquirer Merchant Registration File (R625)
    function format_r625(
        i_msg  in     t_mcw_abu_acq_msg_rec
    ) return com_api_type_pkg.t_raw_data is
        l_line  com_api_type_pkg.t_raw_data;
    begin
        l_line :=
            '2'
         || to_char(i_msg.request_date, 'DDMMYYYY')
         || lpad(' ', 1)
         || lpad(l_cmid, 11, '0')
         || lpad(' ', 1)
         || lpad(i_msg.request_type, 1, ' ')
         || lpad(' ', 1)
         || lpad(i_msg.merchant_number, 15 , ' ')
         || lpad(' ', 1)
         || rpad(i_msg.merchant_name, 25 , ' ')
         || lpad(' ', 1)
         || lpad(i_msg.mcc, 4, ' ')
         || lpad(' ', 10);

        return l_line;
    end;

    -- Trailer Record for the Acquirer Merchant Registration File (R625)
    function format_r625_trailer(
        i_file_rec  in     t_mcw_abu_file_rec
    ) return com_api_type_pkg.t_raw_data is
        l_line com_api_type_pkg.t_raw_data;
    begin
        l_line :=
            '9'
         || lpad(l_cmid, 11, '0')
         || lpad(to_char(nvl(i_file_rec.record_count, 0), com_api_const_pkg.XML_NUMBER_FORMAT), 9, ' ')
         || lpad(' ', 8)
         || lpad(' ', 51)
        ;
        return l_line;
    end;

    procedure create_file(
        i_inst_id  in     com_api_type_pkg.t_inst_id
    ) is
        LOG_PREFIX constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.export_format_r625.create_file: ';
    begin
        trc_log_pkg.debug(i_text => LOG_PREFIX || 'START: i_inst_id ' || i_inst_id );

        rul_api_param_pkg.set_param(
            i_name    => 'INST_ID'
          , i_value   => i_inst_id
          , io_params => l_params
        );
        -- query cm_id
        l_cmid :=
            cmn_api_standard_pkg.get_varchar_value(
                i_inst_id     => i_inst_id
              , i_standard_id => l_standard_id
              , i_object_id   => l_host_id
              , i_entity_type => net_api_const_pkg.ENTITY_TYPE_HOST
              , i_param_name  => mcw_api_const_pkg.CMID
              , i_param_tab   => l_params
            );

        prc_api_file_pkg.open_file(
            o_sess_file_id  => l_session_file_id
          , i_file_purpose  => prc_api_const_pkg.FILE_PURPOSE_OUT
          , io_params       => l_params
          , i_file_type     => mcw_api_const_pkg.FILE_TYPE_ABU_R625
        );

        trc_log_pkg.debug(i_text => LOG_PREFIX || 'l_session_file_id=' || l_session_file_id );

        open cu_acq_incremental(i_inst_id => i_inst_id);
        loop
            fetch cu_acq_incremental bulk collect into l_msg_tab limit BULK_LIMIT;
            trc_log_pkg.debug(i_text => LOG_PREFIX || ' fetched ' || l_msg_tab.count || ' records' );
         
            l_estimated_count := nvl(l_estimated_count, 0) + l_msg_tab.count + 2; -- add header and footer

            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_estimated_count
              , i_measure         => iss_api_const_pkg.ENTITY_TYPE_CARD
            );

            l_eo_tab.delete();
            l_rec_raw.delete();
            l_rec_num.delete();
            l_processed_count := nvl(l_processed_count, 0) + 1;
            l_rec_raw(l_rec_raw.count() + 1) := format_r625_header;
            l_rec_num(l_rec_num.count() + 1) := l_processed_count;

            for i in 1 .. l_msg_tab.count() loop
                l_processed_count :=  nvl(l_processed_count, 0) + 1;
                l_rec_raw(l_rec_raw.count() + 1):= format_r625(i_msg  => l_msg_tab(i) );
                l_rec_num(l_rec_num.count() + 1) := l_processed_count;
                l_eo_tab(l_eo_tab.count() + 1) := l_msg_tab(i).event_object_id;
            end loop;

            l_processed_count :=  nvl(l_processed_count, 0) + 1;
            l_file.record_count := l_processed_count;
            l_rec_raw(l_rec_raw.count() + 1) := format_r625_trailer(i_file_rec  => l_file );
            l_rec_num(l_rec_num.count() + 1) := l_processed_count;

            add_abu_acq_msg_bulk(i_msg_tab => l_msg_tab);

            prc_api_file_pkg.put_bulk(
                i_sess_file_id  => l_session_file_id
              , i_raw_tab       => l_rec_raw
              , i_num_tab       => l_rec_num
            );

            evt_api_event_pkg.process_event_object(i_event_object_id_tab => l_eo_tab);

            prc_api_stat_pkg.log_current (
                i_current_count   => l_processed_count
              , i_excepted_count  => 0
            );

            exit when cu_acq_incremental%notfound;
        end loop;

        close cu_acq_incremental;

        l_file.id                  := l_session_file_id;
        l_file.inst_id             := i_inst_id;
        l_file.network_id          := l_network_id;
        l_file.file_type           := l_file_type;
        l_file.proc_date           := l_sysdate;
        l_file.is_incoming         := com_api_type_pkg.FALSE;
        l_file.business_ica        := l_cmid;
        l_file.reason_code         := null;
        l_file.original_file_date  := l_sysdate;
        l_file.total_msg_count     := null;
        l_file.total_add_count     := null;
        l_file.total_changed_count := null;
        l_file.total_error_count   := null;
        l_file.record_count        := l_processed_count;

        select file_type
          into l_file.file_type
          from prc_session_file
         where id = l_session_file_id;
        
        add_mcw_abu_file(i_file => l_file);

        prc_api_file_pkg.close_file(
            i_sess_file_id  => l_session_file_id
          , i_status        => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count  => l_processed_count
        );

        if l_estimated_count is null then
            prc_api_stat_pkg.log_estimation(
                i_estimated_count => l_processed_count + l_excepted_count
              , i_measure         => iss_api_const_pkg.ENTITY_TYPE_CARD
            );
        end if;

        prc_api_stat_pkg.log_current(
            i_current_count   => l_processed_count
          , i_excepted_count  => l_excepted_count
        );

        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || 'END: processed_count [#1]'
          , i_env_param1 => l_processed_count
        );
    exception
        when others then
            trc_log_pkg.debug(i_text => LOG_PREFIX || 'FAILED ' || sqlerrm );

            if l_session_file_id is not null then
                prc_api_file_pkg.close_file(
                    i_sess_file_id  => l_session_file_id
                  , i_status        => prc_api_const_pkg.FILE_STATUS_REJECTED
                );
            end if;
            raise;
    end;

begin
    savepoint export_format_r625_start;
    prc_api_stat_pkg.log_start;

    l_host_id := net_api_network_pkg.get_default_host(l_network_id);

    l_standard_id := net_api_network_pkg.get_offline_standard(
        i_host_id       => l_host_id
    );
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || ' host_id [#1], standard_id [#2], inst_id [#3]'
      , i_env_param1 => l_host_id
      , i_env_param2 => l_standard_id
      , i_env_param3 => i_inst_id
    );

    rul_api_param_pkg.set_param(
        i_name     => 'NETWORK_ID'
      , i_value    => l_network_id
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'HOST_ID'
      , i_value    => l_host_id
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'STANDARD_ID'
      , i_value    => l_standard_id
      , io_params  => l_params
    );
    rul_api_param_pkg.set_param(
        i_name     => 'FILE_NUMBER'
      , i_value    => l_file_number
      , io_params  => l_params
    );

    if i_inst_id is null or i_inst_id = ost_api_const_pkg.DEFAULT_INST then
        for tab in (
            select m.inst_id
              from acq_merchant m
              join evt_event e on e.event_type in ('EVNT0275', 'EVNT0276')
              join evt_event_object eo on m.id           = eo.object_id
                                      and m.split_hash   = eo.split_hash
                                      and (eo.inst_id     = i_inst_id or i_inst_id = ost_api_const_pkg.DEFAULT_INST or i_inst_id is null)
                                      and eo.entity_type = acq_api_const_pkg.ENTITY_TYPE_MERCHANT
                                      and decode(eo.status, 'EVST0001', procedure_name, null) = C_ACQ_SUBSCRIBER_NAME
                                      and eo.eff_date   <=  l_sysdate
                                      and eo.event_id    = e.id
             where m.split_hash in (select x.split_hash from com_api_split_map_vw x )
             group by m.inst_id
        ) loop
            create_file(i_inst_id => tab.inst_id);
        end loop;
    else
        create_file(i_inst_id => i_inst_id);
    end if;

    prc_api_stat_pkg.log_end(
        i_result_code     => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
      , i_processed_total => l_processed_count
      , i_excepted_total  => l_excepted_count
    );

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || 'END: processed_count [#1]'
      , i_env_param1 => l_processed_count
    );

exception
     when others then
        rollback to savepoint export_format_r625_start;
        if cur_file_raw_data%isopen then
            close cur_file_raw_data;
        end if;

        prc_api_stat_pkg.log_end (
            i_processed_total => nvl(l_total_count, 0)
          , i_excepted_total  => nvl(l_total_excepted_cnt, 0)
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );
        end if;

        raise;
end;

procedure import_format_t626 is
    l_network_id          com_api_type_pkg.t_tiny_id := mcw_api_const_pkg.MCW_NETWORK_ID;
    l_host_id             com_api_type_pkg.t_tiny_id;
    l_standard_id         com_api_type_pkg.t_tiny_id;
    l_inst_id             com_api_type_pkg.t_inst_id;
    l_estimated_count     com_api_type_pkg.t_long_id := 0;
    l_current_count       com_api_type_pkg.t_long_id := 0;
    l_total_count         com_api_type_pkg.t_long_id := 0;
    l_excepted_count      com_api_type_pkg.t_long_id := 0;
    l_total_excepted_cnt  com_api_type_pkg.t_long_id := 0;
    l_session_file_id     com_api_type_pkg.t_long_id;
    l_string_tab          com_api_type_pkg.t_desc_tab;
    l_record_number_tab   com_api_type_pkg.t_short_tab;
    l_string_limit        com_api_type_pkg.t_short_id := 1000;
    l_file_rec            t_mcw_abu_file_rec;
    l_header              com_api_type_pkg.t_raw_data;
    l_trailer             com_api_type_pkg.t_raw_data;
    l_detail              com_api_type_pkg.t_raw_data;
    l_orig_detail_rec     com_api_type_pkg.t_raw_data;
    l_sysdate             date := com_api_sttl_day_pkg.get_sysdate();
    l_acq_rec             t_mcw_abu_acq_msg_rec;
    l_session_id          com_api_type_pkg.t_long_id := get_session_id;
begin
    savepoint import_format_t626_start;
    prc_api_stat_pkg.log_start;

    trc_log_pkg.info(i_text => 'Process MCW Acquirer Account Change Confirmation File (T626)');

    l_host_id      := net_api_network_pkg.get_default_host(l_network_id);
    l_standard_id  := net_api_network_pkg.get_offline_standard(i_host_id => l_host_id);

    select count(1)
      into l_estimated_count
      from prc_file_raw_data rd
         , prc_session_file sf
         , prc_file_attribute a
         , prc_file f
     where sf.session_id      = l_session_id
       and rd.session_file_id = sf.id
       and sf.file_attr_id    = a.id
       and f.id               = a.file_id
       and f.file_type        = mcw_api_const_pkg.FILE_TYPE_ABU_T626;

    prc_api_stat_pkg.log_estimation(i_estimated_count => l_estimated_count );

    for f in (
        select s.id
             , s.file_name
             , s.file_type
          from prc_session_file s
             , prc_file_attribute a
             , prc_file f
         where s.session_id   = l_session_id
           and s.file_attr_id = a.id
           and f.id           = a.file_id
           and f.file_type    = mcw_api_const_pkg.FILE_TYPE_ABU_T626
    ) loop
        l_current_count  := 2; -- header and footer
        l_excepted_count := 0;
        trc_log_pkg.info(
            i_text       => 'Start process file [#1]'
          , i_env_param1 => f.file_name
        );

        l_session_file_id   := f.id;

        open cur_file_raw_data(i_session_file_id => l_session_file_id);
        loop
            fetch cur_file_raw_data
             bulk collect into
                  l_string_tab
                , l_record_number_tab
            limit l_string_limit;

            trc_log_pkg.info(
                i_text       => '#1 records fetched'
              , i_env_param1 => l_string_tab.count
            );

            if l_record_number_tab(1) = 1 then
                l_header := l_string_tab(1);

                if substr(l_header, 1, 1) = '1' then
                    -- header, try to find inst_id with issuer_ica
                    l_file_rec.business_ica := substr(l_header, 2, 11);

                    trc_log_pkg.debug('l_acquirer_ica = ' || l_file_rec.business_ica);
                    begin
                        l_inst_id := 
                            find_value_owner(
                                i_standard_id  => l_standard_id
                              , i_entity_type  => net_api_const_pkg.ENTITY_TYPE_HOST
                              , i_object_id    => l_host_id
                              , i_param_name   => mcw_api_const_pkg.CMID
                              , i_requested_type => com_api_const_pkg.DATA_TYPE_CHAR
                              , i_value          => lpad(l_file_rec.business_ica, 11, '0')
                              , i_mask_error   => com_api_const_pkg.FALSE
                            );
                    exception
                        when others then
                            com_api_error_pkg.raise_error(
                                i_error        => 'MCW_ERROR_WRONG_VALUE'
                              , i_env_param1   => 'ACQUIRER_ICA'
                              , i_env_param2   => l_file_rec.business_ica
                              , i_env_param3   => substr(sqlerrm, 1, 100)
                            );
                    end;
                else
                    com_api_error_pkg.raise_error(
                        i_error        => 'MCW_ERROR_WRONG_VALUE'
                      , i_env_param1   => 'HEADER'
                      , i_env_param2   => l_header
                      , i_env_param3   => 'Invalid file header'
                    );
                end if;

                l_file_rec.id                  := f.id;
                l_file_rec.inst_id             := l_inst_id;
                l_file_rec.network_id          := l_network_id;
                l_file_rec.file_type           := f.file_type;
                l_file_rec.proc_date           := l_sysdate;
                l_file_rec.is_incoming         := com_api_const_pkg.TRUE;
                l_file_rec.reason_code         := null;
                l_file_rec.original_file_date  := to_date(substr(l_header, 14, 8), 'ddmmyyyy');
                l_file_rec.total_msg_count     := to_number(substr(l_header, 22, 7), com_api_const_pkg.XML_NUMBER_FORMAT);
                l_file_rec.total_add_count     := null;
                l_file_rec.total_changed_count := to_number(substr(l_header, 30, 7), com_api_const_pkg.XML_NUMBER_FORMAT);
                l_file_rec.total_error_count   := to_number(substr(l_header, 38, 7), com_api_const_pkg.XML_NUMBER_FORMAT);

                l_trailer := l_string_tab(l_string_tab.count);

                if substr(l_trailer, 1, 1) = '9' then
                    -- trailer record
                    l_file_rec.record_count   := to_number(substr(l_trailer, 13, 9), com_api_const_pkg.XML_NUMBER_FORMAT);
                else
                    com_api_error_pkg.raise_error(
                        i_error        => 'MCW_ERROR_WRONG_VALUE'
                      , i_env_param1   => 'TRAILER'
                      , i_env_param2   => l_trailer
                      , i_env_param3   => 'Invalid file trailer'
                    );
                end if; 

                add_mcw_abu_file(
                    i_file  => l_file_rec
                );
            end if;

            if l_string_tab.count > 2 then
                for i in 2 .. l_string_tab.count-1 loop
                    savepoint process_string_start;
                    begin
                        if l_record_number_tab(i) > 1 then
                            l_detail  := l_string_tab(i);
                            if substr(l_detail, 1, 1) = '2' then
                                -- detail record
                                l_acq_rec.acquirer_ica    := substr(l_detail,   2, 11);
                                l_acq_rec.error_code_1    := substr(l_detail,  93, 3);
                                l_acq_rec.error_code_2    := substr(l_detail,  96, 3);
                                l_acq_rec.error_code_3    := substr(l_detail,  99, 3);
                                l_acq_rec.error_code_4    := substr(l_detail, 102, 3);
                                l_acq_rec.error_code_5    := substr(l_detail, 105, 3);
                                l_acq_rec.error_code_6    := substr(l_detail, 108, 3);
                                l_acq_rec.error_code_7    := substr(l_detail, 111, 3);
                                l_acq_rec.error_code_8    := substr(l_detail, 114, 3);

                                l_orig_detail_rec         := substr(l_detail, 13, 80);
                                l_acq_rec.merchant_number := trim(substr(l_orig_detail_rec, 25, 15));
                                l_acq_rec.merchant_name   := trim(trim(substr(l_orig_detail_rec, 41, 25)));
                                l_acq_rec.request_type    := substr(l_orig_detail_rec, 23, 1);
                                l_acq_rec.mcc             := substr(l_orig_detail_rec, 67, 4);

                                for rec in (
                                    select max(m.id) as id
                                      from mcw_abu_acq_msg m
                                     where m.merchant_number = l_acq_rec.merchant_number
                                       and (m.merchant_name  = trim(l_acq_rec.merchant_name) 
                                            or (m.merchant_name is null and l_acq_rec.merchant_name is null)
                                           )
                                       and m.request_type    = l_acq_rec.request_type
                                       and m.mcc             = l_acq_rec.mcc
                                ) loop
                                    if rec.id is not null then
                                        update mcw_abu_acq_msg m
                                           set m.error_code_1    = l_acq_rec.error_code_1
                                             , m.error_code_2    = l_acq_rec.error_code_2
                                             , m.error_code_3    = l_acq_rec.error_code_3
                                             , m.error_code_4    = l_acq_rec.error_code_4
                                             , m.error_code_5    = l_acq_rec.error_code_5
                                             , m.error_code_6    = l_acq_rec.error_code_6
                                             , m.error_code_7    = l_acq_rec.error_code_7
                                             , m.error_code_8    = l_acq_rec.error_code_8
                                             , m.status          = mcw_api_const_pkg.ABU_MSG_STATUS_REJECTED
                                             , m.confirm_file_id = f.id
                                         where id                = rec.id;

                                        trc_log_pkg.info(
                                            i_text       => 'MCW ABU acq message [#1] updated: error_code_1/2 [#2]'
                                                          ||' error_code_3/4 [#3] error_code_5/6 [#4]'
                                                          ||' error_code_7/8 [#5]'
                                          , i_env_param1 => rec.id
                                          , i_env_param2 => l_acq_rec.error_code_1 || '/' || l_acq_rec.error_code_2
                                          , i_env_param3 => l_acq_rec.error_code_3 || '/' || l_acq_rec.error_code_4
                                          , i_env_param4 => l_acq_rec.error_code_5 || '/' || l_acq_rec.error_code_6
                                          , i_env_param5 => l_acq_rec.error_code_7 || '/' || l_acq_rec.error_code_8
                                          , i_inst_id    => l_inst_id
                                        );
                                        l_current_count := nvl(l_current_count, 0) + 1;
                                    else
                                        -- original message not found
                                        trc_log_pkg.error(
                                            i_text      => 'MCW ABU acquiring msg not found: merchant_number [#1] '
                                                        || 'merchant_name [#2] request_type [#3] mcc [#4]'
                                          , i_env_param1 => l_acq_rec.merchant_number
                                          , i_env_param2 => l_acq_rec.merchant_name
                                          , i_env_param3 => l_acq_rec.request_type
                                          , i_env_param4 => l_acq_rec.mcc
                                          , i_inst_id    => l_inst_id
                                        );

                                        l_excepted_count := l_excepted_count + 1;
                                    end if;
                                end loop;
                            end if;
                         end if;
                    exception
                        when others then
                            rollback to savepoint process_string_start;
                            if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE then
                                l_excepted_count := l_excepted_count + 1;
                            else
                                close cur_file_raw_data;
                                raise;
                            end if;
                    end;

                    if mod(l_current_count, 100) = 0 then
                        prc_api_stat_pkg.log_current (
                            i_current_count   => l_current_count
                          , i_excepted_count  => l_excepted_count
                        );
                    end if;
                end loop;
            end if;
            prc_api_stat_pkg.log_current (
                i_current_count     => l_current_count
              , i_excepted_count    => l_excepted_count
            );

            l_total_count        := nvl(l_total_count, 0)        + nvl(l_current_count, 0);
            l_total_excepted_cnt := nvl(l_total_excepted_cnt, 0) + nvl(l_excepted_count, 0);

            exit when cur_file_raw_data%notfound;
        end loop;

        close cur_file_raw_data;
        prc_api_file_pkg.close_file(
            i_sess_file_id => f.id
          , i_status       => prc_api_const_pkg.FILE_STATUS_ACCEPTED
          , i_record_count => nvl(l_current_count, 0) + nvl(l_excepted_count, 0)
        );
    end loop;

    prc_api_stat_pkg.log_end(
        i_processed_total   => nvl(l_total_count, 0)
      , i_excepted_total    => nvl(l_total_excepted_cnt, 0)
      , i_result_code       => prc_api_const_pkg.PROCESS_RESULT_SUCCESS
    );

exception
     when others then
        rollback to savepoint import_format_t626_start;
        if cur_file_raw_data%isopen then
            close cur_file_raw_data;
        end if;

        prc_api_stat_pkg.log_end (
            i_processed_total => nvl(l_total_count, 0)
          , i_excepted_total  => nvl(l_total_excepted_cnt, 0)
          , i_result_code     => prc_api_const_pkg.PROCESS_RESULT_FAILED
        );

        if com_api_error_pkg.is_fatal_error(sqlcode) = com_api_const_pkg.TRUE then
            raise;

        elsif com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.FALSE then
            com_api_error_pkg.raise_fatal_error(
                i_error      => 'UNHANDLED_EXCEPTION'
              , i_env_param1 => sqlerrm
            );

        end if;

        raise;
end;

end;
/
