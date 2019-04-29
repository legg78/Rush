create or replace package body csm_ui_stop_list_pkg as
/*********************************************************
 *  API for IPS stop lists <br />
 *  Created by Alalykin A. (alalykin@bpcbt.com) at 02.03.2017 <br />
 *  Module: CSM_UI_STOP_LIST_PKG <br />
 *  @headcom
 **********************************************************/

function is_visa(
    i_dispute_id            in     com_api_type_pkg.t_long_id
)
return com_api_type_pkg.t_boolean
is
    l_result                        com_api_type_pkg.t_boolean;
begin
    begin
        select com_api_const_pkg.TRUE
          into l_result
          from opr_operation   opr
          join vis_fin_message vis    on vis.id = opr.id
         where opr.dispute_id = i_dispute_id
           and rownum = 1;
    exception
        when no_data_found then
            l_result := com_api_const_pkg.FALSE;
    end;

    return l_result;
end;

function is_mastercard(
    i_dispute_id            in     com_api_type_pkg.t_long_id
)
return com_api_type_pkg.t_boolean
is
    l_result                        com_api_type_pkg.t_boolean;
begin
    begin
        select com_api_const_pkg.TRUE
          into l_result
          from opr_operation   opr
          join mcw_fin         mcw    on mcw.id = opr.id
         where opr.dispute_id = i_dispute_id
           and rownum = 1;
    exception
        when no_data_found then
            l_result := com_api_const_pkg.FALSE;
    end;

    return l_result;
end;

/*
 * Function returns true if a dispute belongs to VISA or MasterCard network.
 */
function is_visa_or_mastercard(
    i_dispute_id            in     com_api_type_pkg.t_long_id
)
return com_api_type_pkg.t_boolean
is
    l_result                        com_api_type_pkg.t_boolean;
begin
    -- Functions is_visa() and is_mastercard() aren't used to avoid 2 select quieries instead of one
    select case
               when max(vis.id) is not null
                 or max(mcw.id) is not null
               then com_api_const_pkg.TRUE
               else com_api_const_pkg.FALSE
           end
      into l_result
      from      opr_operation   opr
      left join vis_fin_message vis    on vis.id = opr.id
      left join mcw_fin         mcw    on mcw.id = opr.id
     where opr.dispute_id = i_dispute_id;

    return l_result;
end;

function is_put_stop_list_enable(
    i_dispute_id            in     com_api_type_pkg.t_long_id
)
return com_api_type_pkg.t_boolean
is
    l_result       com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;
    l_flow_id      com_api_type_pkg.t_tiny_id;
    l_case_rec     csm_api_type_pkg.t_csm_case_rec;
begin
    trc_log_pkg.debug(
        i_text       => 'is_put_stop_list_enable: check dispute [#1]'
      , i_env_param1 => i_dispute_id
    );
    if is_visa_or_mastercard(i_dispute_id) = com_api_const_pkg.TRUE then
        csm_api_case_pkg.get_case(
            i_dispute_id => i_dispute_id
          , o_case_rec   => l_case_rec
          , i_mask_error => com_api_const_pkg.TRUE
        );
        l_flow_id := l_case_rec.flow_id;
        trc_log_pkg.debug(
            i_text       => 'is_put_stop_list_enable: flow [#1]'
          , i_env_param1 => l_flow_id
        );
        if l_flow_id in (app_api_const_pkg.FLOW_ID_ISS_DISPUTE_DOMESTIC
                       , app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC
                       , app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_DOMESTIC
                       , app_api_const_pkg.FLOW_ID_ACQ_DISPUTE_INTERNTNL) then
            l_result := com_api_const_pkg.TRUE;
        end if;
    end if;
    return l_result;
end is_put_stop_list_enable;

/*
 * Fucntion returns LOV ID of VISA stop list types if card belongs to VISA network,
 * and it returns LOV ID of MasterCard stop list types if card belongs to MasterCard network.
 */
function get_lov_id(
    i_dispute_id            in     com_api_type_pkg.t_long_id
)
return com_api_type_pkg.t_tiny_id
is
begin
    return
        case
            when is_visa(
                     i_dispute_id => i_dispute_id
                 ) = com_api_const_pkg.TRUE          then vis_api_const_pkg.LOV_ID_VIS_STOP_LIST_TYPES
            when is_mastercard(
                     i_dispute_id => i_dispute_id
                 ) = com_api_const_pkg.TRUE          then mcw_api_const_pkg.LOV_ID_MCW_STOP_LIST_TYPES
        end;
end;

/*
 * Procedure tries to register a new event of specified type for a certain card instance;
 * on success it adds a new record into stop list table with event object ID, otherwise it raises an error.
 */
