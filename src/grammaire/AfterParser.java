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

package grammaire ;

import java.util.LinkedList ;
import java.util.HashMap ;
import java.util.Iterator ;
import java.util.StringTokenizer ;

import noeud.AfterParserException;
import noeud.Noeud;

class AfterParser {

	static private Noeud racine ;

	static public Noeud changeTree(SimpleNode n) throws AfterParserException {
		racine = reorganise (n) ;
		racine = racine.getChild(0) ;
		expanseLesDefinitions () ;
		unParentParNoeud (racine) ; 
		return (racine) ;
	}

	static private Noeud instancieDefinitionRecursive (Noeud n, HashMap p) throws AfterParserException {
		Noeud e = new Noeud() ;
		HashMap parametres ;
		if (n.getNodeName().equals("CallDefinitionListExpression") ||
		    n.getNodeName().equals("CallDefinitionExpression") ||
		    n.getNodeName().equals("CallDefinitionPredicate")  ||
		    n.getNodeName().equals("CallDefinitionSubstitution")) {
			int nfils = racine.getChild(0).getNumChildren() ;
			int i = 0 ;
			Noeud travail = racine ;
			while (!travail.getChild(i).getNodeName().equals("Definitions")) {
				i += 1 ;
			}
			travail	= travail.getChild(i) ;
			i = 0 ;
			while (!travail.getChild(i).getChild(0).getChild(0).getChild(0).getNodeValue().equals(n.getChild(0).getNodeValue())) {
				i += 1 ;
			}
			travail = travail.getChild(i) ;
			if (travail.getChild(0).getNumChildren() == 1) {
				if (n.getNumChildren() == 1) {
					parametres = new HashMap (1) ;
				}
				else {
					throw new AfterParserException ("Bad number parameters in definition") ;
				}
			}
			else if (n.getNumChildren() == 1) {
					throw new AfterParserException ("Bad number parameters in definition") ;
				}
			else {
				nfils = travail.getChild(0).getChild(1).getChild(0).getNumChildren () ;
				if (nfils != n.getChild(1).getNumChildren()) throw new AfterParserException ("Bad number parameters in definition") ;
				parametres = new HashMap (nfils) ;
				for (i = 0; i < nfils ; i +=1 ) {
					if (p.containsKey(n.getChild(1).getChild(i).getNodeValue())) {
						parametres.put(travail.getChild(0).getChild(1).getChild(0).getChild(i).getNodeValue(), (String) p.get(n.getChild(1).getChild(i).getNodeValue())) ;
					} else {
						parametres.put(travail.getChild(0).getChild(1).getChild(0).getChild(i).getNodeValue(), n.getChild(1).getChild(i).getNodeValue()) ;
					}
				}
			}
			e = instancieDefinitionRecursive(travail.getChild(1),parametres) ;
		}
		else if (n.getNodeName().equals("IdentifierComposed")) {
			int nombreDeFils = n.getNumChildren() ;
			if (p.containsKey(n.getNodeValue())) {
				Noeud fils ;
				String ident = (String) p.get(n.getNodeValue()) ;
				e.setNodeName("IdentifierComposed", ident) ;
				StringTokenizer st = new StringTokenizer(ident,".");
     				while (st.hasMoreTokens()) {
         				fils = new Noeud() ;
					fils.setNodeName("Identifier", st.nextToken()) ;
					e.addChild (fils);
     				}
			} else {
				e.setNodeName("IdentifierComposed",n.getNodeValue()) ;
				for (int i = 0;  i < nombreDeFils ; i+=1) {
					Noeud nFils = new Noeud() ;
					nFils.setNodeName("Identifier", n.getChild(i).getNodeValue()) ;
					e.addChild (nFils) ;
				}
			}
		}
		else if (n.getNodeName().equals("Integer")) {
			if (p.containsKey(n.getNodeValue())) {
				e.setNodeName("Integer", (String) p.get(n.getNodeValue())) ;
			}
			else {
				e.setNodeName("Integer", n.getNodeValue()) ;
			}
		}
		else {
			int nombreDeFils = n.getNumChildren() ;
			e.setNodeName(n.getNodeName(),n.getNodeValue()) ;
		        for (int i = 0;  i < nombreDeFils ; i+=1) {
				Noeud nFils = instancieDefinitionRecursive(n.getChild(i), p) ;
				e.addChild (nFils) ;
			}
		}
    		return (e) ;				
	}

