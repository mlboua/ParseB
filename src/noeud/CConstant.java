package noeud;

public class CConstant {
	private String name;
	private int value;
	
	public CConstant(String n, int v){
		this.name = n;
		this.value = v;
	}
	
	public CConstant(String n){
		this.name = n;
		this.value = 0;
	}
	
	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getValue() {
		return value;
	}

	public void setValue(int value) {
		this.value = value;
	}

	public String toString(){
		return this.name.toUpperCase()+" : "+this.value;
	}

}
