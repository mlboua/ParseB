package noeud;

public interface IBooleanVisitor extends IArithmeticVisitor {
	
	//public Object visit(CBooleanExpression node, Object data);
	public Object visitAnd(Noeud node);
	public Object visitIn(Noeud node);
	public Object visitNot(Noeud node);
	public Object visitOr(Noeud node);
	public Object visitExists(Noeud node);
	//public Object visitInDomain(Noeud node);
	public Object visitEqual(Noeud node);
	public Object visitGreatherThan(Noeud node);
	/*public Object visit(CBooleanAtom node);done
	
	public Object visit(CForall node);	
	
	*/
}
