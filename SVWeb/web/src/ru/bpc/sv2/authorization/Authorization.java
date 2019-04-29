
package ru.bpc.sv2.authorization;

import javax.jws.WebMethod;
import javax.jws.WebParam;
import javax.jws.WebResult;
import javax.jws.WebService;
import javax.xml.bind.annotation.XmlSeeAlso;


/**
 * This class was generated by the JAX-WS RI.
 * JAX-WS RI 2.1.6 in JDK 6
 * Generated source version: 2.1
 * 
 */
@WebService(name = "Authorization", targetNamespace = "http://www.bpc.ru/sv2/authorization")
@XmlSeeAlso({ObjectFactory.class})
public interface Authorization {


    /**
     * 
     * @param id
     * @return
     *     returns int
     */
    @WebMethod(action = "http://www.bpc.ru/sv2/authorization/reloadTerminal")
    @WebResult(name = "Id", targetNamespace = "http://www.bpc.ru/sv2/authorization", partName = "Result")
    public int reloadTerminal(
        @WebParam(name = "reloadRequest", targetNamespace = "http://www.bpc.ru/sv2/authorization", partName = "Id")
        ReloadRequest id);

    /**
     * 
     * @param id
     * @return
     *     returns int
     */
    @WebMethod(action = "http://www.bpc.ru/sv2/authorization/reloadCommunicationDevice")
    @WebResult(name = "Id", targetNamespace = "http://www.bpc.ru/sv2/authorization", partName = "Result")
    public int reloadCommunicationDevice(
        @WebParam(name = "reloadRequest", targetNamespace = "http://www.bpc.ru/sv2/authorization", partName = "Id")
        ReloadRequest id);

    /**
     * 
     * @param id
     * @return
     *     returns int
     */
    @WebMethod(action = "http://www.bpc.ru/sv2/authorization/reloadAuthorizationScenario")
    @WebResult(name = "Id", targetNamespace = "http://www.bpc.ru/sv2/authorization", partName = "Result")
    public int reloadAuthorizationScenario(
        @WebParam(name = "reloadRequest", targetNamespace = "http://www.bpc.ru/sv2/authorization", partName = "Id")
        ReloadRequest id);

}
