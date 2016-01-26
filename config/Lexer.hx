package config;

import hxparse.Parser.parse as parse;
import hxparse.Position;

enum TToken {
	TBraceOpen(?p:Position);
	TBraceClose(?p:Position);
	TComma(?p:Position);
	TColon(?p:Position);
	TBracketOpen(?p:Position);
	TBracketClose(?p:Position);
	TDash(?p:Position);
	TDot(?p:Position);
	TTrue(?p:Position);
	TFalse(?p:Position);
	TNull(?p:Position);
	TNumber(v:String, ?p:Position);
	TString(v:String, ?p:Position);
	TEof;
}

/**
 * @brief      Basically https://github.com/Simn/hxparse/blob/development/test/JSONParser.hx but with added position information
 */
class Lexer extends hxparse.Lexer implements hxparse.RuleBuilder {
	static var stringBuffer:StringBuf;
	static var stringEnd:Int;

	public static var tokenRules =  hxparse.Lexer.buildRuleset([
		{ // ignore whitespace
			rule: "[\r\n\t ]",
			func: function(lexer:hxparse.Lexer) {
				return lexer.token(tokenRules);
			}
		},
		{
			rule: "{",
			func: function(lexer:hxparse.Lexer) {
				return TBraceOpen(lexer.curPos());
			}
		},
		{
			rule: "}",
			func: function(lexer:hxparse.Lexer) {
				return TBraceClose(lexer.curPos());
			}
		},
		{
			rule: ",",
			func: function(lexer:hxparse.Lexer) {
				return TComma(lexer.curPos());
			}
		},
		{
			rule: ":",
			func: function(lexer:hxparse.Lexer) {
				return TColon(lexer.curPos());
			}
		},
		{
			rule: "[",
			func: function(lexer:hxparse.Lexer) {
				return TBracketOpen(lexer.curPos());
			}
		},
		{
			rule: "]",
			func: function(lexer:hxparse.Lexer) {
				return TBracketClose(lexer.curPos());
			}
		},
		{
			rule: "-",
			func: function(lexer:hxparse.Lexer) {
				return TDash(lexer.curPos());
			}
		},
		{
			rule: "\\.",
			func: function(lexer:hxparse.Lexer) {
				return TDot(lexer.curPos());
			}
		},
		{
			rule: "true",
			func: function(lexer:hxparse.Lexer) {
				return TTrue(lexer.curPos());
			}
		},
		{
			rule: "false",
			func: function(lexer:hxparse.Lexer) {
				return TFalse(lexer.curPos());
			}
		},
		{
			rule: "null",
			func: function(lexer:hxparse.Lexer) {
				return TNull(lexer.curPos());
			}
		},
		{
			rule: "-?(([1-9][0-9]*)|0)(.[0-9]+)?([eE][\\+\\-]?[0-9]?)?",
			func: function(lexer:hxparse.Lexer) {
				return TNumber(lexer.current, lexer.curPos());
			}
		},
		{
			rule: '"',
			func: function(lexer:hxparse.Lexer) {
				// clear the string buffer for use
				stringBuffer = new StringBuf();
				// remember where the start of the string is
				var pos:Position = lexer.curPos();
				// hand the tokenizing over to the string rule set
				lexer.token(string);
				// update our position range appropriately
				pos.pmax = stringEnd;
				// we have a string token!
				return TString(stringBuffer.toString(), pos);
			}
		},
		{
			rule: "",
			func: function(lexer:hxparse.Lexer) {
				return TEof;
			}
		},
	]);

	static var string = @:rule [
		// escaped tabs
		"\\\\t" => {
			stringBuffer.addChar("\t".code);
			lexer.token(string);
		},
		// escaped new lines
		"\\\\n" => {
			stringBuffer.addChar("\n".code);
			lexer.token(string);
		},
		// escaped returns
		"\\\\r" => {
			stringBuffer.addChar("\r".code);
			lexer.token(string);
		},
		// escaped quotes
		'\\\\"' => {
			stringBuffer.addChar('"'.code);
			lexer.token(string);
		},
		// unicode strings
		"\\\\u[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]" => {
			stringBuffer.add(String.fromCharCode(Std.parseInt("0x" +lexer.current.substr(2))));
			lexer.token(string);
		},
		// TODO: ?
		// is this the end?
		'"' => {
			stringEnd = lexer.curPos().pmax;
			lexer.curPos().pmax;
		},
		// anything else that isn't a quote
		'[^"]' => {
			stringBuffer.add(lexer.current);
			lexer.token(string);
		},
	];
}