create or replace package dsp_ui_dispute_search_pkg is
/************************************************************
 * User interface for displaying disputes in Issuing and Acquiring <br />
 * Created by Truschelev O.(truschelev@bpcbt.com) at 08.09.2016 <br />
 * Last changed by $Author: Truschelev $ <br />
 * $LastChangedDate:: 2016-09-08 18:55:00 +0400#$ <br />
 * Revision: $LastChangedRevision: 1 $ <br />
 * Module: dsp_ui_dispute_search_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Split clob by delimer
 * @param i_clob          - Contents
 * @param i_delim         - Delimer
 */
function get_dispute_info(
    i_oper_id               in      com_api_type_pkg.t_long_id
  , i_match_id              in      com_api_type_pkg.t_long_id
  , i_lang                  in      com_api_type_pkg.t_dict_value
) return dsp_ui_dispute_info_tpt pipelined;

end;
/
