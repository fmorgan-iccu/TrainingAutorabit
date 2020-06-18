@IsTest
private class MuleSoftESignRequestSerializerTest {

    private static ESignSendCeremonyRequest getRequest() {
        ESignSendCeremonyRequest request = new ESignSendCeremonyRequest(MuleSoftESignRequestSerializerTest.getCeremony());

        return request;
    }

    private static ESignCeremony getCeremony() {
        String subject = 'subject';
        List<ESignTemplate> templates = new List<ESignTemplate>();
        templates.add(MuleSoftESignRequestSerializerTest.getTemplate());

        List<ESignCustomField> customFields = new List<ESignCustomField>();
        customFields.add(MuleSoftESignRequestSerializerTest.getCustomField());

        ESignCeremony ceremony = new ESignCeremony(subject, templates, customFields);

        return ceremony;
    }

    private static ESignTemplate getTemplate() {
        // ESignTemplate(String id, Integer sequence, List<ESignRecipient> recipients)

        String id = 'idkfj';
        Integer sequence = 1;
        List<ESignRecipient> recipients = new List<ESignRecipient>();
        recipients.add(MuleSoftESignRequestSerializerTest.getRecipient());

        ESignTemplate template = new ESignTemplate(id, sequence, recipients);

        return template;
    }

    private static ESignCustomField getCustomField() {
        return new ESignCustomField('key', 'value');
    }

    private static ESignRecipient getRecipient() {
        String id = 'idspispopd';
        String name = 'John Smith';
        String email = 'jsmith@iccu.com';
        String role = 'Bard';
        ESignData data = MuleSoftESignRequestSerializerTest.getData();

        ESignRecipient recipient = new ESignRecipient(id, name, email, role, data);

        return recipient;
    }

    private static ESignData getData() {
        List<ESignData.ESignTextData> textList = new List<ESignData.ESignTextData>();
        textList.add(MuleSoftESignRequestSerializerTest.getTextData());

        List<ESignData.ESignSelectData> radioList = new List<ESignData.ESignSelectData>();
		radioList.add(MuleSoftESignRequestSerializerTest.getRadioData());

        List<ESignData.ESignSelectData> checkList = new List<ESignData.ESignSelectData>();
        checkList.add(MuleSoftESignRequestSerializerTest.getCheckData());


        ESignData data = new ESignData(textList, radioList, checkList);

        return data;
    }

    private static ESignData.ESignSelectData getRadioData() {
        ESignData.ESignSelectData checkData = new ESignData.ESignSelectData('check group', 'check', true);
        return checkData;
    }

    private static ESignData.ESignSelectData getCheckData() {
        ESignData.ESignSelectData checkData = new ESignData.ESignSelectData('radio group', 'radio', true);
        return checkData;
    }

    private static ESignData.ESignTextData getTextData() {
        ESignData.ESignTextData textData = new ESignData.ESignTextData('key', 'value');
        return textData;
    }

    @IsTest
    private static void testSerializeSendCeremonyRequest() {
        ESignSendCeremonyRequest request = MuleSoftESignRequestSerializerTest.getRequest();

        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();
        Map<String, Object> serialized = serializer.serializeSendCeremonyRequest(request);
        System.assert(serialized != null);

        Map<String, Object> serializedCeremony = (Map<String, Object>)serialized.get('ceremony');
        System.assert(serializedCeremony != null);

        List<Map<String, Object>> serializedCustomFields = (List<Map<String, Object>>)serialized.get('custom_fields');
        System.assert(serializedCustomFields != null);

        Map<String, Object> serializedCustomField = serializedCustomFields.get(0);
        System.assert(serializedCustomField.get('key') != null);
        System.assert(serializedCustomField.get('value') != null);
    }

    @IsTest
    private static void testSerializeCeremony() {
        ESignCeremony ceremony = MuleSoftESignRequestSerializerTest.getCeremony();

        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        Map<String, Object> serialized = serializer.serializeCeremony(ceremony);

        System.assert(serialized != null);
        System.assertEquals(serialized.get('subject'), ceremony.subject);

        List<Map<String, Object>> serializedTemplates = (List<Map<String, Object>>)serialized.get('templates');
        System.assert(serializedTemplates != null);
        System.assert(serializedTemplates.size() == 1);

        Map<String, Object> serializedTemplate = serializedTemplates.get(0);
        System.assert(serializedTemplate.get('id') != null);
        System.assert(serializedTemplate.get('sequence') != null);
        System.assert(serializedTemplate.get('recipients') != null);
    }

