package noeud;

public interface IEventBVisitor{
	public Object visitParallel(Noeud node);
	public Object visitAssignment(Noeud node);
	public Object visitSubstitutionSelect(Noeud node);
	public Object visitAny(Noeud node);
	public Object visitIf(Noeud node);
	/*
	public Object visit(CSubstitution node, Object data);
	public Object visit(CSkip node, Object data);
	public Object visit(CMultipleAssignment node, Object data); done
	public Object visit(CNDChoice node, Object data);
	public Object visit(CGuarded node, Object data);done
	
	
	public Object visit(CNonGuardedEvent node, Object data); done
	
	public Object visit(CAnyEvent node, Object data);
	
*/
}
