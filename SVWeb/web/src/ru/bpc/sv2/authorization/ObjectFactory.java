
package ru.bpc.sv2.authorization;

import javax.xml.bind.JAXBElement;
import javax.xml.bind.annotation.XmlElementDecl;
import javax.xml.bind.annotation.XmlRegistry;
import javax.xml.namespace.QName;


/**
 * This object contains factory methods for each 
 * Java content interface and Java element interface 
 * generated in the ru.bpc.sv2.authorization package. 
 * <p>An ObjectFactory allows you to programatically 
 * construct new instances of the Java representation 
 * for XML content. The Java representation of XML 
 * content can consist of schema derived interfaces 
 * and classes representing the binding of schema 
 * type definitions, element declarations and model 
 * groups.  Factory methods for each of these are 
 * provided in this class.
 * 
 */
@XmlRegistry
public class ObjectFactory {

    private final static QName _Id_QNAME = new QName("http://www.bpc.ru/sv2/authorization", "Id");

    /**
     * Create a new ObjectFactory that can be used to create new instances of schema derived classes for package: ru.bpc.sv2.authorization
     * 
     */
    public ObjectFactory() {
    }

    /**
     * Create an instance of {@link ReloadRequest }
     * 
     */
    public ReloadRequest createReloadRequest() {
        return new ReloadRequest();
    }

    /**
     * Create an instance of {@link JAXBElement }{@code <}{@link Integer }{@code >}}
     * 
     */
    @XmlElementDecl(namespace = "http://www.bpc.ru/sv2/authorization", name = "Id")
    public JAXBElement<Integer> createId(Integer value) {
        return new JAXBElement<Integer>(_Id_QNAME, Integer.class, null, value);
    }

}
