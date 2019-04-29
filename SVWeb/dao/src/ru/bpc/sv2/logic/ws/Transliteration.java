package ru.bpc.sv2.logic.ws;

public class Transliteration {

	public String transliterate(String rusName, boolean toUpperCase) {
		String engName = "";
		for (int i = 0; i < rusName.length(); i++) {
			switch (rusName.charAt(i)) {
				case ('\u0410'): engName += "A"; break;
				case ('\u0411'): engName += "B"; break;
				case ('\u0412'): engName += "V"; break;
				case ('\u0413'): engName += "G"; break;
				case ('\u0414'): engName += "D"; break;
				case ('\u0415'): engName += "E"; break;
				case ('\u0401'): engName += "E"; break;
				case ('\u0416'): engName += "Zh"; break;
				case ('\u0417'): engName += "Z"; break;
				case ('\u0418'): engName += "I"; break;
				case ('\u0419'): engName += "I"; break;
				case ('\u041A'): engName += "K"; break;
				case ('\u041B'): engName += "L"; break;
				case ('\u041C'): engName += "M"; break;
				case ('\u041D'): engName += "N"; break;
				case ('\u041E'): engName += "O"; break;
				case ('\u041F'): engName += "P"; break;
				case ('\u0420'): engName += "R"; break;
				case ('\u0421'): engName += "S"; break;
				case ('\u0422'): engName += "T"; break;
				case ('\u0423'): engName += "U"; break;
				case ('\u0424'): engName += "F"; break;
				case ('\u0425'): engName += "Kh"; break;
				case ('\u0426'): engName += "Tc"; break;
				case ('\u0427'): engName += "Ch"; break;
				case ('\u0428'): engName += "Sh"; break;
				case ('\u0429'): engName += "Shch"; break;
				case ('\u042A'): break;
				case ('\u042B'): engName += "Y"; break;
				case ('\u042C'): break;
				case ('\u042D'): engName += "E"; break;
				case ('\u042E'): engName += "Iu"; break;
				case ('\u042F'): engName += "Ia"; break;
				case ('\u0430'): engName += "a"; break;
				case ('\u0431'): engName += "b"; break;
				case ('\u0432'): engName += "v"; break;
				case ('\u0433'): engName += "g"; break;
				case ('\u0434'): engName += "d"; break;
				case ('\u0435'): engName += "e"; break;
				case ('\u0451'): engName += "e"; break;
				case ('\u0436'): engName += "zh"; break;
				case ('\u0437'): engName += "z"; break;
				case ('\u0438'): engName += "i"; break;
				case ('\u0439'): engName += "i"; break;
				case ('\u043A'): engName += "k"; break;
				case ('\u043B'): engName += "l"; break;
				case ('\u043C'): engName += "m"; break;
				case ('\u043D'): engName += "n"; break;
				case ('\u043E'): engName += "o"; break;
				case ('\u043F'): engName += "p"; break;
				case ('\u0440'): engName += "r"; break;
				case ('\u0441'): engName += "s"; break;
				case ('\u0442'): engName += "t"; break;
				case ('\u0443'): engName += "u"; break;
				case ('\u0444'): engName += "f"; break;
				case ('\u0445'): engName += "kh"; break;
				case ('\u0446'): engName += "tc"; break;
				case ('\u0447'): engName += "ch"; break;
				case ('\u0448'): engName += "sh"; break;
				case ('\u0449'): engName += "shch"; break;
				case ('\u044A'): break;
				case ('\u044B'): engName += "y"; break;
				case ('\u044C'): break;
				case ('\u044D'): engName += "e"; break;
				case ('\u044E'): engName += "iu"; break;
				case ('\u044F'): engName += "ia"; break;
				default: engName += rusName.charAt(i); break;
			}
		}

		return toUpperCase ? engName.toUpperCase() : engName;
	}
}
