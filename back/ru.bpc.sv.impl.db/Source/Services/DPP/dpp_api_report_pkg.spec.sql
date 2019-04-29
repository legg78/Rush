create or replace package dpp_api_report_pkg is
/************************************************************
* Reports for DPP module <br />
* Created by Gogolev I.(i.gogolev@bpcbt.com) at 14.12.2017  <br />
* Last changed by $Author: gogolev_i $  <br />
* $LastChangedDate:: 2017-12-14 12:44:00 +0400#$ <br />
* Revision: $LastChangedRevision: $ <br />
* Module: DPP_API_REPORT_PKG <br />
* @headcom
************************************************************/
procedure get_payment_plan_data_event(
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
);

procedure get_instalment_data_event(
    o_xml                  out clob
  , i_event_type        in     com_api_type_pkg.t_dict_value
  , i_eff_date          in     date
  , i_entity_type       in     com_api_type_pkg.t_dict_value
  , i_object_id         in     com_api_type_pkg.t_long_id
  , i_inst_id           in     com_api_type_pkg.t_inst_id
  , i_lang              in     com_api_type_pkg.t_dict_value
);

end dpp_api_report_pkg;
/