    @IsTest
    private static void testSerializeTemplate() {
        ESignTemplate template = MuleSoftESignRequestSerializerTest.getTemplate();

        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        Map<String, Object> serialized = serializer.serializeTemplate(template);

        System.assert(serialized != null);
        System.assertEquals(serialized.get('id'), template.id);
        System.assertEquals(serialized.get('sequence'), template.sequence);

        List<Map<String, Object>> serializedRecipients = (List<Map<String, Object>>)serialized.get('recipients');
        System.assert(serializedRecipients != null);
        System.assert(serializedRecipients.size() == 1);

        Map<String, Object> serializedRecipient = serializedRecipients.get(0);
        System.assert(serializedRecipient.get('id') != null);
        System.assert(serializedRecipient.get('name') != null);
        System.assert(serializedRecipient.get('email') != null);
        System.assert(serializedRecipient.get('role') != null);
        System.assert(serializedRecipient.get('data') != null);
    }

    @IsTest
    private static void testSerializeCustomField() {
        ESignCustomField customField = MuleSoftESignRequestSerializerTest.getCustomField();

        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        Map<String, Object> serialized = serializer.serializeCustomField(customField);

        System.assert(serialized != null);
        System.assertEquals(serialized.get('key'), customField.key);
        System.assertEquals(serialized.get('value'), customField.value);
    }

    @IsTest
    private static void testSerializeRecipient() {
        ESignRecipient recipient = MuleSoftESignRequestSerializerTest.getRecipient();

        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        Map<String, Object> serialized = serializer.serializeRecipient(recipient);
        System.assert(serialized != null);

        System.assertEquals(serialized.get('id'), recipient.id);
        System.assertEquals(serialized.get('name'), recipient.name);
        System.assertEquals(serialized.get('email'), recipient.email);
        System.assertEquals(serialized.get('role'), recipient.role);

        // Only going to check for the keys, since this data is tested elsewhere...
        Map<String, Object> serializedData = (Map<String, Object>)serialized.get('data');
        System.assert(serializedData != null);
        System.assert(serializedData.get('text') != null);
        System.assert(serializedData.get('radio') != null);
        System.assert(serializedData.get('check') != null);
    }

    @IsTest
    private static void testSerializeData() {
        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        ESignData data = MuleSoftESignRequestSerializerTest.getData();
        Map<String, Object> serialized = serializer.serializeESignData(data);

        System.assert(serialized != null);

        /* Text Data */
        List<Map<String, Object>> serializedTextList = (List<Map<String, Object>>)serialized.get('text');
        System.assert(serializedTextList != null);
        System.assert(serializedTextList.size() == 1);

        ESignData.ESignTextData textData = data.textData.get(0);
        Map<String, Object> serializedText = serializedTextList.get(0);
        System.assertEquals(serializedText.get('key'), textData.key);
        System.assertEquals(serializedText.get('value'), textData.value);

        /* Radio Data */
        List<Map<String, Object>> serializedRadioList = (List<Map<String, Object>>)serialized.get('radio');
        System.assert(serializedRadioList != null);
        System.assert(serializedRadioList.size() == 1);

        ESignData.ESignSelectData radioData = data.radioData.get(0);
        Map<String, Object> serializedRadio = serializedRadioList.get(0);

        System.assertEquals(serializedRadio.get('group_name'), radioData.groupName);

        List<Map<String, Object>> radioList = (List<Map<String, Object>>)serializedRadio.get('values');
        System.assert(radioList != null);
        System.assert(radioList.size() == 1);

        Map<String, Object> serializedRadioData = radioList.get(0);
        System.assertEquals(serializedRadioData.get('key'), radioData.key);
        System.assertEquals(Boolean.valueOf(serializedRadioData.get('value')), radioData.selected);


        /* Check Data */
        List<Map<String, Object>> serializedCheckList = (List<Map<String, Object>>)serialized.get('check');
        System.assert(serializedCheckList != null);
        System.assert(serializedCheckList.size() == 1);

        ESignData.ESignSelectData checkData = data.checkData.get(0);
        Map<String, Object> serializedCheck = serializedCheckList.get(0);

        System.assert(serializedCheck != null);
        System.assertEquals(serializedCheck.get('group_name'), checkData.groupName);

        Map<String, Object> serializedCheckData = (Map<String, Object>)serializedCheck.get('data');
        System.assert(serializedCheckData != null);
        System.assertEquals(serializedCheckData.get('key'), checkData.key);
        System.assertEquals(Boolean.valueOf(serializedCheckData.get('value')), checkData.selected);
    }

