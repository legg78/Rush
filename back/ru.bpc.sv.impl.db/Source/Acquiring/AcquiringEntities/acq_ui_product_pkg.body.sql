create or replace package body acq_ui_product_pkg as
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
  , i_status            in      com_api_type_pkg.t_dict_value
) is
begin
    prd_ui_product_pkg.add_product (
        o_id                => o_product_id
      , o_seqnum            => o_seqnum
      , i_product_type      => prd_api_const_pkg.PRODUCT_TYPE_ACQ
      , i_contract_type     => i_contract_type
      , i_parent_id         => i_parent_id
      , i_inst_id           => i_inst_id
      , i_lang              => i_lang
      , i_label             => i_label
      , i_description       => i_description
      , i_status            => i_status
    );
end;

procedure modify_product(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_label             in      com_api_type_pkg.t_name
  , i_description       in      com_api_type_pkg.t_full_desc        default null
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
  , io_seqnum           in out  com_api_type_pkg.t_seqnum
  , i_status            in      com_api_type_pkg.t_dict_value
) is
begin
    prd_ui_product_pkg.modify_product (
        i_id                => i_product_id
      , io_seqnum           => io_seqnum
      , i_lang              => i_lang
      , i_label             => i_label
      , i_description       => i_description
      , i_status            => i_status
    );
end;

procedure remove_product(
    i_product_id        in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
) is
begin
    null;
end;

end;
/
