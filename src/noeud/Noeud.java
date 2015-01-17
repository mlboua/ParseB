/*****************************************************************************
*
* (C) 2003  B. TATIBOUET - Universit� de Franche-Comt�
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public License
* as published by the Free Software Foundation; either version 2
* of the License, or any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program; if not, write to the Free Software
* Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
******************************************************************************/

package noeud ;


public class Noeud {
	
	
	String nodeName ;
	String nodeValue ;
  	protected Noeud[] children;
	protected Noeud parent ;

  	public void setNodeName(String name) {
    		nodeName = name ;
  	}  
  			
  	public void setNodeName(String name, String value) {
    		nodeName = name ; nodeValue = value ;
  	}
  
  	public String getNodeName() {
    		return (nodeName) ;
  	}
  	
  	public String getNodeValue() {
    		return (nodeValue) ;
  	}

	public void setNumChildren(int i) {
		if (children == null && i > 0) {
			children = new Noeud[i] ;
		}
	}
	
   	public int getNumChildren() {
    		return (children == null) ? 0 : children.length;
  	}

	public Noeud getParent() {
    		return parent;
  	}
  	
 	public void setParent(Noeud n) {
    		parent = n ;
  	}
  	 	
  	public Noeud getChild(int i) {
    		return children[i];
  	}
  	
 	public void setChild(Noeud n, int i) {
    		children[i] = n ;
  	}

  	public void addChild(Noeud n) {
    		if (children == null) {
      			children = new Noeud[1];
      			children[0] = n ;
    		} 
    		else  {
      			Noeud[] fils = new Noeud[children.length + 1];
      			System.arraycopy(children, 0, fils, 0, children.length);
      			children = fils;
      			children[children.length-1] = n ;
    		}
  	}

	public String toString() {
		if (nodeValue == null) {
    			return (new String('<' + nodeName + '>')) ;
    		}
    		else {  return (new String('<' + nodeName + '>' + 
			nodeValue + '<' + '/' + nodeName + '>')) ; }
	}

	public Object accept(BToXMLVisiteur bToXMLVisiteur) {
		//System.out.println("ACCEPTE SUR "+this.nodeName);
		return bToXMLVisiteur.visit(this);
	}

}
