/**** ANTLRv4  grammar for OpenQASM3.0. ****/

grammar qasm3;

/** Parser grammar **/

program
    : header statement*
    ;

header
    : version? include*
    ;

version
    : 'OPENQASM' Integer (DOT Integer)? SEMICOLON
    ;

include
    : 'include' StringLiteral SEMICOLON
    ;

statement
    : globalStatement
    | expressionStatement
    | declarationStatement
    | branchingStatement
    | loopStatement
    | controlDirectiveStatement
    | aliasStatement
    | quantumStatement
    | timeStatement
    | pragma
    | comment
    ;

globalStatement: subroutineDefinition
    | kernelDeclaration
    | quantumGateDefinition
    | calibrationDefinition
    ;

declarationStatement
    : ( quantumDeclaration | classicalDeclaration | constantDeclaration) SEMICOLON
    ;

comment : LineComment | BlockComment ;

returnSignature
    : ARROW classicalDeclaration
    ;

programBlock
    : LBRACE statement* RBRACE
    ;

/* Types and Casting */

designator
    : LBRACKET expression RBRACKET
    ;

doubleDesignator
    : LBRACKET expression COMMA expression RBRACKET
    ;

identifierList
    : ( Identifier COMMA )* Identifier
    ;

indexIdentifier
    : Identifier ( designator | doubleDesignator | rangeDefinition )?
    ;

indexIdentifierList
    : ( indexIdentifier COMMA )* indexIdentifier
    ;

association
    : COLON Identifier
    ;

// Quantum Types
quantumType
    : 'qubit'
    | 'qreg'
    ;

quantumDeclaration
    : quantumType indexIdentifierList
    ;

quantumArgument
    : quantumType designator? association
    ;

quantumArgumentList
    : ( quantumArgument COMMA )* quantumArgument
    ;

// Classical Types
bitType
    : 'bit'
    | 'creg'
    ;

singleDesignatorType
    : 'int'
    | 'uint'
    | 'float'
    | 'angle'
    ;

doubleDesignatorType
    : 'fixed'
    ;

noDesignatorType
    : 'bool'
    | timingType
    ;

classicalType
    : singleDesignatorType designator?
    | doubleDesignatorType doubleDesignator?
    | noDesignatorType
    | bitType designator?
    ;

constantDeclaration
    : 'const' Identifier ASSIGN expression
    ;

singleDesignatorDeclaration
    : singleDesignatorType designator Identifier
    ;

doubleDesignatorDeclaration
    : doubleDesignatorType doubleDesignator Identifier
    ;

noDesignatorDeclaration
    : noDesignatorType Identifier
    ;

bitDeclaration
    : bitType indexIdentifierList
    ;

classicalVariableDeclaration
    : singleDesignatorDeclaration
    | doubleDesignatorDeclaration
    | noDesignatorDeclaration
    | bitDeclaration
    ;

classicalDeclaration
    : classicalVariableDeclaration assignmentExpression?
    ;

classicalTypeList
    : ( classicalType COMMA )* classicalType
    ;

classicalArgument
    : classicalType association
    ;

classicalArgumentList
    : ( classicalArgument COMMA )* classicalArgument
    ;

// Aliasing
aliasStatement
    : 'let' Identifier ASSIGN concatenateExpression
    ;

// Register Concatenation and Slicing
concatenateExpression
    : Identifier rangeDefinition
    | Identifier '||' Identifier
    | Identifier LBRACKET expressionList RBRACKET
    ;

rangeDefinition
    : LBRACKET expression? COLON expression? ( COLON expression )? RBRACKET
    ;

/* Gates and Built-in Quantum Instructions */

quantumGateDefinition
    : 'gate' quantumGateSignature quantumBlock
    ;

quantumGateSignature
    : Identifier ( LPAREN classicalArgumentList? RPAREN )? identifierList
    ;

quantumBlock
    : LBRACE ( quantumStatement | comment )* RBRACE
    ;

quantumStatement
    : ( quantumInstruction | quantumMeasurementDeclaration ) SEMICOLON
    ;

quantumInstruction
    : quantumGateCall
    | quantumMeasurement
    | quantumBarrier
    ;

quantumMeasurement
    : 'measure' indexIdentifierList
    ;

quantumMeasurementDeclaration
    : quantumMeasurement ARROW indexIdentifierList
    | indexIdentifierList ASSIGN quantumMeasurement
    ;

quantumBarrier
    : 'barrier' indexIdentifierList
    ;

quantumGateModifier
    : ( 'inv' | 'pow' LPAREN Integer RPAREN | 'ctrl' ) '@'
    ;

quantumGateCall
    : quantumGateName ( LPAREN expressionList? RPAREN )? indexIdentifierList
    ;

quantumGateName
    : 'CX'
    | 'U'
    | 'reset'
    | Identifier
    | quantumGateModifier quantumGateName
    ;

/* Classical Instructions */

unaryOperator
    : '~' | '!'
    ;

binaryOperator
    : '+' | '-' | '*' | '/' | '<<' | '>>' | 'rotl' | 'rotr' | '&&' | '||' | '&' | '|' | '^'
    | '>' | '<' | '>=' | '<=' | '==' | '!='
    ;

expressionStatement
    : expression SEMICOLON
    | 'return' expressionStatement
    ;

