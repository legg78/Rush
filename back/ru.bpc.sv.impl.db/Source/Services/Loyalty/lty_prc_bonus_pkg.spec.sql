create or replace package lty_prc_bonus_pkg as
/*********************************************************
 *  Process for loyalty bonus <br /> 
 *  Created by Kopachev D.(kopachev@bpc.ru)  at 18.11.2009 <br />
 *  Last changed by $Author: kopachev $ <br />
 *  $LastChangedDate:: 2010-06-30 15:04:48 +0400#$ <br />
 *  Revision: $LastChangedRevision:  $ <br />
 *  Module: lty_prc_bonus_pkg <br />
 *  @headcom
 **********************************************************/ 

procedure export_bonus_file (
    i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_service_id  in     com_api_type_pkg.t_short_id
  , i_full_export in     com_api_type_pkg.t_boolean     default com_api_const_pkg.FALSE
  , i_start_date  in     date                           default null
  , i_end_date    in     date                           default null
);


procedure outdated_bonus (
    i_inst_id     in     com_api_type_pkg.t_inst_id
  , i_service_id  in     com_api_type_pkg.t_tiny_id
  , i_eff_date    in     date
);

end;
/
