
%{
    #include<bits/stdc++.h>
    #include"1905097.cpp"
    using namespace std;

    int yyparse(void);
    int yylex(void);
    extern FILE *yyin;
    extern int yylineno;
    int scopeTableID=0;
    int bucketLength=11;
    ofstream logout;
    int error_count=0;
    ofstream parseTreeOut;
    ofstream errorout;

    SymbolTable* symbolTable = new SymbolTable(++scopeTableID, bucketLength);
    vector<pair<SymbolInfo*, SymbolInfo*> > param;
    string variableType;
    vector<SymbolInfo*> variableList;
    vector<SymbolInfo*> argumentList;
    int value = -1;
    int errorLine = -1;

    void yyerror(char *s)
    {
	    //write your code
    }

    void printParseTree(SymbolInfo* symbol, int space){

        for(int i=0;i<space;i++){
            parseTreeOut<<" ";
        }

        if(symbol->getChildList().size() == 0){
            parseTreeOut<<symbol->getType()<<" : "<<symbol->getName()<<"\t"<<"<Line: "<<symbol->getStartLine()<<">"<<endl;
            return;
        }

        else{
            parseTreeOut<<symbol->getType()<<" : "<<symbol->getName()<<" \t"<<"<Line: "<<symbol->getStartLine()<<"-"<<symbol->getEndLine()<<">"<<endl;
        }

        vector<SymbolInfo*> child=symbol->getChildList();
        for(int i=0;i<child.size();i++){
            printParseTree(child[i], space+1);
        }
    }


    void giveFunctionDefinitionWithParameters(SymbolInfo* returnType, SymbolInfo* functionName){

        SymbolInfo* tmp=new SymbolInfo(functionName->getName(), functionName->getType(), returnType->getStartLine(), functionName->getEndLine());
        tmp->setDataType(returnType->getDataType());
        tmp->setVariableOrFunction("func_definition");

        //param = paramList->getParametersList();
        //logout<<"MOTTTTT"<<endl;
        for(pair<SymbolInfo*, SymbolInfo*> tmp1: param){
            tmp->addParameter(tmp1);
        }

        SymbolInfo* symbol=symbolTable->lookUp(functionName->getName());
        //logout<<"MOTTTTT"<<endl;

            if(symbol == NULL){

                symbolTable->insertKey(*tmp, logout);

            }

            else{

                if(symbol->getVariableOrFunction() == "variable"){
                    error_count++;
                    errorout<<"Line# "<<functionName->getStartLine()<<": '"<<symbol->getName()<<"' redeclared as different kind of symbol"<<endl;
                }

                else{

                    if(symbol->getVariableOrFunction() == "func_declaration"){

                        vector<pair<SymbolInfo*, SymbolInfo*> > param1 = symbol->getParametersList();
                        //vector<pair<SymbolInfo*, SymbolInfo*> > param2 = paramList->getParametersList();
                        //logout<<"MOTTTTT"<<endl;

                        bool flag=true;
                        if(symbol->getDataType() != returnType->getDataType()){
                            error_count++;
                            errorout<<"Line# "<<returnType->getStartLine()<<": Conflicting types for '"<<symbol->getName()<<"'"<<endl;
                            flag=false;
                        }

                        else if(param1.size() != param.size()){
                            //logout<<"MOTTTTT"<<endl;
                            error_count++;
                            errorout<<"Line# "<<returnType->getStartLine()<<": Conflicting types for '"<<symbol->getName()<<"'"<<endl;
                            flag=false;
                            //logout<<"MOTTTTT"<<endl;
                        }

                        else{
                            for(int i=0;i<param1.size();i++){
                            if((param1[i].first)->getType() != (param[i].first)->getType()){
                                error_count++;
                                errorout<<"Line# "<<returnType->getStartLine()<<": Conflicting types for '"<<symbol->getName()<<"'"<<endl;
                                flag=false;
                                break;
                            }
                        }
                        }

                        if(flag){
                            //logout<<"MOTTTTT"<<endl;
                            symbolTable->insertKey(*tmp, logout);
                            //logout<<"MOTTTTT"<<endl;
                        }

                    }

                    else{
                        error_count++;
                        errorout<<"Line# "<<returnType->getStartLine()<<": Redefinition of function '"<<symbol->getName()<<"'"<<endl;
                    }
                }

            }

            //logout<<"Com7"<<endl;
            //symbolTable->printAll(logout);
    }


    void giveFunctionDefinitionWithoutParameters(SymbolInfo* returnType, SymbolInfo* functionName){

        SymbolInfo* tmp=new SymbolInfo(functionName->getName(), functionName->getType(), returnType->getStartLine(), functionName->getEndLine());
        tmp->setDataType(returnType->getDataType());
        tmp->setVariableOrFunction("func_definition");

        SymbolInfo* symbol=symbolTable->lookUp(functionName->getName());

            if(symbol == NULL){

                symbolTable->insertKey(*tmp, logout);

            }

            else{

                if(symbol->getVariableOrFunction() == "variable"){
                    error_count++;
                    errorout<<"Line# "<<functionName->getStartLine()<<": '"<<symbol->getName()<<"' redeclared as different kind of symbol"<<endl;
                }

                else{

                    if(symbol->getVariableOrFunction() == "func_declaration"){

                        bool flag=true;
                        if(symbol->getDataType() != returnType->getDataType()){
                            error_count++;
                            errorout<<"Line# "<<returnType->getStartLine()<<": Conflicting types for '"<<symbol->getName()<<"'"<<endl;
                            flag=false;
                        }

                        if(flag){
                            symbolTable->insertKey(*tmp, logout);
                        }

                    }

                    else{
                        error_count++;
                        errorout<<"Line# "<<returnType->getStartLine()<<": Redefinition of function '"<<symbol->getName()<<"'"<<endl;
                    }
                }

            }

    }

    void createNewScope(){
        symbolTable->enterScope(++scopeTableID, bucketLength);
        //logout<<"Hi beta"<<endl;

        // for(pair<SymbolInfo*, SymbolInfo*> tmp1: param){
        //     logout<<(tmp1.first)->getName()<<" "<<(tmp1.second)->getName()<<endl;
        // }

        //symbolTable->printAll(logout);
        if(param.size() != 0){
            for(pair<SymbolInfo*, SymbolInfo*> tmp1: param){
                SymbolInfo* tmp2 = new SymbolInfo(tmp1.second->getName(), tmp1.second->getType(), tmp1.first->getStartLine(), tmp1.second->getEndLine());
                tmp2->setDataType(tmp1.second->getDataType());

                SymbolInfo* symbol1 = symbolTable->getCurrentScopeTable()->lookUp(tmp2->getName());
                if(symbol1 == NULL){
                    symbolTable->insertKey(*tmp2, logout);
                }

                else{
                    error_count++;
                    errorout<<"Line# "<<tmp2->getStartLine()<<": Redefinition of parameter '"<<tmp2->getName()<<"'"<<endl;
                }

            }
            param.clear();
        }
        //logout<<"Com8"<<endl;
        //symbolTable->printAll(logout);
    }


%}

