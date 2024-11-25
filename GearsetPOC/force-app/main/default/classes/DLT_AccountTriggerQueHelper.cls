public inherited sharing class DLT_AccountTriggerQueHelper implements Queueable {
    public enum Mode {
        FIRE_LOYALTY_EVENTS
    }

    private Mode helperMode;
    private List<Account> accounts;
    private Map<Id, Account> accountsMap;

    public DLT_AccountTriggerQueHelper(Mode helperMode, List<Account> accounts, Map<Id, Account> accountsMap) {
        this.helperMode = helperMode;
        this.accounts = accounts;
        this.accountsMap = accountsMap;
    }

    public void execute(QueueableContext context) {
        switch on helperMode {
            when FIRE_LOYALTY_EVENTS {
                fireLoyaltyEvents();
            }
        }
    }

    private void fireLoyaltyEvents() {
        if (accounts != null && accountsMap != null) {
            DLT_AccountService.fireLoyaltyEvents(accounts, accountsMap);
        } else if (accounts != null) {
            DLT_AccountService.fireLoyaltyEvents(accounts);
        }
    }
}