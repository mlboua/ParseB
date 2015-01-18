package noeud;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;

import org.jdom2.Attribute;
import org.jdom2.Element;

public class BToXMLVisiteur implements IArithmeticVisitor, IBooleanVisitor, IEventBVisitor {
	HashMap<String, CSet> listSets = new HashMap<String, CSet>();
	HashMap<String, CConstant> listConst = new HashMap<String, CConstant>();
	
	public Object visit(Noeud node) {

		String nodeName = node.getNodeName();

		if(nodeName.equals("Machine")){
			return this.visitMachine(node);
		}
		else if(nodeName.equals("AbstractVariables")){
			return this.visitVariables(node);
		}
		else if(nodeName.equals("IdentifierComposed")){
			return this.visitIdentifierComposed(node);
		}
		else if(nodeName.equals("Integer")){
			return this.visitInteger(node);
		}
		else if(nodeName.equals("ListExpression")){
			return this.visitListExpression(node);
		}
		else if(nodeName.equals("Identifiers")){
			return this.visitIdentifiers(node);
		}
		else if(nodeName.equals("ListIdent")){
			return this.visitListIdent(node);
		}
		else if(nodeName.equals("Identifier")){
			return this.visitIdentifier(node);
		}
		else if(nodeName.equals("Invariant")){
			return this.visitInvariant(node);
		}
		else if(nodeName.equals("Sets")){
			this.visitSets(node);
		}
		else if(nodeName.equals("ConcreteConstants")){
			this.visitConstant(node);
		}
		else if(nodeName.equals("Properties")){
			this.visitProperties(node);
		}
		else if(nodeName.equals("Definitions")){
			this.visitDefinitions(node);
		}
		else if(nodeName.equals("ExtensionSet")){
			return this.visitExtensionSet(node);
		}
		else if(nodeName.equals("Initialisation")){
			return this.visitInitialisation(node);
		}
		//visite des noeud boolean

		else if(nodeName.equals("And")){
			return this.visitAnd(node);
		}
		else if(nodeName.equals("In")){
			return this.visitIn(node);
		}
		else if(nodeName.equals("Equal")){
			return this.visitEqual(node);
		}
		else if(nodeName.equals("NotEqual")){
			return this.visitNotEqual(node);
		}
		else if(nodeName.equals("Not")){
			return this.visitNot(node);
		}
		else if(nodeName.equals("GreatherThan")){
			return this.visitGreatherThan(node);
		}
		else if(nodeName.equals("LessThan")){
			return this.visitLessThan(node);
		}
		else if(nodeName.equals("GreatherThanOrEqual")){
			return this.visitGreatherThanOrEqual(node);
		}
		else if(nodeName.equals("LessThanOrEqual")){
			return this.visitLessThanOrEqual(node);
		}
		else if(nodeName.equals("Exists")){
			return this.visitExists(node);
		}
		else if(nodeName.equals("Or")){
			return this.visitOr(node);
		}

		//visit des neud evenements
		else if(nodeName.equals("Parallel")){
			return this.visitParallel(node);
		}
		else if(nodeName.equals("SubstitutionBecomeEqualVariables")){
			return this.visitAssignment(node);
		}
		else if(nodeName.equals("Operations")){
			return this.visitOperations(node);
		}
		else if(nodeName.equals("Operation")){
			return this.visitOperation(node);
		}
		else if(nodeName.equals("SubstitutionSelect") || nodeName.equals("SubstitutionPrecondition")){
			return this.visitSubstitutionSelect(node);
		}
		else if(nodeName.equals("SubstitutionIf")){
			return this.visitIf(node);
		}
		else if(nodeName.equals("Else")){
			return this.visitElse(node);
		}
		else if(nodeName.equals("Then")){
			return this.visitThen(node);
		}
		else if(nodeName.equals("SubstitutionAny")){
			return this.visitAny(node);
		}
		else if(nodeName.equals("PredicateParenthesis")){
			return this.visitPredicateParenthesis(node);
		}
		else if(nodeName.equals("Implication")){
			return this.visitImplication(node);
		}
		
		//visit des neoeuds arithmetique 
		else if(nodeName.equals("Plus")){
			return this.visitPlus(node);
		}
		else if(nodeName.equals("Minus")){
			return this.visitMinus(node);
		}
		else if(nodeName.equals("Product")){
			return this.visitMult(node);
		}
		return null;
	}



	private Object visitElse(Noeud node) {
		return (Element)node.getChild(0).accept(this);
	}


