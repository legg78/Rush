create or replace package body cpn_api_campaign_pkg is

function get_campaign(
    i_campaign_id          in     com_api_type_pkg.t_short_id
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return cpn_api_type_pkg.t_campaign_rec
is
    l_campaign                    cpn_api_type_pkg.t_campaign_rec;
begin
    begin
        select id
             , inst_id
             , seqnum
             , campaign_number
             , null as lang
             , null as name
             , null as description
             , campaign_type
             , start_date
             , end_date
             , cycle_id
          into l_campaign
          from cpn_campaign
         where id = i_campaign_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'CAMPAIGN_NOT_FOUND'
                  , i_env_param1  => i_campaign_id
                );
            else
                trc_log_pkg.debug(
                    i_text       => 'Campaign not found by ID [#1]'
                  , i_env_param1 => i_campaign_id
                );
            end if;
    end;
    return l_campaign;
end get_campaign;

function get_campaign(
    i_campaign_number      in     com_api_type_pkg.t_name
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return cpn_api_type_pkg.t_campaign_rec
is
    l_campaign                    cpn_api_type_pkg.t_campaign_rec;
begin
    begin
        select id
             , inst_id
             , seqnum
             , campaign_number
             , null as lang
             , null as name
             , null as description
             , campaign_type
             , start_date
             , end_date
             , cycle_id
          into l_campaign
          from cpn_campaign
         where campaign_number = i_campaign_number
           and inst_id         = i_inst_id;
    exception
        when no_data_found then
            if nvl(i_mask_error, com_api_const_pkg.FALSE) = com_api_const_pkg.FALSE then
                com_api_error_pkg.raise_error(
                    i_error       => 'CAMPAIGN_NOT_FOUND'
                  , i_env_param2  => i_campaign_number
                  , i_env_param3  => i_inst_id
                );
            else
                trc_log_pkg.debug(
                    i_text       => 'Campaign not found by number [#1] and institution [#2]'
                  , i_env_param1 => i_campaign_number
                  , i_env_param2 => i_inst_id
                );
            end if;
    end;
    return l_campaign;
end get_campaign;

function is_campaign_started(
    i_campaign_id          in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
begin
    return com_api_const_pkg.TRUE;
end;

function is_campaign_finished(
    i_campaign_id          in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean
is
begin
    return com_api_const_pkg.TRUE;
end;

end;
/
