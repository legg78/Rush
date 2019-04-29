create or replace package pmo_ui_provider_group_pkg as
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
);

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
);

procedure remove(
    i_id                      in     com_api_type_pkg.t_short_id
  , i_seqnum                  in     com_api_type_pkg.t_seqnum
);

end pmo_ui_provider_group_pkg;
/