	static private Noeud instancieDefinition(Noeud n) throws AfterParserException {
		int nfils = racine.getNumChildren() ;
		HashMap parametres ;
		int i = 0 ;
		Noeud travail = racine ;
		// On cherche le noeud D�finitions
		while (!travail.getChild(i).getNodeName().equals("Definitions")) {
			i += 1 ;
		}
		travail	= travail.getChild(i) ;
		// on cherche maintenant la d�finition qui nous int�resse
		i = 0 ;
		while (!travail.getChild(i).getChild(0).getChild(0).getChild(0).getNodeValue().equals(n.getChild(0).getNodeValue())) {
			i += 1 ;
		}
		travail = travail.getChild(i) ;
		if (travail.getChild(0).getNumChildren() == 1) {
			if (n.getNumChildren() == 1) {
				parametres = new HashMap (1) ;
			}
			else {
				throw new AfterParserException ("Bad number parameters in definition") ;
			}
		}
		else if (n.getNumChildren() == 1) {
				throw new AfterParserException ("Bad number parameters in definition") ;
			}
		else {
			nfils = travail.getChild(0).getChild(1).getChild(0).getNumChildren () ;
			if (nfils != n.getChild(1).getNumChildren()) throw new AfterParserException ("Bad number parameters in definition") ;
			parametres = new HashMap (nfils) ;
			// on met dans la table comme cl� les param�tres formels et comme valeur les param�tres effectifs
			for (i = 0; i < nfils ; i +=1 ) {
				parametres.put(travail.getChild(0).getChild(1).getChild(0).getChild(i).getNodeValue(), n.getChild(1).getChild(i).getNodeValue()) ;
			}
		}		
		return (instancieDefinitionRecursive(travail.getChild(1),parametres)) ;
	}

	static private void expanseLesDefinitionsRecursive (Noeud n) throws AfterParserException  {
		int nfils = n.getNumChildren() ;
		for (int i = 0; i < nfils; i+=1) {
			if (n.getChild(i).getNodeName().equals("CallDefinitionListExpression")) {
				n.setChild(instancieDefinition (n.getChild(i)),i) ;				
			}
			else if (n.getChild(i).getNodeName().equals("CallDefinitionExpression")) {
				n.setChild(instancieDefinition (n.getChild(i)),i) ;				
			}
			else if (n.getChild(i).getNodeName().equals("CallDefinitionPredicate")) {
				n.setChild(instancieDefinition (n.getChild(i)),i) ;				
			}
			else if (n.getChild(i).getNodeName().equals("CallDefinitionSubstitution")) {
				n.setChild(instancieDefinition (n.getChild(i)),i) ;				
			}
			else {
				expanseLesDefinitionsRecursive (n.getChild(i)) ;
			}
		}
	}

	static private void expanseLesDefinitions () throws AfterParserException  {
		boolean yaDesDefinitions = false ;
		int nfils = racine.getNumChildren() ;
		for (int i = 0; i < nfils; i+=1) {
			if (racine.getChild(i).getNodeName().equals("Definitions")) {
				yaDesDefinitions = true ; break ;
			}
		}
		if (yaDesDefinitions) {
			for (int i = 0; i < nfils; i+=1) {
				if (!racine.getChild(i).getNodeName().equals("Definitions")) {
					expanseLesDefinitionsRecursive (racine.getChild(i)) ;
				}
			}
		}
	}

	static private Noeud recopie (SimpleNode n) {
		Noeud e = new Noeud () ;
		int nombreDeFils = n.jjtGetNumChildren() ;
		e.setNodeName(((SimpleNode)n).toString(),((SimpleNode)n).getNodeName()) ;		
    		if (nombreDeFils != 0) {
			e.setNumChildren (nombreDeFils) ;
      			for (int i = 0; i < nombreDeFils; ++i) {
				e.setChild (reorganise((SimpleNode)n.jjtGetChild(i)), i) ;	
      			}
    		}
		return e ;	
	}

