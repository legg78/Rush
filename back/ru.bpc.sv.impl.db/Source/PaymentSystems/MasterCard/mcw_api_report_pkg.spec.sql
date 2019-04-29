create or replace package mcw_api_report_pkg is
/*********************************************************
 *  Issuer reports API <br />
 *  Created by Kolodkina J.(kolodkina@bpcbt.com)  at 20.03.2013 <br />
 *  Last changed by $Author: kolodkina $ <br />
 *  $LastChangedDate:: 2013-03-20 15:00:44 +0400#$ <br />
 *  Revision: $LastChangedRevision: 25841 $ <br />
 *  Module: mcw_api_report_pkg <br />
 *  @headcom
 **********************************************************/

   procedure mc_reconciliation_250b_batch (
        o_xml                          out clob
        , i_inst_id                    in com_api_type_pkg.t_inst_id
        , i_reconciliation_date        in date
        , i_lang                       in com_api_type_pkg.t_dict_value
    );

    procedure mc_unmatched_presentments (
        o_xml            out clob
      , i_inst_id     in     com_api_type_pkg.t_inst_id
      , i_date_start  in     date
      , i_date_end    in     date
      , i_lang        in     com_api_type_pkg.t_dict_value
    );

end;
/
