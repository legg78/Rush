create or replace package acq_ui_product_pkg as
/*********************************************************
*  UI for acquring products <br />
*  Created by Khougaev A.(khougaev@bpcsv.com)  at 20.03.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: ACQ_UI_PRODUCT_PKG <br />
*  @headcom
**********************************************************/
procedure add_product(
    o_product_id           out  com_api_type_pkg.t_short_id
  , o_seqnum               out  com_api_type_pkg.t_seqnum
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_contract_type     in      com_api_type_pkg.t_dict_value
  , i_parent_id         in      com_api_type_pkg.t_short_id
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , i_status            in      com_api_type_pkg.t_dict_value := rul_api_const_pkg.PRODUCT_STATUS_ACTIVE
);

procedure modify_product(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_status            in      com_api_type_pkg.t_dict_value
);

procedure remove_product(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

end;
/
