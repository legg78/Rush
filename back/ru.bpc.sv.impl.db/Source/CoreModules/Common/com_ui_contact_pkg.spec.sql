create or replace package com_ui_contact_pkg as
/************************************************************
 * UI for Contacts <br />
 * Created by Khougev A.(khougaev@bpc.ru)  at 19.03.2010  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_UI_CONTACT_PKG <br />
 * @headcom
 ************************************************************/
procedure add_contact (
    o_contact_id            out com_api_type_pkg.t_medium_id
  , i_job_title          in     com_api_type_pkg.t_dict_value
  , i_person_id          in     com_api_type_pkg.t_name
  , i_pref_lang          in     com_api_type_pkg.t_dict_value
  , o_seqnum                out com_api_type_pkg.t_seqnum
);

procedure modify_contact (
    i_contact_id         in     com_api_type_pkg.t_medium_id
  , i_job_title          in     com_api_type_pkg.t_dict_value
  , i_person_id          in     com_api_type_pkg.t_name
  , i_pref_lang          in     com_api_type_pkg.t_dict_value
  , io_seqnum            in out com_api_type_pkg.t_seqnum
);

procedure remove_contact (
    i_contact_id         in     com_api_type_pkg.t_medium_id
  , i_seqnum             in     com_api_type_pkg.t_seqnum
);

procedure add_contact_object (
    i_contact_id         in     com_api_type_pkg.t_medium_id
  , i_entity_type        in     com_api_type_pkg.t_dict_value
  , i_contact_type       in     com_api_type_pkg.t_dict_value
  , i_object_id          in     com_api_type_pkg.t_long_id
  , o_contact_object_id     out com_api_type_pkg.t_long_id
);

procedure remove_contact_object (
    i_contact_object_id  in     com_api_type_pkg.t_long_id
);

procedure add_contact_data (
    o_id                    out com_api_type_pkg.t_medium_id
    , i_contact_id       in     com_api_type_pkg.t_medium_id
    , i_commun_method    in     com_api_type_pkg.t_dict_value
    , i_commun_address   in     com_api_type_pkg.t_full_desc
    , i_start_date       in     date
    , i_end_date         in     date
);

procedure modify_contact_data (
    i_id                 in     com_api_type_pkg.t_medium_id
    , i_contact_id       in     com_api_type_pkg.t_medium_id
    , i_commun_method    in     com_api_type_pkg.t_dict_value
    , i_commun_address   in     com_api_type_pkg.t_full_desc
    , i_start_date       in     date
    , i_end_date         in     date
);

procedure remove_contact_data (
    i_id                 in     com_api_type_pkg.t_medium_id
);

procedure get_contacts (
    i_entity_type        in     com_api_type_pkg.t_dict_value
  , i_object_id          in     com_api_type_pkg.t_long_id
  , o_contacts              out sys_refcursor
);

end;
/
