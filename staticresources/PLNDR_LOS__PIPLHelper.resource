window.PIPLHelper = (function () {
    return {
        onCallback : function (a, component) {
            if (component != null) {
                component.set("v.loading",false);
            }
            var state = a.getState();
            if (state === "SUCCESS") {
                console.log("success");
                var url = a.getReturnValue();
                window.open(url,'_blank','location=yes,height=900,width=1440,scrollbars=yes,status=yes');
            }
            else if (state == "ERROR") {
                var errors = a.getError();
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        console.log(errors[0].message);
                        $A.log(a.getError());
                        alert("An error occurred: " + errors[0].message);
                    }
                }
            }
        }
    };
}());