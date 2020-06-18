/**
 * Class responsible for serializing all the data for sending to the eSign API.
 */
public class MuleSoftESignRequestSerializer {

    public Map<String, Object> serializeSendCeremonyRequest(ESignSendCeremonyRequest request) {
        List<Map<String, Object>> customFieldData = new List<Map<String, Object>>();
        if (request.ceremony.customFields != null) {
            for (ESignCustomField customField : request.ceremony.customFields) {
                customFieldData.add(this.serializeCustomField(customField));
            }
        }

        Map<String, Object> jsonRequest = new Map<String, Object>();
        jsonRequest.put('ceremony', this.serializeCeremony(request.ceremony));
        jsonRequest.put('custom_fields', customFieldData);

        return jsonRequest;
    }

    public Map<String, Object> serializeCeremony(ESignCeremony ceremony) {
        List<Map<String, Object>> templateData = new List<Map<String, Object>>();
        if (ceremony.templates != null) {
            for (ESignTemplate template : ceremony.templates) {
                templateData.add(this.serializeTemplate(template));
            }
        }

        Map<String, Object> jsonCeremony = new Map<String, Object>();
        jsonCeremony.put('subject', ceremony.subject);
        jsonCeremony.put('templates', templateData);

        return jsonCeremony;
    }

    public Map<String, Object> serializeTemplate(ESignTemplate template) {
        List<Map<String, Object>> recipientData = new List<Map<String, Object>>();
        for (ESignRecipient recipient : template.recipients) {
            recipientData.add(this.serializeRecipient(recipient));
        }

        Map<String, Object> jsonTemplate = new Map<String, Object>();
        jsonTemplate.put('id', template.id);
        jsonTemplate.put('sequence', template.sequence);
        jsonTemplate.put('recipients', recipientData);

        return jsonTemplate;
    }

    public Map<String, Object> serializeCustomField(ESignCustomField customField) {
        Map<String, Object> jsonField = new Map<String, Object>();
        jsonField.put('key', customField.key);
        jsonField.put('value', customField.value);

        return jsonField;
    }

    public Map<String, Object> serializeRecipient(ESignRecipient recipient) {
        Map<String, Object> jsonRecipient = new Map<String, Object>();
        jsonRecipient.put('id', recipient.id);
        jsonRecipient.put('name', recipient.name);
        jsonRecipient.put('email', recipient.email);
        jsonRecipient.put('role', recipient.role);
        jsonRecipient.put('data', this.serializeESignData(recipient.data));

        return jsonRecipient;
    }

    public Map<String, Object> serializeESignData(ESignData data) {
        List<Map<String, Object>> jsonTextData = new List<Map<String, Object>>();
        if (data.textData != null) {
            for (ESignData.ESignTextData textData : data.textData) {
                jsonTextData.add(this.serializeTextData(textData));
            }
        }

        List<Map<String, Object>> jsonRadioData = new List<Map<String, Object>>();
        if (data.radioData != null) {
            for (ESignData.ESignSelectData selectData : data.radioData) {
                jsonRadioData.add(this.serializeRadioData(selectData));
            }
        }

        List<Map<String, Object>> jsonCheckData = new List<Map<String, Object>>();
        if (data.checkData != null) {
            for (ESignData.ESignSelectData selectData : data.checkData) {
                jsonCheckData.add(this.serializeCheckData(selectData));
            }
        }

        List<Map<String, Object>> jsonListData = new List<Map<String, Object>>();
        if (data.listData != null) {
            for (ESignData.ESignSelectData selectData : data.listData) {
                jsonListData.add(this.serializeListData(selectData));
            }
        }

        Map<String, Object> jsonData = new Map<String, Object>();
        jsonData.put('text', jsonTextData);
        jsonData.put('radio', jsonRadiodata);
        jsonData.put('check', jsonCheckData);
        jsonData.put('list', jsonListData);

        return jsonData;
    }

    public Map<String, Object> serializeRadioData(ESignData.ESignSelectData selectData) {
        Map<String, Object> jsonValue = new Map<String, Object>();
        jsonValue.put('key', selectData.key);
        jsonValue.put('value', String.valueOf(selectData.selected));

        List<Map<String, Object>> jsonValues = new List<Map<String, Object>>();
		jsonValues.add(jsonValue);

        Map<String, Object> jsonSelect = new Map<String, Object>();
        jsonSelect.put('group_name', selectData.groupName);
        jsonSelect.put('values', jsonValues);

        return jsonSelect;
    }

    public Map<String, Object> serializeCheckData(ESignData.ESignSelectData selectData) {
        Map<String, Object> data = new Map<String, Object>();
        data.put('key', selectData.key);
        data.put('value', String.valueOf(selectData.selected));

        Map<String, Object> jsonCheck = new Map<String, Object>();
        jsonCheck.put('group_name', selectData.groupName);
        jsonCheck.put('data', data);

        return jsonCheck;
    }

    public Map<String, Object> serializeListData(ESignData.ESignSelectData selectData) {
        Map<String, Object> jsonValue = new Map<String, Object>();
        jsonValue.put('key', selectData.key);
        jsonValue.put('value', String.valueOf(selectData.selected));

        List<Map<String, Object>> jsonValues = new List<Map<String, Object>>();
		jsonValues.add(jsonValue);

        Map<String, Object> jsonSelect = new Map<String, Object>();
        jsonSelect.put('group_name', selectData.groupName);
        jsonSelect.put('values', jsonValues);

        return jsonSelect;
    }

    public Map<String, Object> serializeTextData(ESignData.ESignTextData textData) {
        Map<String, Object> jsonText = new Map<String, Object>();
        jsonText.put('key', textData.key);
        jsonText.put('value', textData.value);

        return jsonText;
    }
}