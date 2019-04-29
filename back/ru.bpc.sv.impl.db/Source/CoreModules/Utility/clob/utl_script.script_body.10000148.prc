begin
    insert into csm_case_vw (
            id
          , inst_id
          , merchant_name
          , customer_number
          , dispute_reason
          , oper_date
          , oper_amount
          , oper_currency
          , dispute_id
          , dispute_progress
          , write_off_amount
          , write_off_currency
          , due_date
          , reason_code
          , disputed_amount
          , disputed_currency
          , created_date
          , created_by_user_id
          , arn
          , claim_id
          , auth_code
          , case_progress
          , acquirer_inst_bin
          , transaction_code
          , case_source
          , sttl_amount
          , sttl_currency
          , original_id
    )
    select a.id
         , a.inst_id
         , min(case when e.name = 'MERCHANT_NAME'
                    then d.element_value
               end
           ) as merchant_name
         , min(case when e.name = 'CUSTOMER_NUMBER'
                    then d.element_value
               end
           ) as customer_number
         , min(case when e.name = 'DISPUTE_REASON'
                    then d.element_value
               end
           ) as dispute_reason
         , min(case when e.name = 'OPER_DATE'
                    then to_date(d.element_value, 'yyyymmddhh24miss')
               end
           ) as oper_date
         , min(case when e.name = 'OPER_AMOUNT'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as oper_amount
         , min(case when e.name = 'OPER_CURRENCY'
                    then case length(d.element_value) when 3
                         	  then d.element_value
                         	  else to_char(to_number(d.element_value, 'FM000000000000000000.0000'))
                         end
               end
           ) as oper_currency
         , min(case when e.name = 'DISPUTE_ID'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as dispute_id
         , min(case when e.name = 'DISPUTE_PROGRESS'
                    then d.element_value
               end
           ) as dispute_progress
         , min(case when e.name = 'WRITE_OFF_AMOUNT'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as write_off_amount
         , min(case when e.name = 'WRITE_OFF_CURRENCY'
                    then d.element_value
               end
           ) as write_off_currency
         , min(case when e.name = 'DUE_DATE'
                    then to_date(d.element_value, 'yyyymmddhh24miss')
               end
           ) as due_date
         , min(case when e.name = 'REASON_CODE'
                    then d.element_value
               end
           ) as reason_code
         , min(case when e.name = 'DISPUTED_AMOUNT'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as disputed_amount
         , min(case when e.name = 'DISPUTED_CURRENCY'
                    then case length(d.element_value) when 3
                         	  then d.element_value
                         	  else to_char(to_number(d.element_value, 'FM000000000000000000.0000'))
                         end
               end
           ) as disputed_currency
         , min(case when e.name = 'CREATED_DATE'
                    then to_date(d.element_value, 'yyyymmddhh24miss')
               end
           ) as created_date
         , min(case when e.name = 'CREATED_BY_USER_ID'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as created_by_user_id
         , min(case when e.name = 'ARN'
                    then d.element_value
               end
           ) as arn
         , min(case when e.name = 'CLAIM_ID'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as claim_id
         , min(case when e.name = 'AUTH_CODE'
                    then d.element_value
               end
           ) as auth_code
         , min(case when e.name = 'CASE_PROGRESS'
                    then d.element_value
               end
           ) as case_progress
         , min(case when e.name = 'ACQUIRER_INST_BIN'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as acquirer_inst_bin
         , min(case when e.name = 'TRANSACTION_CODE'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as transaction_code
         , min(case when e.name = 'CASE_SOURCE'
                    then d.element_value
               end
           ) as case_source
         , min(case when e.name = 'STTL_AMOUNT'
                    then to_number(d.element_value, 'FM000000000000000000.0000')
               end
           ) as sttl_amount
         , min(case when e.name = 'STTL_CURRENCY'
                    then d.element_value
               end
           ) as sttl_currency
         , (
               select ca.original_id
                 from csm_application ca
                where ca.id = a.id
           ) as original_id
      from app_application a
         , app_data d
         , app_element e
     where a.appl_type = 'APTPDSPT'
       and d.appl_id   = a.id
       and e.id        = d.element_id
     group by a.id
            , a.inst_id;

    insert into csm_card (
            id
          , card_number
    )
    select a.id
         , min(case when e.name = 'CARD_NUMBER'
                    then d.element_value
               end
           ) as card_number
      from app_application a
         , app_data d
         , app_element e
     where a.appl_type = 'APTPDSPT'
       and d.appl_id   = a.id
       and e.id        = d.element_id
     group by a.id;
end;

