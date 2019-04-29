create or replace force view dpp_ui_macros_vw
as
select * 
  from (
    select acc.id                                                               as account_id
         , acc.account_number
         , iss.card_id
         , crd.card_number
         , iss_api_card_pkg.get_card_mask(i_card_number => crd.card_number)     as card_mask
         , m.id                                                                 as macros_id
         , m.macros_type_id
         , get_text('acc_macros_type', 'name',        m.macros_type_id, l.lang) as macros_type_name
         , get_text('acc_macros_type', 'description', m.macros_type_id, l.lang) as macros_type_description
         , get_text('acc_macros_type', 'details',     m.macros_type_id, l.lang) as macros_type_details
         , dpp_api_payment_plan_pkg.get_dpp_amount_only(
               i_account_id => acc.id
             , i_macros_id  => m.id
           )                                                                    as macros_amount
         , m.currency                                                           as macros_currency
         , m.posting_date
         , opr.id                                                               as oper_id
         , opr.oper_type
         , opr.oper_date
         , get_article_text(i_article => opr.oper_type, i_lang => l.lang)       as oper_description
         , acc.inst_id
         , l.lang
      from acc_account           acc
         , acc_macros            m
         , opr_operation         opr
         , opr_participant       iss
         , iss_card_number_vw    crd
         , com_language_vw       l
     where m.object_id           = opr.id
       and m.entity_type         = 'ENTTOPER'
       and m.id not in (select a.id from dpp_payment_plan a)
       and iss.oper_id           = opr.id
       and iss.participant_type  = 'PRTYISS'
       and iss.card_id           = crd.card_id
       and acc.id                = m.account_id
       and opr.oper_type in (
               select e.element_value
                 from com_array_element e
                where e.array_id = 10000050
           )
       and exists (
               -- Check that macros contains entry of balance type which debits the account
               select e.id
                 from crd_event_bunch_type t
                    , acc_entry e
                where t.balance_type = e.balance_type
                  and t.inst_id      = acc.inst_id
                  and t.event_type   = 'EVNT1003' -- Apply payment event
                  and e.account_id   = acc.id
                  and e.split_hash   = acc.split_hash
                  and e.macros_id    = m.id
                  and e.status       = 'ENTRPOST'
           )
    ) 
where macros_amount > 0
/
