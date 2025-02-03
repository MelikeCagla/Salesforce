@isTest
public class WSInvoicesAll_Test {

    @testSetup static void init() {
        // DUMMY PRODUCTS
        Product2 pr1 = new Product2();
        pr1.ProductCode = 'TEST1';
        pr1.Name = 'Test Product 1';
        pr1.C_Code__c = pr1.ProductCode;
        pr1.IsActive = true;
        pr1.Stock1__c = 0;
        pr1.Quantity__c = 0;
        insert pr1;  

        Product2 pr2 = new Product2();
        pr2.ProductCode = 'TEST2';
        pr2.Name = 'Test Product 1';
        pr2.C_Code__c = pr2.ProductCode;
        pr2.IsActive = true;
        insert pr2;          
        // DUMMY ACCOUNTS

        Account acc1 = new Account();
        acc1.Name = 'Test Account';
        acc1.CurrencyIsoCode = 'EUR';
        acc1.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Account').getRecordTypeId();
        acc1.BillingCity = 'Los Angeles';
        acc1.C_Customer__c = 'M211001';
        insert acc1;

        Account acc2 = new Account();
        acc2.Name = 'Test Partner';
        acc2.CurrencyIsoCode = 'USD';
        acc2.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Partner').getRecordTypeId();
        acc2.C_Customer__c = 'M211002';
        acc2.BillingCity = 'Hawaii';
        insert acc2; 
        
         // DUMMY ORDERS
        Invoice__c inv1 = new Invoice__c();
        inv1.C_Code__c = 'INVOICE200072246';
        inv1.External_Invoice_Number__c = '45637463INVOICE1';
        inv1.Partner_Name__c = acc2.Id;
        insert inv1;

        Invoice__c inv2 = new Invoice__c();
        inv2.External_Invoice_Number__c = '45637463INVOICE2';
        inv2.Partner_Name__c = acc2.Id;
        insert inv2;
        // DUMMY ORDERITEMS
        Invoice_Item__c otm21 = new Invoice_Item__c();
        otm21.InvoiceId__c = inv2.Id;
        otm21.ProductName__c = pr1.Id;
        otm21.Quantity__c = 10;
        insert otm21;
        
    }
    static testMethod void testWSInvoicesNew(){
        Invoice__c invoice = getInvoice('45637463INVOICE1');
        String body = getDummyInvoiceBody(invoice.Id, 'INVOICE200072246', 'false', 'false');        

        Blob blobBody = Blob.valueOf(body);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/WSInvoicesAll/';
        req.httpMethod = 'POST';
        req.requestBody = blobBody;
        RestContext.request = req;
        RestContext.response = res;
        System.debug('WSInvoices.PostAccounts triggered');

        WSInvoicesAll.PostAccounts();

    }
    
    static testMethod void testWSInvoicesUpdate(){
        Invoice__c invoice = getInvoice('45637463INVOICE2');
        String body = getDummyInvoiceBody(invoice.Id, 'INVOICE200072246', 'false', 'false');    

        Blob blobBody = Blob.valueOf(body);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/WSInvoicesAll/';
        req.httpMethod = 'POST';
        req.requestBody = blobBody;
        RestContext.request = req;
        RestContext.response = res;
        WSInvoicesAll.PostAccounts();
    }
    static testMethod void testWSInvoicesUpdateDelete(){
        Invoice__c invoice = getInvoice('45637463INVOICE1');
        String body = getDummyInvoiceBody(invoice.Id, 'INVOICE200072246', 'true', 'false');  

        Blob blobBody = Blob.valueOf(body);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/WSInvoicesAll/';
        req.httpMethod = 'POST';
        req.requestBody = blobBody;
        RestContext.request = req;
        RestContext.response = res;
        WSInvoicesAll.PostAccounts();
    }
    static testMethod void testWSInvoicesUpdateStopped(){
        Invoice__c invoice = getInvoice('45637463INVOICE1');
        String body = getDummyInvoiceBody(invoice.Id, 'INVOICE200072246', 'false', 'true');     

        Blob blobBody = Blob.valueOf(body);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/WSInvoicesAll/';
        req.httpMethod = 'POST';
        req.requestBody = blobBody;
        RestContext.request = req;
        RestContext.response = res;
        WSInvoicesAll.PostAccounts();
    }
    static testMethod void testWSError(){
        String body = '{}';        
        Blob blobBody = Blob.valueOf(body);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/WSInvoicesAll/';
        req.httpMethod = 'POST';
        req.requestBody = blobBody;
        RestContext.request = req;
        RestContext.response = res;
        WSInvoicesAll.PostAccounts();
    }

    static Invoice__c getInvoice(string invId) {
        List<Invoice__c> invoices = [SELECT Id, Name, Partner_Name__c, C_Code__c FROM Invoice__c WHERE External_Invoice_Number__c =: invId LIMIT 1];
        Invoice__c invoice = invoices.size() > 0 ? invoices[0] : new Invoice__c();
        return invoice;
    }
    
    static String getDummyInvoiceBody(String Id, String invoiceId, String deletesf, String stopsf) {
        String body = '[{' +
            '"id" : ' + (Id == null ? 'null' : '"' + Id + '"') + ',' +
            '"invoiceid" : "' + invoiceId + '",' +
            '"stext" : "' + invoiceId + ' No Invoice",' +
            '"Invoice_Code" : "INVOICE100000921",' +
            '"Invoice_Document_Type" : "INVOICE1",' +
            '"Invoice_Document_Number" : "00000921",' +
            '"Country" : "TÜRKİYE",' +
            '"Exchange_Rate_Information" : "1.0",' +
            '"External_Invoice_Number" : "XXXRTYESSFFG788867",' +
            '"Grand_Total" : 25443.22,' +
            '"Invoice_ValidFrom" : "2024-12-10",' +
            '"IsStop" : false,' +
            '"CurrencyIsoCode" : "EUR",' +
            '"Partner_Code" : "Partner_Code",' +
            '"Partner_Name" : "{}",' +
            '"Total_Discount" : 0.0,' +
            '"Total_Gross_Total" : 21202.68,' +
            '"Total_Invoice_Quantity" : 1.0,' +
            '"Total_Net_Total" : 21202.68,' +
            '"DeletedSF" : false,' +
            '"InvoiceItems": [' +
            '  {' +
            '	"GrandTotal":25443.22,' +
            '	"GrandTotal_TL":25443.22,' +
            '	"List_Price":21202.68,' +
            '	"Net_Price":21202.68,' +
            '	"CurrencyIsoCode":"EUR",' +
            '	"ProductCode": "TTTT78954RR",' +
            '	"ProductName": "Technical Service Product",' +
            '	"Quantity":1.0,' +
            '	"Reference_Order_Number": "OX-XXXXXXXX",' +
            '	"SubTotal": 21202.68,' +
            '	"Unit":"AD",' +
            '	"VAT_Amount": 4240.54,' +
            '	"Voption": "1. Kalite"' +
            '  }' +
            ']' +
            '}]';

            return body;
    }
}


