create or replace package emv_api_script_type_pkg is
/************************************************************
 * API for EMV script type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 06.07.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: emv_api_script_type_pkg <br />
 * @headcom
 ************************************************************/

/*
 * Get script type record
 * @param  i_type       - Script type dictionary
 */
    function get_script_type (
        i_type                  in com_api_type_pkg.t_dict_value
    ) return emv_api_type_pkg.t_emv_script_type_rec;

end;
/
