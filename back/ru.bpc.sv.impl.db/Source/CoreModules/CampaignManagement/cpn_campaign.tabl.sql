create table cpn_campaign (
    id                number(8)
  , inst_id           number(4)
  , seqnum            number(4)
  , start_date        date
  , end_date          date
  , campaign_number   varchar2(200)
  , campaign_type     varchar2(8)
)
/
comment on table cpn_campaign is 'Campaigns list'
/
comment on column cpn_campaign.id is 'Campaignn identifier'
/
comment on column cpn_campaign.inst_id is 'Owner institution identifier'
/
comment on column cpn_campaign.seqnum is 'Sequential number of data version'
/
comment on column cpn_campaign.start_date is 'Campaign start date'
/
comment on column cpn_campaign.end_date is 'Campaign end date'
/
comment on column cpn_campaign.campaign_type is 'Campaign type ()'
/
comment on column cpn_campaign.campaign_number is 'Campaign Number'
/
comment on column cpn_campaign.campaign_type is 'Campaign type (Dictionary CPNT)'
/
alter table cpn_campaign add cycle_id number(8)
/
comment on column cpn_campaign.cycle_id is 'Cycle identifier associated with the campaign to set dates for a certain object (not product). It is actual for Promotions campaign only.'
/
