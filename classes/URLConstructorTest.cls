@isTest
private class URLConstructorTest {
	@isTest
    private static void testHappyPath() {
        List<URLQueryItem> items = new List<URLQueryItem>();
        items.add(new URLQueryItem('foo', 'true'));
        items.add(new URLQueryItem('bar', '%test%'));
        
        String endpoint = 'https://iccu.com/';

        URLConstructor queryConstructor = new URLConstructor(endpoint, items);
        String queryURL = queryConstructor.constructURL();
        
        String queryExpected = 'https://iccu.com/?foo=true&bar=%25test%25';
        
        System.assert(queryURL.equals(queryExpected), 'URL was: ' + queryURL);
        System.assert(endpoint.equals(queryConstructor.getEndpoint()));
        System.assert(items == queryConstructor.getQueryItems());
        
        URLConstructor noQueryConstructor = new URLConstructor(endpoint, null);
        String noQueryURL = noQueryConstructor.constructURL();
        System.assert(endpoint.equals(noQueryURL), 'URL was: ' + noQueryURL);
    }
    
    @isTest
    private static void testUnhappyPath() {
        URLConstructor nullConstructor = new URLConstructor(null, null);
        String nullURL = nullConstructor.constructURL();
        
        System.assert(nullURL == null);
        
        List<URLQueryItem> items = new List<URLQueryItem>();
        items.add(new URLQueryItem('foo', 'true'));
        items.add(new URLQueryItem('bar', null));
        
        String endpoint = 'https://iccu.com/';
        
        URLConstructor queryConstructor = new URLConstructor(endpoint, items);
        String queryURL = queryConstructor.constructURL();
        
        String queryExpected = 'https://iccu.com/?foo=true';
		System.assert(queryExpected.equals(queryURL));
    }
}