expression
    : expression binaryOperator expression
    | unaryOperator expression
    | membershipTest
    | expression LBRACKET expression RBRACKET
    | parenList
    | call parenList
    | expression incrementor
    | quantumMeasurement
    | MINUS? expressionTerminator
    ;

expressionTerminator
    : Constant
    | Integer
    | RealNumber
    | Identifier
    | StringLiteral
    | timeTerminator
    ;

expressionList
    : ( expression COMMA )* expression
    ;

parenList
    : MINUS? LPAREN expressionList? RPAREN
    ;

call
    : Identifier
    | builtInMath
    | castOperator
    ;

builtInMath
    : 'sin' | 'cos' | 'tan' | 'exp' | 'ln' | 'sqrt' | 'popcount' | 'lengthof'
    ;

castOperator
    : classicalType
    ;

incrementor
    : '++'
    | '--'
    ;

assignmentExpression
    : assignmentOperator expression
    ;

assignmentOperator
    : ASSIGN
    | ARROW
    | '+=' | '-=' | '*=' | '/=' | '&=' | '|=' | '~=' | '^=' | '<<=' | '>>='
    ;

membershipTest
    : Identifier 'in' setDeclaration
    ;

setDeclaration
    : LBRACE expressionList RBRACE
    | rangeDefinition
    ;

loopBranchBlock
    : statement
    | programBlock
    ;

branchingStatement
    : 'if' LPAREN expression RPAREN loopBranchBlock ( 'else' loopBranchBlock )?
    ;

loopStatement: ( 'for' membershipTest | 'while' LPAREN expression RPAREN ) loopBranchBlock
    ;

controlDirectiveStatement
    : controlDirective SEMICOLON
    ;

controlDirective
    : 'break'
    | 'continue'
    | 'end'
    ;

kernelDeclaration
    : 'kernel' Identifier ( LPAREN classicalTypeList? RPAREN )? returnSignature?
    classicalType? SEMICOLON
    ;

/* Subroutines */

subroutineDefinition
    : 'def' Identifier ( LPAREN classicalArgumentList? RPAREN )? quantumArgumentList?
    returnSignature? programBlock
    ;

/* Directives */

pragma
    : '#pragma' LBRACE . RBRACE
    ;

/* Circuit Timing */

timingType
    : 'length'
    | 'stretch' Integer?
    ;

timingBox
    : 'boxas' Identifier quantumBlock
    | 'boxto' TimeLiteral quantumBlock
    ;

timeTerminator
    : timeIdentifier | 'stretchinf'
    ;

timeIdentifier
    :  TimeLiteral
    | 'lengthof' LPAREN Identifier RPAREN
    ;


timeInstructionName
    : 'delay'
    | 'rotary'
    ;

timeInstruction
    : timeInstructionName ( LPAREN expressionList? RPAREN )? designator
    ( rangeDefinition | indexIdentifierList )
    ;

timeStatement
    : timeInstruction SEMICOLON
    | timingBox
    ;

/* Pulse Level Descriptions of Gates and Measurement */

calibration
    : calibrationGrammarDeclaration
    | calibrationDefinition
    ;

calibrationGrammarDeclaration
    : 'defcalgrammar' calibrationGrammar SEMICOLON
    ;

calibrationDefinition
    : 'defcal' calibrationGrammar? Identifier
    ( LPAREN calibrationArgumentList? RPAREN )? identifierList
    returnSignature? LBRACE . RBRACE
    ;

calibrationGrammar
    : 'openpulse' | Identifier
    ;

calibrationArgumentList
    : classicalArgumentList | expressionList
    ;

/** Lexer grammar **/

LBRACKET : '[' ;
RBRACKET : ']' ;

LBRACE : '{' ;
RBRACE : '}' ;

LPAREN : '(' ;
RPAREN : ')' ;

COLON: ':' ;
SEMICOLON : ';' ;

DOT : '.' ;
COMMA : ',' ;

ASSIGN : '=' ;
ARROW : '->' ;

MINUS : '-' ;

Constant : 'pi' | 'π' | 'tau' | '𝜏' | 'euler' | 'e' ;

Whitespace : [ \t]+ -> skip ;
Newline : [\r\n]+ -> skip ;

fragment Digit : [0-9] ;
Integer : MINUS? Digit+ ;

fragment LowerCaseCharacter : [a-z] ;
fragment UpperCaseCharacter : [A-Z] ;

fragment SciNotation : [eE] ;
fragment PlusMinus : [-+] ;

fragment Float : Integer* DOT Integer+ ;

RealNumber : MINUS? Float (SciNotation PlusMinus? Float)? ;

fragment NumericalCharacter
    : LowerCaseCharacter
    | UpperCaseCharacter
    | '_'
    | Integer
    ;

Identifier : LowerCaseCharacter NumericalCharacter* ;

fragment TimeUnit
    : 'dt' | 'ns' | 'us' | 'ms' | 's'
    ;

TimeLiteral : RealNumber TimeUnit ;  // represents explicit time value in SI or backend units

fragment Quotation : '"' | '\'' ;

StringLiteral : Quotation Any Quotation ;

fragment AnyString : ~[ \t\r\n]+? ;
fragment Any : ( AnyString | Whitespace | Newline )+ ;
fragment AnyBlock : LBRACE Any? RBRACE ;

LineComment : '//' ~('\r'|'\n')*; // Token because Any matches all strings
BlockComment : '/*' Any '*/' ; // Token because Any matches all strings
