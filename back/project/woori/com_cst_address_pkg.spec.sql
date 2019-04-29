create or replace package com_cst_address_pkg as
/*********************************************************
 *  The package with user-exits for custom address elements <br />
 *
 *  Created by Madan B. (madan@bpcbt.com) at 27.01.2015 <br />
 *  Last changed by $Author: madan $ <br />
 *  $LastChangedDate: 2015-01-27 12:28:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: com_cst_address_pkg <br />
 *  @headcom
 **********************************************************/

/**********************************************************
 * Adding of additional custom address elements.
 * @param i_address_id  ID of the address
 * @param i_lang        User's interface language
 * @param i_inst_id     Institution ID
 * @param ia_params_tab Address elements collection
 **********************************************************/
procedure collect_address_params (
   i_address_id   in             com_api_type_pkg.t_medium_id
 , i_lang         in             com_api_type_pkg.t_dict_value
 , i_inst_id      in             com_api_type_pkg.t_inst_id
 , ia_params_tab  in out nocopy  com_api_type_pkg.t_param_tab
);

/**********************************************************
 * The editing of format of address string
 * @param i_tag_name name of tag in ber-tlv for CardGen
 * @param io_tag_value value of tag in ber-tlv for CardGen
 **********************************************************/
procedure get_address_string(
    i_country           in      com_api_type_pkg.t_country_code default null
  , i_region            in      com_api_type_pkg.t_name         default null
  , i_city              in      com_api_type_pkg.t_name         default null
  , i_street            in      com_api_type_pkg.t_name         default null
  , i_house             in      com_api_type_pkg.t_name         default null
  , i_apartment         in      com_api_type_pkg.t_name         default null
  , i_postal_code       in      com_api_type_pkg.t_name         default null
  , i_region_code       in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_tag_name          in      com_api_type_pkg.t_name
  , io_tag_value        in out  com_api_type_pkg.t_name
);

end com_cst_address_pkg;
/
