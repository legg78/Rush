create or replace package prd_ui_service_type_pkg is
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
);

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
);

procedure remove_service_type (
    i_id                    in com_api_type_pkg.t_short_id
    , i_seqnum              in com_api_type_pkg.t_seqnum
);

end;
/
