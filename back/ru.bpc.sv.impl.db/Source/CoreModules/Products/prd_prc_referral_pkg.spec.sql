create or replace package prd_prc_referral_pkg as
/*********************************************************
 *  Acquiring/issuing application API  <br />
 *  Created by Sergey Ivanov (sr.ivanov@bpcbt.com)  at 28.09.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: prd_prc_referral_pkg <br />
 *  @headcom
 **********************************************************/

procedure calculate_rewards(
    i_inst_id              in     com_api_type_pkg.t_inst_id
);

end;
/
