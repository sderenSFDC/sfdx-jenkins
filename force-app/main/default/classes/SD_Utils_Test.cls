

@isTest
private class SD_Utils_Test {
    @isTest static void testUtils() {
        Integer res = SD_Utils.addNumbers(1, 1);
        System.assertEquals(2, res);
    }
}