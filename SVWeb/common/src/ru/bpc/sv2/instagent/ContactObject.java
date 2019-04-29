package ru.bpc.sv2.instagent;

/**
 * BPC GROUP 2016 (c) All Rights Reserved
 */
public class ContactObject {

    private String id;
    private String objectId;
    private String contactType;
    private String contactId;

    public ContactObject() {}

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public String getObjectId() {
        return objectId;
    }

    public void setObjectId(String objectId) {
        this.objectId = objectId;
    }

    public String getContactType() {
        return contactType;
    }

    public void setContactType(String contactType) {
        this.contactType = contactType;
    }

    public String getContactId() {
        return contactId;
    }

    public void setContactId(String contactId) {
        this.contactId = contactId;
    }
}
