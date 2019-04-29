create or replace package dpp_prc_payment_plan_pkg as
/*********************************************************
*  API for DPP payment plan process <br />
*  Created by A.Fomichev(fomichev@bpcbt.com)  at 06.09.2018 <br />
*  Module: DPP_PRC_PAYMENT_PLAN_PKG <br />
*  @headcom
**********************************************************/

procedure process(
    i_inst_id                in     com_api_type_pkg.t_inst_id
);

end dpp_prc_payment_plan_pkg;
/
