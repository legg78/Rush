create or replace package vis_prc_ammf_pkg as
/*********************************************************
 *  Visa AMMF service API  <br />
 *  Created by Gerbeev I.(gerbeev@bpcbt.com)  at 21.01.2019 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: vis_prc_ammf_pkg <br />
 *  @headcom
 **********************************************************/

procedure process(
    i_inst_id                   in      com_api_type_pkg.t_inst_id
  , i_full_export               in      com_api_type_pkg.t_boolean       default com_api_const_pkg.FALSE
);

end;
/
