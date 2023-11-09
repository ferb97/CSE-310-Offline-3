#include<bits/stdc++.h>

using namespace std;

class SymbolInfo{

    string name="";
    string type="";
    SymbolInfo* next=NULL;

    string dataType="";
    string variableOrFunction="";
    vector<pair<SymbolInfo*, SymbolInfo*> > parametersList;
    string arraySize="";

    int startLine=0;
    int endLine=0;
    vector<SymbolInfo*> childList;

public:

    SymbolInfo(SymbolInfo* symbol){

        this->name=symbol->name;
        this->type=symbol->type;
        this->next=symbol->next;
        this->dataType=symbol->dataType;
        this->variableOrFunction=symbol->variableOrFunction;
        this->parametersList=symbol->parametersList;
        this->arraySize=symbol->arraySize;
        this->startLine=symbol->startLine;
        this->endLine=endLine;
        this->childList=childList;

    }

    SymbolInfo(string name, string type, int startLine, int endLine){
        this->name=name;
        this->type=type;
        this->next=nullptr;
        this->dataType="";
        this->variableOrFunction="variable";
        this->arraySize="";
        this->parametersList.clear();
        this->startLine=startLine;
        this->endLine=endLine;
        this->childList.clear();

    }

    SymbolInfo(string name, string type, string dataType, string variableOrFunction, string arraySize, int startLine, int endLine){
        this->name=name;
        this->type=type;
        this->dataType=dataType;
        this->variableOrFunction=variableOrFunction;
        this->arraySize=arraySize;
        this->startLine=startLine;
        this->endLine=endLine;
        this->childList.clear();
        this->parametersList.clear();

    }

    SymbolInfo(const SymbolInfo &symbol){
        this->name=symbol.name;
        this->type=symbol.type;
        this->next=symbol.next;
        this->dataType=symbol.dataType;
        this->arraySize=symbol.arraySize;
        this->variableOrFunction=symbol.variableOrFunction;
        this->parametersList=symbol.parametersList;
        this->startLine=symbol.startLine;
        this->endLine=symbol.endLine;
        this->childList=symbol.childList;
    }

    ~SymbolInfo(){

    }

    string getName(){
        return name;
    }

    string getType(){
        return type;
    }

    void setNext(SymbolInfo* next){
        this->next=next;
    }

    SymbolInfo* getNext(){
        return next;
    }

    void setName(string name){
        this->name=name;
    }

    void setType(string type){
        this->type=type;
    }

    void setDataType(string dataType){
        this->dataType=dataType;
    }

    void setVariableOrFunction(string variableOrFunction){
        this->variableOrFunction=variableOrFunction;
    }

    void setArraySize(string arraySize){
        this->arraySize=arraySize;
    }

    void setParametersList(vector<pair<SymbolInfo*, SymbolInfo*> > parametersList){
        this->parametersList=parametersList;
    }

    void setStartLine(int startLine){
        this->startLine=startLine;
    }

    void setEndLine(int endLine){
        this->endLine=endLine;
    }

    void setChildList(vector<SymbolInfo*> childList){
        this->childList=childList;
    }

    int getStartLine(){
        return this->startLine;
    }

    int getEndLine(){
        return this->endLine;
    }

    vector<SymbolInfo*> getChildList(){
        return this->childList;
    }

    void addChild(SymbolInfo* parser){
        childList.push_back(parser);
    }

    string getDataType(){
        return dataType;
    }

    string getVariableOrFunction(){
        return variableOrFunction;
    }

    string getArraySize(){
        return arraySize;
    }

    vector<pair<SymbolInfo*, SymbolInfo*> > getParametersList(){
        return parametersList;
    }

    void addParameter(pair<SymbolInfo*, SymbolInfo*> symbol){
        parametersList.push_back(symbol);

    }

    bool isArray(){
        return arraySize != "";
    }
};

class ScopeTable{

    int id;
    int bucketLength;
    SymbolInfo** bucketList;
    ScopeTable* parentScope;

