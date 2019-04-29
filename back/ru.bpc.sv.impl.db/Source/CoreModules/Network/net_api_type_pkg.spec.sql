create or replace package net_api_type_pkg is
/*********************************************************
 *  API with types for NET module <br />
 *  Created by Alalykin A.(alalykin@bpcbt.com) at 13.05.2015 <br />
 *  Last changed by $Author: alalykin $ <br />
 *  $LastChangedDate:: 2015-05-13 18:00:00 +0300#$ <br />
 *  Revision: $LastChangedRevision: 1 $ <br />
 *  Module: net_api_type_pkg  <br />
 *  @headcom
 **********************************************************/

type t_net_bin_range_rec is record (
    pan_low          com_api_type_pkg.t_card_number
  , pan_high         com_api_type_pkg.t_card_number
  , pan_length       com_api_type_pkg.t_tiny_id
  , priority         com_api_type_pkg.t_tiny_id
  , card_type_id     com_api_type_pkg.t_tiny_id
  , country          com_api_type_pkg.t_country_code
  , iss_network_id   com_api_type_pkg.t_network_id
  , iss_inst_id      com_api_type_pkg.t_inst_id
  , card_network_id  com_api_type_pkg.t_network_id
  , card_inst_id     com_api_type_pkg.t_inst_id
  , module_code      com_api_type_pkg.t_module_code
  , activation_date  date
  , account_currency com_api_type_pkg.t_curr_code
);

type t_net_bin_range_tab is table of t_net_bin_range_rec index by binary_integer;

end;
/
