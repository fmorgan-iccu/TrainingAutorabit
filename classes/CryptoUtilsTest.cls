@isTest
private without sharing class CryptoUtilsTest {

    @IsTest
    private static void testHappyPath() {
        Blob key = CryptoUtils.createUserEncryptionKey();
        System.assert(key != null);

        final String value = 'encrypt me';
        String encryptedValue = CryptoUtils.encrypt(value);
        System.assertNotEquals(value, encryptedValue);

        Blob blobValue = Blob.valueOf(value);
        String encryptedValue2 = CryptoUtils.encrypt(blobValue);
        System.assertNotEquals(value, encryptedValue2);

        String nullValue = null;
        String encryptedValue3 = CryptoUtils.encrypt(nullValue);
        System.assertEquals(null, encryptedValue3);
        
        Blob blobNullValue = null;
        String encryptedValue4 = CryptoUtils.encrypt(blobNullValue);
        System.assertEquals(null, encryptedValue4);

        String decryptedValue = CryptoUtils.decrypt(encryptedValue);
        System.assertEquals(value, decryptedValue);

        String decryptedValue2 = CryptoUtils.decrypt(encryptedValue2);
        System.assertEquals(value, decryptedValue2);
    }

}