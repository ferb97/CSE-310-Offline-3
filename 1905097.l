%option noyywrap yylineno

%{
#include<bits/stdc++.h>
#include"1905097.cpp"
#include"y.tab.h"

using namespace std;

extern ofstream logout;
//ofstream tokenout;

extern YYSTYPE yylval;
//extern int line_count=1;
extern int error_count;
void yyerror(char *);
//void yyerror(char *);
//extern int scopeTableID=0;
//extern int bucketLength=10;

//SymbolTable symbolTable;

map<char, string> escapeCharIdentifier={
	{'\'',"\'"},
	{'\"',"\""},
	{'n',"\n"},
	{'t',"\t"},
	{'\\',"\\"},
	{'a',"\a"},
	{'f',"\f"},
	{'r',"\r"},
	{'b', "\b"},
	{'v', "\v"},
	{'0', "\0"}
};

//string str;
//int strStart;

void printKeyword(string token, string keyword){
	logout<<"Line# "<<yylineno<<": Token <"<<token<<"> Lexeme "<<keyword<<" found"<<endl;
	//tokenout<<"<"<<token<<", "<<keyword<<">"<<endl;
}

void printOperatorPunctuator(string token, string operatorPunctuator){
	logout<<"Line# "<<yylineno<<": Token <"<<token<<"> Lexeme "<<operatorPunctuator<<" found"<<endl;
	//tokenout<<"<"<<token<<", "<<operatorPunctuator<<">"<<endl;
}

%}

WHITESPACE [ \t\v]+ 
LETTER [a-zA-Z]
DIGIT [0-9]
EXPONENT [Ee][+-]?{DIGIT}+
NEWLINE (\r)?\n
CONST_INT {DIGIT}+
CONST_FLOAT {DIGIT}*(\.{DIGIT}+)?{EXPONENT}?
CONST_CHAR \'[^\'\\\n\r]\'
CONST_ESCAPE_CHAR \'\\[nt\\'afrbv0]\'
IDENTIFIER [a-zA-Z_][a-zA-Z0-9_]*
TOO_MANY_DECIMAL_POINTS {DIGIT}*(\.{DIGIT}*)+(\.{DIGIT}*)+{EXPONENT}?
ILLFORMED_NUMBER {DIGIT}*[Ee][+-]?{DIGIT}*(\.{DIGIT}*)+
INVALID_ID_SUFFIX_NUM_PREFIX {CONST_FLOAT}+{IDENTIFIER}+
MULTICHAR_CONST_CHAR \'[^\'\n\r][^\'\n\r]+\'
UNFINISHED_CONST_CHAR \'(\\\')?[^\'\n\r]?
EMPTY_CONST_CHAR \'\'

%%

{WHITESPACE} {}
{NEWLINE} {}

"if"	{
			printKeyword("IF", "if");
			yylval.symbol=new SymbolInfo(yytext, "IF", yylineno, yylineno);
			return IF;
		}
		
"else"	{
			printKeyword("ELSE", "else");
			yylval.symbol=new SymbolInfo(yytext, "ELSE", yylineno, yylineno);
			return ELSE;
		}

"for"	{
			printKeyword("FOR", "for");
			yylval.symbol=new SymbolInfo(yytext, "FOR", yylineno, yylineno);
			return FOR;
		}		

"while"	{
			printKeyword("WHILE", "while");
			yylval.symbol=new SymbolInfo(yytext, "WHILE", yylineno, yylineno);
			return WHILE;
		}

"do"	{
			printKeyword("DO", "do");
			yylval.symbol=new SymbolInfo(yytext, "DO", yylineno, yylineno);
			return DO;
		}

"break"	{
			printKeyword("BREAK", "break");
			yylval.symbol=new SymbolInfo(yytext, "BREAK", yylineno, yylineno);
			return BREAK;
		}

"int"	{
			printKeyword("INT", "int");
			yylval.symbol=new SymbolInfo(yytext, "INT", yylineno, yylineno);
			return INT;
		}

"char"	{
			printKeyword("CHAR", "char");
			yylval.symbol=new SymbolInfo(yytext, "CHAR", yylineno, yylineno);
			return CHAR;
		}

"float"	{
			printKeyword("FLOAT", "float");
			yylval.symbol=new SymbolInfo(yytext, "FLOAT", yylineno, yylineno);
			return FLOAT;
		}