    unsigned long long sdbmHash(string str){
        unsigned long long hashValue=0;

        for (int i=0;i<str.length();i++){
		    hashValue = (str[i]) + (hashValue << 6) + (hashValue << 16) - hashValue;
	    }

	    return (hashValue%bucketLength);
    }

public:

    ScopeTable(){

    }

    ScopeTable(int id, int bucketLength, ScopeTable* parentScope){

        this->id=id;
        this->bucketLength=bucketLength;
        this->parentScope=parentScope;

        this->bucketList=new SymbolInfo*[bucketLength];
        for(int i=0;i<bucketLength;i++){
            bucketList[i]=NULL;
        }
    }

    ~ScopeTable(){
        delete[] bucketList;
    }

    void setId(int id){
        this->id=id;
    }

    int getId(){
        return id;
    }

    void setBucketLength(int bucketLength){
        this->bucketLength=bucketLength;
    }

    int getBucketLength(){
        return bucketLength;
    }

    ScopeTable* getParentScope(){
        return parentScope;
    }

    SymbolInfo* lookUp(string str){
        int ind=sdbmHash(str);

        SymbolInfo* tmp=bucketList[ind];
        int pos=1;

        while(tmp!=NULL){
            if(tmp->getName()==str){
                //out<<"\t'"<<str<<"' found in ScopeTable# "<<id<<" at position "<<ind+1<<", "<<pos<<endl;
                return tmp;
            }
            tmp=tmp->getNext();
            pos++;
        }
        //cout<<"Not found"<<endl;
        return NULL;
    }

    bool insertKey(SymbolInfo& symbol, ofstream& out){
        int ind=sdbmHash(symbol.getName());

        SymbolInfo* tmp=bucketList[ind];
        //out<<"Index is: "<<ind<<endl;

        while(tmp!=NULL){
            if(tmp->getName()==symbol.getName()){
                //out<<"\t"<<symbol.getName()<<" already exisits in the current ScopeTable"<<endl;
                return false;
            }
            tmp=tmp->getNext();
        }

        tmp=bucketList[ind];
        //out<<"\tInserted in ScopeTable# "<<id<<" at position "<<ind+1<<", ";
        int pos=1;

        if(tmp==NULL){
            bucketList[ind]=&symbol;
            symbol.setNext(NULL);
            //out<<pos<<endl;
            return true;
        }

        while(tmp->getNext()!=NULL){
            tmp=tmp->getNext();
            pos++;
        }

        pos++;
        tmp->setNext(&symbol);
        symbol.setNext(NULL);
        //out<<pos<<endl;
        return true;
    }

    bool deleteKey(string str,ofstream& out){

        int ind=sdbmHash(str);
        SymbolInfo* tmp=bucketList[ind];
        SymbolInfo* prev=NULL;
        bool flag=false;
        int pos=1;

        while(tmp!=NULL){
            if(tmp->getName()==str){
               flag=true;
               break;
            }
            prev=tmp;
            tmp=tmp->getNext();
            pos++;
        }

        if(!flag){
           out<<"\tNot found in the current ScopeTable"<<endl;
           return false;
        }

        if(prev==NULL){
            bucketList[ind]=tmp->getNext();
        }
        else{
            prev->setNext(tmp->getNext());
        }

        delete tmp;
        out<<"\tDeleted '"<<str<<"' from ScopeTable# "<<id<<" at position "<<ind+1<<", "<<pos<<endl;
        return true;
    }

    void print(ofstream& out){
        out<<"\tScopeTable# "<<id<<endl;

        for (int i = 0; i < bucketLength; i++)
        {
            SymbolInfo *tmp = bucketList[i];

            if (tmp != NULL){
               out << "\t" << i + 1 << "--> ";
               while (tmp != NULL){
                    if(tmp->getVariableOrFunction() == "variable" && tmp->isArray()){    
                        out << "<" << tmp->getName() << ", ARRAY, " << tmp->getDataType() << "> ";
                        tmp = tmp->getNext();
                    }

                    else if(tmp->getVariableOrFunction() == "variable"){    
                        out << "<" << tmp->getName() << ", " << tmp->getDataType() << "> ";
                        tmp = tmp->getNext();
                    }

                    else{
                        out << "<" << tmp->getName() << ", FUNCTION, " << tmp->getDataType() << "> ";
                        tmp = tmp->getNext();
                    }
               }
               out << endl;
            }
        }
    }

};

