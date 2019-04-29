create or replace package itf_cst_cardgen_pkg is
/*********************************************************
 *  Custom cardgen processing API <br />
 *  Created by Kondratyev A.(kondratyev@bpcbt.com)  at 18.02.2015 <br />
 *  Last changed by $Author: kondratyev $ <br />
 *  $LastChangedDate:: 2015-02-18 12:20:06 +0400#$ <br />
 *  Revision: $LastChangedRevision: 36849 $ <br />
 *  Module: itf_cst_cardgen_pkg <br />
 *  @headcom
 **********************************************************/

    procedure get_add_data(
        i_batch_card_rec in     prs_api_type_pkg.t_batch_card_rec
      , i_card_info_rec  in     prs_api_type_pkg.t_card_info_rec
      , o_add_line          out com_api_type_pkg.t_lob_data
    );

    procedure collect_file_params (
        i_batch_card_rec in     prs_api_type_pkg.t_batch_card_rec
      , i_card_info_rec  in     prs_api_type_pkg.t_card_info_rec
      , io_params        in out nocopy com_api_type_pkg.t_param_tab
    );

end;
/