"double" { 
			printKeyword("DOUBLE", "double");
			yylval.symbol=new SymbolInfo(yytext, "DOUBLE", yylineno, yylineno);
			return DOUBLE;
		 }

"void"	{
			printKeyword("VOID", "void");
			yylval.symbol=new SymbolInfo(yytext, "VOID", yylineno, yylineno);
			return VOID;
		}

"return" {
			printKeyword("RETURN", "return");
			yylval.symbol=new SymbolInfo(yytext, "RETURN", yylineno, yylineno);
			return RETURN;
		 }

"switch" {
			printKeyword("SWITCH", "switch");
			yylval.symbol=new SymbolInfo(yytext, "SWITCH", yylineno, yylineno);
			return SWITCH;
		 }

"case"	{
			printKeyword("CASE", "case");
			yylval.symbol=new SymbolInfo(yytext, "CASE", yylineno, yylineno);
			return CASE;
		}

"default" {
			printKeyword("DEFAULT", "default");
			yylval.symbol=new SymbolInfo(yytext, "DEFAULT", yylineno, yylineno);
			return DEFAULT;
		  }

"continue" {
			printKeyword("CONTINUE", "continue");
			yylval.symbol=new SymbolInfo(yytext, "CONTINUE", yylineno, yylineno);
			return CONTINUE;
		   }

"printf"	{
				printKeyword("PRINTLN", "printf");
				yylval.symbol=new SymbolInfo(yytext, "PRINTLN", yylineno, yylineno);
				return PRINTLN;
			}


{CONST_INT} {
	         	logout<<"Line# "<<yylineno<<": Token <CONST_INT> Lexeme "<<yytext<<" found"<<endl;
				//tokenout<<"<CONST_INT, "<<yytext<<">"<<endl;
				yylval.symbol=new SymbolInfo(yytext, "CONST_INT", yylineno, yylineno);
				return CONST_INT;
			}

{CONST_FLOAT}	{
					logout<<"Line# "<<yylineno<<": Token <CONST_FLOAT> Lexeme "<<yytext<<" found"<<endl;
					yylval.symbol=new SymbolInfo(yytext, "CONST_FLOAT", yylineno, yylineno);
					return CONST_FLOAT;
					//tokenout<<"<CONST_FLOAT, "<<yytext<<">"<<endl;
				}

{CONST_CHAR}	{
					string str2="";
					str2 += yytext[1];
					logout<<"Line# "<<yylineno<<": Token <CONST_CHAR> Lexeme "<<str2<<" found"<<endl;
					yylval.symbol=new SymbolInfo(yytext, "CONST_CHAR", yylineno, yylineno);
					return CONST_CHAR;
					//tokenout<<"<CONST_CHAR, "<<str2<<">"<<endl;
				}	

{CONST_ESCAPE_CHAR}	{
						string str2=escapeCharIdentifier[yytext[2]];
						logout<<"Line# "<<yylineno<<": Token <CONST_CHAR> Lexeme "<<str2<<" found"<<endl;
						yylval.symbol=new SymbolInfo(yytext, "CONST_CHAR", yylineno, yylineno);
						return CONST_CHAR;
						//tokenout<<"<CONST_CHAR, "<<str2<<">"<<endl;
					}

[+-]	{
			printOperatorPunctuator("ADDOP", yytext);
			yylval.symbol=new SymbolInfo(yytext, "ADDOP", yylineno, yylineno);
			return ADDOP;
		}

[*/%]	{
			printOperatorPunctuator("MULOP", yytext);
			yylval.symbol=new SymbolInfo(yytext, "MULOP", yylineno, yylineno);
			return MULOP;
		}

"++"	{
			printOperatorPunctuator("INCOP", yytext);
			yylval.symbol=new SymbolInfo(yytext, "INCOP", yylineno, yylineno);
			return INCOP;
		}

"--"	{
			printOperatorPunctuator("DECOP", yytext);
			yylval.symbol=new SymbolInfo(yytext, "DECOP", yylineno, yylineno);
			return DECOP;
		}			

"<"|"<="|">"|">="|"=="|"!="	{
								printOperatorPunctuator("RELOP", yytext);
								yylval.symbol=new SymbolInfo(yytext, "RELOP", yylineno, yylineno);
								return RELOP;
							}

\=	{
		printOperatorPunctuator("ASSIGNOP", yytext);
		yylval.symbol=new SymbolInfo(yytext, "ASSIGNOP", yylineno, yylineno);
		return ASSIGNOP;
	}

