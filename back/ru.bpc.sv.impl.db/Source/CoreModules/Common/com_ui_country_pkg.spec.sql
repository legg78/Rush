CREATE OR REPLACE package com_ui_country_pkg as
/*********************************************************
 *  UI for Dictionary of Countries <br />
 *  Created by Mashonkin V.(mashonkin@bpcbt.com)  at 06.06.2014 <br />
 *  Last changed by $Author:  $ <br />
 *  $LastChangedDate:: 2014-06-06 12:40:30 +0400#$ <br />
 *  Revision: $LastChangedRevision:  $ <br />
 *  Module: com_ui_country_pkg  <br />
 *  @headcom
 **********************************************************/
procedure add_country (
    i_code                in      com_api_type_pkg.t_curr_code
  , i_name                in      com_api_type_pkg.t_curr_code
  , i_curr_code           in      com_api_type_pkg.t_curr_code
  , i_visa_country_code   in      com_api_type_pkg.t_curr_code
  , i_mastercard_region   in      com_api_type_pkg.t_curr_code
  , i_mastercard_eurozone in      com_api_type_pkg.t_curr_code
  , i_visa_region         in      com_api_type_pkg.t_tiny_id
  , i_description         in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value
  , o_country_id          out     com_api_type_pkg.t_medium_id
);

procedure modify_country (
  i_country_id            in out  com_api_type_pkg.t_medium_id
  , i_code                in      com_api_type_pkg.t_curr_code
  , i_name                in      com_api_type_pkg.t_curr_code
  , i_curr_code           in      com_api_type_pkg.t_curr_code
  , i_visa_country_code   in      com_api_type_pkg.t_curr_code
  , i_mastercard_region   in      com_api_type_pkg.t_curr_code
  , i_mastercard_eurozone in      com_api_type_pkg.t_curr_code
  , i_visa_region         in      com_api_type_pkg.t_tiny_id
  , i_description         in      com_api_type_pkg.t_name
  , i_lang                in      com_api_type_pkg.t_dict_value
);

procedure remove_country (
    i_country_id          in      com_api_type_pkg.t_medium_id
);

end com_ui_country_pkg;
/