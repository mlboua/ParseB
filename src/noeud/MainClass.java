package noeud;

import grammaire.BParser;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;

import org.jdom2.Document;
import org.jdom2.Element;
import org.jdom2.output.Format;
import org.jdom2.output.XMLOutputter;

public class MainClass {

	public static void main(String[] args) {

		BToXMLVisiteur visitor = new BToXMLVisiteur();
		XMLOutputter xmlOutput = new XMLOutputter();
		try {
			Noeud bComponent  = BParser.analyse (new File("ressources/ESSUYAGE_AV.mch"));
			BParser.writeXMLFileAfterParsing((Noeud)bComponent, "robot.xml");
			Element xMachine = null;
			try {
				xMachine = (Element) visitor.visit(bComponent);
			} catch (Exception e) {
				e.printStackTrace();
			}
			
			Document doc = new Document(xMachine);


			xmlOutput.setFormat(Format.getPrettyFormat());
			xmlOutput.output(doc, new FileWriter("file.ebm"));
		} catch (BParserException | AfterParserException | IOException e) {
			e.printStackTrace();
		}

	}

}
