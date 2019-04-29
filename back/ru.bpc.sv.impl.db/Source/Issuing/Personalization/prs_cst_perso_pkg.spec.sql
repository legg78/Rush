create or replace package prs_cst_perso_pkg is
/*********************************************************
*  Custom API for personalization <br />
*  Created by Kopachev D.(kopachev@bpcbt.com) at 30.04.2014 <br />
*  Last changed by $Author: necheukhin $ <br />
*  $LastChangedDate:: 2014-04-01 16:31:23 +0400#$ <br />
*  Revision: $LastChangedRevision: 41277 $ <br />
*  Module: cst_api_perso_pkg <br />
*  @headcom
**********************************************************/
  
    function need_record_number (
        i_entity_type           in com_api_type_pkg.t_dict_value
    ) return boolean;
    
    procedure setup_templates (
        i_template_rec          in prs_api_type_pkg.t_template_rec
        , i_inst_id             in com_api_type_pkg.t_inst_id
        , i_perso_rec           in prs_api_type_pkg.t_perso_rec
        , i_embossing_request   in com_api_type_pkg.t_dict_value
        , i_pin_mailer_request  in com_api_type_pkg.t_dict_value
        , i_perso_method        in prs_api_type_pkg.t_perso_method_rec
        , io_perso_data         in out nocopy prs_api_type_pkg.t_perso_data_rec
    );

end;
/