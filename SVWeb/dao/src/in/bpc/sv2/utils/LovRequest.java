
package in.bpc.sv2.utils;

import java.util.ArrayList;
import java.util.List;
import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for lov_request complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="lov_request">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="lovId" type="{http://www.w3.org/2001/XMLSchema}int"/>
 *         &lt;element name="lov_param" type="{http://sv2.bpc.in/Utils}lov_param" maxOccurs="unbounded" minOccurs="0"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "lov_request", propOrder = {
    "lovId",
    "lovParam"
})
public class LovRequest {

    protected int lovId;
    @XmlElement(name = "lov_param")
    protected List<LovParam> lovParam;

    /**
     * Gets the value of the lovId property.
     * 
     */
    public int getLovId() {
        return lovId;
    }

    /**
     * Sets the value of the lovId property.
     * 
     */
    public void setLovId(int value) {
        this.lovId = value;
    }

    /**
     * Gets the value of the lovParam property.
     * 
     * <p>
     * This accessor method returns a reference to the live list,
     * not a snapshot. Therefore any modification you make to the
     * returned list will be present inside the JAXB object.
     * This is why there is not a <CODE>set</CODE> method for the lovParam property.
     * 
     * <p>
     * For example, to add a new item, do as follows:
     * <pre>
     *    getLovParam().add(newItem);
     * </pre>
     * 
     * 
     * <p>
     * Objects of the following type(s) are allowed in the list
     * {@link LovParam }
     * 
     * 
     */
    public List<LovParam> getLovParam() {
        if (lovParam == null) {
            lovParam = new ArrayList<LovParam>();
        }
        return this.lovParam;
    }

}
