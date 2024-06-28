public with sharing class SpeedTargetGraphController {

    @AuraEnabled(cacheable=true)
    public static List<Integer> getYear() {
        List<Integer> years = new List<Integer>();
        Integer currentYear = Date.today().year();
        for (Integer i = currentYear - 2; i <= currentYear; i++) {
            years.add(i);
        }
        return years;
    }

    @AuraEnabled(cacheable=true)
    public static List<User> getSaldept() {

        System.debug(UserInfo.getUserId());
        List<User> user =  [SELECT Id FROM User WHERE Id =: UserInfo.getUserId()];
        if(user[0].Id == '0054K000001iHMyQAM')
        {
            user[0].Id = '0054K000003Ly8RQAS';
        }
        
        List<User> user1 = new List<User>();
        User newUser = new User();

        String query3 = 'SELECT GroupId FROM GroupMember WHERE UserOrGroupId = \'' + user[0].Id + '\'';
        List<GroupMember> groupmember1 =  Database.query(query3);

        integer j=0;
        integer x=0;
        while (j < groupmember1.size()) {
            String query1 = 'SELECT GroupId,UserOrGroupId FROM GroupMember WHERE GroupId = \'' + groupmember1[j].GroupId + '\'';
            List<GroupMember> groupmember2 =  Database.query(query1);
            for (integer y=0; y < groupmember2.size() ; y++)
            {
                newUser = new User();
                newUser.Id = groupmember2[y].UserOrGroupId;
                user1.add(newUser);
            }
            j++;
        }
        System.debug(user1);
        
        String dize = '';
        for (integer z=0; z < user1.size() ; z++)
        {
            dize += '\'' + user1[z].Id + '\', ';        
        }
        dize = dize.removeEnd(', ');
        // Diziyi ekrana yazdırma
        System.debug(dize);
        String query = 'SELECT Id,Name FROM User WHERE Id IN (' + dize + ')';
        System.debug(query);
        List<User> users =  Database.query(query);    
        
        return users;
    }

    @AuraEnabled(cacheable=true)
    public static OrderUserTargetClass searchRecords(String saldept,String voption,Integer month,Integer year) {
        system.debug('saldept:'+ saldept);
        system.debug('voption:'+ voption);
        system.debug('month:'+ month);
        system.debug('year:'+ year);

        String query = 'SELECT SUM(Subtotal__c) Subtotal,SUM(Quantity__c) Quant,SUM(EURTUTAR__c) Eurtotal FROM Order WHERE OwnerId = \'' + saldept + '\' AND Varyant__c LIKE \'' + voption + '\' AND Document_Type__c NOT IN (\'' + 'O8' + '\',\'' + 'O9' + '\',\'' + 'E8' + '\',\'' + 'S8' + '\',\'' + 'MS1' + '\',\'' + 'MS2' + '\') AND C_Code__c !=\'' + '' + '\' AND Status != \'' + 'Stopped' + '\'';

        String query1 = 'SELECT SUM(Target_Amount_TL__c) Amount,SUM(Target_Amount_EUR__c) Eur,SUM(Target_Quantity__c) Quantity FROM User_Target__c WHERE Sales_Representive__c=\'' + saldept + '\' AND Target_Year__c=\'' + year + '\''; 

        if(month == -1)
        {
            query+=' AND CALENDAR_MONTH(CaniasCreateDate__c) IN (1,2,3) ';
            query1+=' AND Target_Month__c IN (\'' + '1' + '\',\'' + '2' + '\',\'' + '3' + '\') ';
        }
        else if(month == -2)
        {
            query+=' AND CALENDAR_MONTH(CaniasCreateDate__c) IN (4,5,6) ';
            query1+=' AND Target_Month__c IN (\'' + '4' + '\',\'' + '5' + '\',\'' + '6' + '\') ';
        }
        else if(month == -3)
        {
            query+=' AND CALENDAR_MONTH(CaniasCreateDate__c) IN (7,8,9) ';
            query1+=' AND Target_Month__c IN (\'' + '7' + '\',\'' + '8' + '\',\'' + '9' + '\') ';
        }
        else if(month == -4)
        {
            query+=' AND CALENDAR_MONTH(CaniasCreateDate__c) IN (10,11,12) ';
            query1+=' AND Target_Month__c IN (\'' + '10' + '\',\'' + '11' + '\',\'' + '12' + '\') ';
        }
        else if(month != 0 && month != null)
        {
            query+=' AND CALENDAR_MONTH(CaniasCreateDate__c) =  ' + month + ' ';
            query1+=' AND Target_Month__c = \'' + month + '\'';
        }

        query+='AND CALENDAR_YEAR(CaniasCreateDate__c) =' + year;

        system.debug('query:'+ query);
        List<AggregateResult> order =  Database.query(query);    
        
        system.debug('query1:'+ query1);
        List<AggregateResult> usertarget =  Database.query(query1); 
        
        OrderUserTargetClass orderusertargets = new OrderUserTargetClass();
        orderusertargets.ActualAmountTL = (Double) (order[0].get('Subtotal') == null ? 0 : order[0].get('Subtotal'));
        orderusertargets.ActualAmountTL1 = (orderusertargets.ActualAmountTL.format().contains('.')? orderusertargets.ActualAmountTL.format():( orderusertargets.ActualAmountTL.format()+''));

        orderusertargets.ActualAmountEUR = (Double) (order[0].get('Eurtotal') == null ? 0 : order[0].get('Eurtotal'));
        orderusertargets.ActualAmountEUR1 = (orderusertargets.ActualAmountEUR.format().contains('.')? orderusertargets.ActualAmountEUR.format():( orderusertargets.ActualAmountEUR.format()+''));

        orderusertargets.ActualQuantity = (Double) (order[0].get('Quant') == null ? 0 : order[0].get('Quant'));
        orderusertargets.ActualQuantity1 = (orderusertargets.ActualQuantity.format().contains('.')? orderusertargets.ActualQuantity.format():( orderusertargets.ActualQuantity.format()+''));

        orderusertargets.TargetAmountTL = (Double) (usertarget[0].get('Amount') == null ? 0 : usertarget[0].get('Amount'));
        orderusertargets.TargetAmountTL1 = (orderusertargets.TargetAmountTL.format().contains('.')? orderusertargets.TargetAmountTL.format():( orderusertargets.TargetAmountTL.format()+''));

        orderusertargets.TargetAmountEUR = (Double) (usertarget[0].get('Eur') == null ? 0 : usertarget[0].get('Eur'));
        orderusertargets.TargetAmountEUR1 = (orderusertargets.TargetAmountEUR.format().contains('.')? orderusertargets.TargetAmountEUR.format():( orderusertargets.TargetAmountEUR.format()+''));

        orderusertargets.TargetQuantity = (Double) (usertarget[0].get('Quantity') == null ? 0 : usertarget[0].get('Quantity'));
        orderusertargets.TargetQuantity1 = (orderusertargets.TargetQuantity.format().contains('.')? orderusertargets.TargetQuantity.format():( orderusertargets.TargetQuantity.format()+''));
        system.debug(orderusertargets);

        return orderusertargets;
    }

    public class OrderUserTargetClass {
        @AuraEnabled
        public Double ActualAmountTL;
        @AuraEnabled
        public String ActualAmountTL1;
        @AuraEnabled
        public Double ActualAmountEUR;
        @AuraEnabled
        public String ActualAmountEUR1;
        @AuraEnabled
        public Double ActualQuantity;
        @AuraEnabled
        public String ActualQuantity1;
        @AuraEnabled
        public Double TargetAmountTL;
        @AuraEnabled
        public String TargetAmountTL1;
        @AuraEnabled
        public Double TargetAmountEUR;
        @AuraEnabled
        public String TargetAmountEUR1;
        @AuraEnabled
        public Double TargetQuantity;
        @AuraEnabled
        public String TargetQuantity1;
    }
}
