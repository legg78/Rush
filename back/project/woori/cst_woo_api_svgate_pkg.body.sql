create or replace package body cst_woo_api_svgate_pkg as

procedure block_customer_cards (
    i_inst_id           in      com_api_type_pkg.t_inst_id
  , i_cus_number        in      com_api_type_pkg.t_name
  , i_status            in      com_api_type_pkg.t_dict_value
  , o_res_code          out     com_api_type_pkg.t_dict_value
  , o_res_mess          out     com_api_type_pkg.t_text
  , o_int_mess          out     com_api_type_pkg.t_text
) is
    l_params            com_api_type_pkg.t_param_tab;
    l_event_type        com_api_type_pkg.t_dict_value;
    l_count_all         pls_integer := 0;
    l_count_run         pls_integer := 0;
begin
    if trim(i_inst_id) is null then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Institution ID is empty!';
        o_int_mess := 'Parameter i_inst_id is null';
        com_api_error_pkg.raise_error(
            i_error      => 'PARAM_VALUE_IS_NULL'
        );
    end if;

    if trim(i_cus_number) is null then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Customer number is empty!';
        o_int_mess := 'Parameter i_cus_number is null';
        com_api_error_pkg.raise_error(
            i_error      => 'PARAM_VALUE_IS_NULL'
        );
    end if;

    if trim(i_status) is null then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Input status is empty!';
        o_int_mess := 'Parameter i_status is null';
        com_api_error_pkg.raise_error(
            i_error      => 'PARAM_VALUE_IS_NULL'
        );
    end if;

    case i_status
        when C_STATUS_TEMP_BLOCK then l_event_type := cst_woo_const_pkg.EVENT_TYPE_CARD_TEMP_BLOCK;
        when C_STATUS_UNBLOCK    then l_event_type := cst_woo_const_pkg.EVENT_TYPE_CARD_ACTIVATION;
        when C_STATUS_PERM_BLOCK then l_event_type := cst_woo_const_pkg.EVENT_TYPE_CARD_PERM_BLOCK;
        else                          l_event_type := null;
    end case;

    if l_event_type is null then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Status received from CBS is not valid!';
        o_int_mess := 'Invalid status received from CBS, i_status=' || i_status;
        com_api_error_pkg.raise_error(
            i_error      => 'WRONG_ATTRIBUTE_VALUE'
        );
    end if;

    o_int_mess := 'l_event_type=' || l_event_type || ', ';

    for p in (
        select ici.id as card_instance_id, ici.state, ici.status
          from iss_card ica, iss_card_instance ici, prd_customer pct
         where 1                    = 1
           and ica.id               = ici.card_id
           and ica.customer_id      = pct.id
           and pct.customer_number  = i_cus_number
           and pct.inst_id          = i_inst_id
     )
    loop
        l_count_all := l_count_all + 1;

        -- Temporary block card, only block the card if:
        --  + State = CARD_STATE_ACTIVE ('CSTE0200')
        --  + Status = CARD_STATUS_VALID_CARD ('CSTS0000')
        -- Results after change: state = 'CSTE0200' and status = 'CSTS0023' (Temporary block)
        if      i_status        = C_STATUS_TEMP_BLOCK
            and p.state         = iss_api_const_pkg.CARD_STATE_ACTIVE
            and p.status        = iss_api_const_pkg.CARD_STATUS_VALID_CARD
        then
            evt_api_status_pkg.change_status (
                i_event_type    => l_event_type
              , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id     => p.card_instance_id
              , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
              , i_params        => l_params
            );
            l_count_run := l_count_run + 1;
             o_int_mess := o_int_mess || 'card_instance_id=' || p.card_instance_id || ', ';
        end if;

        -- Unlock Temporary block status, only unblock the card if:
        --  + State = CARD_STATE_ACTIVE ('CSTE0200')
        --  + Status = CARD_STATUS_TEMP_BLOCK_BANK ('CSTS0023')
        -- Results after change: state = 'CSTE0200' and status = 'CSTS0000' (Valid)
        if      i_status        = C_STATUS_UNBLOCK
            and p.state         = iss_api_const_pkg.CARD_STATE_ACTIVE
            and p.status        = iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_BANK
        then
            evt_api_status_pkg.change_status (
                i_event_type    => l_event_type
              , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id     => p.card_instance_id
              , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
              , i_params        => l_params
            );
            l_count_run := l_count_run + 1;
             o_int_mess := o_int_mess || 'card_instance_id=' || p.card_instance_id || ', ';
        end if;

        -- Permanent block card, only block the card if:
        --  + State = CARD_STATE_ACTIVE ('CSTE0200')
        --  + Status = CARD_STATUS_VALID_CARD ('CSTS0000')
        -- Results after change: state = 'CSTE0300' (closed) and status = 'CSTS0025' (Permanent block)
        if      i_status        = C_STATUS_PERM_BLOCK
            and p.state         = iss_api_const_pkg.CARD_STATE_ACTIVE
            and p.status        = iss_api_const_pkg.CARD_STATUS_VALID_CARD
        then
            evt_api_status_pkg.change_status (
                i_event_type    => l_event_type
              , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
              , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
              , i_object_id     => p.card_instance_id
              , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
              , i_params        => l_params
            );
            l_count_run := l_count_run + 1;
             o_int_mess := o_int_mess || 'card_instance_id=' || p.card_instance_id || ', ';
        end if;

    end loop;

    case
        when l_count_all = 0 then
            o_res_code := C_RES_CODE_ERROR;
            o_res_mess := 'Customer ' || i_cus_number || ' is not found!';
            o_int_mess := 'Customer is not found! Input parameters:'||
                          ' i_cus_number=' || i_cus_number ||
                          ', i_inst_id=' || i_inst_id ||
                          ', i_status=' || i_status;
        when l_count_all > 0 and l_count_run = 0 then
            o_res_code := C_RES_CODE_ERROR;
            o_res_mess := 'Customer ' || i_cus_number || ' has no valid card to process.';
            o_int_mess := 'No valid data to process. Input parameters:'||
                          ' i_cus_number='|| i_cus_number ||
                          ', i_inst_id=' || i_inst_id ||
                          ', i_status=' || i_status;
        when l_count_run > 0 then
            o_res_code := C_RES_CODE_OK ;
            o_res_mess := 'Processed';
            o_int_mess := o_int_mess || 'Total cards counted: ' || l_count_all ||
                          ', Total cards processed: ' || l_count_run;
    end case;

exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            null;
        else
            o_res_code := C_RES_CODE_ERROR;
            o_res_mess := 'Unexpected error! Check webservice logs for more details';
            o_int_mess := 'Input parameters:'||
                          ' i_cus_number=' || i_cus_number ||
                          ', i_inst_id=' || i_inst_id ||
                          ', i_status=' || i_status ||
                          ', Unexpected error: ' || sqlerrm;
        end if;
end block_customer_cards;

procedure block_card(
    i_card_number       in      com_api_type_pkg.t_card_number
  , i_status            in      com_api_type_pkg.t_dict_value
  , i_inst_id           in      com_api_type_pkg.t_inst_id
  , o_res_code          out     com_api_type_pkg.t_dict_value
  , o_res_mess          out     com_api_type_pkg.t_text
  , o_int_mess          out     com_api_type_pkg.t_text
) is
    l_params            com_api_type_pkg.t_param_tab;
    l_event_type        com_api_type_pkg.t_dict_value;
    l_card_instance_id  com_api_type_pkg.t_medium_id;
    l_card_state        com_api_type_pkg.t_dict_value;
    l_card_status       com_api_type_pkg.t_dict_value;
    l_count_run         pls_integer := 0;
begin

    if trim(i_card_number) is null then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Card number is empty!';
        o_int_mess := 'Parameter i_card_number is null';
        com_api_error_pkg.raise_error(
            i_error      => 'PARAM_VALUE_IS_NULL'
        );
    end if;

    if trim(i_status) is null then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Input status is empty!';
        o_int_mess := 'Parameter i_status is null';
        com_api_error_pkg.raise_error(
            i_error      => 'PARAM_VALUE_IS_NULL'
        );
    end if;

    case i_status
        when C_STATUS_TEMP_BLOCK then l_event_type := cst_woo_const_pkg.EVENT_TYPE_CARD_TEMP_BLOCK;
        when C_STATUS_UNBLOCK    then l_event_type := cst_woo_const_pkg.EVENT_TYPE_CARD_ACTIVATION;
        when C_STATUS_PERM_BLOCK then l_event_type := cst_woo_const_pkg.EVENT_TYPE_CARD_PERM_BLOCK;
        else                          l_event_type := null;
    end case;

    if l_event_type is null then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Input status is not valid!';
        o_int_mess := 'Invalid status, i_status=' || i_status;
        com_api_error_pkg.raise_error(
            i_error      => 'WRONG_ATTRIBUTE_VALUE'
        );
    end if;

    o_int_mess := 'l_event_type=' || l_event_type || ', ';

    begin
        select ci.id
             , ci.state
             , ci.status
          into l_card_instance_id
             , l_card_state
             , l_card_status
          from iss_card_instance ci
         where ci.id = (
                        select max(i.id)
                          from iss_card c
                             , iss_card_number n
                             , iss_card_instance i
                         where c.id = n.card_id
                           and c.id = i.card_id
                           and n.card_number = i_card_number
                           and (i.inst_id = i_inst_id or i_inst_id is null)
                        );
    exception
    when no_data_found then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Card_number ' || i_card_number || ' is not found!';
        o_int_mess := 'Card number is not found! Input parameters:'||
                      ' i_card_number=' || i_card_number ||
                      ', i_inst_id=' || i_inst_id ||
                      ', i_status=' || i_status;
    end;

    -- Case 01: Temporary block card, only block the card if:
    --  + State = CARD_STATE_ACTIVE ('CSTE0200')
    --  + Status = CARD_STATUS_VALID_CARD ('CSTS0000')
    -- Results after change: state = 'CSTE0200' and status = 'CSTS0023' (Temporary block)
    if      i_status        = C_STATUS_TEMP_BLOCK
        and l_card_state    = iss_api_const_pkg.CARD_STATE_ACTIVE
        and l_card_status   = iss_api_const_pkg.CARD_STATUS_VALID_CARD
    then
        evt_api_status_pkg.change_status (
            i_event_type    => l_event_type
          , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id     => l_card_instance_id
          , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
          , i_params        => l_params
        );
        l_count_run := l_count_run + 1;
        o_int_mess := o_int_mess || 'card_instance_id=' || l_card_instance_id || ', ';
    end if;

    -- Case 02: Unlock Temporary block status, only unblock the card if:
    --  + State = CARD_STATE_ACTIVE ('CSTE0200')
    --  + Status = CARD_STATUS_TEMP_BLOCK_BANK ('CSTS0023')
    -- Results after change: state = 'CSTE0200' and status = 'CSTS0000' (Valid)
    if      i_status        = C_STATUS_UNBLOCK
        and l_card_state    = iss_api_const_pkg.CARD_STATE_ACTIVE
        and l_card_status   = iss_api_const_pkg.CARD_STATUS_TEMP_BLOCK_BANK
    then
        evt_api_status_pkg.change_status (
            i_event_type    => l_event_type
          , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id     => l_card_instance_id
          , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
          , i_params        => l_params
        );
        l_count_run := l_count_run + 1;
        o_int_mess := o_int_mess || 'card_instance_id=' || l_card_instance_id || ', ';
    end if;

    -- Case 03: Permanent block card, only block the card if:
    --  + State = CARD_STATE_ACTIVE ('CSTE0200')
    --  + Status = CARD_STATUS_VALID_CARD ('CSTS0000')
    -- Results after change: state = 'CSTE0300' (closed) and status = 'CSTS0025' (Permanent block)
    if      i_status        = C_STATUS_PERM_BLOCK
        and l_card_state    = iss_api_const_pkg.CARD_STATE_ACTIVE
        and l_card_status   = iss_api_const_pkg.CARD_STATUS_VALID_CARD
    then
        evt_api_status_pkg.change_status (
            i_event_type    => l_event_type
          , i_initiator     => evt_api_const_pkg.INITIATOR_SYSTEM
          , i_entity_type   => iss_api_const_pkg.ENTITY_TYPE_CARD_INSTANCE
          , i_object_id     => l_card_instance_id
          , i_reason        => iss_api_const_pkg.CARD_STATUS_REASON_PC_REGUL
          , i_params        => l_params
        );
        l_count_run := l_count_run + 1;
        o_int_mess := o_int_mess || 'card_instance_id=' || l_card_instance_id || ', ';
    end if;

   if l_count_run = 0 then
        o_res_code := C_RES_CODE_ERROR;
        o_res_mess := 'Card number ' || i_card_number || ' has no valid state or status to process.';
        o_int_mess := 'No valid data to process. Input parameters:'
                      || ' i_card_number='|| i_card_number
                      || ', i_inst_id=' || i_inst_id
                      || ', i_status=' || i_status
                      || ', l_card_state=' || l_card_state
                      || ', l_card_status=' || l_card_status
                      ;
    else
        o_res_code := C_RES_CODE_OK ;
        o_res_mess := 'Processed';
        o_int_mess := o_int_mess || ' processed successfully' ;
   end if;

exception
    when others then
        if com_api_error_pkg.is_application_error(sqlcode) = com_api_const_pkg.TRUE then
            null;
        else
            o_res_code := C_RES_CODE_ERROR;
            o_res_mess := 'Unexpected error! Check webservice logs for more details';
            o_int_mess := 'Input parameters:'||
                          ' i_card_number=' || i_card_number ||
                          ', i_inst_id=' || i_inst_id ||
                          ', i_status=' || i_status ||
                          ', Unexpected error: ' || sqlerrm;
        end if;
end block_card;

end;
/
