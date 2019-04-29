create or replace package dsp_ui_application_pkg as
/************************************************************
 * User interface for dispute applications <br />
 * Created by Kondratyev A.(kondratyev@bpcbt.com)  at 24.11.2016  <br />
 * Last changed by $Author$  <br />
 * $LastChangedDate::                           $ <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: dsp_api_application_pkg <br />
 * @headcom
 ************************************************************/

procedure process(
    i_appl_id      in      com_api_type_pkg.t_long_id
);

function get_dispute_inst_id(
    i_oper_id      in      com_api_type_pkg.t_long_id
) return com_api_type_pkg.t_inst_id;

end dsp_ui_application_pkg;
/
