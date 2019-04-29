create or replace package pos_api_report_pkg is
/*********************************************************
 *  POS reports API <br />
 *  Created by Nick (shalnov@bpcbt.com) at 11.09.2018 <br />
 *  Last changed by $Author: Nick $ <br />
 *  $LastChangedDate:: 2018-09-11 09:46:00 +0400#$ <br />
 *  Revision: $LastChangedRevision: 25841 $ <br />
 *  Module: pos_api_report_pkg <br />
 *  @headcom
 **********************************************************/

procedure pos_batch_unmatched(
    o_xml                  out clob
  , i_inst_id           in     com_api_type_pkg.t_inst_id        default null
  , i_start_date        in     date                              default null
  , i_end_date          in     date                              default null
  , i_mode              in     com_api_type_pkg.t_dict_value
  , i_lang              in     com_api_type_pkg.t_dict_value     default null
);

end pos_api_report_pkg;
/
