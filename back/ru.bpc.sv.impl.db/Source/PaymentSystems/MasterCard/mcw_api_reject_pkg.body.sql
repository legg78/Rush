create or replace package body mcw_api_reject_pkg is

g_process_run_date date := sysdate;

type t_de_tab is table of com_api_type_pkg.t_text index by com_api_type_pkg.t_text;

procedure put_message(
    i_reject_rec             in     mcw_api_type_pkg.t_reject_rec
  , i_create_rev_reject      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
begin
    insert into mcw_reject (
        id
      , network_id
      , inst_id
      , file_id
      , rejected_fin_id
      , rejected_file_id
      , mti
      , de024
      , de071
      , de072
      , de093
      , de094
      , de100
      , p0005
      , p0006
      , p0025
      , p0026
      , p0138
      , p0165
      , p0280
    ) values (
        i_reject_rec.id
      , i_reject_rec.network_id
      , i_reject_rec.inst_id
      , i_reject_rec.file_id
      , i_reject_rec.rejected_fin_id
      , i_reject_rec.rejected_file_id
      , i_reject_rec.mti
      , i_reject_rec.de024
      , i_reject_rec.de071
      , i_reject_rec.de072
      , i_reject_rec.de093
      , i_reject_rec.de094
      , i_reject_rec.de100
      , i_reject_rec.p0005
      , i_reject_rec.p0006
      , i_reject_rec.p0025
      , i_reject_rec.p0026
      , i_reject_rec.p0138
      , i_reject_rec.p0165
      , i_reject_rec.p0280
    );

    -- if not Collection only message
    -- creates reversal operation, register reject event, set oper_status = REJECTED (OPST700), register oper stage = REJECTED
    if nvl(i_reject_rec.p0165, mcw_api_const_pkg.SETTLEMENT_TYPE_MASTERCARD) != mcw_api_const_pkg.SETTLEMENT_TYPE_COLLECTION then
        if i_create_rev_reject = com_api_const_pkg.TRUE then
            finalize_rejected_oper(
                i_oper_id           => i_reject_rec.rejected_fin_id
            );
        end if;
    end if;
end;

procedure put_reject_code (
    i_reject_data_id         in     com_api_type_pkg.t_long_id
  , i_reject_code_tab        in     mcw_api_type_pkg.t_reject_code_tab
) is
begin
    forall i in 1 .. i_reject_code_tab.count
        insert into mcw_reject_code (
            id
          , reject_data_id
          , de_number
          , severity_code
          , message_code
          , subfield_id
          , is_from_orig_msg
        ) values (
            com_api_id_pkg.get_id(mcw_reject_code_seq.nextval, get_sysdate)
          , i_reject_data_id
          , i_reject_code_tab(i).de_number
          , i_reject_code_tab(i).severity_code
          , i_reject_code_tab(i).message_code
          , i_reject_code_tab(i).subfield_id
          , 1
        );
end;

procedure put_reject_code (
    i_reject_data_id         in     com_api_type_pkg.t_long_id
  , i_de_number              in     com_api_type_pkg.t_text
  , i_pds_number             in     com_api_type_pkg.t_text
  , i_message_code           in     com_api_type_pkg.t_text
) is
begin
    insert into mcw_reject_code (
        id
      , reject_data_id
      , de_number
      , severity_code
      , message_code
      , subfield_id
      , is_from_orig_msg
    )
    values (
        com_api_id_pkg.get_id(mcw_reject_code_seq.nextval, get_sysdate)
      , i_reject_data_id
      , i_de_number
      , com_api_reject_pkg.C_REJECT_CODE_INVALID_FORMAT
      , i_message_code
      , i_pds_number
      , 0
    );
end put_reject_code;

function check_dict_field(
    i_dict                   in     com_api_type_pkg.t_dict_value
  , i_reject_data_id         in     com_api_type_pkg.t_long_id
  , i_field_value            in     com_api_type_pkg.t_text
  , i_de_number              in     com_api_type_pkg.t_text
  , i_pds_number             in     com_api_type_pkg.t_text
) return com_api_type_pkg.t_boolean
is
    l_code                          com_api_type_pkg.t_dict_value;
begin
    --modifyed copy of com_api_dictionary_pkg.check_article
    begin
        select code
          into l_code
          from com_dictionary
         where dict = 'DICT'
           and code = upper(i_dict);
    exception
        when no_data_found then
            put_reject_code(
                i_reject_data_id => i_reject_data_id
              , i_de_number      => i_de_number
              , i_pds_number     => i_pds_number
              , i_message_code   => com_api_reject_pkg.C_MSG_DICTIONARY_NOT_EXISTS || ' Field_value ['||i_field_value||'] dict ['||i_dict||']'|| sqlerrm
            );
            return com_api_const_pkg.FALSE;
    end;
    -- value can content only dict article or whole name with dict name
    begin
        select code
          into l_code
          from com_dictionary
         where dict = upper(i_dict)
           and code = lpad(nvl(substr(i_field_value, 5), i_field_value), 4 , '0');
    exception
        when no_data_found then
            put_reject_code(
                i_reject_data_id => i_reject_data_id
              , i_de_number      => i_de_number
              , i_pds_number     => i_pds_number
              , i_message_code   => com_api_reject_pkg.C_MSG_CODE_NOT_EXISTS_IN_DICT || ' Field_value ['||i_field_value||'] dict ['||i_dict||']'|| sqlerrm
            );
            return com_api_const_pkg.FALSE;
    end;

    return com_api_const_pkg.TRUE;
exception
    when others then
        put_reject_code(
            i_reject_data_id => i_reject_data_id
          , i_de_number      => i_de_number
          , i_pds_number     => i_pds_number
          , i_message_code   => com_api_reject_pkg.C_MSG_CHECK_DICT_FIELD_FAILED || ' Field_value ['||i_field_value||'] dict ['||i_dict||']'|| sqlerrm
        );
    return com_api_const_pkg.FALSE;
end check_dict_field;

-- put 'Operation reject data' for further validation of auth messages
procedure put_reject_data_dummy(
    i_oper_id                in     com_api_type_pkg.t_long_id
  , o_reject_data_id            out com_api_type_pkg.t_long_id
) is
    l_msg                           mcw_reject_data%rowtype;
begin
    if i_oper_id is not null then
        begin
            select a.oper_type
                 , iss_api_token_pkg.decode_card_number(i_card_number => b.card_number)
                 , m.de031
              into l_msg.operation_type
                 , l_msg.card_number
                 , l_msg.arn
              from opr_operation a
                 , opr_card b
                 , mcw_fin m
             where a.id = b.oper_id
               and a.id = m.id
               and a.id = i_oper_id; --mcw_fin.id = opr_operation.id
        exception
            when no_data_found then
                null;
        end;
    end if;

    l_msg.reject_id           := null; -- vis_rject is empty for auth messages
    l_msg.original_id         := i_oper_id;
    -- "3"(REJECT RECORDS INFORMED BY NATIONAL/INTERNATIONAL SCHEMES
    l_msg.reject_type         := com_api_reject_pkg.REJECT_TYPE_PRIMARY_VALIDATION; -- RJTP0001
    l_msg.process_date        := g_process_run_date;
    l_msg.originator_network  := null;
    l_msg.destination_network := null;
    l_msg.scheme              := com_api_reject_pkg.C_DEF_SCHEME;
    l_msg.reject_code         := com_api_reject_pkg.REJECT_CODE_INVALID_FORMAT; -- RJCD0001
    l_msg.assigned            := null; --assigned user ?
    l_msg.resolution_mode     := com_api_reject_pkg.REJECT_RESOLUT_MODE_FORWARD; --'RJMD001';  -- FORWARD
    l_msg.resolution_date     := null; -- just created, not resolved
    l_msg.status              := com_api_reject_pkg.REJECT_STATUS_OPENED; --'RJST0001'; -- Opened

    insert into mcw_reject_data (
        id
      , reject_id
      , original_id
      , reject_type
      , process_date
      , originator_network
      , destination_network
      , scheme
      , reject_code
      , operation_type
      , assigned
      , card_number
      , arn
      , resolution_mode
      , resolution_date
      , status
    )
    values (
        mcw_reject_data_seq.nextval
      , l_msg.reject_id
      , l_msg.original_id
      , l_msg.reject_type
      , l_msg.process_date
      , l_msg.originator_network
      , l_msg.destination_network
      , l_msg.scheme
      , l_msg.reject_code
      , l_msg.operation_type
      , l_msg.assigned
      , l_msg.card_number
      , l_msg.arn
      , l_msg.resolution_mode
      , l_msg.resolution_date
      , l_msg.status
    )
    returning
        id
    into
        o_reject_data_id;
end put_reject_data_dummy;

-- save operation rejected data in format 'Operation reject data'
procedure put_reject_data (
    i_reject_rec             in     mcw_api_type_pkg.t_reject_rec
  , o_reject_data_id            out com_api_type_pkg.t_long_id
) is
    l_msg                           mcw_reject_data%rowtype;
begin
    begin
      select a.oper_type
           , iss_api_token_pkg.decode_card_number(i_card_number => b.card_number)
           , m.de031
        into l_msg.operation_type
           , l_msg.card_number
           , l_msg.arn
        from opr_operation a
           , opr_card b
           , mcw_fin m
       where a.id = b.oper_id
         and a.id = m.id
         and a.id = i_reject_rec.rejected_fin_id; --mcw_fin.id = opr_operation.id
    exception
        when no_data_found then
            null;
    end;

    l_msg.reject_id           := i_reject_rec.id;
    l_msg.original_id         := i_reject_rec.rejected_fin_id;
    -- "3"(REJECT RECORDS INFORMED BY NATIONAL/INTERNATIONAL SCHEMES
    l_msg.reject_type         := com_api_reject_pkg.REJECT_TYPE_REGULATORS_SCHEMES; -- RJTP0003
    l_msg.process_date        := g_process_run_date;
    l_msg.originator_network  := i_reject_rec.de094; -- Transaction Originator Institution ID Code
    l_msg.destination_network := i_reject_rec.de093; -- Transaction Destination Institution ID Code
    l_msg.scheme              := com_api_reject_pkg.C_DEF_SCHEME;
    l_msg.reject_code         := com_api_reject_pkg.REJECT_CODE_INVALID_FORMAT; -- RJCD0001
    l_msg.assigned            := null; --assigned user
    l_msg.resolution_mode     := com_api_reject_pkg.REJECT_RESOLUT_MODE_FORWARD; --'RJMD001';  -- FORWARD
    l_msg.resolution_date     := null; -- just created, not resolved
    l_msg.status              := com_api_reject_pkg.REJECT_STATUS_OPENED; --'RJST0001'; -- Opened

    insert into mcw_reject_data(
        id
      , reject_id
      , original_id
      , reject_type
      , process_date
      , originator_network
      , destination_network
      , scheme
      , reject_code
      , operation_type
      , assigned
      , card_number
      , arn
      , resolution_mode
      , resolution_date
      , status
    )
    values (
        mcw_reject_data_seq.nextval
      , l_msg.reject_id
      , l_msg.original_id
      , l_msg.reject_type
      , l_msg.process_date
      , l_msg.originator_network
      , l_msg.destination_network
      , l_msg.scheme
      , l_msg.reject_code
      , l_msg.operation_type
      , l_msg.assigned
      , l_msg.card_number
      , l_msg.arn
      , l_msg.resolution_mode
      , l_msg.resolution_date
      , l_msg.status
    )
    returning
        id
    into
        o_reject_data_id;
end put_reject_data;

procedure find_original_file(
    i_p0105                  in     mcw_api_type_pkg.t_p0105
  , i_network_id             in     com_api_type_pkg.t_tiny_id
  , o_file_id                   out com_api_type_pkg.t_short_id
  , i_lock                   in     com_api_type_pkg.t_boolean    default com_api_const_pkg.TRUE
) is
begin
    if i_lock = com_api_const_pkg.TRUE then
        select id
          into o_file_id
          from mcw_file
         where p0105      = i_p0105
           and network_id = i_network_id
           for update;
    else
        select id
          into o_file_id
          from mcw_file
         where p0105      = i_p0105
           and network_id = i_network_id;
    end if;
exception
    when no_data_found then
        o_file_id := null;
end;

procedure find_original_message(
    i_file_id                in     com_api_type_pkg.t_short_id
  , i_p0138                  in     mcw_api_type_pkg.t_p0138
  , i_de071                  in     mcw_api_type_pkg.t_de071
  , i_network_id             in     com_api_type_pkg.t_tiny_id
  , o_fin_id                    out com_api_type_pkg.t_long_id
) is
    LOG_PREFIX      constant com_api_type_pkg.t_name := lower($$PLSQL_UNIT) || '.find_original_message ';
    l_stage                  com_api_type_pkg.t_name;
begin
    trc_log_pkg.debug(
        i_text       => LOG_PREFIX || '<< i_file_id [#1], i_p0138 [#2], i_de071 [#3], i_network_id [#4]'
      , i_env_param1 => i_file_id
      , i_env_param2 => i_p0138
      , i_env_param3 => i_de071
      , i_env_param4 => i_network_id
    );
    -- From MasterCard specification.
    -- The rejected message itself. If rejected message is generated by the IPM Pre-edit utility,
    -- Data Element (DE 71, Message Number) in it is modified to contain a value that is greater
    -- than the DE 71 value of the preceding message in the file.
    -- If generated by GCMS, DE 71 in the rejected message is not modified.
    begin
        select id
          into o_fin_id
          from mcw_fin
         where file_id    = i_file_id
           and network_id = i_network_id
           and de071      = i_p0138
           for update;

        l_stage := 'i_p0138';
    exception
        when no_data_found then
            -- So if an original rejected message is not found by PDS 138 of the error message (1644/691),
            -- try to find it by field DE 71 from the rejected message that follows after this error message.
            -- It correspondes to the case when a rejected message is generated by GCMS (see above).
            begin
                select id
                  into o_fin_id
                  from mcw_fin
                 where file_id    = i_file_id
                   and network_id = i_network_id
                   and de071      = i_de071
                   for update;

                l_stage := 'i_de071';
            exception
                when no_data_found then
                    null;
            end;
    end;

    if o_fin_id is not null then
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> original message with ID [#1] is found by [#2]'
          , i_env_param1 => o_fin_id
          , i_env_param2 => l_stage
        );
    else
        trc_log_pkg.debug(
            i_text       => LOG_PREFIX || '>> original message is NOT found'
          , i_env_param1 => o_fin_id
          , i_env_param2 => l_stage
        );
    end if;
end find_original_message;

procedure mark_file_rejected(
    i_file_id                in     com_api_type_pkg.t_short_id
  , i_reject_id              in     com_api_type_pkg.t_long_id
) is
begin
    update mcw_fin
       set is_rejected = com_api_const_pkg.TRUE
         , reject_id   = i_reject_id
     where file_id     = i_file_id;

    update mcw_file
       set is_rejected = com_api_const_pkg.TRUE
         , reject_id   = i_reject_id
     where id          = i_file_id;
end;

procedure mark_msg_rejected(
    i_id                     in     com_api_type_pkg.t_long_id
  , i_reject_id              in     com_api_type_pkg.t_long_id
) is
begin
    update mcw_fin
       set is_rejected = com_api_const_pkg.TRUE
         , reject_id   = i_reject_id
     where id          = i_id;
end;

procedure set_message(
    i_mes_rec                in            mcw_api_type_pkg.t_mes_rec
  , i_file_id                in            com_api_type_pkg.t_short_id
  , i_network_id             in            com_api_type_pkg.t_tiny_id
  , i_host_id                in            com_api_type_pkg.t_tiny_id
  , i_standard_id            in            com_api_type_pkg.t_tiny_id
  , io_reject_rec            in out nocopy mcw_api_type_pkg.t_reject_rec
  , io_pds_tab               in out nocopy mcw_api_type_pkg.t_pds_tab
) is
    l_stage                         com_api_type_pkg.t_name;
begin
    io_reject_rec            := null;

    l_stage := 'init';
    -- init
    io_reject_rec.id         := opr_api_create_pkg.get_id;
    io_reject_rec.file_id    := i_file_id;
    io_reject_rec.network_id := i_network_id;

    l_stage := 'mti & de24 - de100';
    io_reject_rec.mti        := i_mes_rec.mti;
    io_reject_rec.de024      := i_mes_rec.de024;
    io_reject_rec.de071      := i_mes_rec.de071;
    io_reject_rec.de072      := i_mes_rec.de072;
    io_reject_rec.de093      := i_mes_rec.de093;
    io_reject_rec.de094      := i_mes_rec.de094;
    io_reject_rec.de100      := i_mes_rec.de100;

    l_stage := 'get_inst_id';
    -- determine internal institution number
    io_reject_rec.inst_id := cmn_api_standard_pkg.find_value_owner (
                                 i_standard_id    => i_standard_id
                               , i_entity_type    => net_api_const_pkg.ENTITY_TYPE_HOST
                               , i_object_id      => i_host_id
                               , i_param_name     => mcw_api_const_pkg.CMID
                               , i_value_char     => io_reject_rec.de093
                             );

    if io_reject_rec.inst_id is null then
        com_api_error_pkg.raise_error(
            i_error         => 'MCW_CMID_NOT_REGISTRED'
          , i_env_param1    => io_reject_rec.de093
          , i_env_param2    => i_network_id
        );
    end if;

    l_stage := 'extract_pds';
    mcw_api_pds_pkg.extract_pds (
        de048       => i_mes_rec.de048
      , de062       => i_mes_rec.de062
      , de123       => i_mes_rec.de123
      , de124       => i_mes_rec.de124
      , de125       => i_mes_rec.de125
      , pds_tab     => io_pds_tab
    );
    l_stage := 'p0005';
    io_reject_rec.p0005 := mcw_api_pds_pkg.get_pds_body (
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0005
    );
    l_stage := 'p0025';
    io_reject_rec.p0025 := mcw_api_pds_pkg.get_pds_body (
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0025
    );
    l_stage := 'p0026';
    io_reject_rec.p0026 := mcw_api_pds_pkg.get_pds_body (
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0026
    );
    l_stage := 'p0138';
    io_reject_rec.p0138 := mcw_api_pds_pkg.get_pds_body (
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0138
    );
    l_stage := 'p0165';
    io_reject_rec.p0165 := mcw_api_pds_pkg.get_pds_body (
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0165
    );
    l_stage := 'p0280';
    io_reject_rec.p0280 := mcw_api_pds_pkg.get_pds_body (
        i_pds_tab         => io_pds_tab
      , i_pds_tag         => mcw_api_const_pkg.PDS_TAG_0280
    );

exception
    when others then
        trc_log_pkg.debug(
            i_text  => 'Error generating IPM reject on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end set_message;

-- creates reversal operation, register reject event, set oper_status = REJECTED (OPST700), register oper stage = REJECTED
procedure finalize_rejected_oper(
    i_oper_id                in     com_api_type_pkg.t_long_id
) is
begin
    if i_oper_id is not null then
        evt_api_event_pkg.register_event(
            i_event_type    =>  com_api_reject_pkg.EVENT_REGISTER_REJECT
          , i_eff_date      =>  com_api_sttl_day_pkg.get_sysdate
          , i_entity_type   =>  opr_api_const_pkg.ENTITY_TYPE_OPERATION
          , i_object_id     =>  i_oper_id
          , i_inst_id       =>  ost_api_const_pkg.DEFAULT_INST
          , i_split_hash    =>  com_api_hash_pkg.get_split_hash(
                                    i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
                                  , i_object_id     => i_oper_id
                                )
        );

        opr_ui_operation_pkg.modify_status(
            i_oper_id       => i_oper_id
          , i_oper_status   => com_api_reject_pkg.OPER_STATUS_REJECTED
        );

        insert into opr_oper_stage(
            oper_id
          , proc_stage
          , exec_order
          , status
          , split_hash
        ) values (
            i_oper_id
          , opr_api_const_pkg.PROCESSING_STAGE_REJECTED
          , 1
          , com_api_reject_pkg.OPER_STATUS_REJECTED
          , com_api_hash_pkg.get_split_hash(
                i_entity_type   => opr_api_const_pkg.ENTITY_TYPE_OPERATION
              , i_object_id     => i_oper_id
            )
        );

        -- reversal should be made for every rejected operation during its loading
        create_reversal_operation(
            i_oper_id => i_oper_id
        );
    end if;
end;

procedure validate_mcw_record_auth(
    i_oper_id                in     com_api_type_pkg.t_long_id
  , i_mes_rec                in     mcw_api_type_pkg.t_mes_rec
  , i_pds_tab                in     mcw_api_type_pkg.t_pds_tab
  , i_create_rev_reject      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
)
is
    l_validation_result     com_api_type_pkg.t_boolean;
    l_reject_data_id        com_api_type_pkg.t_long_id;
begin
    -- validate record and save visa rejected codes
    put_reject_data_dummy(
        i_oper_id          => i_oper_id
      , o_reject_data_id   => l_reject_data_id
    );
    -- validate record and save visa rejected codes
    l_validation_result :=
           validate_mcw_record(
               i_reject_data_id => l_reject_data_id
             , i_mcw_rec        => i_mes_rec
             , i_pds_tab        => i_pds_tab
           );
    if l_validation_result = com_api_const_pkg.TRUE then
        delete from mcw_reject_code
         where reject_data_id = l_reject_data_id;

        delete from mcw_reject_data
         where id = l_reject_data_id;

    elsif i_create_rev_reject = com_api_const_pkg.TRUE then
        -- creates reversal operation, register reject event, set oper_status = REJECTED (OPST700), register oper stage = REJECTED
        finalize_rejected_oper(
            i_oper_id => i_oper_id
        );
    end if;
end;

function validate_mcw_record (
    i_reject_data_id         in     com_api_type_pkg.t_long_id
  , i_mcw_rec                in     mcw_api_type_pkg.t_mes_rec
  , i_pds_tab                in     mcw_api_type_pkg.t_pds_tab
) return com_api_type_pkg.t_boolean
is
    l_validation_result   com_api_type_pkg.t_boolean;
    l_mti                 com_api_type_pkg.t_tiny_id;
    l_function_code       com_api_type_pkg.t_tiny_id;
    l_field_value         com_api_type_pkg.t_text;
    l_de_tab              t_de_tab;
    l_pds_founded         com_api_type_pkg.t_boolean := com_api_const_pkg.FALSE;

    cursor mcw_rules_de_cur (
        p_mti             in com_api_type_pkg.t_tiny_id
      , p_function_code   in com_api_type_pkg.t_tiny_id
    ) is
    select 'de' || lpad(to_char(de), 3, '0') as de
         , nvl(incoming, '~') as mandatory
         , dictionary
         , lov_id
      from mcw_validation_rules_de
     where mti           = p_mti
       and function_code = p_function_code
     order by de asc;

    cursor mcw_rules_pds_cur (
        p_mti             in com_api_type_pkg.t_tiny_id
      , p_function_code   in com_api_type_pkg.t_tiny_id
    ) is
    select pds
         , nvl(incoming, '~') as mandatory
         , dictionary
         , lov_id
      from mcw_validation_rules_pds
     where mti           = p_mti
       and function_code = p_function_code
     order by pds asc;


    procedure init_de_tab(
        i_mcw_rec                in     mcw_api_type_pkg.t_mes_rec
      , o_de_tab                    out t_de_tab
    )
    is
    begin
        o_de_tab.delete;
        o_de_tab('de002')   := i_mcw_rec.de002;
        o_de_tab('de002')   := i_mcw_rec.de002;
        o_de_tab('de0031')  := i_mcw_rec.de003_1;
        o_de_tab('de0032')  := i_mcw_rec.de003_2;
        o_de_tab('de0033')  := i_mcw_rec.de003_3;
        o_de_tab('de004')   := i_mcw_rec.de004;
        o_de_tab('de005')   := i_mcw_rec.de005;
        o_de_tab('de006')   := i_mcw_rec.de006;
        o_de_tab('de006')   := i_mcw_rec.de006;
        o_de_tab('de010')   := i_mcw_rec.de010;
        o_de_tab('de012')   := i_mcw_rec.de012;
        o_de_tab('de014')   := i_mcw_rec.de014;
        o_de_tab('de0221')  := i_mcw_rec.de022_1;
        o_de_tab('de0222')  := i_mcw_rec.de022_2;
        o_de_tab('de0223')  := i_mcw_rec.de022_3;
        o_de_tab('de0224')  := i_mcw_rec.de022_4;
        o_de_tab('de022_5') := i_mcw_rec.de022_5;
        o_de_tab('de022_6') := i_mcw_rec.de022_6;
        o_de_tab('de022_7') := i_mcw_rec.de022_7;
        o_de_tab('de022_8') := i_mcw_rec.de022_8;
        o_de_tab('de022_9') := i_mcw_rec.de022_9;
        o_de_tab('de022_10'):= i_mcw_rec.de022_10;
        o_de_tab('de022_11'):= i_mcw_rec.de022_11;
        o_de_tab('de022_12'):= i_mcw_rec.de022_12;
        o_de_tab('de023')   := i_mcw_rec.de023;
        o_de_tab('de024')   := i_mcw_rec.de024;
        o_de_tab('de025')   := i_mcw_rec.de025;
        o_de_tab('de026')   := i_mcw_rec.de026;
        o_de_tab('de030_1') := i_mcw_rec.de030_1;
        o_de_tab('de030_2') := i_mcw_rec.de030_2;
        o_de_tab('de031')   := i_mcw_rec.de031;
        o_de_tab('de032')   := i_mcw_rec.de032;
        o_de_tab('de033')   := i_mcw_rec.de033;
        o_de_tab('de037')   := i_mcw_rec.de037;
        o_de_tab('de038')   := i_mcw_rec.de038;
        o_de_tab('de040')   := i_mcw_rec.de040;
        o_de_tab('de041')   := i_mcw_rec.de041;
        o_de_tab('de042')   := i_mcw_rec.de042;
        o_de_tab('de043_1') := i_mcw_rec.de043_1;
        o_de_tab('de043_2') := i_mcw_rec.de043_2;
        o_de_tab('de043_3') := i_mcw_rec.de043_3;
        o_de_tab('de043_4') := i_mcw_rec.de043_4;
        o_de_tab('de043_5') := i_mcw_rec.de043_5;
        o_de_tab('de043_6') := i_mcw_rec.de043_6;
        o_de_tab('de048')   := i_mcw_rec.de048;
        o_de_tab('de049')   := i_mcw_rec.de049;
        o_de_tab('de050')   := i_mcw_rec.de050;
        o_de_tab('de051')   := i_mcw_rec.de051;
        o_de_tab('de054')   := i_mcw_rec.de054;
        o_de_tab('de055')   := i_mcw_rec.de055;
        o_de_tab('de062')   := i_mcw_rec.de062;
        o_de_tab('de063')   := i_mcw_rec.de063;
        o_de_tab('de071')   := i_mcw_rec.de071;
        o_de_tab('de072')   := i_mcw_rec.de072;
        o_de_tab('de073')   := i_mcw_rec.de073;
        o_de_tab('de093')   := i_mcw_rec.de093;
        o_de_tab('de094')   := i_mcw_rec.de094;
        o_de_tab('de095')   := i_mcw_rec.de095;
        o_de_tab('de100')   := i_mcw_rec.de100;
        o_de_tab('de111')   := i_mcw_rec.de111;
        o_de_tab('de123')   := i_mcw_rec.de123;
        o_de_tab('de124')   := i_mcw_rec.de124;
        o_de_tab('de125')   := i_mcw_rec.de125;
        o_de_tab('de127')   := i_mcw_rec.de127;
    end init_de_tab;

begin
    l_validation_result := com_api_const_pkg.TRUE;

    if trim(i_mcw_rec.mti) is null then
        return l_validation_result;
    end if;
    l_mti           := to_number(ltrim(i_mcw_rec.mti, '0'));
    l_function_code := to_number(ltrim(i_mcw_rec.de024, '0'));
    -- 1 check DE rules
    init_de_tab (
        i_mcw_rec  => i_mcw_rec
      , o_de_tab   => l_de_tab
    );

    for i in mcw_rules_de_cur(
                 p_mti             => l_mti
               , p_function_code   => l_function_code
             )
    loop
        if upper(i.mandatory) = 'M' and not l_de_tab.exists(i.de)
        then
            put_reject_code(
                i_reject_data_id => i_reject_data_id
              , i_de_number      => i.de
              , i_pds_number     => null
              , i_message_code   => com_api_reject_pkg.C_MSG_MANDAT_FIELD_NOT_PRESENT
            );
            l_validation_result := com_api_const_pkg.false;
        end if;

        if l_de_tab.exists(i.de) then
            l_field_value := trim(to_char(l_de_tab(i.de)));
            if l_field_value is null then
                put_reject_code(
                    i_reject_data_id => i_reject_data_id
                  , i_de_number      => i.de
                  , i_pds_number     => null
                  , i_message_code   => com_api_reject_pkg.C_MSG_FIELD_IS_EMPTY
                );
                l_validation_result := com_api_const_pkg.false;
            else
                -- checking of DICTIONARY value (com_dictionary)
                if trim(i.dictionary) is not null then
                  l_validation_result :=
                      check_dict_field(
                          i_dict              => trim(i.dictionary)
                        , i_reject_data_id    => i_reject_data_id
                        , i_field_value       => l_field_value
                        , i_de_number         => i.de
                        , i_pds_number        => null
                      );
                end if;
                --checking of LOV_ID value (com_lov)
                if i.lov_id is not null then
                    l_validation_result :=
                        com_ui_lov_pkg.check_lov_value(
                            i_lov_id => i.lov_id
                          , i_value  => l_field_value
                        );
                end if;
            end if;
        end if;
    end loop;
    -- 2 check PDS rules
    --index of i_pds_tab = pds_number
    --value of i_pds_tab = pds_body
    for i in mcw_rules_pds_cur(
        p_mti             => l_mti
      , p_function_code   => l_function_code
    ) loop
        l_pds_founded := com_api_const_pkg.FALSE;

        if upper(i.mandatory) = 'M'
        then
            for j in i_pds_tab.first .. i_pds_tab.last
            loop
                if j = i.pds then
                    l_pds_founded := com_api_const_pkg.TRUE;
                    exit;
                end if;
            end loop;

            if l_pds_founded = com_api_const_pkg.FALSE then
                put_reject_code(
                    i_reject_data_id => i_reject_data_id
                  , i_de_number      => null
                  , i_pds_number     => i.pds
                  , i_message_code   => com_api_reject_pkg.C_MSG_MANDAT_FIELD_NOT_PRESENT
                );
                l_validation_result := com_api_const_pkg.false;
            end if;
        end if;

        for j in i_pds_tab.first .. i_pds_tab.last
        loop
            if j = i.pds then -- pds_number
                l_field_value := trim(to_char(i_pds_tab(j))); -- pds_body
                if l_field_value is null then
                    put_reject_code(
                        i_reject_data_id => i_reject_data_id
                      , i_de_number      => null
                      , i_pds_number     => i.pds
                      , i_message_code   => com_api_reject_pkg.C_MSG_FIELD_IS_EMPTY
                    );
                    l_validation_result := com_api_const_pkg.false;
                    exit;
                else
                    -- checking of DICTIONARY value (com_dictionary)
                    if trim(i.dictionary) is not null then
                      l_validation_result :=
                          check_dict_field(
                              i_dict              => trim(i.dictionary)
                            , i_reject_data_id    => i_reject_data_id
                            , i_field_value       => l_field_value
                            , i_de_number         => null
                            , i_pds_number        => i.pds
                          );
                    end if;
                    --checking of LOV_ID value (com_lov)
                    if i.lov_id is not null then
                        l_validation_result :=
                            com_ui_lov_pkg.check_lov_value(
                                i_lov_id => i.lov_id
                              , i_value  => l_field_value
                            );
                    end if;
                end if;
            end if;
        end loop;
    end loop;

    return l_validation_result;
end validate_mcw_record;

procedure create_incoming_file_reject(
    i_mes_rec                in     mcw_api_type_pkg.t_mes_rec
  , i_file_id                in     com_api_type_pkg.t_short_id
  , i_network_id             in     com_api_type_pkg.t_tiny_id
  , i_host_id                in     com_api_type_pkg.t_tiny_id
  , i_standard_id            in     com_api_type_pkg.t_tiny_id
  , i_create_rev_reject      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    l_reject_rec            mcw_api_type_pkg.t_reject_rec;
    l_reject_code_tab       mcw_api_type_pkg.t_reject_code_tab;
    l_reject_data_id        com_api_type_pkg.t_long_id;
    l_rejected_file_id      com_api_type_pkg.t_short_id;
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
    l_stage                 varchar2(100);
begin
    trc_log_pkg.debug(
        i_text      => 'Processing incoming file reject'
    );

    set_message (
        i_mes_rec        => i_mes_rec
      , i_file_id        => i_file_id
      , i_network_id     => i_network_id
      , i_host_id        => i_host_id
      , i_standard_id    => i_standard_id
      , io_reject_rec    => l_reject_rec
      , io_pds_tab       => l_pds_tab
    );

    if l_reject_rec.p0280 is null then
        trc_log_pkg.debug(
            i_text         => 'File reject received without original file specified. id[#1]'
          , i_env_param1   => l_reject_rec.id
        );
    else
        find_original_file (
            i_p0105         => l_reject_rec.p0280
          , i_network_id    => i_network_id
          , o_file_id       => l_rejected_file_id
        );
        if l_rejected_file_id is null then
            trc_log_pkg.debug(
                i_text         => 'File reject received, but original file not found. id[#1] p0280[#2]'
              , i_env_param1   => l_reject_rec.id
              , i_env_param2   => l_reject_rec.p0280
            );
        else
            trc_log_pkg.debug(
                i_text         => 'Original file found file_id[#1]'
              , i_env_param1   => l_rejected_file_id
            );

            mark_file_rejected (
                i_file_id      => l_rejected_file_id
              , i_reject_id    => l_reject_rec.id
            );
            l_reject_rec.rejected_file_id := l_rejected_file_id;

            trc_log_pkg.debug(
                i_text         => 'Message marked as rejected. reject.id[#1]'
              , i_env_param1   => l_reject_rec.id
            );
        end if;
    end if;

    l_stage := 'parse_p0005';
    mcw_api_pds_pkg.parse_p0005 (
        i_p0005              => l_reject_rec.p0005
      , o_reject_code_tab    => l_reject_code_tab
    );

    l_stage := 'put_message';
    put_message (
        i_reject_rec         => l_reject_rec
      , i_create_rev_reject  => i_create_rev_reject
    );

    l_stage := 'put_reject_data';
    put_reject_data(
        i_reject_rec         => l_reject_rec
      , o_reject_data_id     => l_reject_data_id
    );

    l_stage := 'put_reject_code';
    put_reject_code (
        i_reject_data_id     => l_reject_data_id
      , i_reject_code_tab    => l_reject_code_tab
    );

    l_stage := 'save_pds';
    mcw_api_pds_pkg.save_pds (
        i_msg_id             => l_reject_rec.id
      , i_pds_tab            => l_pds_tab
    );

    trc_log_pkg.debug(
        i_text               => 'Incoming file reject processed. Assigned id[#1]'
      , i_env_param1         => l_reject_rec.id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text  => 'Error processing incoming file reject on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_incoming_file_reject;

procedure create_incoming_msg_reject(
    i_mes_rec                in     mcw_api_type_pkg.t_mes_rec
  , i_next_mes_rec           in     mcw_api_type_pkg.t_mes_rec
  , i_file_id                in     com_api_type_pkg.t_short_id
  , i_network_id             in     com_api_type_pkg.t_tiny_id
  , i_host_id                in     com_api_type_pkg.t_tiny_id
  , i_standard_id            in     com_api_type_pkg.t_tiny_id
  , i_validate_record        in     com_api_type_pkg.t_boolean
  , o_rejected_msg_found        out com_api_type_pkg.t_boolean
  , i_create_rev_reject      in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    l_reject_rec            mcw_api_type_pkg.t_reject_rec;
    l_reject_code_tab       mcw_api_type_pkg.t_reject_code_tab;
    l_reject_data_id        com_api_type_pkg.t_long_id;
    l_rejected_file_id      com_api_type_pkg.t_short_id;
    l_rejected_fin_id       com_api_type_pkg.t_long_id;
    l_pds_tab               mcw_api_type_pkg.t_pds_tab;
    l_stage                 varchar2(100);
    l_validation_result     com_api_type_pkg.t_boolean;
begin
    trc_log_pkg.debug(
        i_text      => 'Processing incoming message reject'
    );

    l_validation_result  := com_api_const_pkg.TRUE;
    o_rejected_msg_found := com_api_const_pkg.FALSE;

    set_message(
        i_mes_rec        => i_mes_rec
      , i_file_id        => i_file_id
      , i_network_id     => i_network_id
      , i_host_id        => i_host_id
      , i_standard_id    => i_standard_id
      , io_reject_rec    => l_reject_rec
      , io_pds_tab       => l_pds_tab
    );

    if l_reject_rec.p0280 is null then
        trc_log_pkg.debug(
            i_text       => 'Message reject received without original file specified. id[#1]'
          , i_env_param1 => l_reject_rec.id
        );
    else
        find_original_file(
            i_p0105         => l_reject_rec.p0280
          , i_network_id    => i_network_id
          , o_file_id       => l_rejected_file_id
          , i_lock          => com_api_const_pkg.FALSE
        );
        if l_rejected_file_id is null then
            trc_log_pkg.debug(
                i_text       => 'Message reject received, but original file not found. id[#1] p0280[#2]'
              , i_env_param1 => l_reject_rec.id
              , i_env_param2 => l_reject_rec.p0280
            );
        else
            trc_log_pkg.debug(
                i_text       => 'Original file found file_id[#1]'
              , i_env_param1 => l_rejected_file_id
            );
        end if;
    end if;

    if l_reject_rec.p0138 is null then
        trc_log_pkg.debug(
            i_text         => 'Message reject received without original message number specified. id[#1]'
          , i_env_param1   => l_reject_rec.id
        );
    end if;

    if l_rejected_file_id is not null and l_reject_rec.p0138 is not null then
        find_original_message(
            i_file_id       => l_rejected_file_id
          , i_p0138         => l_reject_rec.p0138
          , i_de071         => i_next_mes_rec.de071
          , i_network_id    => i_network_id
          , o_fin_id        => l_rejected_fin_id
        );
        if l_rejected_fin_id is not null then
            mark_msg_rejected(
                i_id           => l_rejected_fin_id
              , i_reject_id    => l_reject_rec.id
            );
            l_reject_rec.rejected_fin_id := l_rejected_fin_id;

            trc_log_pkg.debug(
                i_text         => 'Message marked as rejected: ID [#1]'
              , i_env_param1   => l_reject_rec.id
            );
        end if;
    end if;

    if l_reject_rec.de093 = i_next_mes_rec.de094 then
        trc_log_pkg.debug(
            i_text         => 'Following message is identified as a rejected: mti[#1] de024[#2] de031[#3] de094[#4] de071[#5]'
          , i_env_param1   => i_next_mes_rec.mti
          , i_env_param2   => i_next_mes_rec.de024
          , i_env_param3   => i_next_mes_rec.de031
          , i_env_param4   => i_next_mes_rec.de094
          , i_env_param5   => i_next_mes_rec.de071
        );
        o_rejected_msg_found := com_api_const_pkg.TRUE;
    else
        trc_log_pkg.debug(
            i_text         => 'Following message is not identified as a rejected: mti[#1] de024[#2] de031[#3] de094[#4] de071[#5]'
          , i_env_param1   => i_next_mes_rec.mti
          , i_env_param2   => i_next_mes_rec.de024
          , i_env_param3   => i_next_mes_rec.de031
          , i_env_param4   => i_next_mes_rec.de094
          , i_env_param5   => i_next_mes_rec.de071
        );
    end if;

    l_stage := 'parse_p0005';
    mcw_api_pds_pkg.parse_p0005 (
        i_p0005              => l_reject_rec.p0005
      , o_reject_code_tab    => l_reject_code_tab
    );

    l_stage := 'put_message';
    put_message(
        i_reject_rec         => l_reject_rec
      , i_create_rev_reject  => i_create_rev_reject
    );

    l_stage := 'save_pds';
    mcw_api_pds_pkg.save_pds (
        i_msg_id             => l_reject_rec.id
      , i_pds_tab            => l_pds_tab
    );

    l_stage := 'put_reject_data';
    put_reject_data(
        i_reject_rec         => l_reject_rec
      , o_reject_data_id     => l_reject_data_id
    );

    l_stage := 'put_reject_code';
    put_reject_code(
        i_reject_data_id     => l_reject_data_id
      , i_reject_code_tab    => l_reject_code_tab
    );

    --validate record and save MasterCard rejected codes
    if i_validate_record = com_api_const_pkg.true
    then
        l_validation_result :=
            validate_mcw_record(
                i_reject_data_id => l_reject_data_id
              , i_mcw_rec        => i_mes_rec
              , i_pds_tab        => l_pds_tab
            );
        -- set that record failed on format validation
        if l_validation_result = com_api_const_pkg.false
        then
            update mcw_reject_data
               -- 1(REJECTS DUE TO FORMAL/LOGICAL-FORMAL VALIDATIONS
               set reject_type = com_api_reject_pkg.REJECT_TYPE_PRIMARY_VALIDATION -- RJTP0001
             where id = l_reject_data_id;
        end if;
    end if;

    trc_log_pkg.debug(
        i_text         => 'Incoming message reject processed. Assigned ID [#1]'
      , i_env_param1   => l_reject_rec.id
    );
exception
    when others then
        trc_log_pkg.debug(
            i_text     => 'Error processing incoming message reject on stage ' || l_stage || ': ' || sqlerrm
        );
        raise;
end create_incoming_msg_reject;

-- creates mcw_fin and mcw_card
procedure create_duplicate_mcw_fin (
    i_oper_id                in     com_api_type_pkg.t_long_id
  , i_new_oper_id            in     com_api_type_pkg.t_long_id
  , i_create_reversal        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) is
    l_mcw_fin_rec                   mcw_api_type_pkg.t_fin_rec;
begin
    trc_log_pkg.debug(
        i_text       => 'create_duplicate_mcw_fin: started, original id [#1], new id [#2]'
      , i_env_param1 => i_oper_id
      , i_env_param2 => i_new_oper_id
    );

    mcw_api_fin_pkg.get_fin(
        i_id         => i_oper_id
      , o_fin_rec    => l_mcw_fin_rec
    );

    if i_create_reversal = com_api_const_pkg.TRUE then
        l_mcw_fin_rec.is_reversal := com_api_const_pkg.TRUE;
    end if;

    l_mcw_fin_rec.id := i_new_oper_id; -- replace ID with newly genarated operation

    mcw_api_fin_pkg.put_message(
        i_fin_rec => l_mcw_fin_rec
    );

    trc_log_pkg.debug(
        i_text       => 'create_duplicate_mcw_fin: ended.'
    );
end create_duplicate_mcw_fin;

-- duplicate should be made when rejected operation edited first time
function create_duplicate_operation (
    i_oper_id                in     com_api_type_pkg.t_long_id
  , i_fin_msg_type           in     com_api_type_pkg.t_text       -- visa, mastercard
  , i_create_reversal        in     com_api_type_pkg.t_boolean    default com_api_const_pkg.FALSE
) return com_api_type_pkg.t_long_id
is
    l_oper_rec        opr_operation%rowtype;   --opr_api_type_pkg.t_oper_rec; --hard to match
    l_new_oper_id     com_api_type_pkg.t_long_id := null;
    l_participant     opr_api_type_pkg.t_oper_part_rec;
    l_participant_tab opr_api_type_pkg.t_oper_part_by_type_tab;
begin
    trc_log_pkg.debug(
        i_text       => 'create_duplicate_operation: started, original id [#1].'
      , i_env_param1 => i_oper_id
    );

    select a.*
      into l_oper_rec
      from opr_operation a
     where a.id = i_oper_id;

    -- get participants
    l_participant_tab.delete;
    for i in (
        select o.participant_type
          from opr_participant o
         where o.oper_id = i_oper_id
    ) loop
        opr_api_operation_pkg.get_participant(
            i_oper_id           => i_oper_id
          , i_participaint_type => i.participant_type
          , o_participant       => l_participant
        );
        l_participant_tab(i.participant_type) := l_participant;
    end loop;

    -- duplicates operation, its participants and opr_card
    opr_api_create_pkg.create_operation(
        io_oper_id                => l_new_oper_id
      , i_session_id              => l_oper_rec.session_id
      , i_is_reversal             => case when i_create_reversal = com_api_const_pkg.TRUE
                                          then com_api_const_pkg.TRUE
                                          else l_oper_rec.is_reversal
                                     end
      , i_original_id             => case when i_create_reversal = com_api_const_pkg.TRUE
                                          then l_oper_rec.id -- reversal must refer on id of reversed operation
                                          else l_oper_rec.original_id
                                     end
      , i_oper_type               => case
                                         when i_create_reversal = com_api_const_pkg.TRUE then
                                              case
                                              when l_oper_rec.oper_type in (--debit oper types - replace on credit
                                                       opr_api_const_pkg.OPERATION_TYPE_PURCHASE   -- OPTP0000
                                                     , opr_api_const_pkg.OPERATION_TYPE_ATM_CASH   -- OPTP0001
                                                     , opr_api_const_pkg.OPERATION_TYPE_CASHBACK   -- OPTP0009
                                                   )
                                                  then opr_api_const_pkg.OPERATION_TYPE_REJECT_CREDIT -- OPTP0701
                                              when l_oper_rec.oper_type in (--credit oper types - replace on debit
                                                       opr_api_const_pkg.OPERATION_TYPE_REFUND     -- OPTP0020
                                                     , opr_api_const_pkg.OPERATION_TYPE_CASHIN     -- OPTP0022
                                                     , opr_api_const_pkg.OPERATION_TYPE_P2P_CREDIT -- OPTP0026
                                                  )
                                                  then opr_api_const_pkg.OPERATION_TYPE_REJECT_DEBIT   -- OPTP0702
                                              else l_oper_rec.oper_type
                                              end
                                         else l_oper_rec.oper_type
                                     end
      , i_oper_reason             => l_oper_rec.oper_reason
      , i_msg_type                => l_oper_rec.msg_type
      , i_status                  => l_oper_rec.status
      , i_status_reason           => l_oper_rec.status_reason
      , i_sttl_type               => l_oper_rec.sttl_type
      , i_terminal_type           => l_oper_rec.terminal_type
      , i_acq_inst_bin            => l_oper_rec.acq_inst_bin
      , i_forw_inst_bin           => l_oper_rec.forw_inst_bin
      , i_merchant_number         => l_oper_rec.merchant_number
      , i_terminal_number         => l_oper_rec.terminal_number
      , i_merchant_name           => l_oper_rec.merchant_name
      , i_merchant_street         => l_oper_rec.merchant_street
      , i_merchant_city           => l_oper_rec.merchant_city
      , i_merchant_region         => l_oper_rec.merchant_region
      , i_merchant_country        => l_oper_rec.merchant_country
      , i_merchant_postcode       => l_oper_rec.merchant_postcode
      , i_mcc                     => l_oper_rec.mcc
      , i_originator_refnum       => l_oper_rec.originator_refnum
      , i_network_refnum          => l_oper_rec.network_refnum
      , i_oper_count              => l_oper_rec.oper_count
      , i_oper_request_amount     => l_oper_rec.oper_request_amount
      , i_oper_amount_algorithm   => l_oper_rec.oper_amount_algorithm
      , i_oper_amount             => l_oper_rec.oper_amount
      , i_oper_currency           => l_oper_rec.oper_currency
      , i_oper_cashback_amount    => l_oper_rec.oper_cashback_amount
      , i_oper_replacement_amount => l_oper_rec.oper_replacement_amount
      , i_oper_surcharge_amount   => l_oper_rec.oper_surcharge_amount
      , i_oper_date               => l_oper_rec.oper_date
      , i_match_status            => l_oper_rec.match_status
      , i_sttl_amount             => l_oper_rec.sttl_amount
      , i_sttl_currency           => l_oper_rec.sttl_currency
      , i_dispute_id              => l_oper_rec.dispute_id
      , i_payment_order_id        => l_oper_rec.payment_order_id
      , i_payment_host_id         => l_oper_rec.payment_host_id
      , i_forced_processing       => l_oper_rec.forced_processing
      , i_proc_mode               => l_oper_rec.proc_mode
      , i_incom_sess_file_id      => l_oper_rec.incom_sess_file_id
      , io_participants           => l_participant_tab
    );
    if i_create_reversal = com_api_const_pkg.FALSE then
        trc_log_pkg.debug(
            i_text       => 'create_duplicate_operation: ended, created NEW operation with id [#1] for original_id [#2].'
          , i_env_param1 => l_new_oper_id
          , i_env_param2 => i_oper_id
        );
    else
        trc_log_pkg.debug(
            i_text       => 'create_duplicate_operation: ended, created REVERSAL operation with id [#1] for original_id [#2].'
          , i_env_param1 => l_new_oper_id
          , i_env_param2 => i_oper_id
        );
    end if;
    -- duplicate network data
    if i_fin_msg_type = com_api_reject_pkg.C_NETW_MASTERCARD then
        create_duplicate_mcw_fin(
            i_oper_id         => i_oper_id
          , i_new_oper_id     => l_new_oper_id
          , i_create_reversal => i_create_reversal
        );
    end if;

    return l_new_oper_id;
end create_duplicate_operation;

procedure create_reversal_operation (
    i_oper_id                in     com_api_type_pkg.t_long_id
) is
    l_vis_cnt          com_api_type_pkg.t_long_id;
    l_mcw_cnt          com_api_type_pkg.t_long_id;
    l_reversal_oper_id com_api_type_pkg.t_long_id;
    l_id               com_api_type_pkg.t_long_id;
begin
    -- check if dulicate need to be made
    select count(id)
      into l_vis_cnt
      from vis_reject_data
     where original_id = i_oper_id;

    select count(id)
      into l_mcw_cnt
      from mcw_reject_data
     where original_id = i_oper_id;

    -- visa
    if l_vis_cnt = 1 then
        null;

    elsif l_mcw_cnt = 1 then
        select id
             , reversal_oper_id
          into l_id
             , l_reversal_oper_id
          from mcw_reject_data
         where original_id = i_oper_id;

        if l_reversal_oper_id is null then
            l_reversal_oper_id :=
                create_duplicate_operation(
                    i_oper_id           => i_oper_id
                  , i_fin_msg_type      => com_api_reject_pkg.C_NETW_MASTERCARD
                  , i_create_reversal   => com_api_const_pkg.TRUE
                );
            update mcw_reject_data
               set reversal_oper_id = l_reversal_oper_id
             where id = l_id;
        else
            trc_log_pkg.warn(
                i_text       => 'create_reversal_operation: mcw Reversal [#1] for operation [#2] have been already created.'
              , i_env_param1 => l_reversal_oper_id
              , i_env_param2 => i_oper_id
            );
        end if;
    else
        trc_log_pkg.error(
            i_text       => 'create_reversal_operation: Operation [#1] not found in rejected data.'
          , i_env_param1 => i_oper_id
        );
    end if;
end create_reversal_operation;

end;
/
