
package in.bpc.sv2.utils;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;



/**
 * <p>Java class for lov complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="lov">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="lov_record" type="{http://sv2.bpc.in/Utils}lov_record" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "kladr_records", namespace="http://sv2.bpc.in/Utils", propOrder = {
    "kladrRecord"
})
public class KladrRecords {

    @XmlElement(name = "kladr_record")
    protected List<KladrRecord> kladrRecord;

    /**
     * Gets the value of the kladrRecord property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the kladrRecord property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getLovRecord().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link KladrRecord }
     * 
     * 
     */
    public List<KladrRecord> getKladrRecord() {
        if (kladrRecord == null) {
            kladrRecord = new ArrayList<KladrRecord>();
        }
        return this.kladrRecord;
    }

	public void setKladrRecord(List<KladrRecord> kladrRecord) {
		this.kladrRecord = kladrRecord;
	}

}
