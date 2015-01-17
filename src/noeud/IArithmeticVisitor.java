package noeud;

public interface IArithmeticVisitor {
	
	public Object visitPlus(Noeud node);
	public Object visitMinus(Noeud node);
	public Object visitMult(Noeud node);
	/*
	public Object visit(CArithmeticTerm node, Object data);
	 */
}