"&&"|"||"	{
				printOperatorPunctuator("LOGICOP", yytext);
				yylval.symbol=new SymbolInfo(yytext, "LOGICOP", yylineno, yylineno);
				return LOGICOP;
			}

"&"|"|"|"^"|"<<"|">>"	{
							printOperatorPunctuator("BITOP", yytext);
							yylval.symbol=new SymbolInfo(yytext, "BITOP", yylineno, yylineno);
							return BITOP;
						}

"!"	{
		printOperatorPunctuator("NOT", yytext);
		yylval.symbol=new SymbolInfo(yytext, "NOT", yylineno, yylineno);
		return NOT;
	}

"("	{
		printOperatorPunctuator("LPAREN", yytext);
		yylval.symbol=new SymbolInfo(yytext, "LPAREN", yylineno, yylineno);
		return LPAREN;
	}

")"	{
		printOperatorPunctuator("RPAREN", yytext);
		yylval.symbol=new SymbolInfo(yytext, "RPAREN", yylineno, yylineno);
		return RPAREN;
	}																																						   																								

"{"	{
		printOperatorPunctuator("LCURL", yytext);
		//scopeTableID++;
		//symbolTable.enterScope(scopeTableID, bucketLength, logout);
		yylval.symbol=new SymbolInfo(yytext, "LCURL", yylineno, yylineno);
		return LCURL;
	}

"}"	{
		printOperatorPunctuator("RCURL", yytext);
		//symbolTable.exitScope(false, logout);
		yylval.symbol=new SymbolInfo(yytext, "RCURL", yylineno, yylineno);
		return RCURL;
	}

\[	{
		printOperatorPunctuator("LSQUARE", yytext);
		yylval.symbol=new SymbolInfo(yytext, "LSQUARE", yylineno, yylineno);
		return LSQUARE;
	}

\]	{
		printOperatorPunctuator("RSQUARE", yytext);
		yylval.symbol=new SymbolInfo(yytext, "RSQUARE", yylineno, yylineno);
		return RSQUARE;
	}

\,	{
		printOperatorPunctuator("COMMA", yytext);
		yylval.symbol=new SymbolInfo(yytext, "COMMA", yylineno, yylineno);
		return COMMA;
	}

\;	{
		printOperatorPunctuator("SEMICOLON", yytext);
		yylval.symbol=new SymbolInfo(yytext, "SEMICOLON", yylineno, yylineno);
		return SEMICOLON;
	}

