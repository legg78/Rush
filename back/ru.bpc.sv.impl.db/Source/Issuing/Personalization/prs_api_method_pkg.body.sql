create or replace package body prs_api_method_pkg is
/************************************************************
 * API for personalization method <br />
 * Created by Kopachev D.(kopachev@bpcbt.com) at 05.08.2011 <br />
 * Last changed by $Author: kopachev $ <br />
 * $LastChangedDate:: 2011-10-28 17:01:09 +0400#$ <br />
 * Revision: $LastChangedRevision: 13428 $ <br />
 * Module: prs_api_method_pkg <br />
 * @headcom
 ************************************************************/

    function get_perso_method (
        i_inst_id                   in com_api_type_pkg.t_inst_id
        , i_perso_method_id         in com_api_type_pkg.t_tiny_id
    ) return prs_api_type_pkg.t_perso_method_rec is
    
        l_result                    prs_api_type_pkg.t_perso_method_rec;
    
    begin
        select
            m.id
            , m.inst_id
            , m.pvv_store_method
            , m.pin_store_method
            , m.pin_verify_method
            , m.cvv_required
            , m.icvv_required
            , m.pvk_index
            , m.key_schema_id
            , m.service_code
            , m.dda_required
            , m.imk_index
            , m.private_key_component
            , m.private_key_format
            , m.module_length
            , m.max_script
            , m.decimalisation_table
            , (select
                   count(id)
               from
                   prs_key_schema_entity_vw e
               where
                   e.key_type = sec_api_const_pkg.SECURITY_DES_KEY_IMK_CVC3
                   and e.key_schema_id = m.key_schema_id
            ) is_contactless
            , exp_date_format
            , nvl(pin_length, prs_api_const_pkg.PIN_LENGTH) pin_length
            , m.cvv2_required
        into
            l_result
        from
            prs_method_vw m
        where
            m.id = i_perso_method_id
            and m.inst_id = i_inst_id;
            
        return l_result;
    exception
        when no_data_found then
            com_api_error_pkg.raise_error (
                i_error             => 'ILLEGAL_PERSO_METHOD'
                , i_env_param1      => i_perso_method_id
                , i_env_param2      => i_inst_id
            );
    end;
    
    procedure mark_perso_method (
        i_method_tab              in com_api_type_pkg.t_number_tab
    ) is
    begin
        trc_log_pkg.debug (
            i_text         => 'Mark perso method'
        );

        forall i in indices of i_method_tab
            update
                prs_method_vw
            set
                is_active = 1
            where
                id = i_method_tab(i)
                and is_active = 0;

        trc_log_pkg.debug (
            i_text         => 'Mark perso method - ok'
        );
    end;

end;
/