	static private Noeud reorganiseExpression (SimpleNode n, String expr) {
		Noeud ntop, ne1, ne2 ;
		ne1 = reorganise((SimpleNode)n.jjtGetChild(0)) ;
		while (((SimpleNode)n.jjtGetChild(1).jjtGetChild(0)).toString().equals(expr)) {
			ne2 = reorganise((SimpleNode)n.jjtGetChild(1).jjtGetChild(0).jjtGetChild(0)) ;
			ntop = new Noeud () ;
			ntop.setNodeName(((SimpleNode)n.jjtGetChild(1)).getNodeName()) ;
			ntop.setNumChildren(2) ;
			ntop.setChild(ne1,0) ;
			ntop.setChild(ne2,1);
			ne1 = ntop ;
			n = (SimpleNode) n.jjtGetChild(1).jjtGetChild(0) ;
		}
		ntop = new Noeud () ;
		ntop.setNumChildren(2) ;
		ntop.setNodeName(((SimpleNode)n.jjtGetChild(1)).getNodeName()) ;
		ntop.setChild (ne1,0) ;
		ne2 = reorganise((SimpleNode)n.jjtGetChild(1).jjtGetChild(0)) ;	
		ntop.setChild (ne2,1) ;		
		return (ntop) ;
	}

	static private Noeud reorganise (SimpleNode n) {
		Noeud e = new Noeud() ;
		int nombreDeFils = n.jjtGetNumChildren() ;
		if (((SimpleNode)n).toString().equals("IdentifierComposed")) {
			e = recopie(n) ;
			StringBuffer identifierComposed = new StringBuffer(256) ;
			identifierComposed.append(((SimpleNode)n.jjtGetChild(0)).getNodeName()) ;
			for (int i = 1;  i < nombreDeFils ; i+=1) {
				identifierComposed.append(".") ;
				identifierComposed.append(((SimpleNode)n.jjtGetChild(i)).getNodeName()) ;
			}
			e.setNodeName("IdentifierComposed",identifierComposed.toString()) ;
		}
		else if (((SimpleNode)n).toString().equals("Identifier")) {
			e.setNodeName("Identifier", ((SimpleNode)n).getNodeName()) ;
		}
		else if (((SimpleNode)n).toString().equals("IndexOfElement")) {
			e = reorganiseExpression ((SimpleNode)n,"IndexOfElement") ;
		}		
		else if (((SimpleNode)n).toString().equals("ElementImplementation")) {
			e = reorganiseExpression ((SimpleNode)n,"ElementImplementation") ;
		}
		else if (((SimpleNode)n).toString().equals("ElementUnionSetImplementation")) {
			e = reorganiseExpression ((SimpleNode)n,"ElementUnionSetImplementation") ;
		}
		else if (((SimpleNode)n).toString().equals("UnionSetImplementation")) {
			e = reorganiseExpression ((SimpleNode)n,"UnionSetImplementation") ;
		}
		else if (((SimpleNode)n).toString().equals("SubstitutionImplementation0")) {
			e = reorganiseExpression ((SimpleNode)n,"SubstitutionImplementation0") ;
		}
		else if (((SimpleNode)n).toString().equals("SubstitutionRefinement0")) {
			e = reorganiseExpression ((SimpleNode)n,"SubstitutionRefinement0") ;
		}
		else if (((SimpleNode)n).toString().equals("SubstitutionMachine0")) {
			e = reorganiseExpression ((SimpleNode)n,"SubstitutionMachine0") ;
		}
		else if (((SimpleNode)n).toString().equals("Condition0")) {
			e = reorganiseExpression ((SimpleNode)n,"Condition0") ;
		}
		else if (((SimpleNode)n).toString().equals("ExprArith")) {
			e = reorganiseExpression ((SimpleNode)n,"ExprArith") ;
		}
		else if (((SimpleNode)n).toString().equals("ExprArith0")) {
			e = reorganiseExpression ((SimpleNode)n,"ExprArith0") ;
		}
		else if (((SimpleNode)n).toString().equals("ExprArith1")) {
			e = reorganiseExpression ((SimpleNode)n,"ExprArith1") ;
		}
		else if (((SimpleNode)n).toString().equals("ExprArith2")) {
			e.setNodeName(((SimpleNode)n.jjtGetChild(0)).getNodeName()) ;
			e.addChild (reorganise((SimpleNode)n.jjtGetChild(1))) ;
		}
		else if (((SimpleNode)n).toString().equals("PredLevel")) {
			e = reorganiseExpression ((SimpleNode)n,"PredLevel") ;
		}
		else if (((SimpleNode)n).toString().equals("PredLevel0")) {
			e = reorganiseExpression ((SimpleNode)n,"PredLevel0") ;
		}
		else if (((SimpleNode)n).toString().equals("PredLevel1")) {
			e = reorganiseExpression ((SimpleNode)n,"PredLevel1") ;
		}
		else if (((SimpleNode)n).toString().equals("PredLevel3")) {
			e.setNodeName(((SimpleNode)n).getNodeName(),null) ;		
    			if (nombreDeFils != 0) {
				e.setNumChildren(nombreDeFils) ;
      				for (int i = 0; i < nombreDeFils; ++i) {
					e.setChild (reorganise((SimpleNode)n.jjtGetChild(i)), i) ;	
      				}
    			}
		}
		else if (((SimpleNode)n).toString().equals("Condition2")) {
			e.setNodeName(((SimpleNode)n).getNodeName(),null) ;		
    			if (nombreDeFils != 0) {
				e.setNumChildren(nombreDeFils) ;
      				for (int i = 0; i < nombreDeFils; ++i) {
					e.setChild (reorganise((SimpleNode)n.jjtGetChild(i)),i) ;	
      				}
    			}
		}
		else if (((SimpleNode)n).toString().equals("Expr")) {
			e = reorganiseExpression ((SimpleNode)n,"Expr") ;
		}
		else if (((SimpleNode)n).toString().equals("Expr0")) {
			e = reorganiseExpression ((SimpleNode)n,"Expr0") ;
		}
		else if (((SimpleNode)n).toString().equals("Expr1")) {
			e = reorganiseExpression ((SimpleNode)n,"Expr1") ;
		}
		else if (((SimpleNode)n).toString().equals("Expr2")) {
			e = reorganiseExpression ((SimpleNode)n,"Expr2") ;
		}
		else if (((SimpleNode)n).toString().equals("Expr3")) {
			e = reorganiseExpression ((SimpleNode)n,"Expr3") ;
		}
		else if (((SimpleNode)n).toString().equals("Expr4")) {
			e = reorganiseExpression ((SimpleNode)n,"Expr4") ;
		}
		else if (((SimpleNode)n).toString().equals("Expr5")) {
			e = reorganiseExpression ((SimpleNode)n,"Expr5") ;
		}
		else if (((SimpleNode)n).toString().equals("Expr6")) {
			e.setNodeName(((SimpleNode)n.jjtGetChild(0)).getNodeName()) ;
			e.addChild (reorganise((SimpleNode)n.jjtGetChild(1))) ;
		}
		else if (((SimpleNode)n).toString().equals("Expr7")
			|| ((SimpleNode)n).toString().equals("LeftCallFunction")) {
			e.setNodeName(((SimpleNode)n.jjtGetChild(1)).toString()) ;
			e.addChild (reorganise((SimpleNode)n.jjtGetChild(0))) ;
			if (!e.getNodeName().equals("Inverse")) {
				e.addChild (reorganise((SimpleNode)n.jjtGetChild(1).jjtGetChild(0))) ;
			}
			for (int i = 2;  i < nombreDeFils ; i+=1) {
				Noeud ntop = new Noeud() ;
				ntop.setNodeName(((SimpleNode)n.jjtGetChild(i)).toString()) ;
				ntop.addChild (e) ;
				if (!ntop.getNodeName().equals("Inverse")) {
					ntop.addChild (reorganise((SimpleNode)n.jjtGetChild(i).jjtGetChild(0))) ;
				}
				e = ntop ;
			}
		}
		else {
			e = recopie ((SimpleNode)n) ;	
    		}
    		return (e) ;		
	}

	static private void unParentParNoeud (Noeud pere) {
    		int nombreDeFils = pere.getNumChildren() ;
    		if (nombreDeFils != 0) {
      			for (int i = 0; i < nombreDeFils; i += 1) {
				Noeud fils = pere.getChild(i);
				fils.setParent(pere) ;
				if (fils != null) {
	  				unParentParNoeud (fils) ;
				}
      			}
    		}
  	}

}