    @IsTest
    private static void testSerializeDataUnhappy() {
        // Checks for that the data lists are there and not null, as well as that they do not throw NPEs
        ESignData data = new ESignData(null, null, null);

        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        Map<String, Object> serialized = serializer.serializeESignData(data);
        System.assert(serialized != null);

        List<Map<String, Object>> serializedTextList = (List<Map<String, Object>>)serialized.get('text');
        List<Map<String, Object>> serializedRadioList = (List<Map<String, Object>>)serialized.get('radio');
        List<Map<String, Object>> serializedCheckList = (List<Map<String, Object>>)serialized.get('check');

        System.assert(serializedTextList != null);
        System.assert(serializedTextList.size() == 0);

        System.assert(serializedRadioList != null);
        System.assert(serializedRadioList.size() == 0);

        System.assert(serializedCheckList != null);
        System.assert(serializedCheckList.size() == 0);
    }

    @IsTest
    private static void testSerializeRadioData() {
        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        ESignData.ESignSelectData selectData = MuleSoftESignRequestSerializerTest.getCheckData();
        Map<String, Object> serialized = serializer.serializeRadioData(selectData);

        System.assert(serialized != null);
        System.assertEquals(serialized.get('group_name'), selectData.groupName);

        List<Map<String, Object>> serializedDataList = (List<Map<String, Object>>)serialized.get('values');
        System.assert(serializedDataList != null);
        System.assert(serializedDataList.size() == 1);

        Map<String, Object> serializedData = serializedDataList.get(0);
        System.assertEquals(serializedData.get('key'), selectData.key);
        System.assertEquals(Boolean.valueOf(serializedData.get('value')), selectData.selected);
    }

    @IsTest
    private static void testSerializeCheckData() {
        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        ESignData.ESignSelectData selectData = MuleSoftESignRequestSerializerTest.getCheckData();
        Map<String, Object> serialized = serializer.serializeCheckData(selectData);

        System.assert(serialized != null);
        System.assertEquals(serialized.get('group_name'), selectData.groupName);

        Map<String, Object> serializedData = (Map<String, Object>)serialized.get('data');
        System.assert(serializedData != null);
        System.assertEquals(serializedData.get('key'), selectData.key);
        System.assertEquals(Boolean.valueOf(serializedData.get('value')), selectData.selected);
    }

	@IsTest
    private static void testSerializeTextData() {
        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        ESignData.ESignTextData textData = MuleSoftESignRequestSerializerTest.getTextData();
        Map<String, Object> serialized = serializer.serializeTextData(textData);
        System.assert(serialized != null);
        System.assertEquals(serialized.get('key'), textData.key);
        System.assertEquals(serialized.get('value'), textData.value);
    }

    @IsTest
    private static void testSerializeListData() {
        MuleSoftESignRequestSerializer serializer = new MuleSoftESignRequestSerializer();

        ESignData.ESignSelectData selectData = MuleSoftESignRequestSerializerTest.getRadioData();
        Map<String, Object> serialized = serializer.serializeListData(selectData);

        System.assert(serialized != null);
        System.assertEquals(serialized.get('group_name'), selectData.groupName);

        List<Map<String, Object>> serializedDataList = (List<Map<String, Object>>)serialized.get('values');
        System.assert(serializedDataList != null);
        System.assert(serializedDataList.size() == 1);

        Map<String, Object> serializedData = serializedDataList.get(0);
        System.assertEquals(serializedData.get('key'), selectData.key);
        System.assertEquals(Boolean.valueOf(serializedData.get('value')), selectData.selected);
    }
}