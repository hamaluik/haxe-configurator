import config.Lexer;
import hxparse.Position;

using Lambda;

class Sample {
	static function sanitizeCharacterDisplay(input:String):String {
		var s:StringBuf = new StringBuf();
		for(i in 0...input.length) {
			s.add(switch(input.charAt(i)) {
				/*case '\r': '\\r';
				case '\n': '\\n';
				case '\t': '\\t';
				case ' ': '[space]';*/
				case '\r': ' ';
				case '\n': ' ';
				case '\t': ' ';
				case ' ': ' ';
				default: input.charAt(i);
			});
		}
		return s.toString();
	}

	static function drawErrorLocation(s:String, p:Position):String {
		var b:byte.ByteData = byte.ByteData.ofString(s);
		var lineStart:Int = 0;
		for(i in 1...p.pmin) {
			if(b.readByte(i) == "\n".code) {
				lineStart = i + 1;
			}
		}
		var lineEnd:Int = 0;
		for(i in lineStart...b.length) {
			lineEnd = i + 1;
			if(b.readByte(i) == "\n".code) {
				lineEnd--;
				break;
			}
		}
		var spaces:StringBuf = new StringBuf();
		spaces.add(sanitizeCharacterDisplay(s.substr(lineStart, lineEnd - lineStart)));
		spaces.add("\n");
		for(i in lineStart...p.pmin) {
			spaces.add(" ");
		}
		spaces.add("^");
		return spaces.toString();
	}

	static public function main() {
		var testString:String = sys.io.File.getContent('test.json');
		var b:byte.ByteData = byte.ByteData.ofString(testString);
		var lexer = new Lexer(b, "test.json");
		var tokens:Array<config.Lexer.TToken> = new Array<config.Lexer.TToken>();
		try {
			var token:config.Lexer.TToken = null;
			while(token != config.Lexer.TToken.TEof) {
				token = lexer.token(Lexer.tokenRules);
				tokens.push(token);
			}
		}
		catch(ex:hxparse.UnexpectedChar) {
			Sys.println('Unexpected character \'${sanitizeCharacterDisplay(ex.char)}\' at ${ex.pos.format(b)}');
			Sys.println('${drawErrorLocation(testString, ex.pos)}');
		}
		catch(ex:haxe.io.Eof) {
			Sys.println("Lexing complete, result: ");
			Sys.println(tokens);
		}
	}
}