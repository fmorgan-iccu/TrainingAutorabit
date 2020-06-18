public with sharing class AORestHelper {

    public static Date parseDateString(String dateString) {
        Date d = !String.isBlank(dateString) ? Date.valueOf(dateString) : null;
        return d;
    }

    /**
     * NOTE:  Zippex doesn't actually compress the zip file and instead stores data as-is.  The name of this function
     * is a misnomer.
     */
    public static String compressRequest(String requestBody) {
        Blob payload = Blob.valueOf(requestBody);
        Zippex zip = new Zippex();
        zip.addFile('payload.json', payload, null);
        Blob zipData = zip.getZipArchive();
        String encodedData = EncodingUtil.base64Encode(zipData);
        return encodedData;
    }

    public static String decompressRequest(String requestBody) {
        Blob zipBlob = EncodingUtil.base64Decode(requestBody);
        Zippex myZip = new Zippex(zipBlob);
        Set<String> fileNames = myZip.getFileNames();
        if (!fileNames.contains('payload.json')) {
            return null;
        }
        Blob fileData = myZip.getFile('payload.json');
        return fileData.toString();
    }

    public static String getRequestBody() {
        RestRequest req = RestContext.request;
        String requestBody = req.requestBody.toString();
        if (requestBody.left(1) != '{' && requestBody.right(1) != '}') {
            requestBody = AORestHelper.decompressRequest(requestBody);
        }
        return requestBody;
    }

    public static AOApplicationRestRequest parseRequestBody() {
        String requestBody = AORestHelper.getRequestBody();
        AOApplicationRestRequest request = AOApplicationRestRequest.parse(requestBody);
        return request;
    }

}