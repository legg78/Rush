/**
 * @brief Script file with patches to external code for Interner Explorer browser.
 *        Is called at the top of pages that extend base page.
 */

if (jQuery.browser.msie) {
    /**
     * @bug The line in AJAX request "LOG.debug("Hidden JSF state fields: " + Q);" causes IE
     *      to fail with error "Object doesn't support this property or method".
     * @fix Redefine 'processResponse' commenting "+Q" part to prevent such behavior.
     */
    A4J.AJAX.processResponse = function (A) {
        A4J.AJAX.TestScriptEvaluation();
        var E = A.options;
        var T = A.getResponseHeader("Ajax-Response");
        var R = A.getResponseHeader("Ajax-Expired");
        if (R && typeof(A4J.AJAX.onExpired) == "function") {
            var I = A4J.AJAX.onExpired(window.location, R);
            if (I) {
                window.location = I;
                return
            }
        }
        if (T != "true") {
            LOG.warn("No ajax response header ");
            var I = A.getResponseHeader("Location");
            try {
                if (T == "redirect" && I) {
                    window.location = I
                } else {
                    if (T == "reload") {
                        window.location.reload(true)
                    } else {
                        A4J.AJAX.replacePage(A)
                    }
                }
            } catch(O) {
                LOG.error("Error redirect to new location ")
            }
        } else {
            if (A.getParserStatus() == Sarissa.PARSED_OK) {
                if (E.onbeforedomupdate || E.queueonbeforedomupdate) {
                    var M = A.domEvt;
                    var S = A.getJSON("_ajax:data");
                    LOG.debug("Call local onbeforedomupdate function before replacing elemements");
                    if (E.onbeforedomupdate) {
                        E.onbeforedomupdate(A, M, S)
                    }
                    if (E.queueonbeforedomupdate) {
                        E.queueonbeforedomupdate(A, M, S)
                    }
                }
                var B = A.getResponseHeader("Ajax-Update-Ids");
                var L;
                var G = function(){
                    if (A4J.AJAX.headElementsCounter != 0) {
                        LOG.debug("Script " + A4J.AJAX.headElementsCounter + " was loaded");
                        --A4J.AJAX.headElementsCounter
                    }
                    if (A4J.AJAX.headElementsCounter == 0) {
                        A4J.AJAX.processResponseAfterUpdateHeadElements(A, L)
                    }
                };
                if (E.affected) {
                    L = E.affected;
                    A.appendNewHeadElements(G)
                } else {
                    if (B && B != "") {
                        LOG.debug("Update page by list of rendered areas from response " + B);
                        L = B.split(",");
                        A.appendNewHeadElements(G)
                    } else {
                        LOG.warn("No information in response about elements to replace");
                        A.doFinish()
                    }
                }
                var Q = A.getElementById("ajax-view-state");
                LOG.debug("Hidden JSF state fields: ");/* + Q);*/
                if (Q != null) {
                    var J = E.parameters["org.ajax4jsf.portlet.NAMESPACE"];
                    LOG.debug("Namespace for hidden view-state input fields is " + J);
                    var H = J ? window.document.getElementById(J) : window.document;
                    var C = H.getElementsByTagName("input");
                    try {
                        var N = A.getElementsByTagName("input", Q);
                        A4J.AJAX.replaceViewState(C, N)
                    } catch(O) {
                        LOG.warn("No elements 'input' in response")
                    }
                    try {
                        var N=A.getElementsByTagName("INPUT", Q);
                        A4J.AJAX.replaceViewState(C, N)
                    } catch(O) {
                        LOG.warn("No elements 'INPUT' in response")
                    }
                }
                for(var K = 0; K < A4J.AJAX._listeners.length; K++) {
                    var F = A4J.AJAX._listeners[K];
                    if (F.onafterajax) {
                        var S = A.getJSON("_ajax:data");
                        F.onafterajax(A, A.domEvt, S)
                    }
                }
                var P = A.getJSON("_A4J.AJAX.focus");
                if (P) {
                    LOG.debug("focus must be set to control " + P);
                    var D = false;
                    if (A.form) {
                        D = A.form.elements[P]
                    }
                    if (!D) {
                        LOG.debug("No control element " + P + " in submitted form");
                        D = document.getElementById(P)
                    }
                    if (D) {
                        LOG.debug("Set focus to control ");
                        D.focus();
                        if (D.select) {
                            D.select()
                        }
                    } else {
                        LOG.warn("Element for set focus not found")
                    }
                } else {
                    LOG.debug("No focus information in response")
                }
            } else {
                LOG.error("Error parsing XML");
                LOG.error("Parse Error: "+A.getParserStatus())
            }
        }
    };

    /**
     * @bug The line in AJAX request "A = Richfaces.findModalPanel(E)" causes IE to fail
     *      with error "Unable to get the property 'component' link, which is not defined or is NULL".
     * @fix Redefine 'showModalPanel' forbidding output of modal panel for awaiting object.
     */
    Richfaces.showModalPanel = function (E, D, C) {
        var B = (Richfaces.browser.isIE || Richfaces.browser.isSafari) ? function (H) {
            if (document.readyState != "complete") {
                var G = arguments;
                var F = this;
                window.setTimeout(function(){ G.callee.apply(F, G) }, 50)
            } else {
                H()
            }
        } : function (F) {
            F()
        };
        if (E != "wait" ) {
            var A = $(E);
            if (!A) {
                A = Richfaces.findModalPanel(E)
            }
            B(function () { A.component.show(C, D) })
        }
    };
}