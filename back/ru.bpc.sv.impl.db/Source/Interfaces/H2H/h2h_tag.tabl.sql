create table h2h_tag(
    id                  number(8)       not null
  , seqnum              number(4)
  , tag                 varchar2(200)   not null
  , fe_tag_id           number(8)
  , fe_tag_reference    varchar2(200)
  , mcw_field           varchar2(200)
  , vis_field           varchar2(200)
)
/

comment on table h2h_tag is 'H2H interface tags'
/
comment on column h2h_tag.id is 'Identifier.'
/
comment on column h2h_tag.seqnum is 'Sequential number of record version.'
/
comment on column h2h_tag.tag is 'Tag name.'
/
comment on column h2h_tag.fe_tag_id is 'FE tag identifier. Reference to aup_tag.tag.'
/
comment on column h2h_tag.fe_tag_reference is 'FE tag reference. Reference to aup_tag.reference.'
/
comment on column h2h_tag.mcw_field is 'MasterCard message field name.'
/
comment on column h2h_tag.vis_field is 'Visa message field name.'
/

alter table h2h_tag add jcb_field varchar2(200 char)
/
comment on column h2h_tag.jcb_field is 'JCB message field name.'
/
alter table h2h_tag add (din_field varchar2(200))
/
comment on column h2h_tag.din_field is 'DinersClub message field name.'
/
alter table h2h_tag add (amx_field varchar2(200))
/
comment on column h2h_tag.amx_field is 'AMEX message field name.'
/
alter table h2h_tag drop column fe_tag_reference
/

comment on table h2h_tag is 'H2H interface tag reference. IPS fields may content either entire IPS field name or its extended version. In the 2nd case, after delimiter "|" there is a substring position or date format'
/
comment on column h2h_tag.id is 'Identifier (PK)'
/
comment on column h2h_tag.seqnum is 'Sequential number of record version'
/
comment on column h2h_tag.tag is 'Tag name'
/
comment on column h2h_tag.fe_tag_id is 'Front-End tag identifier, it refers to field aup_tag.tag. This field is used to map H2H tags onto AUP (FE) tags during the creation of a new authorization by an incoming H2H message'
/
comment on column h2h_tag.mcw_field is 'MasterCard message DE/PDS name. This field is used to map MasterCard fields/PDS onto H2H tags during the creation of a new outgoing H2H message by the incoming MasterCard clearing message'
/
comment on column h2h_tag.vis_field is 'Visa message field name. This field is used to map Visa fields onto H2H tags during the creation of a new outgoing H2H message by the incoming Visa clearing message'
/
comment on column h2h_tag.jcb_field is 'JCB message DE/PDS name. This field is used to map JCB fields/PDS onto H2H tags during the creation of a new outgoing H2H message by the incoming JCB clearing message'
/
comment on column h2h_tag.din_field is 'Diners Club message field/addendum name. This field is used to map JCB fields/addendums onto H2H tags during the creation of a new outgoing H2H message by the incoming Diners Club clearing message'
/
comment on column h2h_tag.amx_field is 'AMEX message field name. This field is used to map AMEX fields onto H2H tags during the creation of a new outgoing H2H message by the incoming AMEX clearing message'
/
alter table h2h_tag add (mup_field varchar2(200))
/
comment on column h2h_tag.mup_field is 'MIR message field name.'
/