%union{
    SymbolInfo* symbol;
}

%token <symbol> IF ELSE FOR WHILE DO BREAK INT CHAR FLOAT DOUBLE VOID RETURN SWITCH CASE DEFAULT CONTINUE PRINTLN 
%token <symbol> INCOP DECOP ASSIGNOP NOT ADDOP MULOP RELOP LOGICOP BITOP CONST_INT CONST_FLOAT CONST_CHAR ID LPAREN RPAREN LCURL RCURL LSQUARE RSQUARE COMMA SEMICOLON

%type <symbol> start program unit func_declaration func_definition parameter_list compound_statement 
%type <symbol> var_declaration type_specifier declaration_list statements statement expression_statement
%type <symbol> variable expression logic_expression rel_expression simple_expression term unary_expression factor argument_list arguments

%nonassoc LOWER_THAN_ELSE
%nonassoc ELSE

%%  

start : program {
            $$ = new SymbolInfo("program", "start", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            printParseTree($$, 0);
            logout<<"start : program "<<endl;
            //symbolTable->printAll(logout);
            logout<<"Total Lines: "<<yylineno<<endl;
            logout<<"Total Errors: "<<error_count<<endl;
        }
        ;


program : program unit  {
            logout<<"program : program unit "<<endl;
            $$ = new SymbolInfo("program unit", "program", $1->getStartLine(), $2->getEndLine());
            $$->addChild($1);
            $$->addChild($2);

        }  
        | unit  {
            logout<<"program : unit "<<endl;
            $$ = new SymbolInfo("unit", "program", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);
        }
        ;


unit : var_declaration  {
            logout<<"unit : var_declaration "<<endl;
            $$ = new SymbolInfo("var_declaration", "unit", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

        }
        | func_declaration  {
            logout<<"unit : func_declaration "<<endl;
            $$ = new SymbolInfo("func_declaration", "unit", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);
        }
        | func_definition   {
            logout<<"unit : func_definition "<<endl;
            $$ = new SymbolInfo("func_definition", "unit", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);
        }
        ;


func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON {
            logout<<"func_declaration : type_specifier ID LPAREN parameter_list RPAREN SEMICOLON "<<endl;
            $$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN SEMICOLON", "func_declaration", $1->getStartLine(), $6->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($5);
            $$->addChild($6);

            SymbolInfo* symbol=symbolTable->lookUp($2->getName());

            if(symbol == NULL){
                SymbolInfo* tmp=new SymbolInfo($2->getName(), $2->getType(), $1->getStartLine(), $6->getEndLine());
                tmp->setDataType($1->getDataType());
                tmp->setVariableOrFunction($$->getType());

                //vector<pair<SymbolInfo*, SymbolInfo*> > param = $4->getParametersList();
                for(pair<SymbolInfo*, SymbolInfo*> tmp1: param){
                    tmp->addParameter(tmp1);
                }

                symbolTable->insertKey(*tmp, logout);
            }

            else{

                if(symbol->getVariableOrFunction() == "variable"){
                    error_count++;
                    errorout<<"Line# "<<$2->getStartLine()<<": '"<<symbol->getName()<<"' redeclared as different kind of symbol"<<endl;
                }

                else{
                    error_count++;
                    errorout<<"Line# "<<$2->getStartLine()<<": Redeclaration of "<<symbol->getName()<<" function"<<endl;
                }

            }

            if(param.size() > 0){
                param.clear();
            }

        }
        | type_specifier ID LPAREN RPAREN SEMICOLON {
            logout<<"func_declaration : type_specifier ID LPAREN RPAREN SEMICOLON "<<endl;
            $$ = new SymbolInfo("type_specifier ID LPAREN RPAREN SEMICOLON", "func_declaration", $1->getStartLine(), $5->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($5);

            SymbolInfo* symbol=symbolTable->lookUp($2->getName());

            if(symbol == NULL){
                SymbolInfo* tmp=new SymbolInfo($2->getName(), $2->getType(), $1->getStartLine(), $5->getEndLine());
                tmp->setDataType($1->getDataType());
                tmp->setVariableOrFunction($$->getType());
                symbolTable->insertKey(*tmp, logout);
            }

            else{

                if(symbol->getVariableOrFunction() == "variable"){
                    error_count++;
                    errorout<<"Line# "<<$2->getStartLine()<<": '"<<symbol->getName()<<"' redeclared as different kind of symbol"<<endl;
                }

                else{
                    error_count++;
                    errorout<<"Line# "<<$2->getStartLine()<<": Redeclaration of "<<symbol->getName()<<" function"<<endl;
                }

            }

        }
        ;


func_definition : type_specifier ID LPAREN parameter_list RPAREN {giveFunctionDefinitionWithParameters($1, $2);} compound_statement {
        logout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl;
        $$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement", "func_definition", $1->getStartLine(), $7->getEndLine());
        $$->addChild($1);
        $$->addChild($2);
        $$->addChild($3);
        $$->addChild($4);
        $$->addChild($5);
        $$->addChild($7);

        /*
        SymbolInfo* tmp1 = new SymbolInfo($2->getName(), "FUNCTION", $1->getType(), "func_definition", "", $1->getStartLine(), $2->getEndLine());
        tmp1->setParametersList(param);

        symbolTable->printCur(logout);

        bool isInserted = symbolTable->insertKey(*tmp1, logout);
        logout<<tmp1->getName()<<" "<<tmp1->getType()<<endl;
        logout<<isInserted<<endl;
        // if(!isInserted){
        //     logout<<"Function definition exists"<<endl;
        // }

        //symbolTable->printAll(logout);
        symbolTable->printCur(logout);


        */
        /*
        SymbolInfo* tmp=new SymbolInfo($2->getName(), $2->getType(), $1->getStartLine(), $6->getEndLine());
        tmp->setDataType($1->getType());
        tmp->setVariableOrFunction("func_definition");

        //param = paramList->getParametersList();
        logout<<"MOTTTTT"<<endl;
        for(pair<SymbolInfo*, SymbolInfo*> tmp1: param){
            tmp->addParameter(tmp1);
        }

        SymbolInfo* symbol=symbolTable->lookUp($2->getName());

            if(symbol == NULL){

                symbolTable->insertKey(*tmp);

            }

            else{

                if(symbol->getVariableOrFunction() == "variable"){
                    error_count++;
                    errorout<<"Line# "<<$2->getStartLine()<<": '"<<symbol->getName()<<"' redeclared as different kind of symbol"<<endl;
                }

                else{

                    if(symbol->getVariableOrFunction() == "func_declaration"){

                        vector<pair<SymbolInfo*, SymbolInfo*> > param1 = symbol->getParametersList();
                        //vector<pair<SymbolInfo*, SymbolInfo*> > param2 = paramList->getParametersList();

                        bool flag=true;
                        if(symbol->getDataType() != $1->getName()){
                            error_count++;
                            errorout<<"Line# "<<$1->getStartLine()<<": Conflicting types for '"<<symbol->getName()<<"'"<<endl;
                            flag=false;
                        }

                        else if(param1.size() != param.size()){
                            error_count++;
                            errorout<<"Line# "<<$1->getStartLine()<<": Conflicting types for '"<<symbol->getName()<<"'"<<endl;
                            flag=false;
                        }

                        for(int i=0;i<param1.size();i++){
                            if((param1[i].first)->getType() != (param[i].first)->getType()){
                                error_count++;
                                errorout<<"Line# "<<$1->getStartLine()<<": Conflicting types for '"<<symbol->getName()<<"'"<<endl;
                                flag=false;
                                break;
                            }
                        }

                        if(flag){
                            symbolTable->insertKey(*tmp);
                        }

                    }

                    else{
                        error_count++;
                        errorout<<"Line# "<<$1->getStartLine()<<": Redefinition of function '"<<symbol->getName()<<"'"<<endl;
                    }
                }

            }

            logout<<"Com7"<<endl;
            symbolTable->printAll(logout);
            */

        }
        | type_specifier ID LPAREN RPAREN {giveFunctionDefinitionWithoutParameters($1, $2);} compound_statement    {
            logout<<"func_definition : type_specifier ID LPAREN RPAREN compound_statement "<<endl;
            $$ = new SymbolInfo("type_specifier ID LPAREN RPAREN compound_statement", "func_definition", $1->getStartLine(), $6->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($6);

        }
        | type_specifier ID LPAREN error {  if(errorLine == -1){
                                            errorLine = yylineno;
                                            error_count++;
                                            errorout<<"Line# "<<$3->getStartLine()<<": Syntax error at parameter list of function definition"<<endl;
                                            logout<<"Error at line no "<<errorLine<<" : syntax error"<<endl;
                                            param.clear();
                                            }} RPAREN {errorLine = -1;} compound_statement    {
            logout<<"func_definition : type_specifier ID LPAREN parameter_list RPAREN compound_statement "<<endl;
            $$ = new SymbolInfo("type_specifier ID LPAREN parameter_list RPAREN compound_statement", "func_definition", $1->getStartLine(), $8->getEndLine());
            SymbolInfo* symbol1 = new SymbolInfo("error", "parameter_list", $3->getEndLine(), $6->getStartLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild(symbol1);
            $$->addChild($6);
            $$->addChild($8);

            errorLine = -1;

        }
        ;       


parameter_list : parameter_list COMMA type_specifier ID {
            logout<<"parameter_list : parameter_list COMMA type_specifier ID "<<endl;
            $$ = new SymbolInfo("parameter_list COMMA type_specifier ID", "parameter_list", $1->getStartLine(), $4->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);

            for(pair<SymbolInfo*, SymbolInfo*> tmp1: $1->getParametersList()){
                $$->addParameter(tmp1);
            }
            //logout<<"Com3"<<endl;
            $4->setDataType($3->getDataType());
            $$->addParameter({$3, $4});
            param.push_back({$3, $4});
            //symbolTable->printAll(logout);

        }
        | parameter_list COMMA type_specifier   {
            logout<<"parameter_list : parameter_list COMMA type_specifier "<<endl;
            $$ = new SymbolInfo("parameter_list COMMA type_specifier", "parameter_list", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            for(pair<SymbolInfo*, SymbolInfo*> tmp1: $1->getParametersList()){
                $$->addParameter(tmp1);
            }
            SymbolInfo* symbol = new SymbolInfo("", "", $3->getStartLine(), $3->getEndLine());
            symbol->setDataType($3->getDataType());
            $$->addParameter({$3, symbol});
            param.push_back({$3, symbol});
            //logout<<"Com4"<<endl;
            //symbolTable->printAll(logout);

        }
        | type_specifier ID {
            logout<<"parameter_list : type_specifier ID "<<endl;
            $$ = new SymbolInfo("type_specifier ID", "parameter_list", $1->getStartLine(), $2->getEndLine());
            $$->addChild($1);
            $$->addChild($2);

            $2->setDataType($1->getDataType());
            $$->addParameter({$1, $2});
            param.push_back({$1, $2});
            //logout<<"Com5"<<endl;
            //symbolTable->printAll(logout);

        }
        | type_specifier    {
            logout<<"parameter_list : type_specifier "<<endl;
            $$ = new SymbolInfo("type_specifier", "parameter_list", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            SymbolInfo* symbol = new SymbolInfo("", "", $1->getStartLine(), $1->getEndLine());
            symbol->setDataType($1->getDataType());
            $$->addParameter({$1, symbol});
            param.push_back({$1, symbol});
            //logout<<"Com6"<<endl;
            //symbolTable->printAll(logout);
        }
        ;


compound_statement : LCURL {createNewScope();} statements RCURL {
            logout<<"compound_statement : LCURL statements RCURL "<<endl;
            $$ = new SymbolInfo("LCURL statements RCURL", "compound_statement", $1->getStartLine(), $4->getEndLine());
            $$->addChild($1);
            $$->addChild($3);
            $$->addChild($4);

            //logout<<"Com1"<<endl;
            symbolTable->printAll(logout);
            symbolTable->exitScope();

        }
        | LCURL {createNewScope();} RCURL   {
            logout<<"compound_statement : LCURL RCURL "<<endl;
            $$ = new SymbolInfo("LCURL RCURL", "compound_statement", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($3);

            //logout<<"Com2"<<endl;
            symbolTable->printAll(logout);
            symbolTable->exitScope();
        }
        ;


var_declaration : type_specifier declaration_list SEMICOLON {
            logout<<"var_declaration : type_specifier declaration_list SEMICOLON "<<endl;
            $$ = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            for(SymbolInfo* tmp1: variableList){

                if(variableType == "VOID"){
                    error_count++;
                    errorout<<"Line# "<<tmp1->getStartLine()<<": Variable or field '"<<tmp1->getName()<<"' declared void"<<endl;
                }

                else{
                tmp1->setDataType(variableType);

                SymbolInfo* symbol1 = symbolTable->getCurrentScopeTable()->lookUp(tmp1->getName());

                if(symbol1 != NULL){
                    if(symbol1->getDataType() == tmp1->getDataType() && symbol1->getVariableOrFunction() == tmp1->getVariableOrFunction()){
                        error_count++;
                        errorout<<"Redeclaration of variable '"<<tmp1->getName()<<"'"<<endl;
                    }

                    else if(symbol1->getVariableOrFunction() != tmp1->getVariableOrFunction()){
                        error_count++;
                        errorout<<"Line# "<<tmp1->getStartLine()<<": '"<<tmp1->getName()<<"' redeclared as different kind of symbol"<<endl;
                    }

                    else if(symbol1->getDataType() != tmp1->getDataType()){
                        error_count++;
                        errorout<<"Line# "<<tmp1->getStartLine()<<": Conflicting types for'"<<tmp1->getName()<<"'"<<endl;
                    }
                    
                }

                symbolTable->insertKey(*tmp1, logout);
                }
            }

            variableList.clear();
            variableType="";
        }
        | type_specifier error {if(errorLine == -1){
                                    errorLine = yylineno;
                                    logout<<"Error at line no "<<errorLine<<" : syntax error"<<endl;
                                    }} SEMICOLON    {

            error_count++;
            errorout<<"Line# "<<errorLine<<": Syntax error at declaration list of variable declaration"<<endl;
            logout<<"var_declaration : type_specifier declaration_list SEMICOLON "<<endl;
            $$ = new SymbolInfo("type_specifier declaration_list SEMICOLON", "var_declaration", $1->getStartLine(), $4->getEndLine());
            SymbolInfo* symbol1 = new SymbolInfo("error", "declaration_list", errorLine, errorLine);
            $$->addChild($1);
            $$->addChild(symbol1);
            $$->addChild($4);

            errorLine = -1;
            variableList.clear();
            variableType="";
        }
        ;


type_specifier : INT    {
            logout<<"type_specifier : INT "<<endl;
            $$ = new SymbolInfo("INT", "type_specifier", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            $$->setDataType("INT");
            variableType = "INT";

        }
        | FLOAT {
            logout<<"type_specifier : FLOAT "<<endl;
            $$ = new SymbolInfo("FLOAT", "type_specifier", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            $$->setDataType("FLOAT");
            variableType = "FLOAT";

        }
        | VOID  {
            logout<<"type_specifier : VOID "<<endl;
            $$ = new SymbolInfo("VOID", "type_specifier", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            $$->setDataType("VOID");
            variableType = "VOID";

        }
        ;

declaration_list : declaration_list COMMA ID    {
            logout<<"declaration_list : declaration_list COMMA ID "<<endl;
            $$ = new SymbolInfo("declaration_list COMMA ID", "declaration_list", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            variableList.push_back($3);

        }
        | declaration_list COMMA ID LSQUARE CONST_INT RSQUARE   {
            logout<<"declaration_list : declaration_list COMMA ID LSQUARE CONST_INT RSQUARE "<<endl;
            $$ = new SymbolInfo("declaration_list COMMA ID LSQUARE CONST_INT RSQUARE", "declaration_list", $1->getStartLine(), $6->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($5);
            $$->addChild($6);

            $3->setArraySize($5->getName());
            variableList.push_back($3);

        }
        | ID    {
            logout<<"declaration_list : ID "<<endl;
            $$ = new SymbolInfo("ID", "declaration_list", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            variableList.push_back($1);

        }
        | ID LSQUARE CONST_INT RSQUARE  {
            logout<<"declaration_list : ID LSQUARE CONST_INT RSQUARE "<<endl;
            $$ = new SymbolInfo("ID LSQUARE CONST_INT RSQUARE", "declaration_list", $1->getStartLine(), $4->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);

            $1->setArraySize($3->getName());
            variableList.push_back($1);

        }
        ;


statements : statement  {
            logout<<"statements : statement "<<endl;
            $$ = new SymbolInfo("statement", "statements", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

        }
        | statements statement  {
            logout<<"statements : statements statement "<<endl;
            $$ = new SymbolInfo("statements statement", "statements", $1->getStartLine(), $2->getEndLine());
            $$->addChild($1);
            $$->addChild($2);

        }
        ;

statement : var_declaration {
            logout<<"statement : var_declaration "<<endl;
            $$ = new SymbolInfo("var_declaration", "statement", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

        }
        | expression_statement  {
            logout<<"statement : expression_statement "<<endl;
            $$ = new SymbolInfo("expression_statement", "statement", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

        }
        | compound_statement    {
            logout<<"statement : compound_statement "<<endl;
            $$ = new SymbolInfo("compound_statement", "statement", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

        }
        | FOR LPAREN expression_statement expression_statement expression RPAREN statement  {
            logout<<"statement : FOR LPAREN expression_statement expression_statement expression RPAREN statement "<<endl;
            $$ = new SymbolInfo("FOR LPAREN expression_statement expression_statement expression RPAREN statement", "statement", $1->getStartLine(), $7->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($5);
            $$->addChild($6);
            $$->addChild($7);

        }
        | IF LPAREN expression RPAREN statement %prec LOWER_THAN_ELSE{
            logout<<"statement : IF LPAREN expression RPAREN statement "<<endl;
            $$ = new SymbolInfo("IF LPAREN expression RPAREN statement", "statement", $1->getStartLine(), $5->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($5);

        }
        | IF LPAREN expression RPAREN statement ELSE statement  {
            logout<<"statement : IF LPAREN expression RPAREN statement ELSE statement "<<endl;
            $$ = new SymbolInfo("IF LPAREN expression RPAREN statement ELSE statement", "statement", $1->getStartLine(), $7->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($5);
            $$->addChild($6);
            $$->addChild($7);

        }
        | WHILE LPAREN expression RPAREN statement  {
            logout<<"statement : WHILE LPAREN expression RPAREN statement "<<endl;
            $$ = new SymbolInfo("WHILE LPAREN expression RPAREN statement", "statement", $1->getStartLine(), $5->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($5);

        }
        | PRINTLN LPAREN ID RPAREN SEMICOLON    {
            logout<<"statement : PRINTLN LPAREN ID RPAREN SEMICOLON "<<endl;
            $$ = new SymbolInfo("PRINTLN LPAREN ID RPAREN SEMICOLON", "statement", $1->getStartLine(), $5->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);
            $$->addChild($5);

            SymbolInfo* symbol1 = symbolTable->lookUp($3->getName());
            if(symbol1 == NULL){
                error_count++;
                errorout<<"Line# "<<$3->getStartLine()<<": Undeclared variable '"<<$3->getName()<<"'"<<endl;
            }

        }
        | RETURN expression SEMICOLON   {
            logout<<"statement : RETURN expression SEMICOLON "<<endl;
            $$ = new SymbolInfo("RETURN expression SEMICOLON", "statement", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

        }
        ;


expression_statement : SEMICOLON    {
            logout<<"expression_statement : SEMICOLON "<<endl;
            $$ = new SymbolInfo("SEMICOLON", "expression_statement", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

        }
        | expression SEMICOLON  {
            logout<<"expression_statement : expression SEMICOLON "<<endl;
            $$ = new SymbolInfo("expression SEMICOLON", "expression_statement", $1->getStartLine(), $2->getEndLine());
            $$->addChild($1);
            $$->addChild($2);

        }
        | error {if(errorLine == -1)
                    errorLine = yylineno;} SEMICOLON   {

            error_count++;
            errorout<<"Line# "<<errorLine<<": Syntax error at expression of expression statement"<<endl;
            logout<<"expression_statement : expression SEMICOLON "<<endl;
            $$ = new SymbolInfo("expression SEMICOLON", "expression_statement", $3->getStartLine(), $3->getEndLine());
            SymbolInfo* symbol1 = new SymbolInfo("error", "expression", errorLine, errorLine);
            $$->addChild(symbol1);
            $$->addChild($3);

            errorLine = -1;
        }
        ;


variable : ID   {
            logout<<"variable : ID "<<endl;
            $$ = new SymbolInfo("ID", "variable", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            SymbolInfo* symbol1 = symbolTable->lookUp($1->getName());
            if(symbol1 == NULL){
                error_count++;
                errorout<<"Line# "<<$1->getStartLine()<<": Undeclared variable '"<<$1->getName()<<"'"<<endl;
            }

            else{
                // if(symbol1->isArray()){
                //     error_count++;
                //     errorout<<"Line# "<<$1->getStartLine()<<": '"<<$1->getName()<<"' is an array"<<endl;
                // }

                $1->setDataType(symbol1->getDataType());
                $1->setArraySize(symbol1->getArraySize());
            }

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

        }
        | ID LSQUARE expression RSQUARE {
            logout<<"variable : ID LSQUARE expression RSQUARE "<<endl;
            $$ = new SymbolInfo("ID LSQUARE expression RSQUARE", "variable", $1->getStartLine(), $4->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);

            SymbolInfo* symbol1 = symbolTable->lookUp($1->getName());
            if(symbol1 == NULL){
                error_count++;
                errorout<<"Line# "<<$1->getStartLine()<<": Undeclared variable '"<<$1->getName()<<"'"<<endl;
            }

            else{
                $1->setDataType(symbol1->getDataType());
                $1->setArraySize(symbol1->getArraySize());
                if(!symbol1->isArray()){
                    error_count++;
                    errorout<<"Line# "<<$1->getStartLine()<<": '"<<$1->getName()<<"' is not an array"<<endl;
                }

                if($3->getDataType() != "INT"){
                    error_count++;
                    errorout<<"Line# "<<$3->getStartLine()<<": Array subscript is not an integer"<<endl;
                }
            }

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

        }
        ;


expression : logic_expression   {
            logout<<"expression : logic_expression "<<endl;
            $$ = new SymbolInfo("logic_expression", "expression", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            //errorout<<"Line "<<$1->getStartLine()<<" Hello 11: "<<$1->getDataType()<<endl;

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

        }
        | variable ASSIGNOP logic_expression    {
            logout<<"expression : variable ASSIGNOP logic_expression "<<endl;
            $$ = new SymbolInfo("variable ASSIGNOP logic_expression", "expression", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            //SymbolInfo* symbol1 = symbolTable->lookUp($3->getName());
            //errorout<<"Line "<<$1->getStartLine()<<$3->getName()<<" Hello 11: "<<$3->getDataType()<<endl;
        
            if($3->getDataType() == "VOID"){
                error_count++;
                errorout<<"Line# "<<$3->getStartLine()<<": Void cannot be used in expression "<<endl;
            }

            if($1->getDataType() == "INT" && $3->getDataType() == "FLOAT"){
                error_count++;
                errorout<<"Line# "<<$1->getStartLine()<<": Warning: possible loss of data in assignment of FLOAT to INT"<<endl;
            }

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

        }
        ;


logic_expression : rel_expression   {
            logout<<"logic_expression : rel_expression "<<endl;
            $$ = new SymbolInfo("rel_expression", "logic_expression", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            //errorout<<"Line "<<$1->getStartLine()<<" Hello 10: "<<$1->getDataType()<<endl;

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

        }
        | rel_expression LOGICOP rel_expression {
            logout<<"logic_expression : rel_expression LOGICOP rel_expression "<<endl;
            $$ = new SymbolInfo("rel_expression LOGICOP rel_expression", "logic_expression", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            $$->setDataType("INT");

        }
        ;


rel_expression : simple_expression  {
            logout<<"rel_expression : simple_expression "<<endl;
            $$ = new SymbolInfo("simple_expression", "rel_expression", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            //errorout<<"Line "<<$1->getStartLine()<<" Hello 9: "<<$1->getDataType()<<endl;

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

        }
        | simple_expression RELOP simple_expression {
            logout<<"rel_expression : simple_expression RELOP simple_expression "<<endl;
            $$ = new SymbolInfo("simple_expression RELOP simple_expression", "rel_expression", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            if($1->getDataType() == "INT" && $3->getDataType() == "FLOAT"){
                $1->setDataType("FLOAT");
            }

            else if($1->getDataType() == "FLOAT" && $3->getDataType() =="INT"){
                $3->setDataType("FLOAT");
            }

            $$->setDataType("INT");

        }
        ;


simple_expression : term    {
            logout<<"simple_expression : term "<<endl;
            $$ = new SymbolInfo("term", "simple_expression", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            //errorout<<"Line "<<$1->getStartLine()<<" Hello 8: "<<$1->getDataType()<<endl;

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

            value=-1;

        }
        | simple_expression ADDOP term  {
            logout<<"simple_expression : simple_expression ADDOP term "<<endl;
            $$ = new SymbolInfo("simple_expression ADDOP term", "simple_expression", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            if($1->getDataType() == "VOID" || $3->getDataType() == "VOID"){
                error_count++;
                errorout<<"Line# "<<$3->getStartLine()<<": Void cannot be used in expression "<<endl;
            }

            if($1->getDataType() == $3->getDataType()){
                $$->setDataType($1->getDataType());
            }

            else if($1->getDataType() == "INT" && $3->getDataType() == "FLOAT"){
                $1->setDataType("FLOAT");
                $$->setDataType("FLOAT");
            }

            else if($3->getDataType() == "INT" && $1->getDataType() == "FLOAT"){
                $3->setDataType("FLOAT");
                $$->setDataType("FLOAT");
            }

            else if($1->getDataType() != "VOID"){
                $$->setDataType($1->getDataType());
            }

            else{
                $$->setDataType($3->getDataType());
            }

            value=-1;

        }
        ;


term : unary_expression {
            logout<<"term : unary_expression "<<endl;
            $$ = new SymbolInfo("unary_expression", "term", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            //errorout<<"Line "<<$1->getStartLine()<<" Hello 7: "<<$1->getDataType()<<endl;

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

            value=-1;

        }
        | term MULOP unary_expression   {
            logout<<"term : term MULOP unary_expression "<<endl;
            $$ = new SymbolInfo("term MULOP unary_expression", "term", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            //errorout<<"Hello 4: "<<$3->getDataType()<<endl;

            if($1->getDataType() == "VOID" || $3->getDataType() == "VOID"){
                error_count++;
                errorout<<"Line# "<<$3->getStartLine()<<": Void cannot be used in expression "<<endl;
            }

            if($2->getName() == "%"){

                if(value == 0){
                    error_count++;
                    errorout<<"Line# "<<$1->getStartLine()<<": Warning: division by zero i=0f=1Const=0"<<endl;
                }

                if($1->getDataType() != "INT" || $3->getDataType() != "INT"){
                    error_count++;
                    errorout<<"Line# "<<$1->getStartLine()<<": Operands of modulus must be integers "<<endl;
                }

                $1->setDataType("INT");
                $3->setDataType("INT");

            }

            if($2->getName() == "/" && value == 0){
                error_count++;
                errorout<<"Line# "<<$1->getStartLine()<<": Warning: division by zero i=0f=1Const=0"<<endl;
            }

            if($1->getDataType() == $3->getDataType()){
                $$->setDataType($1->getDataType());
            }

            else if($1->getDataType() == "INT" && $3->getDataType() == "FLOAT"){
                $1->setDataType("FLOAT");
                $$->setDataType("FLOAT");
            }

            else if($3->getDataType() == "INT" && $1->getDataType() == "FLOAT"){
                $3->setDataType("FLOAT");
                $$->setDataType("FLOAT");
            }

            else if($1->getDataType() != "VOID"){
                $$->setDataType($1->getDataType());
            }

            else{
                $$->setDataType($3->getDataType());
            }

        }
        ;


unary_expression : ADDOP unary_expression   {
            logout<<"unary_expression : ADDOP unary_expression "<<endl;
            $$ = new SymbolInfo("ADDOP unary_expression", "unary_expression", $1->getStartLine(), $2->getEndLine());
            $$->addChild($1);
            $$->addChild($2);

            $$->setDataType($2->getDataType());
            $$->setArraySize($2->getArraySize());
            $$->setVariableOrFunction($2->getVariableOrFunction());
            $$->setParametersList($2->getParametersList());
            
            value=-1;

        }
        | NOT unary_expression  {
            logout<<"unary_expression : NOT unary_expression "<<endl;
            $$ = new SymbolInfo("NOT unary_expression", "unary_expression", $1->getStartLine(), $2->getEndLine());
            $$->addChild($1);
            $$->addChild($2);

            $$->setDataType($2->getDataType());
            $$->setArraySize($2->getArraySize());
            $$->setVariableOrFunction($2->getVariableOrFunction());
            $$->setParametersList($2->getParametersList());

            value=-1;

        }
        | factor    {
            logout<<"unary_expression : factor "<<endl;
            $$ = new SymbolInfo("factor", "unary_expression", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            //errorout<<"Line: <<yylineno<<Hello 6: "<<$1->getDataType()<<endl;

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

        }
        ;


factor : variable   {
            logout<<"factor : variable "<<endl;
            $$ = new SymbolInfo("variable", "factor", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            $$->setDataType($1->getDataType());
            $$->setArraySize($1->getArraySize());
            $$->setVariableOrFunction($1->getVariableOrFunction());
            $$->setParametersList($1->getParametersList());

        }
        | ID LPAREN argument_list RPAREN    {
            logout<<"factor : ID LPAREN argument_list RPAREN "<<endl;
            $$ = new SymbolInfo("ID LPAREN argument_list RPAREN", "factor", $1->getStartLine(), $4->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);
            $$->addChild($4);

            SymbolInfo* symbol1 = symbolTable->lookUp($1->getName());
            if(symbol1 == NULL){
                error_count++;
                errorout<<"Line# "<<$1->getStartLine()<<": Undeclared function '"<<$1->getName()<<"'"<<endl;
            }

            else if(symbol1->getVariableOrFunction() == "variable"){
                error_count++;
                errorout<<"Line# "<<$1->getStartLine()<<": '"<<$1->getName()<<"' is not a function"<<endl;
            }

            else{
                
                $1->setDataType(symbol1->getDataType());
                if($1->getVariableOrFunction() == "func_declaration"){
                    error_count++;
                    errorout<<"Line# "<<$1->getStartLine()<<": '"<<$1->getName()<<"' is not defined"<<endl;
                }

                else{
                    if(symbol1->getParametersList().size() < argumentList.size()){
                        error_count++;
                        errorout<<"Line# "<<$1->getStartLine()<<": Too many arguments to function '"<<$1->getName()<<"'"<<endl;
                    }

                    else if(symbol1->getParametersList().size() > argumentList.size()){
                        error_count++;
                        errorout<<"Line# "<<$1->getStartLine()<<": Too few arguments to function '"<<$1->getName()<<"'"<<endl;
                    }

                    else{
                        //errorout<<"Hello1"<<endl;
                        vector<pair<SymbolInfo*, SymbolInfo*> > param1 = symbol1->getParametersList();

                        for(int i=0; i<argumentList.size(); i++){
                            //typeList.push_back(param1[i].first);
                            //errorout<<(param1[i].second)->getDataType()<<"   "<<argumentList[i]->getDataType()<<endl;
                            //errorout<<"ArgumentList[i] is an array: "<<argumentList[i]->getArraySize()<<endl;
                            if((param1[i].second)->getDataType() != argumentList[i]->getDataType()){
                                //errorout<<(param1[i].first)->getType()<<"   "<<argumentList[i]->getDataType()<<endl;
                                error_count++;
                                errorout<<"Line# "<<argumentList[i]->getStartLine()<<": Type mismatch for argument "<<i+1<<" of '"<<$1->getName()<<"'"<<endl;
                            }
                        }
                    }
                }

                //errorout<<"Line "<<yylineno<<"Hello 5: "<<$1->getDataType()<<endl;

                $$->setDataType($1->getDataType());
                $$->setVariableOrFunction($1->getVariableOrFunction());
                $$->setArraySize($1->getArraySize());
                $$->setParametersList(symbol1->getParametersList());
            }

            argumentList.clear();

        }
        | LPAREN expression RPAREN  {
            logout<<"factor : LPAREN expression RPAREN "<<endl;
            $$ = new SymbolInfo("LPAREN expression RPAREN", "factor", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            $$->setDataType($2->getDataType());
            $$->setArraySize($2->getArraySize());
            $$->setVariableOrFunction($2->getVariableOrFunction());
            $$->setParametersList($2->getParametersList());

        }
        | CONST_INT {
            logout<<"factor : CONST_INT "<<endl;
            $$ = new SymbolInfo("CONST_INT", "factor", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            $$->setDataType("INT");
            value=stoi($1->getName());

        }
        | CONST_FLOAT   {
            logout<<"factor : CONST_FLOAT "<<endl;
            $$ = new SymbolInfo("CONST_FLOAT", "factor", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            $$->setDataType("FLOAT");
            value=stoi($1->getName());

        }
        | variable INCOP    {
            logout<<"factor : variable INCOP "<<endl;
            $$ = new SymbolInfo("variable INCOP", "factor", $1->getStartLine(), $2->getEndLine());
            $$->addChild($1);
            $$->addChild($2);

            $$->setDataType($2->getDataType());
            $$->setArraySize($2->getArraySize());

        }
        | variable DECOP    {
            logout<<"factor : variable DECOP "<<endl;
            $$ = new SymbolInfo("variable DECOP", "factor", $1->getStartLine(), $2->getEndLine());
            $$->addChild($1);
            $$->addChild($2);

            $$->setDataType($2->getDataType());
            $$->setArraySize($2->getArraySize());

        }
        ;


argument_list : arguments   {
            logout<<"argument_list : arguments "<<endl;
            $$ = new SymbolInfo("arguments", "argument_list", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);
        }
        |       {
            logout<<"argument_list :  "<<endl;
            $$ = new SymbolInfo("", "argument_list", yylineno, yylineno);

        }
        ;


arguments : arguments COMMA logic_expression    {
            logout<<"arguments : arguments COMMA logic_expression "<<endl;
            $$ = new SymbolInfo("arguments COMMA logic_expression", "arguments", $1->getStartLine(), $3->getEndLine());
            $$->addChild($1);
            $$->addChild($2);
            $$->addChild($3);

            //errorout<<"Hello 3: "<<$3->getDataType()<<endl;

            argumentList.push_back($3);

        }
        | logic_expression  {
            logout<<"arguments : logic_expression "<<endl;
            $$ = new SymbolInfo("logic_expression", "arguments", $1->getStartLine(), $1->getEndLine());
            $$->addChild($1);

            //errorout<<"Hello 2: "<<$1->getDataType()<<endl;

            argumentList.push_back($1);

        }
        ;


%%

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
    parseTreeOut.open("1905097_parsetree.txt");
    errorout.open("1905097_error.txt");
	//tokenout.open("1905097_token.txt");

	//scopeTableID++;
	//symbolTable.enterScope(scopeTableID, bucketLength, logout);

	yyin= fin;
    //yylineno=1;
    //symbolTable->enterScope(++scopeTableID, bucketLength);
	yyparse();
	//st.print();
	fclose(yyin);
    //fclose(fin);
	//tokenout.close();
	logout.close();
    parseTreeOut.close();
    errorout.close();
	return 0;
}