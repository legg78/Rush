create or replace package iss_prc_card_instance_pkg is
/**********************************************************
 * Processes for card instance processing
 * 
 * Created by Gogolev I.(i.gogolev@bpcbt.com) at 01.02.2017<br />
 * <br />
 * Last changed by $Author$ <br />
 * $LastChangedDate::                           $ <br />
 * <br />
 * Revision: $LastChangedRevision$ <br />
 * Module: ISS_PRC_CARD_INSTANCE_PKG
 * @headcom
 **********************************************************/

procedure process_expire_date(
    i_inst_id      in com_api_type_pkg.t_inst_id
);
    
end iss_prc_card_instance_pkg;
/
