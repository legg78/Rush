CREATE OR REPLACE package jcb_api_dsp_init_pkg is
/************************************************************
 * API for dispute init <br />
 * Created by Maslov I.(maslov@bpcbt.com) at 01.06.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-20 16:36:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: mcw_api_dsp_init_pkg <br />
 * @headcom
 ************************************************************/

procedure init_first_pres_reversal;

procedure init_first_chargeback_part;

procedure init_first_chargeback_full;

procedure init_common_reversal;

procedure init_second_pres_full;

procedure init_second_pres_part;

procedure init_second_chbk_full;

procedure init_second_chbk_part;

procedure init_retrieval_request;

end;
/
