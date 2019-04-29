create or replace package ntf_ui_template_pkg is
/********************************************************* 
 *  Interface for notification templates  <br /> 
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 28.07.2010 <br /> 
 *  Last changed by $Author$ <br /> 
 *  $LastChangedDate::                           $ <br /> 
 *  Revision: $LastChangedRevision$ <br /> 
 *  Module: ntf_ui_template_pkg <br /> 
 *  @headcom 
 **********************************************************/
procedure add_template (
    o_id                        out com_api_type_pkg.t_short_id
    , o_seqnum                  out com_api_type_pkg.t_seqnum
    , i_notif_id                in com_api_type_pkg.t_tiny_id
    , i_channel_id              in com_api_type_pkg.t_tiny_id
    , i_lang                    in com_api_type_pkg.t_dict_value
    , i_report_template_id      in com_api_type_pkg.t_short_id
);

procedure modify_template (
    i_id                        in com_api_type_pkg.t_short_id
    , io_seqnum                 in out com_api_type_pkg.t_seqnum
    , i_report_template_id      in com_api_type_pkg.t_short_id
);

procedure remove_template (
    i_id                        in com_api_type_pkg.t_short_id
    , i_seqnum                  in com_api_type_pkg.t_seqnum
);

end; 
/
