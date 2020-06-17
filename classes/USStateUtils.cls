public with sharing class USStateUtils {

    public class State {
        public String name { get; private set; }
        public String code { get; private set; }

        public State(String name, String code) {
            this.name = name;
            this.code = code;
        }

        public Map<String, Object> toMap() {
            Map<String, Object> stateMap = new Map<String, Object> {
                'name' => this.name,
                'code' => this.code
            };
            return stateMap;
        }
    }

    private static final Map<String, State> usStates = new Map<String, State> {
        'AL' => new State('Alabama', 'AL'),
        'AK' => new State('Alaska', 'AK'),
        'AZ' => new State('Arizona', 'AZ'),
        'AR' => new State('Arkansas', 'AR'),
        'CA' => new State('California', 'CA'),
        'CO' => new State('Colorado', 'CO'),
        'CT' => new State('Connecticut', 'CT'),
        'DE' => new State('Delaware', 'DE'),
        'DC' => new State('District of Columbia', 'DC'),
        'FL' => new State('Florida', 'FL'),
        'GA' => new State('Georgia', 'GA'),
        'HI' => new State('Hawaii', 'HI'),
        'ID' => new State('Idaho', 'ID'),
        'IL' => new State('Illinois', 'IL'),
        'IN' => new State('Indiana', 'IN'),
        'IA' => new State('Iowa', 'IA'),
        'KS' => new State('Kansas', 'KS'),
        'KY' => new State('Kentucky', 'KY'),
        'LA' => new State('Louisiana', 'LA'),
        'ME' => new State('Maine', 'ME'),
        'MD' => new State('Maryland', 'MD'),
        'MA' => new State('Massachusetts', 'MA'),
        'MI' => new State('Michigan', 'MI'),
        'MN' => new State('Minnesota', 'MN'),
        'MS' => new State('Mississippi', 'MS'),
        'MO' => new State('Missouri', 'MO'),
        'MT' => new State('Montana', 'MT'),
        'NE' => new State('Nebraska', 'NE'),
        'NV' => new State('Nevada', 'NV'),
        'NH' => new State('New Hampshire', 'NH'),
        'NJ' => new State('New Jersey', 'NJ'),
        'NM' => new State('New Mexico', 'NM'),
        'NY' => new State('New York', 'NY'),
        'NC' => new State('North Carolina', 'NC'),
        'ND' => new State('North Dakota', 'ND'),
        'OH' => new State('Ohio', 'OH'),
        'OK' => new State('Oklahoma', 'OK'),
        'OR' => new State('Oregon', 'OR'),
        'PA' => new State('Pennsylvania', 'PA'),
        'RI' => new State('Rhode Island', 'RI'),
        'SC' => new State('South Carolina', 'SC'),
        'SD' => new State('South Dakota', 'SD'),
        'TN' => new State('Tennessee', 'TN'),
        'TX' => new State('Texas', 'TX'),
        'UT' => new State('Utah', 'UT'),
        'VT' => new State('Vermont', 'VT'),
        'VA' => new State('Virginia', 'VA'),
        'WA' => new State('Washington', 'WA'),
        'WV' => new State('West Virginia', 'WV'),
        'WI' => new State('Wisconson', 'WI'),
        'WY' => new State('Wyoming', 'WY')
    };

    public static State getState(String code) {
        if (code == null) {
            return null;
        }

        State usState = usStates.get(code);

        return usState;
    }

    /**
     * This function should only be used by controllers/REST interfaces that require a base type
     * representation of the data.  Always use the Country based functions if at all possible.
     */
    @AuraEnabled(cacheable=true)
    public static List<Map<String, Object>> getStates() {
        List<Map<String,Object>> usStateList = new List<Map<String,Object>>();
        for (State s : usStates.values()) {
            usStateList.add(s.toMap());
        }
        return usStateList;
    }

}