	private Object visitNotEqual(Noeud node) {
		Element cnotE = new Element("CNot");
		Element cnotEqu = new Element("CEquals");
		cnotEqu.addContent((Element)node.getChild(0).accept(this));
		cnotEqu.addContent((Element)node.getChild(1).accept(this));
		cnotE.addContent(cnotEqu);
		return cnotE;
	}

	private Object visitImplication(Noeud node) {
		Element cOr = new Element("COr");
		Element cNot = new Element("CNot");
		cNot.addContent((Element)node.getChild(0).accept(this));
		cOr.addContent(cNot);
		cOr.addContent((Element)node.getChild(1).accept(this));
		return cOr;
	}


	private Object visitPredicateParenthesis(Noeud node) {
		return (Element)node.getChild(0).accept(this);
	}


	public Object visitMachine(Noeud node) {
		Element cMachine = new Element("MACHINE");
		if(node.getChild(0) == null){
			throw new NullPointerException("Header required !");
		}
		cMachine.setAttribute("name", node.getChild(0).getChild(0).getChild(0).getNodeValue());
		for(int i=1; i< node.getNumChildren();i++){
			//System.out.println(node.getChild(i).getNodeName());
			//if(node.getChild(i).getNodeName().equals("Invariant")){
				if(node.getChild(i).getNodeName().equals("Sets") ||
						node.getChild(i).getNodeName().equals("ConcreteConstants") ||
						node.getChild(i).getNodeName().equals("Properties") ||
						node.getChild(i).getNodeName().equals("Definitions")){
					node.getChild(i).accept(this);
				}
				else{
					cMachine.addContent((Element)node.getChild(i).accept(this));
				}
			//}
		}		
		return cMachine;
	}

	
	private Object visitGreatherThanOrEqual(Noeud node) {// revoir pour >=
		Element cG = new Element("CGreater");
		cG.addContent((Element)node.getChild(0).accept(this));
		
		Element cm = new Element("CMinus");
		cm.addContent((Element)node.getChild(1).accept(this));
		Element cN = new Element("CNumber");
		cN.setAttribute("val","1");
		cm.addContent(cN);
		cG.addContent(cm);
		return cG;
	}
	
	private Object visitLessThanOrEqual(Noeud node) {// revoir pour <=
		Element cG = new Element("CGreater");
		cG.addContent((Element)node.getChild(1).accept(this));
		
		Element cm = new Element("CMinus");
		cm.addContent((Element)node.getChild(1).accept(this));
		Element cN = new Element("CNumber");
		cN.setAttribute("val","1");
		cm.addContent(cN);
		cG.addContent(cm);
		return cG;
	}


	private Object visitLessThan(Noeud node) {
		Element cG = new Element("CGreater");
		cG.addContent((Element)node.getChild(1).accept(this));
		cG.addContent((Element)node.getChild(0).accept(this));
		return cG;
	}

	private Object visitListIdent(Noeud node) {
		Element cVarList = new Element("VariablesList");
		for(int i=0;i<node.getNumChildren();i++){
			cVarList.addContent((Element)node.getChild(i).accept(this));
		}
		return cVarList;
	}


	private Object visitIdentifiers(Noeud node) {
		return (Element)node.getChild(0).accept(this);
	}


	private Object visitListExpression(Noeud node) {
		return node.getChild(0).accept(this);
	}

	private Object visitInteger(Noeud node) {
		Element cInt = new Element("CNumber");
		cInt.setAttribute("val", node.getNodeValue());
		return cInt;
	}

	public Object visitVariables(Noeud node) {
		Noeud n;
		Element cVar = new Element("VARIABLES");
		for(int i=0; i< node.getNumChildren();i++){
			//System.out.println(node.getChild(i).getNodeName());
			n = node.getChild(i);
			for(int j = 0; j<n.getNumChildren(); j++){
				//System.out.println(n.getChild(i).getChild(0).getNodeName());
				cVar.addContent((Element)(n.getChild(j).getChild(0)).accept(this));
			}
		}
		return cVar;
	}

	public Object visitIdentifierComposed(Noeud node) {
		Element n = (Element) node.getChild(0).accept(this);
		return n;
	}

	public Object visitIdentifier(Noeud node) {
		Element var = new Element("CVariable");
		var.setAttribute("val", node.getNodeValue());
		return var;
	}

