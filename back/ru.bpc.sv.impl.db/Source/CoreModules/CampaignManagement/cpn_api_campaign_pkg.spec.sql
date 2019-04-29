create or replace package cpn_api_campaign_pkg is

function get_campaign(
    i_campaign_id          in     com_api_type_pkg.t_short_id
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return cpn_api_type_pkg.t_campaign_rec;

function get_campaign(
    i_campaign_number      in     com_api_type_pkg.t_name
  , i_inst_id              in     com_api_type_pkg.t_inst_id
  , i_mask_error           in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return cpn_api_type_pkg.t_campaign_rec;

function is_campaign_started(
    i_campaign_id          in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

function is_campaign_finished(
    i_campaign_id          in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_boolean;

end;
/
