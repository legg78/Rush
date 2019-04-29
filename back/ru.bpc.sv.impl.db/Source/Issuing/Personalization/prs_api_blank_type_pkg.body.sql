create or replace package body prs_api_blank_type_pkg is
/************************************************************
 * API for blank type <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 10.12.2010 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_blank_type_pkg <br />
 * @headcom
 ************************************************************/

    procedure mark_blank_type (
        i_blank_type_tab         in com_api_type_pkg.t_number_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text         => 'Mark blank type'
        );

        forall i in indices of i_blank_type_tab
            update
                prs_blank_type_vw
            set
                is_active = 1
            where
                id = i_blank_type_tab(i)
                and is_active = 0;

        trc_log_pkg.debug (
            i_text         => 'Mark blank type - ok'
        );
    end;
    
    function get_blank_type_name (
        i_id                     in com_api_type_pkg.t_tiny_id
        , i_lang                 in com_api_type_pkg.t_dict_value
    ) return com_api_type_pkg.t_name is
    begin
        return get_text('prs_blank_type', 'name', i_id, nvl(i_lang, get_def_lang));
    end;

end;
/