procedure send_card_to_stop_list(
    i_card_instance_id      in     com_api_type_pkg.t_long_id
  , i_stop_list_type        in     com_api_type_pkg.t_dict_value
  , i_event_type            in     com_api_type_pkg.t_dict_value
  , i_reason_code           in     com_api_type_pkg.t_dict_value
  , i_purge_date            in     date
  , i_region_list           in     com_api_type_pkg.t_name
  , i_product               in     com_api_type_pkg.t_dict_value default null
) is
    LOG_PREFIX            constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.send_card_to_stop_list ';
    l_param_tab                    com_api_type_pkg.t_param_tab;
    l_card_instance                iss_api_type_pkg.t_card_instance;
    l_sysdate                      date;
    l_id                           com_api_type_pkg.t_long_id;
    l_event_id                     com_api_type_pkg.t_medium_id;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_card_instance_id [' || i_card_instance_id
                                   || '], i_stop_list_type [#1], i_event_type [#2]'
                                   ||  ', i_reason_code [#3], i_purge_date [#4]'
                                   ||  ', i_region_list [' || i_region_list || ']'
      , i_env_param1 => i_stop_list_type
      , i_env_param2 => i_event_type
      , i_env_param3 => i_reason_code
      , i_env_param4 => to_char(i_purge_date, com_api_const_pkg.LOG_DATE_FORMAT)
    );

    begin
        select e.id
          into l_event_id
          from evt_event e
             , evt_subscription s
         where e.event_type = i_event_type
           and e.id = s.event_id
           and rownum = 1;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error(
                i_error      => 'SUBSCRIPTION_ON_EVENT_TYPE_NOT_FOUND'
              , i_env_param1 => i_event_type
            );
    end;

    l_sysdate := com_api_sttl_day_pkg.get_sysdate();

    l_card_instance :=
        iss_api_card_instance_pkg.get_instance(
            i_id           => i_card_instance_id
          , i_raise_error  => com_api_const_pkg.FALSE
        );

    evt_api_event_pkg.register_event(
        i_event_type    => i_event_type
      , i_eff_date      => l_sysdate
      , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
      , i_object_id     => l_card_instance.id
      , i_inst_id       => l_card_instance.inst_id
      , i_split_hash    => l_card_instance.split_hash
      , i_param_tab     => l_param_tab
    ); 

    -- Check if an event object was created for the card instance,
    -- always choose last unprocessed event as far as it should be "just created"
    select max(eo.id)
      into l_id
      from evt_event_object eo
     where eo.entity_type = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
       and eo.object_id   = i_card_instance_id
       and eo.status      = evt_api_const_pkg.EVENT_STATUS_READY
       and eo.split_hash  = l_card_instance.split_hash
       and eo.id         >= com_api_id_pkg.get_from_id(i_date => l_sysdate - 1)
       and eo.id         <= com_api_id_pkg.get_till_id(i_date => l_sysdate);

    if l_id is null then
        com_api_error_pkg.raise_error(
            i_error      => 'STOP_LIST_SUBSCRIPTION_IS_NOT_CONFIGURATED'
          , i_env_param1 => i_event_type
        );
    else
        insert into csm_stop_list_vw(
            id
          , stop_list_type
          , reason_code
          , purge_date
          , region_list
          , product
        )
        values(
            l_id
          , i_stop_list_type
          , i_reason_code
          , i_purge_date
          , i_region_list
          , i_product
        );
    end if;

    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '>> new event object ID [' || l_id || ']'
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> FAILED; l_id [' || l_id || '], sqlerrm: ' || sqlerrm
        );
        raise;
end send_card_to_stop_list;

procedure get_last_csm_stop_list(
    i_card_instance_id      in     com_api_type_pkg.t_long_id
  , o_id                    out    com_api_type_pkg.t_long_id
  , o_stop_list_type        out    com_api_type_pkg.t_dict_value
  , o_reason_code           out    com_api_type_pkg.t_dict_value
  , o_purge_date            out    date
  , o_region_list           out    com_api_type_pkg.t_short_desc
  , o_product               out    com_api_type_pkg.t_dict_value
)
is
begin
    select id
         , stop_list_type
         , reason_code
         , purge_date
         , region_list
         , product
      into o_id
         , o_stop_list_type
         , o_reason_code
         , o_purge_date
         , o_region_list
         , o_product
      from (
        select sl.id
             , sl.stop_list_type
             , sl.reason_code
             , sl.purge_date
             , sl.region_list
             , sl.product
          from csm_stop_list       sl
             , evt_event_object    eo
             , iss_card_instance   ci
         where sl.id            = eo.id
           and eo.object_id     = ci.id
           and ci.id            = i_card_instance_id
           and eo.entity_type   = iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
           and eo.split_hash    = ci.split_hash
          order by sl.id desc
    ) where rownum = 1;
exception
    when no_data_found then
        com_api_error_pkg.raise_error (
            i_error       => 'CARD_NOT_FOUND'
          , i_env_param1  => i_card_instance_id
        );
end get_last_csm_stop_list;

end;
/
