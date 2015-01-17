package noeud;

import java.util.ArrayList;

public class CXMLElement {
	private String name;
	private String attribute;
	private String attributeValue;
	private boolean isClosed;
	private ArrayList<CXMLElement> children;
	
	public CXMLElement(String n, boolean isClosed){
		this.name = n;
		this.isClosed = isClosed;
		this.attribute = null;
		this.attributeValue = null;
		
		this.children = new ArrayList<CXMLElement>();
	}
	
	public String toString(){
		//System.out.println(this.name);
		String tmp = "<"+this.name;
		if(this.attribute != null){
			tmp += " "+this.attribute+"=\""+this.attributeValue+"\"";
		}
		if(!isClosed){
			tmp+= " />";
			//return tmp;
		}
		else{
			tmp += ">\n";
			if(!this.children.isEmpty()){
				for(CXMLElement c : this.children){
					//System.out.println(this.name);
					tmp += c.toString()+"\n";
				}
			}
			tmp += "</"+this.name+">\n";
		}
		return tmp;
	}
	
	public void setAttribute(String name, String value){
		this.attribute = name;
		this.attributeValue = value;
	}
	
	public void addContent(CXMLElement c){
		//System.out.println("Ajout de "+c.getName());
		this.children.add(c);
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public ArrayList<CXMLElement> getChildren() {
		return children;
	}

	public void setChildren(ArrayList<CXMLElement> children) {
		this.children = children;
	}
	
}