class SymbolTable{

    ScopeTable* cur;

public:

    SymbolTable(){
        cur=NULL;
    }

    SymbolTable(int id, int bucketLength){
        ScopeTable* scopeTable = new ScopeTable(id, bucketLength, NULL);
        cur=scopeTable;
    }

    ~SymbolTable(){

        ScopeTable *tmp = cur;
        while (tmp != NULL){
            cur = cur->getParentScope();
            delete tmp;
            tmp = cur;
        }
    }

    ScopeTable* getCurrentScopeTable(){
        return cur;
    }

    void enterScope(int id,int bucketLength){
        ScopeTable* tmp=new ScopeTable(id,bucketLength,cur);
        //out<<"\tScopeTable# "<<id<<" created"<<endl;
        cur=tmp;
    }

    void exitScope(){
        if(cur==NULL){
           //out<<"\tNo Scopetable"<<endl;
           return;
        }

        ScopeTable* tmp=cur;
        //if(tmp->getId()==1&&!flag){
           //out<<"\tScopeTable# "<<tmp->getId()<<" cannot be removed"<<endl;
           //return;
        //}
        cur=cur->getParentScope();

        //out<<"\tScopeTable# "<<tmp->getId()<<" removed"<<endl;
        delete tmp;
        return;
    }

    bool insertKey(SymbolInfo& symbol, ofstream& out){
        if(cur==NULL){
           //out<<"\tInsertion not possible"<<endl;
           return false;
        }

        return cur->insertKey(symbol, out);
    }

    bool deleteKey(string str,ofstream& out){

        if(cur==NULL){
           out<<"\tDeletion not possible"<<endl;
           return false;
        }

        return cur->deleteKey(str,out);
    }

    SymbolInfo* lookUp(string str){

        if(cur==NULL){
           //out<<"\tLookup is not posssible"<<endl;
           return NULL;
        }

        ScopeTable* tmp=cur;
        SymbolInfo* ans=NULL;

        while(tmp!=NULL){
            ans=tmp->lookUp(str);

            if(ans!=NULL){
                break;
            }

            tmp=tmp->getParentScope();
        }

        if(ans==NULL){
           //out<<"\t'"<<str<<"' not found in any of the ScopeTables"<<endl;
        }

        return ans;
    }

    void printCur(ofstream& out){

        if(cur==NULL){
           //out<<"\tNo scope Table"<<endl;
           return;
        }

        cur->print(out);
    }

