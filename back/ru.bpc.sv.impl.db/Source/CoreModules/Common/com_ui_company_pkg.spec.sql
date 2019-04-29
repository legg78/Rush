create or replace package com_ui_company_pkg as
/*********************************************************
*  Company <br />
*  Created by Kryukov E.(krukov@bpc.ru)  at 09.09.2010 <br />
*  Last changed by $Author$ <br />
*  $LastChangedDate::                           $ <br />
*  Revision: $LastChangedRevision$ <br />
*  Module: com_ui_company_pkg <br />
*  @headcom
**********************************************************/

/*
 * @param o_id
 * @param i_company_short_name
 * @param i_company_full_name
 * @param i_embossed_name
 * @param i_incorp_form
 */

procedure add_company(
    o_id                     out  com_api_type_pkg.t_short_id
  , o_seqnum                 out  com_api_type_pkg.t_short_id
  , i_company_short_name  in      com_api_type_pkg.t_multilang_value_tab
  , i_company_full_name   in      com_api_type_pkg.t_multilang_desc_tab
  , i_embossed_name       in      com_api_type_pkg.t_name
  , i_incorp_form         in      com_api_type_pkg.t_dict_value
);

/*
 * @param i_id
 * @param io_seqnum
 * @param i_company_short_name
 * @param i_company_full_name
 * @param i_company_embossed_name
 * @param i_incorp_form
 */

procedure modify_company(
    i_id                  in      com_api_type_pkg.t_short_id
  , io_seqnum             in out  com_api_type_pkg.t_seqnum
  , i_company_short_name  in      com_api_type_pkg.t_multilang_value_tab
  , i_company_full_name   in      com_api_type_pkg.t_multilang_desc_tab
  , i_embossed_name       in      com_api_type_pkg.t_name
  , i_incorp_form         in      com_api_type_pkg.t_dict_value
);

/*
 * @param i_id
 * @param i_seqnum
 */

procedure remove_company(
    i_id                in      com_api_type_pkg.t_short_id
  , i_seqnum            in      com_api_type_pkg.t_seqnum
);

function get_company_name(
    i_company_id        in      com_api_type_pkg.t_short_id
  , i_lang              in      com_api_type_pkg.t_dict_value       default null
) return com_api_type_pkg.t_name;

end com_ui_company_pkg;
/
