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
			Noeud bComponent  = BParser.analyse (new File("./ESSUYAGE_AV1.mch"));
			BParser.writeXMLFileAfterParsing((Noeud)bComponent, "robot.xml");
			Element xMachine = (Element) visitor.visit(bComponent);
			Document doc = new Document(xMachine);


			xmlOutput.setFormat(Format.getPrettyFormat());
			xmlOutput.output(doc, new FileWriter("file.xml"));
			//xMachine.toString();
			//System.out.println(xMachine.toString());
		} catch (BParserException | AfterParserException | IOException e) {
			e.printStackTrace();
		}

	}

}
