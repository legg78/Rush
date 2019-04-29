create or replace package prd_api_report_pkg is
/*********************************************************
 *  Product reports API <br />
 *  Created by Madan B.(madan@bpcbt.com) at 02.04.2014 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate$ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_api_report_pkg <br />
 *  @headcom
 **********************************************************/

/**************************************************
 *
 * It prepares data for a landscape report for the structure
 * of products and all their inclusives: services and attributes.
 *
 * @param o_xml        Data - source for report
 * @param i_inst_id    Filter for institute
 * @param i_product_id Start with this product
 * @param i_status     Filter for product status
 * @param i_lang       Language
 *
 ***************************************************/
procedure product_structure (
    o_xml            out clob
    , i_inst_id      in com_api_type_pkg.t_inst_id
    , i_product_id   in com_api_type_pkg.t_short_id    default null
    , i_status       in com_api_type_pkg.t_dict_value  default null
    , i_lang         in com_api_type_pkg.t_dict_value  default null
);

end;
/