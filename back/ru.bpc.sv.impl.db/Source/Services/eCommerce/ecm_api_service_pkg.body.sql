create or replace package body ecm_api_service_pkg is

    function get_active_service_id (
        i_card_id                 in com_api_type_pkg.t_medium_id
        , i_eff_date              in date
    ) return com_api_type_pkg.t_boolean is
        l_service_id              com_api_type_pkg.t_short_id;
    begin
        l_service_id := prd_api_service_pkg.get_active_service_id (
            i_entity_type        => iss_api_const_pkg.ENTITY_TYPE_CARD
            , i_object_id        => i_card_id
            , i_attr_name        => null
            , i_service_type_id  => ecm_api_const_pkg.DSEC_PROG_SERVICE_TYPE_ID
            , i_eff_date         => i_eff_date
        );
        if l_service_id is not null then
            return com_api_type_pkg.TRUE;
        end if;
        return com_api_type_pkg.FALSE;
    exception
        when others then
            if com_api_error_pkg.is_application_error(sqlcode) = com_api_type_pkg.TRUE 
                and com_api_error_pkg.get_last_error = 'PRD_NO_ACTIVE_SERVICE' then
                return com_api_type_pkg.FALSE;
            else
                return com_api_type_pkg.FALSE;
                --raise;
            end if;
    end;

    function get_active_service_id (
        i_card_number             in com_api_type_pkg.t_card_number
        , i_eff_date              in date
    ) return com_api_type_pkg.t_boolean is
        l_card_rec              iss_api_type_pkg.t_card_rec;
    begin
    
        l_card_rec := 
            iss_api_card_pkg.get_card (
                i_card_number       => i_card_number
              , i_mask_error        => com_api_const_pkg.FALSE
            );        

        return get_active_service_id (
            i_card_id         => l_card_rec.id
            , i_eff_date      => i_eff_date
        );

    exception
        when others then
            return com_api_type_pkg.FALSE;
    end;
end;
/