	private void visitConstant(Noeud node) {
		for(int i=0; i< node.getChild(0).getNumChildren();i++){
			CConstant cConst = new CConstant(node.getChild(0).getChild(i).getChild(0).getNodeValue());
			listConst.put(cConst.getName(), cConst);
		}
	}	
	
	public void visitSets(Noeud node){
		for(int i=0; i< node.getNumChildren();i++){
			Noeud decl = node.getChild(i);
			CSet cset = new CSet((decl.getChild(0).getNodeValue()).toString(),Integer.parseInt(decl.getChild(1).getNodeValue()),Integer.parseInt(decl.getChild(decl.getNumChildren()-1).getNodeValue()));
			listSets.put(cset.getName(), cset);
		}
	}
	
	private void visitProperties(Noeud node) {
		//System.out.println(node.getNodeName());
		for(int i=0; i< node.getNumChildren();i++){
			//System.out.println(node.getChild(i).getNodeName());
			Noeud fn = node.getChild(i);
			
			if(fn.getNodeName().equals("Equal")){
				String cons = fn.getChild(0).getChild(0).getNodeValue();
				//System.out.println(cons);
				if(listConst.containsKey(cons)){
					CConstant cc = listConst.get(cons);
					cc.setValue(Integer.parseInt(fn.getChild(1).getNodeValue()));
					listConst.put(cc.getName(), cc);
					//System.out.println(cc);
				}
			}
			else{
				visitProperties(fn);
			}
		}
	}
	
	
	private void visitDefinitions(Noeud node) {
		for(int i=0; i< node.getNumChildren();i++){
			Noeud def = node.getChild(i);
			CSet cset = new CSet((def.getChild(0).getChild(0).getChild(0).getNodeValue()).toString());
			if(def.getChild(1).getChild(0).getNodeName().equals("Integer")){
				cset.setBorMin(Integer.parseInt(def.getChild(1).getChild(0).getNodeValue()));
			}
			else{
				
				cset.setBorMin(listConst.get(def.getChild(1).getChild(0).getChild(0).getNodeValue()).getValue());
			}
			
			if(def.getChild(1).getChild(1).getNodeName().equals("Integer")){
				cset.setBornMax(Integer.parseInt(def.getChild(1).getChild(1).getNodeValue()));
			}
			else{
				cset.setBornMax(listConst.get(def.getChild(1).getChild(1).getChild(0).getNodeValue()).getValue());
			}
			//System.out.println(cset);
			listSets.put(cset.getName(), cset);
		}
	}




	@SuppressWarnings("unchecked")
	public Object visitInvariant(Noeud node) {
		Element cInvariant = new Element("INVARIANT");
		for(int i=0; i< node.getNumChildren();i++){
			//System.out.println(node.getChild(i).getNodeName());
			Object elt = node.getChild(i).accept(this);
			if(elt instanceof Element){
				cInvariant.addContent((Element)elt);
			}
			else{
				cInvariant.addContent((Collection<Element>)elt);
			}
		}
		return cInvariant;
	}

	public  Object visitInitialisation(Noeud node) {
		Element cInit = new Element("INITIALISATION");
		//System.out.println(node.getNumChildren());
		for(int i=0; i< node.getNumChildren();i++){
			//System.out.println(node.getNumChildren());
			cInit.addContent((Element)node.getChild(i).accept(this));
		}
		return cInit;
	}

	private Object visitExtensionSet(Noeud node) {
		return (Element)node.getChild(0).accept(this);
	}

	//************************************Visite des expression boolean **********************************************
	@SuppressWarnings("unchecked")
	@Override
	public Object visitAnd(Noeud node) {
		Element cCAnd = new Element("CAnd");
		for(int i=0; i< node.getNumChildren();i++){
			if(node.getChild(i).getNodeName().equals("And")){
				for(int j=0; j < node.getChild(i).getNumChildren(); j++){
					Object elt = node.getChild(i).getChild(j).accept(this);
					if(elt instanceof Element){
						cCAnd.addContent((Element)elt);
					}else{
						cCAnd.addContent((Collection<Element>)elt);
					}
				}
			}
			else{
				//cCAnd.addContent((Element)node.getChild(i).accept(this));
				Object elt = node.getChild(i).accept(this);
				if(elt instanceof Element){
					cCAnd.addContent((Element)elt);
				}else{
					cCAnd.addContent((Collection<Element>)elt);
				}
			}
		}
		return cCAnd;
	}

