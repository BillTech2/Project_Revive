public inherited sharing class DLT_CaseTriggerQueHelper implements Queueable {
    public enum Mode {
        HANDLE_E4A_LOGIC
    }

    private Mode helperMode;
    List<Case> cases;

    public DLT_CaseTriggerQueHelper(Mode helperMode, List<Case> cases) {
        this.helperMode = helperMode;
        this.cases = cases;
    }

    public void execute(QueueableContext context) {
        switch on helperMode {
            when HANDLE_E4A_LOGIC {
                DLT_CaseService.handleLogicForE4A(cases);
            }
        }
    }
}