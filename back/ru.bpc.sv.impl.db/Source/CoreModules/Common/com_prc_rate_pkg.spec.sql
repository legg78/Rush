create or replace package com_prc_rate_pkg as
/*********************************************************
 *  Process for load currency rates <br />
 *  Created by Kopachev D.(kopachev@bpcbt.com)  at 03.06.2013 <br />
 *  Last changed by $Author: kopachev $ <br />
 *  $LastChangedDate:: 2011-11-15 11:43:12 +0300#$ <br />
 *  Revision: $LastChangedRevision: 13781 $ <br />
 *  Module: com_prc_rate_pkg   <br />
 *  @headcom
 **********************************************************/
 
    procedure load_rates(
        i_dict_version      in      com_api_type_pkg.t_name           default com_api_const_pkg.VERSION_DEFAULT
      , i_unload_file       in      com_api_type_pkg.t_boolean        default null
    );

   procedure unload_rates(
        i_dict_version              in     com_api_type_pkg.t_name           default com_api_const_pkg.VERSION_DEFAULT
      , i_inst_id                   in     com_api_type_pkg.t_inst_id        default null
      , i_eff_date                  in     date                              default null
      , i_full_export               in     com_api_type_pkg.t_boolean        default null
      , i_base_rate_export          in     com_api_type_pkg.t_boolean        default null
      , i_rate_type                 in     com_api_type_pkg.t_dict_value     default null
      , i_replace_inst_id_by_number in     com_api_type_pkg.t_boolean        default com_api_const_pkg.FALSE
    );

end;
/