	@Override
	public Object visitIn(Noeud node) {
		Element cn = null;
		Noeud n =  node.getChild(1);
		if(n.getNodeName().equals("IntegerSet")){
			if(n.getNodeValue().equals("NAT")){
				cn = new Element("CInDomain");
				cn.setAttribute("type", "0");
				cn.addContent((Element)node.getChild(0).getChild(0).accept(this));
			}
		}
		else if(n.getNodeName().equals("NatRange")){
			Collection<Element> cl = new ArrayList<Element>();
			Element g1 = new Element("CGreater");
			Element g2 = new Element("CGreater");
			
			g1.addContent((Element)node.getChild(0).accept(this));
			if(n.getChild(0).getNodeName().equals("IdentifierComposed")){
				if(listConst.containsKey(n.getChild(0).getChild(0).getNodeValue())){
					//System.out.println(n.getChild(0).getChild(0).getNodeValue());
					Element e = new Element("CNumber");
					e.setAttribute("val",""+(listConst.get(n.getChild(0).getChild(0).getNodeValue())).getValue());
					g1.addContent(e);
				}
			}
			else{
				g1.addContent((Element)n.getChild(0).accept(this));
			}
			cl.add(g1);
			
			if(n.getChild(n.getNumChildren()-1).getNodeName().equals("IdentifierComposed")){
				if(listConst.containsKey(n.getChild(n.getNumChildren()-1).getChild(0).getNodeValue())){
					
					Element e = new Element("CNumber");
					e.setAttribute("val",""+(listConst.get(n.getChild(n.getNumChildren()-1).getChild(0).getNodeValue())).getValue());
					g2.addContent(e);
				}
			}
			else{
				g2.addContent((Element)n.getChild(n.getNumChildren()-1).accept(this));
			}
			//g2.addContent((Element)n.getChild(n.getNumChildren()-1).accept(this));
			g2.addContent((Element)node.getChild(0).accept(this));
			cl.add(g2);
			return cl;
		}
		else if(n.getNodeName().equals("Minus")){
			CSet cset = listSets.get(node.getChild(1).getChild(0).getNodeValue());
			int bormin = cset.getBorMin()-1;
			int bormax = cset.getBornMax()+1;
			
			Element cExist = new Element("CExist");
			Element cVarList = new Element("VariablesList");
			//Element cVar = new Element("CVariable");
			//cVar.setAttribute("val","i");
			
			cVarList.addContent((Element)node.getChild(0).getChild(0).accept(this));
			
			
			Element cAnd = new Element("CAnd");
			Element cIn = new Element("CInDomain");
			cIn.setAttribute("type","0");
			cIn.addContent(((Element)node.getChild(0).getChild(0).accept(this)).clone());
			
			Element cGrea = new Element("CGreater");
			cGrea.addContent(((Element)node.getChild(0).getChild(0).accept(this)).clone());
			Element ct = new Element("CNumber");
			ct.setAttribute(new Attribute("val",String.valueOf(bormin)));
			cGrea.addContent(ct);
			
			Element cGrea1 = new Element("CGreater");
			Element ct1 = new Element("CNumber");
			ct1.setAttribute(new Attribute("val",String.valueOf(bormax)));
			cGrea1.addContent(ct1);
			cGrea1.addContent(((Element)node.getChild(0).getChild(0).accept(this)).clone());
			
			cAnd.addContent(cIn);
			cAnd.addContent(cGrea);
			cAnd.addContent(cGrea1);
			
			
			for(int i=0; i<n.getChild(1).getChild(0).getNumChildren();i++){
				Element cNot = new Element("CNot");
				Element cEqual = new Element("CEquals");
				cEqual.addContent(((Element)node.getChild(0).getChild(0).accept(this)).clone());
				cEqual.addContent((Element)n.getChild(1).getChild(0).getChild(i).accept(this));
				cNot.addContent(cEqual);
				cAnd.addContent(cNot);
			}
			
			cExist.addContent(cVarList);
			cExist.addContent(cAnd);
			/*Element cAss = new Element("CEquals");
			cAss.addContent((Element)node.getChild(0).getChild(0).accept(this));
			cAss.addContent(cVar.clone());*/
			
			//cAnd.addContent(cAss);
			return cExist;			
		}
		else if(n.getNodeName().equals("ExtensionSet")){
			Element cOr = new Element("COr");
			for(int i=0;i<n.getChild(0).getNumChildren();i++){
				Element cEq = new Element("CEquals");
				cEq.addContent((Element)node.getChild(0).accept(this));
				cEq.addContent((Element)n.getChild(0).getChild(i).accept(this));
				cOr.addContent(cEq);
			}
			return cOr;			
		}
		else if(!listSets.isEmpty()){
			
			Collection<Element> cl = new ArrayList<Element>();
			Element g1 = new Element("CGreater");
			Element g2 = new Element("CGreater");
			CSet cset = listSets.get(node.getChild(1).getChild(0).getNodeValue());
			int bormin = cset.getBorMin()-1;
			int bormax = cset.getBornMax()+1;
			g1.addContent((Element)node.getChild(0).getChild(0).accept(this));
			Element ct = new Element("CNumber");
			ct.setAttribute(new Attribute("val",String.valueOf(bormin)));
			
			Element ct1 = new Element("CNumber");
			ct1.setAttribute(new Attribute("val",String.valueOf(bormax)));
			
			g1.addContent(ct);
			cl.add(g1);
			
			g2.addContent(ct1);
			g2.addContent((Element)node.getChild(0).getChild(0).accept(this));
			cl.add(g2);
			return cl;
		}
		/*else{

			//System.out.println(n.getNodeName());
			//cn = new Element("CInDomain");
			//cn.setAttribute("type", "0");
			//cn.addContent((Element)node.getChild(0).getChild(0).accept(this));

		}*/
		return cn;
	}

