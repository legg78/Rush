create or replace package iss_ui_bin_pkg is
/**********************************************************
*  UI for bin table <br />
*  Created by Kopachev D.(kopachev@bpc.ru)  at 09.08.2010 <br />
*  Last changed by $Author: krukov $ <br />
*  $LastChangedDate:: 2011-03-01 14:46:54 +0300#$ <br />
*  Revision: $LastChangedRevision: 8281 $ <br />
*  Module: iss_ui_bin_pkg <br />
*  @headcom
***********************************************************/
procedure add_iss_bin(
    o_id                  out com_api_type_pkg.t_short_id
  , o_seqnum              out com_api_type_pkg.t_seqnum
  , i_bin              in     com_api_type_pkg.t_card_number
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_network_id       in     com_api_type_pkg.t_tiny_id
  , i_bin_currency     in     com_api_type_pkg.t_curr_code
  , i_sttl_currency    in     com_api_type_pkg.t_curr_code
  , i_pan_length       in     com_api_type_pkg.t_tiny_id
  , i_card_type_id     in     com_api_type_pkg.t_tiny_id
  , i_country          in     com_api_type_pkg.t_country_code
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_description      in     com_api_type_pkg.t_full_desc
);

procedure modify_iss_bin(
    i_id               in     com_api_type_pkg.t_tiny_id
  , io_seqnum          in out com_api_type_pkg.t_seqnum
  , i_bin              in     com_api_type_pkg.t_card_number
  , i_inst_id          in     com_api_type_pkg.t_inst_id
  , i_network_id       in     com_api_type_pkg.t_tiny_id
  , i_bin_currency     in     com_api_type_pkg.t_curr_code
  , i_sttl_currency    in     com_api_type_pkg.t_curr_code
  , i_pan_length       in     com_api_type_pkg.t_tiny_id
  , i_card_type_id     in     com_api_type_pkg.t_tiny_id
  , i_country          in     com_api_type_pkg.t_country_code
  , i_lang             in     com_api_type_pkg.t_dict_value
  , i_description      in     com_api_type_pkg.t_full_desc
);

procedure remove_iss_bin(
    i_id               in     com_api_type_pkg.t_tiny_id
  , i_seqnum           in     com_api_type_pkg.t_seqnum
);

function get_iss_bin(
    i_id               in     com_api_type_pkg.t_tiny_id
) return com_api_type_pkg.t_bin;

end; 
/
