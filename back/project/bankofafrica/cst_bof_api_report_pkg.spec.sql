create or replace package cst_bof_api_report_pkg is
/*********************************************************
 *  Custom reports API for BOA <br />
 *  Created by Gogolev I.(i.gogolev@bpcbt.com) at 25.04.2018 <br />
 *  Last changed by $Author$ <br />
 *  $LastChangedDate::                           $ <br />
 *  Revision: $LastChangedRevision$ <br />
 *  Module: cst_bof_api_report_pkg <br />
 *  @headcom
 **********************************************************/
function get_header (
    i_inst_id       in  com_api_type_pkg.t_inst_id
  , i_start_date    in  date
  , i_end_date      in  date
  , i_lang          in  com_api_type_pkg.t_dict_value
) return xmltype;

procedure reissued_cards(
    o_xml          out    clob
  , i_inst_id       in    com_api_type_pkg.t_inst_id        default null
  , i_start_date    in    date
  , i_end_date      in    date
  , i_lang          in    com_api_type_pkg.t_dict_value     default null
);

end cst_bof_api_report_pkg;
/
