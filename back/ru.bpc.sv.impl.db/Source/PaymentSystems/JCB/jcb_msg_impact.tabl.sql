create table jcb_msg_impact(
    mti             varchar2(4)
  , de024           varchar2(3)
  , de003_1         varchar2(2)
  , is_reversal     number(1)
  , is_incoming     number(1)
  , impact          number(1) 
  , primary key(mti, de024, de003_1, is_reversal, is_incoming)
)
organization index
/

comment on table jcb_msg_impact is 'Impact on financial processing of JCB messages'
/

comment on column jcb_msg_impact.mti is 'Message Type Identifier'
/

comment on column jcb_msg_impact.de024 is 'Function Code'
/

comment on column jcb_msg_impact.de003_1 is 'Cardholder Transaction Type'
/

comment on column jcb_msg_impact.is_reversal is 'Reversal indicator'
/

comment on column jcb_msg_impact.is_incoming is 'Incoming message indicator'
/

comment on column jcb_msg_impact.impact is 'Message impact'
/