	@Override
	public Object visitEqual(Noeud node) {
		Element cCEquals = new Element("CEquals");
		//System.out.println(node.getChild(0).getNodeName());
		cCEquals.addContent((Element) node.getChild(0).accept(this));
		cCEquals.addContent((Element)node.getChild(1).accept(this));
		return cCEquals;
	}

	@Override
	public Object visitGreatherThan(Noeud node) {
		Element cCEquals = new Element("CGreater");
		//System.out.println(node.getChild(0).getNodeName());
		cCEquals.addContent((Element) node.getChild(0).accept(this));
		cCEquals.addContent((Element)node.getChild(1).accept(this));
		return cCEquals;
	}

	@Override
	public Object visitParallel(Noeud node) {
		Element cParallel = new Element("CParallel");
		for(int i=0;i<node.getNumChildren();i++){
			if(node.getChild(i).getNodeName().equals("Parallel")){
				for(int j=0; j < node.getChild(i).getNumChildren(); j++)
					cParallel.addContent((Element)node.getChild(i).getChild(j).accept(this));
			}
			else{
				
				
				/*if(!node.getChild(i).getNodeName().equals("SubstitutionAny"))
				{*/
					//System.out.println(node.getChild(i).getNodeName());
				
				cParallel.addContent((Element)node.getChild(i).accept(this));
				//}
			}
		}
		return cParallel;
	}

	//************************************Visite des operations  **********************************************
	@Override
	public Object visitAssignment(Noeud node) {
		Element cCAssignment = null;
		if(node.getChild(0).getNumChildren() > 1){
			cCAssignment = new Element("CMultipleAssignment");
			for(int i=0; i< node.getChild(0).getNumChildren();i++){
				Element cAssign = new Element("CAssignment");
				cAssign.addContent((Element)node.getChild(0).getChild(i).accept(this));
				cAssign.addContent((Element)node.getChild(1).getChild(i).accept(this));
				cCAssignment.addContent(cAssign);
			}
		}
		else{
			cCAssignment = new Element("CAssignment");
			cCAssignment.addContent((Element)node.getChild(0).accept(this));
			cCAssignment.addContent((Element)node.getChild(1).accept(this));
			
		}
		return cCAssignment;
			
	}


	private Object visitOperations(Noeud node) {
		Element cEvent = new Element("EVENTS");
		for(int i=0;i<node.getNumChildren();i++){
			cEvent.addContent((Element)node.getChild(i).accept(this));
		}
		return cEvent;
	}


	private Object visitOperation(Noeud node) {
		Element cOperation = null;
		if(node.getChild(0) == null){
			throw new NullPointerException("Header required !");
		}

		//System.out.println(node.getChild(node.getNumChildren()-1).getNodeName());
		if(node.getChild(node.getNumChildren()-1).getNodeName().equals("SubstitutionSelect") ||
				node.getChild(node.getNumChildren()-1).getNodeName().equals("SubstitutionPrecondition")){
			cOperation = new Element("CGuardedEvent");
		}
		else if(node.getChild(node.getNumChildren()-1).getNodeName().equals("SubstitutionBegin")){
			cOperation = new Element("CNonGuardedEvent");
		}
		else if(node.getChild(node.getNumChildren()-1).getNodeName().equals("SubstitutionAny")){
			cOperation = new Element("CAnyEvent");
		}
		cOperation.setAttribute("name", node.getChild(0).getChild(0).getChild(0).getNodeValue());
		for(int i=0;i<node.getChild(1).getNumChildren();i++){
			//if(!node.getChild(1).getChild(i).getNodeName().equals("Then"))
			cOperation.addContent((Element)node.getChild(1).getChild(i).accept(this));
			//System.out.println(node.getChild(1).getChild(i).getNodeName());
		}
		return cOperation;
	}

