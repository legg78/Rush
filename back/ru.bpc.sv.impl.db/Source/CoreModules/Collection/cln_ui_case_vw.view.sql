create or replace force view cln_ui_case_vw as
select t.id
     , t.seqnum
     , t.inst_id
     , t.split_hash
     , t.case_number
     , t.creation_date
     , t.customer_id
     , t.user_id
     , t.status
     , t.resolution
     , get_article_text(i_article  => t.status) as status_name
     , get_article_text(i_article  => t.resolution) as resolution_name
     , get_text('OST_INSTITUTION', 'NAME', t.inst_id, l.lang) as institution
     , t.customer_number
     , p.first_name as first_name
     , p.second_name as second_name
     , p.surname as surname
     , p.birthday
     , nvl(prd_api_customer_pkg.get_customer_aging(i_customer_id => t.customer_id), 0) as aging_period
     , n.activity_type as last_activity
     , n.action_date as last_activity_date
     , acm_api_user_pkg.get_user_name(i_user_id  => n.user_id, i_mask_error  => 1) as user_name
     , t.assign_date
     , l.lang
  from (select c.id
             , c.seqnum
             , c.inst_id
             , c.split_hash
             , c.case_number
             , c.creation_date
             , c.customer_id
             , c.user_id
             , c.status
             , c.resolution
             , s.entity_type
             , s.object_id
             , s.customer_number
             , i.action_id
             , (select min(a.action_date) from cln_action a where a.case_id = c.id and a.activity_type in ('EVNT2501', 'EVNT2503')) as assign_date
          from cln_case        c
             , prd_customer    s
             , (select a.case_id
                     , max(a.id) keep(dense_rank first order by a.id desc) as action_id
                  from cln_action a
                 group by a.case_id
               )               i
         where c.inst_id     in (select inst_id from acm_cu_inst_vw)
           and c.customer_id  = s.id
           and c.id           = i.case_id
       )               t
     , com_person      p
     , cln_action      n
     , com_language_vw l
 where t.entity_type  = 'ENTTPERS'
   and t.object_id    = p.id
   and t.action_id    = n.id
/