{IDENTIFIER}	{
					logout<<"Line# "<<yylineno<<": Token <ID> Lexeme "<<yytext<<" found"<<endl;
					//tokenout<<"<ID, "<<yytext<<">"<<endl;
					//SymbolInfo* symbol = new SymbolInfo(yytext, "ID");

					//if(symbolTable.insertKey(*symbol, logout)){
					//	symbolTable.printAll(logout);
					//}

					yylval.symbol=new SymbolInfo(yytext, "ID", yylineno, yylineno);
					return ID;
				}
				/*	

\"	{
		str=yytext;
		strStart=line_count;
		BEGIN STRING;
	}

<STRING>\\{NEWLINE} {
						str+=yytext;
						line_count++;
					}

<STRING>\\\"	{
					str+=yytext;
				}					

<STRING>[^\"\n\r]	{
						str+=yytext;
					}

<STRING>\"	{
				str+=yytext;

				if(strStart == line_count){
					logout<<"Line# "<<strStart<<": Token <SINGLE LINE STRING> Lexeme "<<str<<" found"<<endl;
				}
				else{
					logout<<"Line# "<<strStart<<": Token <MULTI LINE STRING> Lexeme "<<str<<" found"<<endl;
				}

				string str2="";

				for(int i=1; i<str.length()-1; i++){

					if(str[i] == '\\'){
						str2+=escapeCharIdentifier[str[i+1]];
						i++;
						continue;
					}
					str2+=str[i];
				}

				if(strStart == line_count){
					tokenout<<"<SINGLE LINE STRING, "<<str2<<">"<<endl;
				}
				else{
					tokenout<<"<MULTI LINE STRING, "<<str2<<">"<<endl;
				}

				BEGIN INITIAL;

			}

<STRING>{NEWLINE}	{
						str+=yytext;
						error_count++;
						logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<str;
						line_count++;
						BEGIN INITIAL;
					}

<STRING><<EOF>>	{
					//line_count--;
					error_count++;
					logout<<"Error at line# "<<line_count<<": UNFINISHED_STRING "<<str<<endl;
					symbolTable.printAll(logout);
					logout<<"Total lines: "<<line_count<<endl;
					logout<<"Total errors: "<<error_count<<endl;
					return 0;
				}					


"//"	{
			str=yytext;
			strStart=line_count;
			BEGIN SINGLELINE_COMMENT;
		}


<SINGLELINE_COMMENT>.	{
							str+=yytext;
						}

<SINGLELINE_COMMENT>\\{NEWLINE}	{
									str+=yytext;
									line_count++;
								}

<SINGLELINE_COMMENT>{NEWLINE}	{
									logout<<"Line# "<<strStart<<": Token <SINGLE LINE COMMENT> Lexeme "<<str<<" found"<<endl;
									line_count++;
									BEGIN INITIAL;
								}
																																				
<SINGLELINE_COMMENT><<EOF>>	{
								//line_count--;
								logout<<"Line# "<<strStart<<": Token <SINGLE LINE COMMENT> Lexeme "<<str<<" found"<<endl;
								symbolTable.printAll(logout);
								logout<<"Total lines: "<<line_count<<endl;
								logout<<"Total errors: "<<error_count<<endl;
								return 0;
							}


"/*"	{
			str=yytext;
			strStart=line_count;
			BEGIN MULTILINE_COMMENT;
		}


<MULTILINE_COMMENT>.	{
							str+=yytext;
						}

<MULTILINE_COMMENT>{NEWLINE}	{
									str+=yytext;
									line_count++;
								}

<MULTILINE_COMMENT>"*//*"	{
								str+=yytext;
								logout<<"Line# "<<strStart<<": Token <MULTI LINE COMMENT> Lexeme "<<str<<" found"<<endl;
								BEGIN INITIAL;
							}
																																				
<MULTILINE_COMMENT><<EOF>>	{
								//line_count--;
								error_count++;
								logout<<"Error at line# "<<line_count<<": UNFINISHED_COMMENT "<<str<<endl;
								symbolTable.printAll(logout);
								logout<<"Total lines: "<<line_count<<endl;
								logout<<"Total errors: "<<error_count<<endl;
								return 0;
							}

*/

{TOO_MANY_DECIMAL_POINTS}	{
								logout<<"Error at line# "<<yylineno<<": TOO_MANY_DECIMAL_POINTS "<<yytext<<endl;
								error_count++;
							}

{ILLFORMED_NUMBER}	{
						logout<<"Error at line# "<<yylineno<<": ILLFORMED_NUMBER "<<yytext<<endl;
						error_count++;
					}

{INVALID_ID_SUFFIX_NUM_PREFIX}	{
									logout<<"Error at line# "<<yylineno<<": INVALID_ID_SUFFIX_NUM_PREFIX "<<yytext<<endl;
									error_count++;
								}

{MULTICHAR_CONST_CHAR}	{
							logout<<"Error at line# "<<yylineno<<": MULTICHAR_CONST_CHAR "<<yytext<<endl;
							error_count++;
						}

{UNFINISHED_CONST_CHAR}	{
							logout<<"Error at line# "<<yylineno<<": UNFINISHED_CONST_CHAR "<<yytext<<endl;
							error_count++;
						}

{EMPTY_CONST_CHAR}	{
						logout<<"Error at line# "<<yylineno<<": EMPTY_CONST_CHAR "<<yytext<<endl;
						error_count++;
					}						


<<EOF>>	{
			//symbolTable.printAll(logout);
			//logout<<"Total lines: "<<line_count<<endl;
			//logout<<"Total errors: "<<error_count<<endl;
			return 0;
		}

.	{
		logout<<"Error at line# "<<yylineno<<": UNRECOGNIZED CHAR "<<yytext<<endl;
		error_count++;
	}																

%%

/*
int main(int argc, char** argv) {
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout.open("1905097_log.txt");
	//tokenout.open("1905097_token.txt");

	scopeTableID++;
	symbolTable.enterScope(scopeTableID, bucketLength, logout);

	yyin= fin;
	yylex();
	//st.print();
	fclose(yyin);
	//tokenout.close();
	logout.close();
	return 0;
}
*/
