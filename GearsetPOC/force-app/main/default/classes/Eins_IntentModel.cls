public class Eins_IntentModel {

	public ProbabilityItem[] probabilities = new List<ProbabilityItem>();
	//public String object;	//predictresponse
	public class ProbabilityItem {
		public String label = '';	//Password Help
		public Double probability = 0;	//0.99040705
	}

    public static Eins_IntentModel parseFromJSON(string jsonString) {
        Eins_IntentModel data = (Eins_IntentModel)JSON.deserialize(jsonString, Eins_IntentModel.class);
        return data;
    }

}