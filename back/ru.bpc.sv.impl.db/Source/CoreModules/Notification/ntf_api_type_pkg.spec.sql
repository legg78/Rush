create or replace package ntf_api_type_pkg is
/************************************************************
 * Notification types <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 24.09.2013 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2013-09-24 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: ntf_api_type_pkg <br />
 * @headcom
 ************************************************************/

    type t_notif_object_tab is table of com_api_type_pkg.t_long_id index by com_api_type_pkg.t_dict_value;

    type t_notif_addr_rec is record(
        notif_id            com_api_type_pkg.t_long_id
      , delivery_address    com_api_type_pkg.t_full_desc
    );

    type t_notif_addr_rec_tab is table of t_notif_addr_rec index by binary_integer;

    type t_custom_event_rec is record (
        custom_event_id     com_api_type_pkg.t_medium_id
      , is_active           com_api_type_pkg.t_boolean
    );
    type t_custom_event_tab is table of t_custom_event_rec index by binary_integer;

end;
/
