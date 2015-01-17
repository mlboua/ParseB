package noeud;

public class CSet {
	private String name;
	private int borMin, bornMax;
	
	public CSet(String name, int bmin, int bmax){
		this.name = name;
		this.borMin = bmin;
		this.bornMax = bmax;
	}
	
	public String toString(){
		String str = this.name+" = {";
		for(int i = this.borMin; i < bornMax; i++){
			str+= i+",";
		}
		str+= bornMax+"}";
		
		return str;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getBorMin() {
		return borMin;
	}

	public void setBorMin(int borMin) {
		this.borMin = borMin;
	}

	public int getBornMax() {
		return bornMax;
	}

	public void setBornMax(int bornMax) {
		this.bornMax = bornMax;
	}
}
