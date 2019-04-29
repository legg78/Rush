alter table cpn_campaign add (
    constraint cpn_campaign_pk primary key (id)
)
/ 
alter table cpn_campaign add (constraint cpn_campaign_uk unique (campaign_number, inst_id))
/
