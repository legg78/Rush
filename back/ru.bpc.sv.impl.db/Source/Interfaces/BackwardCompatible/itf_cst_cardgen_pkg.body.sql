create or replace package body itf_cst_cardgen_pkg is
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
    ) is
    begin
        o_add_line := '';
    end;

    procedure collect_file_params (
        i_batch_card_rec in     prs_api_type_pkg.t_batch_card_rec
      , i_card_info_rec  in     prs_api_type_pkg.t_card_info_rec
      , io_params        in out nocopy com_api_type_pkg.t_param_tab
    ) is
    begin
        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_PERSO_PRIORITY
          , i_value      => i_batch_card_rec.perso_priority
          , io_params    => io_params
        );

        rul_api_param_pkg.set_param (
            i_name       => prs_api_const_pkg.PARAM_CARD_TYPE_NAME
          , i_value      => get_text('net_card_type',   'name', i_batch_card_rec.card_type_id, i_batch_card_rec.lang)
          , io_params    => io_params
        );
    end collect_file_params;

end;
/