	private Object visitThen(Noeud node) {
		//System.out.println(node.getNumChildren());
		return (Element)node.getChild(0).accept(this);
	}

	@Override
	public Object visitSubstitutionSelect(Noeud node) {

		return null;
	}
	
	@SuppressWarnings("unchecked")
	public Object visitAny(Noeud node) {
		Element cAny = new Element("CAny");
		for(int i=0;i<node.getNumChildren();i++){
			Object elt = node.getChild(i).accept(this);
			if(elt instanceof Element){
				cAny.addContent((Element)elt);
			}else{
				cAny.addContent((Collection<Element>)elt);
			}
		}
		return cAny;
	}

	//************************************Visite des operations arithmetiques **********************************************

	@Override
	public Object visitPlus(Noeud node) {
		Element cPlus = new Element("CPlus");
		for(int i=0;i<node.getNumChildren();i++){
			cPlus.addContent((Element)node.getChild(i).accept(this));
		}
		return cPlus;
	}


	@Override
	public Object visitMinus(Noeud node) {
		Element cMinus = new Element("CMinus");
		for(int i=0;i<node.getNumChildren();i++){
			cMinus.addContent((Element)node.getChild(i).accept(this));
		}
		return cMinus;
	}


	@Override
	public Object visitMult(Noeud node) {
		Element cMult = new Element("CMult");
		for(int i=0;i<node.getNumChildren();i++){
			cMult.addContent((Element)node.getChild(i).accept(this));
		}
		return cMult;
	}

	@SuppressWarnings("unchecked")
	@Override
	public Object visitNot(Noeud node) {
		Element cNot = new Element("CNot");
		Object elt = node.getChild(0).accept(this);
		if(elt instanceof Element){
			cNot.addContent((Element)elt);
		}else{
			cNot.addContent((Collection<Element>)elt);
		}
		return cNot;
	}


	@SuppressWarnings("unchecked")
	@Override
	public Object visitOr(Noeud node) {
		Element cCAnd = new Element("COr");
		for(int i=0; i< node.getNumChildren();i++){
			if(node.getChild(i).getNodeName().equals("Or")){
				for(int j=0; j < node.getChild(i).getNumChildren(); j++){
					Object elt = node.getChild(i).getChild(j).accept(this);
					if(elt instanceof Element){
						cCAnd.addContent((Element)elt);
					}else{
						cCAnd.addContent((Collection<Element>)elt);
					}
				}
			}
			else{
				Object elt = node.getChild(i).accept(this);
				if(elt instanceof Element){
					cCAnd.addContent((Element)elt);
				}else{
					cCAnd.addContent((Collection<Element>)elt);
				}
			}
		}
		return cCAnd;
	}


	@SuppressWarnings("unchecked")
	@Override
	public Object visitIf(Noeud node) {
		
		Element cIf = new Element("CIf");
		for(int i=0;i<node.getNumChildren();i++){
			Object elt = node.getChild(i).accept(this);
			if(elt instanceof Element){
				cIf.addContent((Element)elt);
			}else{
				cIf.addContent((Collection<Element>)elt);
			}
		}
		if(!node.getChild(node.getNumChildren()-1).getNodeName().equals("Else")){
			cIf.addContent(new Element("CSkip"));
		}
		return cIf;
	}



	@Override
	public Object visitExists(Noeud node) {
		// TODO Auto-generated method stub
		return null;
	}


}


/* Trouver ou se trouve le traitement des entier naturel dans hadara
pretraiter les ensembles enumerée (avec python) remplecer ETATS = {libre, occupe} par ETATS = {1,2}
revoir la grammaire pour qu'elle accepte plusieurs declaton de Sets
Revoir le visiteur sur ListExpression

FAIRE LA 2eme partie des set et NatRange c.a.d a > 0 & 3 > a
Idées pour les sets: conserver les declarations avec les identifiants comme literaux et faire correspondre des numero lors de la visite des noeuds
 */