    void printAll(ofstream& out){

        if(cur==NULL){
           //out<<"\tNo scope Table"<<endl;
           return;
        }

        ScopeTable* tmp=cur;

        while(tmp!=NULL){
            tmp->print(out);
            tmp=tmp->getParentScope();
        }
    }

};
/*
class ParserSymbol{

    string symbolName;
    int startLine;
    int endLine;
    vector<ParserSymbol*> childList;

public:

    ParserSymbol(string symbolName, int startLine, int endLine){
        this->symbolName=symbolName;
        this->startLine=startLine;
        this->endLine=endLine;
        this->childList.clear();
    }

    ParserSymbol(string symbolName){
        this->symbolName=symbolName;
        this->startLine=-1;
        this->endLine=-1;
        this->childList.clear();
    }

    void setSymbolName(string symbolName){
        this->symbolName=symbolName;
    }

    void setStartLine(int startLine){
        this->startLine=startLine;
    }

    void setEndLine(int endLine){
        this->endLine=endLine;
    }

    void setChildList(vector<ParserSymbol*> childList){
        this->childList=childList;
    }

    string getSymbolName(){
        return this->symbolName;
    }

    int getStartLine(){
        return this->startLine;
    }

    int getEndLine(){
        return this->endLine;
    }

    vector<ParserSymbol*> getChildList(){
        return this->childList;
    }

    void addChild(ParserSymbol* parser){
        childList.push_back(parser);
    }

}
*/
/*
int main()
{

    ifstream in("input.txt");
    ofstream out("output.txt");

    if(!in.is_open()){
       exit(1);
    }

    if(!out.is_open()){
       exit(1);
    }

    int bucketLength,scopeNum=0,totalScope=0;
    //cin>>bucketLength;
    in>>bucketLength;

    SymbolTable symbolTable;
    scopeNum++;
    symbolTable.enterScope(scopeNum,bucketLength,out);
    totalScope++;
    int cmdNo=0;
    string line;
    getline(in,line);

    //string name,type,op;
    while(getline(in,line)){
        //cin>>op;
        //getline(cin,line);
        //cout<<cmdNo<<endl;
        cmdNo++;
        out<<"Cmd "<<cmdNo<<": "<<line<<endl;
        string command[4];
        int start=0,l=0,t=0;

        for(int i=0;i<line.size();i++){

            if(line[i]==' '&&l>0){
               command[t]=line.substr(start,l);
               t++;
               start=i+1;
               l=0;
               if(t>3){
                  break;
               }
            }

            else if(line[i]==' '){
                start++;
            }

            else{
                l++;
            }
        }

        if(l>0){
           command[t]=line.substr(start,l);
           t++;
        }

        if(command[0]=="I"){
           //cin>>name>>type;
           //cout<<"Cmd "<<cmdNo<<": "<<op<<" "<<name<<" "<<type<<endl;
           if(t!=3){
              out<<"\tNumber of parameters mismatch for the command I"<<endl;
              continue;
           }

           SymbolInfo* symbol=new SymbolInfo(command[1],command[2]);
           symbolTable.insertKey(*symbol,out);
        }

        else if(command[0]=="L"){
            //cin>>name;
            //cout<<"Cmd "<<cmdNo<<": "<<op<<" "<<name<<endl;
            if(t!=2){
               out<<"\tNumber of parameters mismatch for the command L"<<endl;
               continue;
            }

            symbolTable.lookUp(command[1],out);
        }

        else if(command[0]=="D"){
            //cin>>name;
            //cout<<"Cmd "<<cmdNo<<": "<<op<<" "<<name<<endl;
            if(t!=2){
               out<<"\tNumber of parameters mismatch for the  command D"<<endl;
               continue;
            }

            symbolTable.deleteKey(command[1],out);
        }

        else if(command[0]=="S"){
            //cout<<"Cmd "<<cmdNo<<": "<<op<<endl;
            if(t!=1){
               out<<"\tNumber of parameters mismatch for the command S"<<endl;
               continue;
            }

            scopeNum++;
            symbolTable.enterScope(scopeNum,bucketLength,out);
            totalScope++;
        }

        else if(command[0]=="E"){
            //cout<<"Cmd "<<cmdNo<<": "<<op<<endl;
            if(t!=1){
               out<<"\tNumber of parameters mismatch for the command E"<<endl;
               continue;
            }

            symbolTable.exitScope(false,out);
            if(totalScope>1){
               totalScope--;
            }
        }

        else if(command[0]=="P"){
            //cin>>name;
            //cout<<"Cmd "<<cmdNo<<": "<<op<<" "<<name<<endl;
            if(t!=2){
               out<<"\tNumber of parameters mismatch for the command P"<<endl;
               continue;
            }

            if(command[1]=="A"){
               symbolTable.printAll(out);
            }
            else if(command[1]=="C"){
                symbolTable.printCur(out);
            }

        }

        else{
            //cout<<"Cmd "<<cmdNo<<": "<<op<<endl;
            break;
        }

    }

    //cout<<totalScope<<endl;
    for(int i=0;i<totalScope;i++){
        symbolTable.exitScope(true,out);
    }

    in.close();
    out.close();
    return 0;

}
*/