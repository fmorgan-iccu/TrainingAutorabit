public class AOExperianPreciseIDReportParser extends AOReportParser {

    private static final Map<String, String> fraudShieldCodes = new Map<String, String>{
        '01' => 'Inquiry/On-file Current Address Conflict',
        '02' => 'Inquiry Address First Reported > 90 Days',
        '03' => 'Inquiry Current Address Not On-file',
        '04' => 'Input SSN Issue Date Cannot Be Verified',
        '05' => 'Inquiry SSN Recorded As Deceased',
        '06' => 'Inquiry Age Younger Than SSN Issue Date',
        '07' => 'Credit Established Before Age 18',
        '08' => 'Creidt Established Prior To SSN Issue Date',
        '09' => 'More Than 3 Inquiries In Last 30 Days',
        '10' => 'Inquiry Address: Alert',
        '11' => 'Inquiry Address: Non-Residential',
        '13' => 'High Probability SSN Belongs To Another',
        '14' => 'Inquiry SSN Format Is Invalid',
        '15' => 'Inquiry Address: Cautious',
        '16' => 'On-File Address: Alert',
        '17' => 'On-File Address: Non-Residential',
        '18' => 'On-File Address: Cautious',
        '19' => 'Current Address Rpt By New Trade',
        '20' => 'Current Address Rpt By Trade Open < 90 Days',
        '21' => 'Telephone Number Inconsistent w/ Address',
        '25' => 'Best On-File SSN Recorded As Deceased',
        '26' => 'Best On-File SSN Issue Date Cannot Be Verified',
        '27' => 'SSN reported More Frequently For Another'
    };
    
    private static final Map<String, String> ofacCodes = new Map<String, String> {
        ''   => 'Not supplied',
        '1'  => 'No match',
        '2'  => 'Match to full name only',
        '3'  => 'Match to SSN only',
        '4'  => 'Match to name and SSN',
        '5'  => 'Match to name and DOB',
        '6'  => 'Match to name and YOB',
        '7'  => 'Match SSN and DOB',
        '8'  => 'Match to SSN and YOB',
        '9'  => 'Match to name, SSN, and DOB',
        '10' => 'Match name, SSN, and YOB',
        '11' => 'Match to company name only',
        '12' => 'Match to company address only',
        '13' => 'Match company name and address',
        '14' => 'Match to surname and first name',
        '15' => 'Match to full name only -- PLC NS list',
        '16' => 'Match to surname and first initial -- PLC NS list'
    };
    
    private static final Map<String, String> dobCodes = new Map<String, String> {
        '1'  => 'Match',
        '2'  => 'Partial match',
        '3'  => 'No Match',
        '4'  => 'Not on file',
        '5'  => 'SSN not on-file; search cannot be performed',
        '6'  => 'DOB not provided on search request',
        '7'  => 'Invalid DOB format',
        '8'  => 'YOB only exact match (no +/- 1 year logic accomodation)',
        '9'  => 'DOB and MOB exact match, YOB exact match (no +/- 1 year logic accomodation)',
        'A'  => 'MOB exact match, YOB partial match (+/- 1 year logic accomodation)',
        'B'  => 'MON exact match, YOB exact match (no +/- 1 year logic accomodation)',
        'C'  => 'MOB exact match, YOB +/- 10 years exactly',
        'D'  => 'MOB exact match, YOB +/- years exactly',
        'E'  => 'DOB and MOB eact match, no YOB match',
        'F'  => 'DOB and MOB swapped, YOB exact match ',
        'G'  => 'YOB exact match, full DOB provided ',
        ''   => 'DOB not provided on inquiry'
    };
        
    private static final Map<String, String> pidReasonCodes = new Map<String,String> {
        'A101' => 'Low level of validation',
        'A102' => 'Lack of trade line history or no record found',
        'A103' => 'Insufficient credit history',
        'A104' => 'Insufficient length of credit history',
        'A105' => 'Lack of open bankcard trades',
        'A106' => 'Lack of open bank installment trades',
        'A107' => 'Lack of installment trades',
        'A108' => 'Number of real property trades',
        'A109' => 'Number of open revolving trades',
        'A201' => 'Low level of verification',
        'A202' => 'Presence of high fraud risk FCRA verification indicators',
        'A203' => 'Presence of medium low fraud risk FCRA verification indicators',
        'A204' => 'Lack of new credit activity',
        'A205' => 'Too many recent credit checks in last 6 months',
        'A206' => 'Profile consists of high percent of bankcard trades',
        'A207' => 'Too many recently opened installment trades',
        'A208' => 'Lack of revolving trades or at or above credit limit on new revolving trades',
        'A301' => 'Too many recent credit checks in last 12 months',
        'A302' => 'Presence of delinquent or derogatory trades',
        'A303' => 'Presence of trades with past due balances',
        'A304' => 'No trades/too new to rate or presence of delinquency/derogatory on recently opened trades',
        'A305' => 'Currently delinquent or derogatory on recently opened trades',
        'A306' => 'Currently delinquent or derogatory on revolving trades',
        'A307' => 'Time since most recent delinquency or derogatory on revolving trades',
        'A308' => 'No qualified bankcard trades or no bankcard trades reported in last 6 months',
        'A309' => 'Presence of bankcard trades at or above credit limit',
        'A310' => 'Number of trades with high revolving credit utilization',
        'A311' => 'Lack of open revolving trades or lack of constant activity on revolving trades A401 Hit to OFAC',
        'A402' => 'Hit to NFD Low value',
        'A403' => 'Hit to NFD Medium value',
        'A404' => 'Hit to NFD High value',
        'A405' => 'No adverse factor observed',
        'A501' => 'Authentication Solutions system error',
        'A502' => 'Deceased',
        'A503' => 'Victim Statement found on file',
        'A601' => 'Non NFD Member',
        'A602' => 'NFD ‚Äì No record found',
        'A701' => 'Number of SSN hits in the last 3 months',
        'A702' => 'Number of Address hits',
        'A703' => 'Number of Address hits in the last 12 months',
        'A704' => 'Number of Phone hits in the last 3 months',
        'A705' => 'Number of Phone hits in the last 12 months',
        'A706' => 'Number of Bankcard SSN hits in the last 3 months',
        'A708' => 'Number of Bankcard Address hits in the last 12 months',
        'A709' => 'Number of Telecom Address hits in the last 12 months',
        'A710' => 'Number of Bankcard Phone hits in the last 3 months',
        'A711' => 'Number of Telecom Phone hits in the last 3 months',
        'B101' => 'Low level of authentication indicative of ID Fraud',
        'B104' => 'Insufficient length of credit history',
        'B105' => 'High credit limits and balances on revolving trades',
        'B106' => 'Presence of recently opened inquiry or too many inquiries in the last 6 months',
        'B107' => 'Too many bankcard or real property trades or no recently opened revolving trades',
        'B108' => 'A high number of bankcard, installment or real property trades never reported delinquent or derogatory indicative that file is susceptible to ID Fraud',
        'B109' => 'High average credit limit or loan amount on revolving/real property trades or credit balance to limit ratio on revolving trades',
        'B110' => 'Lack of public record information or collection trades indicative that file is susceptible to ID Fraud',
        'B111' => 'Lack of delinquency or derogs on installment and real property trades in the last 24 months indicative that file is susceptible to ID Fraud',
        'B112' => 'High ID fraud risk due to non-face-to-face application channel',
        'B113' => 'Presence of fraud record on the National Fraud Database',
        'B115' => 'Credit established before age 18',
        'B116' => 'More than 3 inquiries in the last 30 days',
        'B117' => 'Current address reported by recently opened trade only',
        'B118' => 'Current address reported by trade open < 90 days only',
        'B121' => 'First Payment never received on one or more trades',
        'B122' => 'Average age of revolving trades is too high indicative that file is susceptible of ID Fraud',
        'B201' => 'Low level of authentication indicative of First Party Fraud',
        'B204' => 'Insufficient length of credit history',
        'B205' => 'Recently opened revolving trade or limited history on revolving trade',
        'B207' => 'Too many trades with high revolving credit balance to limit ratio',
        'B209' => 'Number of consecutive months with balance activity on all revolving trades in the last 12 months is too short',
        'B210' => 'No revolving trades with high credit limits',
        'B212' => 'Presence of recently opened inquiry or too many inquiries in the last 24 months',
        'B213' => 'Too few trades',
        'B214' => 'Too many revolving trades opened in the last 24 months',
        'B217' => 'Too many trades with delinquencies',
        'B218' => 'Too many trades with high revolving credit balance to limit ratio',
        'B219' => 'Low credit limits or loan amounts indicative of First Party Fraud',
        'B220' => 'High revolving balance to limit ratio or low available credit on bankcard trades or low average balance on open trades',
        'B222' => 'No public record bankruptcy indicative of First Party Fraud',
        'B223' => 'Too many public record derogs or trades reported in collection status',
        'B225' => 'Credit established before age 18',
        'B226' => 'Current address reported by recently opened trade only',
        'B229' => 'First payment never received on one or more trades',
        'B230' => 'Current address reported by trade open < 90 days only',
        'B232' => 'Account condition code on credit profile is set to ‚Äúskip cannot locate‚Äù',
        'B399' => 'High risk due to lack of credit bureau data',
        'B405' => 'No adverse factor observed',
        'B501' => 'Authentication Solutions system error',
        'B502' => 'Deceased',
        'B503' => 'Victim Statement found on file',
        'B601' => 'Non-NFD member',
        'B602' => 'NFD ‚Äì no record found',
        'B701' => 'Number of SSN hits in the last 3 months',
        'B702' => 'Number of Address hits',
        'B703' => 'Number of Address hits in the last 12 months',
        'B704' => 'Number of Phone hits in the last 3 months',
        'B705' => 'Number of Phone hits in the last 12 months',
        'B706' => 'Number of Bankcard SSN hits in the last 3 months',
        'B707' => 'Number of Telecom SSN hits',
        'B708' => 'Number of Bankcard Address hits in the last 12 months',
        'B709' => 'Number of Telecom Address hits in the last 12 months',
        'B710' => 'Number of Bankcard Address hits in the last 3 months',
        'B711' => 'Number of Telecom Address hits in the last 3 months',
        '' => 'Not supplied'  
    };
    
    private static final Map<String, String> kbaCodes = new Map<String, String> {
        '1'    => 'Mortgage Lender ',
        '2'    => 'Mortgage Amount',
        '3'    => 'Auto Loan Lender',
        '4'    => 'Auto Loan Amount',
        '5'    => 'Student Loan Lender',
        '6'    => 'Student Loan Amount',
        '7'    => 'Previous Street Name',
        '8'    => 'Previous City Name',
        '9'    => 'Street City Name',
        '10'   => 'Last 4 Digits SSN',
        '11'   => 'SSN Issue State',
        '12'   => 'Year of Birth',
        '13'   => 'County of Residence',
        '20'   => 'Household Member',
        '21'   => 'Year Home Built',
        '22'   => 'Home Value',
        '23'   => 'Employer Name',
        '24'   => 'Profession',
        '25'   => 'Business Name',
        '26'   => 'Education',
        '27'   => 'Vehicle Make Model',
        '28'   => 'Vehicle Year',
        '29'   => 'Vehicle Color',
        '30'   => 'Vehicle License Plate',
        '31'   => 'Diversionary Mirror Address',
        '32'   => 'Diversionary Mirror Mortgage Lender',
        '33'   => 'Diversionary Mirror Mortgage Amount',
        '34'   => 'Diversionary Mirror Auto Loan Lender Name',
        '35'   => 'Diversionary Mirror Loan Amount',
        '36'   => 'Diversionary - People Living With',
        '37'   => 'Diversionary - Retail Credit Card Number',
        '38'   => 'Diversionary - Bank Name',
        '39'   => 'Diversionary - Previous Phone Number',
        '40'   => 'Term of Auto Loan',
        '41'   => 'Number of Bedrooms',
        '42'   => 'Zodiac Sign',
        '43'   => 'Birthstone',
        '44'   => 'Diversionary - Last 4 Digits Cell Phone Number',
        '45'   => 'Diversionary - Last 4 Digits Bank Account Number',
        '46'   => 'HELOC Lender Name',
        '47'   => 'Diversionary - HELOC Lender Name',
        '48'   => 'Credit Card Open Date',
        '49'   => 'Diversionary - High School Name',
        '50'   => 'Diversionary - Pet Name',
        '51'   => 'Auto loan Year',
        '52'   => 'Credit Card Limit',
        '53'   => 'Student Loan Open Date',
        '54'   => 'Phone Last 4 Digits',
        '55'   => 'Phone Area Code',
        '56'   => 'Current Phone Number',
        '57'   => 'Age in 5 Years',
        '58'   => 'Mortgage Loan Year',
        '101'  => 'Closed Mortgage Lender',
        '102'  => 'Closed Auto Loan Lender',
        '103'  => 'Closed Student Loan Lender',
        '104'  => 'Closed HELOC Lender Name',
        '301'  => 'NCX Dl Height',
        '302'  => 'NCX Dl Eye Color',
        '303'  => 'NCX Dl Prev State',
        '304'  => 'NCX Dl Number',
        '305'  => 'NCX Property Subdivision',
        '306'  => 'NCX Property Prev Owner',
        '307'  => 'NCX Property Sale Price',
        '308'  => 'NCX Property Second Owner',
        '309'  => 'NCX Property Sale Last Name',
        '310'  => 'NCX Associate Other Names',
        '311'  => 'NCX Associate Relative State',
        '312'  => 'NCX Associate Relative City',
        '313'  => 'NCX Associate Name',
        '314'  => 'NCX Trans Boat Manufacturer',
        '315'  => 'NCX Personal High School Year',
        '316'  => 'NCX Pro Licenses',
        '317'  => 'NCX Pro License Expires',
        '318'  => 'NCX Pro Concealed Weapon'
    };
        
    public override String getReportName() {
        return 'Experian Precise ID';
    }

    public override void parsePayload(Map<String,Object> payload, AOApplicationInfo appInfo) {
        try {
            if (payload == null || appInfo == null) {
                throw new IllegalArgumentException('Payload nor ApplicationInfo can be null.');
            }
            
            Map<String, Object> data = (Map<String, Object>)payload.get(RAW_DATA_KEY);

            if (data == null) {
                throw new IllegalArgumentException('Data was not present in the payload map.');
            }

            String[] path = 'clientResponsePayload'.split('/');
            Map<String, Object> responsePayload = APIUtils.walkTreeToValue(data, path);
            List<Object> decisionElements = (List<Object>)responsePayload.get('decisionElements');
            
            if (decisionElements == null || decisionElements.size() == 0) {
                throw new IllegalArgumentException('Decision elements in Precise ID payload was missing.');
            }

            Map<String, Object> decisionData = (Map<String, Object>)decisionElements[0];
            Map<String, Object> dobSection = this.createDataElement('Date of Birth', this.parseDOBMatch(decisionData));
            Map<String, Object> fraudShieldSection = this.createDataElement('Fraud Shield', this.parseFraudShield(decisionData));
            Map<String, Object> addressSection = this.createDataElement('Address Details', this.parseAddressDetails(decisionData));
            Map<String, Object> kiqSection = this.createDataElement('KIQ Details', this.parseKIQDetails(decisionData));
            Map<String, Object> ofacSection = this.createDataElement('OFAC', this.parseOFACDetails(decisionData));
            Map<String, Object> answerSection = this.createDataElement('Answers', this.parseAnswers(decisionData));
            Map<String, Object> reasonSection = this.createDataElement('Decision Reasons', this.parseReasonCodeDetails(decisionData));

            List<Map<String, Object>> summary = new List<Map<String, Object>> {
                fraudShieldSection,
                ofacSection,
                dobSection,
                kiqSection
            };
            
            List<Map<String, Object>> sections = new List<Map<String, Object>> {
                fraudShieldSection,
                ofacSection,
                dobSection,
                kiqSection,
                addressSection,
                answerSection,
                reasonSection
            };

            appInfo.kbaReport = this.createReport(summary, sections);
        } catch (Exception e) {
            if (appInfo != null) {
                appInfo.kbaReport = this.createExceptionMap(e);
            }
        }
    }
    
    private List<List<Map<String, Object>>> parseAnswers(Map<String, Object> data) {
        List<List<Map<String, Object>>> answerInfo = new List<List<Map<String, Object>>>();
        
        String[] path = 'otherData/json/fraudSolutions/response/products/preciseIDServer/kbascore/gradedAnswer'.split('/');
        
        Map<String, Object> gradedAnswer = APIUtils.walkTreeToValue(data, path);
        
        if (gradedAnswer == null) {
            return answerInfo;
        }
        
        List<Map<String, Object>> answerSet = APIUtils.convertObjectList((List<Object>)gradedAnswer.get('answerSet'));
        if (answerSet == null) {
            return answerInfo;
        }
        
        for (Map<String, Object> answer : answerSet) {
            List<Map<String, Object>> answerGroup = new List<Map<String, Object>>();

            Integer questionTypeCode = (Integer)answer.get('questionType');
            if (questionTypeCode != null) {
                String value = kbaCodes.get(String.valueOf(questionTypeCode));
                if (value == null) {
                    value = String.valueOf(questionTypeCode);
                }

                this.addDataToList('Question Type', value, answerGroup);
            }

            String description = (String)answer.get('questionTypeDescription');
            if (description != null) {
                this.addDataToList('Question Description', description, answerGroup);
            }

            Integer questionWeight = (Integer)answer.get('questionWeight');
            if (questionWeight != null) {
                this.addDataToList('Question Weight', String.valueOf(questionWeight), answerGroup);
            }
            
            String answerResult = (String)answer.get('answerResult');
            if (answerResult != null) {
                this.addDataToList('Answer Result', answerResult, answerGroup);
            }
            
            answerInfo.add(answerGroup);
        }

        return answerInfo;
    }
    
    private List<List<Map<String, Object>>> parseAddressDetails(Map<String, Object> data) {
        List<List<Map<String, Object>>> addresses = new List<List<Map<String, Object>>>();

        String[] path = 'otherData/json/fraudSolutions/response/products/preciseIDServer/preciseMatch/consumerID/detail'.split('/');

        Map<String, Object> consumerDetail = APIUtils.walkTreeToValue(data, path);
        
        if (consumerDetail == null) {
            return addresses;
        }
        
        List<Map<String, Object>> rawAddresses = APIUtils.convertObjectList((List<Object>)consumerDetail.get('consumerIDRcd'));
        if (rawAddresses == null) {
            return addresses;
        }
        
        for (Map<String, Object> rawAddress : rawAddresses) {
            List<Map<String, Object>> address = new List<Map<String, Object>>();
            
            String lastName = (String)rawAddress.get('surname');
            String firstName = (String)rawAddress.get('firstName');
            
            if (lastName != null && firstName != null) {
                String name = firstName + ' ' + lastName;
                address.add(this.createDataElement('', name, REPORT_FULL_WIDTH));
            }
            
            String street = (String)rawAddress.get('address');
            if (street != null) {
                address.add(this.createDataElement('', street, REPORT_FULL_WIDTH));
            }
            
            String city = (String)rawAddress.get('city');
            String state = (String)rawAddress.get('state');
            String zip = (String)rawAddress.get('zipCode');
            
            String cityStateZip = AddressUtils.combineCityStateZip(city, state, zip);
            if (cityStateZip != null) {
                address.add(this.createDataElement('', cityStateZip, REPORT_FULL_WIDTH));
            }

            addresses.add(address);
        }
        
        return addresses;
    }
    
    private List<List<Map<String, Object>>> parseDOBMatch(Map<String, Object> data) {
        
        String[] path = 'otherData/json/fraudSolutions/response/products/preciseIDServer/preciseMatch/dateOfBirth/summary'.split('/');
        
        Map<String, Object> dobSummary = APIUtils.walkTreeToValue(data, path);
        
        if (dobSummary == null) {
            System.debug('dobSummary was not found!');
            return new List<List<Map<String, Object>>>();
        }
        
        Map<String, Object> matchResult = (Map<String, Object>)dobSummary.get('matchResult');

        if (matchResult == null) {
            System.debug('matchResult was not found!');
            return new List<List<Map<String, Object>>>();
        }

        String code = (String)matchResult.get('code');
        String value = dobCodes.get(code);
        
        if (value == null) {
            value = code;
        }

        return new List<List<Map<String, Object>>> {
            new List<Map<String, Object>> {
                this.createDataElement(code, value)
            }
        };         
    }
    
    private List<List<Map<String, Object>>> parseFraudShield(Map<String, Object> data) {
        List<List<Map<String, Object>>> fraudInfo = new List<List<Map<String, Object>>>();
        
        String[] path = 'otherData/json/fraudSolutions/response/products/preciseIDServer/fcraDetail/fraudShield'.split('/');
        
        Map<String, Object> fraudShield = APIUtils.walkTreeToValue(data, path);
        
        if (fraudShield == null) {
            return fraudInfo;
        }
        
        List<Map<String, Object>> indicators = APIUtils.convertObjectList((List<Object>)fraudShield.get('indicator'));
        
        if (indicators == null) {
            return fraudInfo;
        }
        
        List<Map<String, Object>> noIndicators = new List<Map<String, Object>> {
            this.createDataElement('Fraud Shield Indicators', 'None')
        };

        if (indicators.size() == 0) {
            fraudInfo.add(noIndicators);
            
            return fraudInfo;
        }
        
        Boolean hadFindings = false;
        
        List<Map<String, Object>> indicatorList = new List<Map<String, Object>>();
        
        for (Map<String, Object> indicator : indicators) {
            String code = (String)indicator.get('code');
            String value = (String)indicator.get('value');
            
            if (code == null || value == null) {
                continue;
            }
            
            if (value != 'N') {
                hadFindings = true;
                indicatorList.add(this.createDataElement('', fraudShieldCodes.get(code)));
            }
        }
        
        if (indicatorList.size() == 0) {
            fraudInfo.add(noIndicators);
        } else {
            fraudInfo.add(indicatorList);
        }

        return fraudInfo;
    }
    
    private List<List<Map<String, Object>>> parseReasonCodeDetails(Map<String, Object> data) {
        List<List<Map<String, Object>>> reasonData = new List<List<Map<String, Object>>>();
        
        List<Object> reasonCodes = (List<Object>)data.get('decisions');
        
        if (reasonCodes.size() == 0) {
            return reasonData;
        }
        
        List<Map<String,Object>> decisionReasons = new List<Map<String,Object>>();
        
        for (Object reason : reasonCodes) {
            Map<String,Object> reasonMap = (Map<String,Object>)reason;
            
            String element = (String)reasonMap.get('element');
            String value = (String)reasonMap.get('value');
            
            if ((element == null || !element.contains('pidScoreReason')) || value == null) {
                continue;
            }
            
            String humanReadableCode = pidReasonCodes.get(value);
            
            if (humanReadableCode != null) {
                decisionReasons.add(this.createDataElement('',humanReadableCode));
            }
            
        }
        
        if (decisionReasons.size() > 0) {
            reasonData.add(decisionReasons);
        }
        
        return reasonData;
    }
    
    private List<List<Map<String, Object>>> parseKIQDetails(Map<String, Object> data) {
        List<List<Map<String, Object>>> kiqInfo = new List<List<Map<String, Object>>>();
        
        String[] path = 'otherData/json/fraudSolutions/response/products/preciseIDServer/kbascore'.split('/');
        
        Map<String, Object> kbaScore = APIUtils.walkTreeToValue(data, path);
        
        if (kbaScore == null) {
            return kiqInfo;
        }
        
        Map<String, Object> scoreSummary = (Map<String, Object>)kbaScore.get('scoreSummary');
        if (scoreSummary != null) {
            List<Map<String, Object>> grouping = new List<Map<String, Object>>();
            
            String acceptReferCode = (String)scoreSummary.get('acceptReferCode');
            if (acceptReferCode != null) {
                this.addDataToList('Result', acceptReferCode, grouping);
            }
            
            String outWalletScore = (String)scoreSummary.get('preciseIDScore');
            if (outWalletScore != null) {
                this.addDataToList('Precise ID Score', outWalletScore, grouping);
            }
            
            String outWalletFormula = (String)scoreSummary.get('outWalletFormula');
            if (outWalletFormula != null) {
                this.addDataToList('Out of Wallet Formula', outWalletFormula, grouping);
            }
            
            kiqInfo.add(grouping);
        }

        return kiqInfo;
    }
    
    private List<List<Map<String, Object>>> parseOFACDetails(Map<String, Object> data) {
        List<List<Map<String, Object>>> ofacInfo = new List<List<Map<String, Object>>>();

        String[] path = 'otherData/json/fraudSolutions/response/products/preciseIDServer/preciseMatch/ofac/summary/verificationResult'.split('/');
        
        Map<String, Object> ofacData = APIUtils.walkTreeToValue(data, path);
        
        if (ofacData == null) {
            return ofacInfo;
        }
        
        String code = (String)ofacData.get('code');
        
        if (code == null) {
            return ofacInfo;
        }
        
        String value = ofacCodes.get(code.trim()); // trimming because I've seen single digits with trailing white space.
        if (value == null) { // situations where the data doesn't match anything in our code map.
            value = code;
        }
        
        ofacInfo.add(new List<Map<String, Object>> {
            this.createDataElement('Result', value)
        });

        return ofacInfo;
    }
    
}