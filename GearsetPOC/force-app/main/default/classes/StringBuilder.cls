public class StringBuilder implements CharSequence{
    private String body;

    public StringBuilder() {
        this.body = '';
    }

    public StringBuilder(String body) {
        this.body = body;
    }

    public void append(String str) {
        body += str;
    }

    public void left(Integer pos){
        body = body.left(pos);
    }

    public void right(Integer fromPos){
        body = body.substring(fromPos);
    }

    public String charAt(Integer index) {
        return body.substring(index, index + 1);
    }

    public Integer length() {
        return body.length();
    }

    public void replace(String newBody) {
        body = newBody;
    }
    public CharSequence subSequence(Integer start, Integer ends) {
        return new StringBuilder(body.substring(start, ends));
    }

    public override String toString() {
        return body;
    }
}