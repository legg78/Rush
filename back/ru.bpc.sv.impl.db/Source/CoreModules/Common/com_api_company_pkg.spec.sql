create or replace package com_api_company_pkg as
/*********************************************************
*  API for entity Company <br />
*  Created by Kryukov E.(krukov@bpcbt.com)  at 09.09.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: com_api_company_pkg <br />
*  @headcom
**********************************************************/ 

procedure add_company(
    o_id                     out  com_api_type_pkg.t_short_id
  , o_seqnum                 out  com_api_type_pkg.t_tiny_id
  , i_company_short_name  in      com_api_type_pkg.t_multilang_value_tab
  , i_company_full_name   in      com_api_type_pkg.t_multilang_desc_tab
  , i_embossed_name       in      com_api_type_pkg.t_name
  , i_incorp_form         in      com_api_type_pkg.t_dict_value
  , i_inst_id             in      com_api_type_pkg.t_inst_id
);

procedure modify_company(
    i_id                  in      com_api_type_pkg.t_short_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_company_short_name  in      com_api_type_pkg.t_multilang_value_tab
  , i_company_full_name   in      com_api_type_pkg.t_multilang_desc_tab
  , i_embossed_name       in      com_api_type_pkg.t_name
  , i_incorp_form         in      com_api_type_pkg.t_dict_value
);

procedure remove_company(
    i_id                  in      com_api_type_pkg.t_short_id
  , i_seqnum              in      com_api_type_pkg.t_seqnum
);

function get_company_incorp_form(
    i_id                  in      com_api_type_pkg.t_short_id
) return com_api_type_pkg.t_dict_value;

end com_api_company_pkg;
/
