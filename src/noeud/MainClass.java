package noeud;

//import grammaire.BParser;
import static grammaire.BParser.*;
import grammaire.BParser;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;

public class MainClass {

	public static void main(String[] args) throws BParserException, AfterParserException {
		
		if(args.length < 2){
			System.out.println("Vous devez donner les noms des fichiers source et cible comme arguments de la commande !");
			System.exit(-1);
		}
		
		String source = args[0], outputfile = args[1];
		BToXMLVisiteur visitor = new BToXMLVisiteur();
		XMLOutputter xmlOutput = new XMLOutputter();
		try {
			Noeud bComponent  = analyse (new File(source));
			BParser.writeXMLFileAfterParsing((Noeud)bComponent, "robot.xml");
			Element xMachine = null;
			try {
				xMachine = (Element) visitor.visit( bComponent);
				//xMachine = (Element) visitor.visit( analyse (new File(source)));
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			Document doc = new Document(xMachine);

			xmlOutput.setFormat(Format.getPrettyFormat());
			//xmlOutput.output(doc, new FileWriter("robot.ebm"));
			xmlOutput.output(doc, new FileWriter(outputfile));
		} catch (IOException e) {
			e.printStackTrace();
		}

	}

}
