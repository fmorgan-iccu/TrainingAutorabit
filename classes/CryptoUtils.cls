public with sharing class CryptoUtils {

    public static String encrypt(String value) {
        if (value == null) {
            return null;
        }

        Blob blobValue = Blob.valueOf(value);
        String encryptedValue = CryptoUtils.encrypt(blobValue);

        return encryptedValue;
    }

    public static String encrypt(Blob value) {
        if (value == null) {
            return null;
        }

        Blob key = CryptoUtils.createUserEncryptionKey();
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', key , value);
        String encryptedValue = EncodingUtil.base64Encode(encryptedData);

        return encryptedValue;
    }

    public static String decrypt(String encryptedValue) {
        Blob key = CryptoUtils.createUserEncryptionKey();
        Blob valueData = EncodingUtil.base64Decode(encryptedValue);
        Blob decryptedData = Crypto.decryptWithManagedIV('AES128', key , valueData);
        String value = decryptedData.toString();

        return value;
    }
    
    /**
     * Generates a user specific key that can be used in calls to Crypto encryption functions
     * (e.g. Crypto.encryptWithManagedIV).
     */
    @TestVisible
    private static Blob createUserEncryptionKey() {
        integer maxLength = 16; // The key MUST be 16 bytes.
        String userId = CryptoUtils.getUserId();

        if (userId.length() > maxLength) {
            userId = userId.subString(0, 16);
        } else if (userId.length() < maxLength) {
            for (integer i = 0; i < maxLength - userId.length(); i++) {
                userId = userId + 'X';
            }
        }

        Blob key = Blob.valueOf(userId);
        return key;
    }

    private static String getUserId() {
        String userId = UserInfo.getUserId() + '_ICCU';
        return userId;
    }

}