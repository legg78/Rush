
package in.bpc.sv2.utils;

import javax.xml.bind.annotation.XmlAccessType;
import javax.xml.bind.annotation.XmlAccessorType;
import javax.xml.bind.annotation.XmlElement;
import javax.xml.bind.annotation.XmlType;


/**
 * <p>Java class for rate complex type.
 * 
 * <p>The following schema fragment specifies the expected content contained within this class.
 * 
 * <pre>
 * &lt;complexType name="rate">
 *   &lt;complexContent>
 *     &lt;restriction base="{http://www.w3.org/2001/XMLSchema}anyType">
 *       &lt;sequence>
 *         &lt;element name="source_currency" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="destination_currency" type="{http://www.w3.org/2001/XMLSchema}string"/>
 *         &lt;element name="value" type="{http://www.w3.org/2001/XMLSchema}float"/>
 *       &lt;/sequence>
 *     &lt;/restriction>
 *   &lt;/complexContent>
 * &lt;/complexType>
 * </pre>
 * 
 * 
 */
@XmlAccessorType(XmlAccessType.FIELD)
@XmlType(name = "rate", propOrder = {
    "sourceCurrency",
    "destinationCurrency",
    "value"
})
public class Rate {

    @XmlElement(name = "source_currency", required = true)
    protected String sourceCurrency;
    @XmlElement(name = "destination_currency", required = true)
    protected String destinationCurrency;
    protected Float value;

    /**
     * Gets the value of the sourceCurrency property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getSourceCurrency() {
        return sourceCurrency;
    }

    /**
     * Sets the value of the sourceCurrency property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setSourceCurrency(String value) {
        this.sourceCurrency = value;
    }

    /**
     * Gets the value of the destinationCurrency property.
     * 
     * @return
     *     possible object is
     *     {@link String }
     *     
     */
    public String getDestinationCurrency() {
        return destinationCurrency;
    }

    /**
     * Sets the value of the destinationCurrency property.
     * 
     * @param value
     *     allowed object is
     *     {@link String }
     *     
     */
    public void setDestinationCurrency(String value) {
        this.destinationCurrency = value;
    }

    /**
     * Gets the value of the value property.
     * 
     */
    public Float getValue() {
        return value;
    }

    /**
     * Sets the value of the value property.
     * 
     */
    public void setValue(Float value) {
        this.value = value;
    }

}
