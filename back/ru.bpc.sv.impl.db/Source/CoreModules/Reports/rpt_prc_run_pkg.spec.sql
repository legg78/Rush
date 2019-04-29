create or replace package rpt_prc_run_pkg as
/*********************************************************
*  API for run reports from processes <br />
*  Created by Fomichev A.(fomichev@bpcbt.com)  at 05.04.2012 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: rpt_prc_run_pkg <br />
*  @headcom
**********************************************************/

procedure run_report;

function get_format_name(
    i_report_id             in     com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_inst_id;

procedure run_multiple_reports(
    i_event_type            in     com_api_type_pkg.t_dict_value
  , i_report_id             in     com_api_type_pkg.t_short_id
  , i_template_id           in     com_api_type_pkg.t_short_id     default null
  , i_lang                  in     com_api_type_pkg.t_dict_value   default null
  , i_ignore_empty_reports  in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_make_notification     in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
  , i_subscriber_name       in     com_api_type_pkg.t_name         default null
);

procedure multiple_run_and_notif(
    i_event_type            in     com_api_type_pkg.t_dict_value
  , i_report_id             in     com_api_type_pkg.t_short_id
  , i_template_id           in     com_api_type_pkg.t_short_id     default null
  , i_lang                  in     com_api_type_pkg.t_dict_value   default null
  , i_ignore_empty_reports  in     com_api_type_pkg.t_boolean      default com_api_type_pkg.FALSE
);

end rpt_prc_run_pkg;
/
