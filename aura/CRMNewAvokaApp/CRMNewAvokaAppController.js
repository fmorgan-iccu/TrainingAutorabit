({
    doInit: function(component, event, helper) {
        var action = component.get('c.fetchAvailableProducts');      
        $A.enqueueAction(action);
    },
    
    closeModal: function(component, event, helper) {
        component.find("overlayLib").notifyClose();
    },
    
    fetchAvailableProducts: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.errorMessage', '');
        
        var action = component.get("c.getAvailableProducts");
        action.setCallback(this, function(response) {
			component.set('v.isLoading', false);
            
            var showError = function(error) {
                console.log(error);
                component.set('v.errorMessage', error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var categories = responseData.categories;
                var products = responseData.products;
                var error = responseData.error;

                if (error) {
                    showError(error);
                    return;
                }

                if (!categories || !products) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }
                
                var categoryValues = [];
                
                // Some categories might not have products associated with them.  We're going to filter out the categories that do not.
                categories.forEach(function (category) {
                    var categoryId = category.id;
                    var hasProducts = false;
                    
                    products.forEach(function (product) {
                        product.id = product.majorTypeCode + '_' + product.minorTypeCode;

                        if (product.categoryId === categoryId) {
                            hasProducts = true;
                        }
                    });

                    if (hasProducts) {
                        categoryValues.push({
                            label: category.displayName,
                            value: category.id
                        });
                    }
                });
                
                categories.sort(function (a, b){
                    var x = a.order;
                    var y = b.order;
                    if (x < y) {
                        return -1;
                    }

                    if (x > y) {
                        return 1;
                    }
                    
                    return 0;
                });

                component.set('v.categories', categories);
                component.set('v.categoryValues', categoryValues);
                component.set('v.allProducts', products);
            } else {
                showError('There was a problem obtaining the available products.');
            }
        });

        action.setBackground();
        $A.enqueueAction(action);
    },
    
    selectCategory: function(component, event, helper) {
        
        var selectedValue = event.getSource().get("v.value")
        var selectedCategory = null;
        var categories = component.get('v.categories');
        categories.forEach(function (category) {
            if (category.id === selectedValue) {
                selectedCategory = category;
            };
        });

        var filteredProducts = [];
        var products = component.get('v.allProducts');
        products.forEach(function (product) {
            if (product.categoryId === selectedCategory.id) {
                filteredProducts.push(product);
            }
        });

        component.set('v.filteredProducts', filteredProducts);
    },
    
    selectProduct: function(component, event, helper) {
        var productId = event.getSource().get("v.value")
        var selectedProduct = null;
        
        var products = component.get('v.filteredProducts');
        products.forEach(function (product) {
            if (productId === product.id) {
                selectedProduct = product;
            }
        });

        component.set('v.enableSubmit', true);
        component.set('v.selectedProduct', selectedProduct);
    },
    
    submitNewApp: function(component, event, helper) {
        component.set('v.isLoading', true);
        component.set('v.errorMessage', '');
        
        var action = component.get("c.submitPrefilledApplication");
        var contactId = component.get("v.recordId");
        var product = component.get("v.selectedProduct");
        
        action.setParams({
            "contactId": contactId,
            "productMap" : product
        });

        action.setCallback(this, function(response) {
			component.set('v.isLoading', false);
            
            var showError = function(error) {
                console.log(error);
                component.set('v.errorMessage', error);
            }

            if (component.isValid() && response.getState() === "SUCCESS") {
                var responseData = response.getReturnValue();
                var prefillURL = responseData.prefillURL;
                var error = responseData.error;

                if (error) {
                    showError(error);
                    return;
                }

                if (!prefillURL) {
                    showError('An unknown error occured.  Please try again later.');
                    return;
                }

                component.set('v.prefillURL', prefillURL);
            }
        });

        action.setBackground();
        $A.enqueueAction(action);
    }
})