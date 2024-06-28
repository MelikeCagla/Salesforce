/**
 * Class containing tests for SiteRegisterController
 */
@IsTest public with sharing class SpeedTargetGraphController_Test {

    @IsTest(SeeAllData=true) static void getYearTest() {
        Test.startTest();
            List<Integer> year = SpeedTargetGraphController.getYear();
        Test.stopTest();
        System.assertNotEquals(null, year, 'Year list should not be null');
        System.assertEquals(3, year.size(), 'Year list should contain 3 elements');
    }
} 