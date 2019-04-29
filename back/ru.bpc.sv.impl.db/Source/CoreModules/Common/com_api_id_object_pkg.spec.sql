create or replace package com_api_id_object_pkg as
/************************************************************
 * Provides an interface for managing documents. <br />
 * Created by Kryukov E.(krukov@bpc.ru)  at 18.03.2011 <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: COM_API_ID_OBJECT_PKG <br />
 * @headcom
 *************************************************************/
procedure add_id_object(
    o_id                 out  com_api_type_pkg.t_medium_id
  , o_seqnum             out  com_api_type_pkg.t_seqnum
  , i_entity_type     in      com_api_type_pkg.t_dict_value
  , i_object_id       in      com_api_type_pkg.t_long_id
  , i_id_type         in      com_api_type_pkg.t_dict_value
  , i_id_series       in      com_api_type_pkg.t_name
  , i_id_number       in      com_api_type_pkg.t_name
  , i_id_issuer       in      com_api_type_pkg.t_full_desc
  , i_id_issue_date   in      date
  , i_id_expire_date  in      date
  , i_id_desc         in      com_api_type_pkg.t_full_desc
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_inst_id         in      com_api_type_pkg.t_inst_id
  , i_country         in      com_api_type_pkg.t_country_code       default null
);

procedure modify_id_object(
    i_id              in      com_api_type_pkg.t_medium_id
  , io_seqnum         in out  com_api_type_pkg.t_seqnum
  , i_id_type         in      com_api_type_pkg.t_dict_value
  , i_id_series       in      com_api_type_pkg.t_name
  , i_id_number       in      com_api_type_pkg.t_name
  , i_id_issuer       in      com_api_type_pkg.t_full_desc
  , i_id_issue_date   in      date
  , i_id_expire_date  in      date
  , i_id_desc         in      com_api_type_pkg.t_full_desc
  , i_lang            in      com_api_type_pkg.t_dict_value
  , i_country         in      com_api_type_pkg.t_country_code       default null
);

procedure remove_id_object(
    i_id                in      com_api_type_pkg.t_medium_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
