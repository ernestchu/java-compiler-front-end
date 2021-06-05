<FieldDeclaration>  ::= <FieldModifiers>? <Type> <VariableDeclarators> ;
<FieldModifiers>    ::= <FieldModifier> | <FieldModifiers> <FieldModifier>
<FieldModifier>	    ::= public | protected | private | static | final | transient | volatile

<MethodDeclaration> ::= <MethodHeader> <MethodBody>
<MethodHeader>	    ::= <MethodModifiers>? <ResultType> <MethodDeclarator> <Throws>?
<ResultType>	    ::= <Type> | void
<MethodModifiers>   ::= <MethodModifier> | <MethodModifiers> <MethodModifier>
<MethodModifier>    ::= public | protected | private | static | abstract | final | synchronized | native
