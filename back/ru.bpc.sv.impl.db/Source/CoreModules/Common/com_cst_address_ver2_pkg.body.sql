create or replace package body com_cst_address_ver2_pkg as
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
)
is
begin
    com_cst_address_pkg.collect_address_params (
        i_address_id   => i_address_id
      , i_lang         => i_lang
      , i_inst_id      => i_inst_id
      , ia_params_tab  => ia_params_tab
    );

end collect_address_params;

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
  , i_postal_code       in      varchar2                        default null
  , i_region_code       in      com_api_type_pkg.t_dict_value   default null
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_tag_name          in      com_api_type_pkg.t_name
  , io_tag_value        in out  com_api_type_pkg.t_name
  , i_card_id           in      com_api_type_pkg.t_medium_id    default null
  , i_card_instance_id  in      com_api_type_pkg.t_medium_id    default null
)
is
begin
    com_cst_address_pkg.get_address_string(
        i_country           => i_country
      , i_region            => i_region
      , i_city              => i_city
      , i_street            => i_street
      , i_house             => i_house
      , i_apartment         => i_apartment
      , i_postal_code       => i_postal_code
      , i_region_code       => i_region_code
      , i_inst_id           => i_inst_id
      , i_tag_name          => i_tag_name
      , io_tag_value        => io_tag_value
    );

end get_address_string;

end com_cst_address_ver2_pkg;
/
