CREATE OR REPLACE package jcb_api_dsp_generate_pkg is
/************************************************************
 * API for dispute generate <br />
 * Created by Maslov I.(maslov@bpcbt.com) at 01.06.2013 <br />
 * Last changed by $Author: truschelev $ <br />
 * $LastChangedDate:: 2015-10-20 16:53:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: mcw_api_dsp_generate_pkg <br />
 * @headcom
 ************************************************************/

procedure gen_first_chargeback_part;

procedure gen_first_chargeback_full;

procedure gen_second_pres_full;

procedure gen_second_pres_part;

procedure gen_second_chbk_full;

procedure gen_second_chbk_part;

procedure gen_first_pres_reversal;

procedure gen_retrieval_request;

end;
/
