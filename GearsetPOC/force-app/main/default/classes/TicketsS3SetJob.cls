// This class required to workaround issues related to AccountingSyncHelper (impossibility to run future method from batch)
public without sharing class TicketsS3SetJob implements Queueable {

    private List<Ticket__c> tickets;

    public TicketsS3SetJob(List<Ticket__c> tickets) {
        this.tickets = tickets;
    }
    public void execute(QueueableContext context) {
        update tickets;
    }
}