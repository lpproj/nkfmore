#!/usr/local/bin/perl
#
# nkf test program for nkf 1.7
#    Shinji KONO <kono@ie.u-ryukyu.ac.jp>
# Sun Aug 18 12:25:40 JST 1996
# Sun Nov  8 00:16:06 JST 1998
#
# This is useful when you add new patch on nkf.
# Since this test is too strict, faileurs may not mean
# wrong conversion. 
#
# nkf 1.5 differs on MIME decoding
# nkf 1.4 passes Basic Conversion tests
# nkf PDS version passes Basic Conversion tests  using "nkf -iB -oB "
#

# Basic Conversion
print "\nBasic Conversion test\n\n";

# I gave up simple literal quote because there are big difference
# on perl4 and perl5 on literal quote. Of course we cannot use
# jperl.

$example{'jis'} = unpack('u',<<'eofeof');
M1FER<W0@4W1A9V4@&R1"(3DQ(3%^2R%+?D]3&RA"(%-E8V]N9"!3=&%G92`;
M)$)0)TU:&RA"($AI<F%G86YA(!LD0B0B)"0D)B0H)"HD;R1R)',;*$(*2V%T
M86MA;F$@&R1")2(E)"4F)2@E*B5O)7(E<QLH0B!+:6=O=2`;)$(A)B%G(S`C
/029!)E@G(B=!*$`;*$(*
eofeof

$example{'sjis'} = unpack('u',<<'eofeof');
M1FER<W0@4W1A9V4@@5B)0(F>ED"6GIAR(%-E8V]N9"!3=&%G92"8I9=Y($AI
M<F%G86YA((*@@J*"I(*F@JB"[8+P@O$*2V%T86MA;F$@@T&#0X-%@T>#28./
>@Y*#DR!+:6=O=2"!18&'@D^"8(._@]:$081@A+X*
eofeof

$example{'euc'} = unpack('u',<<'eofeof');
M1FER<W0@4W1A9V4@H;FQH;'^RZ'+_L_3(%-E8V]N9"!3=&%G92#0I\W:($AI
M<F%G86YA(*2BI*2DIJ2HI*JD[Z3RI/,*2V%T86MA;F$@I:*EI*6FI:BEJJ7O
>I?*E\R!+:6=O=2"AIJ'GH["CP:;!IMBGHJ?!J,`*
eofeof

$example{'utf'} = unpack('u',<<'eofeof');
M1FER<W0@4W1A9V4@XX"%Z9FBY;^<YK.5YKJ`Z(65(%-E8V]N9"!3=&%G92#D
MN+SI@:4@2&ER86=A;F$@XX&"XX&$XX&&XX&(XX&*XX*/XX*2XX*3"DMA=&%K
M86YA(.."HN."I.."IN."J.."JN.#K^.#LN.#LR!+:6=O=2#C@[OBB)[OO)#O
.O*'.L<^)T)'0K^*5@@H`
eofeof


$example{'jis1'} = unpack('u',<<'eofeof');
M&R1";3%Q<$$L&RA""ALD0F4Z3F\;*$(*&R1"<FT;*$()&R1"/F5.3D]+&RA"
#"0D*
eofeof

$example{'sjis1'} = unpack('u',<<'eofeof');
8YU#ID)%+"N-9E^T*Z>L)C^.7S)AJ"0D*
eofeof

$example{'euc1'} = unpack('u',<<'eofeof');
8[;'Q\,&L"N6ZSN\*\NT)ON7.SL_+"0D*
eofeof

$example{'utf1'} = unpack('u',<<'eofeof');
AZ+J%Z:N/Z8JM"N>VNNFZEPKIM(D)Y+B*Z:"8Y+J8"0D*
eofeof

$example{'jis2'} = unpack('u',<<'eofeof');
+&R1".EA&(QLH0@H`
eofeof

$example{'sjis2'} = unpack('u',<<'eofeof');
%C=:3H0H`
eofeof

$example{'euc2'} = unpack('u',<<'eofeof');
%NMC&HPH`
eofeof

$example{'utf2'} = unpack('u',<<'eofeof');
'YI:.Z)>D"@``
eofeof

# From JIS

print "JIS  to JIS ... ";&test("$nkf   ",$example{'jis'},$example{'jis'});
print "JIS  to SJIS... ";&test("$nkf -s",$example{'jis'},$example{'sjis'});
print "JIS  to EUC ... ";&test("$nkf -e",$example{'jis'},$example{'euc'});
print "JIS  to UTF8... ";&test("$nkf -w",$example{'jis'},$example{'utf'});

# From SJIS

print "SJIS to JIS ... ";&test("$nkf -j",$example{'sjis'},$example{'jis'});
print "SJIS to SJIS... ";&test("$nkf -s",$example{'sjis'},$example{'sjis'});
print "SJIS to EUC ... ";&test("$nkf -e",$example{'sjis'},$example{'euc'});
print "SJIS to UTF8... ";&test("$nkf -w",$example{'sjis'},$example{'utf'});

# From EUC

print "EUC  to JIS ... ";&test("$nkf   ",$example{'euc'},$example{'jis'});
print "EUC  to SJIS... ";&test("$nkf -s",$example{'euc'},$example{'sjis'});
print "EUC  to EUC ... ";&test("$nkf -e",$example{'euc'},$example{'euc'});
print "EUC  to UTF8... ";&test("$nkf -w",$example{'euc'},$example{'utf'});

# From UTF8

print "UTF8 to JIS ... ";&test("$nkf   ",$example{'utf'},$example{'jis'});
print "UTF8 to SJIS... ";&test("$nkf -s",$example{'utf'},$example{'sjis'});
print "UTF8 to EUC ... ";&test("$nkf -e",$example{'utf'},$example{'euc'});
print "UTF8 to UTF8... ";&test("$nkf -w",$example{'utf'},$example{'utf'});



# From JIS

print "JIS  to JIS ... ";&test("$nkf   ",$example{'jis1'},$example{'jis1'});
print "JIS  to SJIS... ";&test("$nkf -s",$example{'jis1'},$example{'sjis1'});
print "JIS  to EUC ... ";&test("$nkf -e",$example{'jis1'},$example{'euc1'});
print "JIS  to UTF8... ";&test("$nkf -w",$example{'jis1'},$example{'utf1'});

# From SJIS

print "SJIS to JIS ... ";&test("$nkf -j",$example{'sjis1'},$example{'jis1'});
print "SJIS to SJIS... ";&test("$nkf -s",$example{'sjis1'},$example{'sjis1'});
print "SJIS to EUC ... ";&test("$nkf -e",$example{'sjis1'},$example{'euc1'});
print "SJIS to UTF8... ";&test("$nkf -w",$example{'sjis1'},$example{'utf1'});

# From EUC

print "EUC  to JIS ... ";&test("$nkf   ",$example{'euc1'},$example{'jis1'});
print "EUC  to SJIS... ";&test("$nkf -s",$example{'euc1'},$example{'sjis1'});
print "EUC  to EUC ... ";&test("$nkf -e",$example{'euc1'},$example{'euc1'});
print "EUC  to UTF8... ";&test("$nkf -w",$example{'euc1'},$example{'utf1'});

# From UTF8

print "UTF8 to JIS ... ";&test("$nkf   ",$example{'utf1'},$example{'jis1'});
print "UTF8 to SJIS... ";&test("$nkf -s",$example{'utf1'},$example{'sjis1'});
print "UTF8 to EUC ... ";&test("$nkf -e",$example{'utf1'},$example{'euc1'});
print "UTF8 to UTF8... ";&test("$nkf -w",$example{'utf1'},$example{'utf1'});

# Ambigous Case

$example{'amb'} = unpack('u',<<'eofeof');
MI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<*PL:7"L+&E
MPK"QI<*PL:7"L+&EPK"QI<(*I<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<*P
ML:7"L+&EPK"QI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<(*I<*PL:7"L+&E
MPK"QI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<*PL:7"
ML+&EPK"QI<(*I<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"Q
MI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<(*I<*PL:7"L+&EPK"QI<*PL:7"
ML+&EPK"QI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<*PL:7"L+&EPK"QI<(*
eofeof

$example{'amb.euc'} = unpack('u',<<'eofeof');
M&R1")4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25"
M,#$E0C`Q)4(P,25",#$E0C`Q)4(;*$(*&R1")4(P,25",#$E0C`Q)4(P,25"
M,#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(;
M*$(*&R1")4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P
M,25",#$E0C`Q)4(P,25",#$E0C`Q)4(;*$(*&R1")4(P,25",#$E0C`Q)4(P
M,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q
M)4(;*$(*&R1")4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q
>)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(;*$(*
eofeof

$example{'amb.sjis'} = unpack('u',<<'eofeof');
M&RA))4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25"
M,#$E0C`Q)4(P,25",#$E0C`Q)4(;*$(*&RA))4(P,25",#$E0C`Q)4(P,25"
M,#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(;
M*$(*&RA))4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P
M,25",#$E0C`Q)4(P,25",#$E0C`Q)4(;*$(*&RA))4(P,25",#$E0C`Q)4(P
M,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q
M)4(;*$(*&RA))4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q
>)4(P,25",#$E0C`Q)4(P,25",#$E0C`Q)4(;*$(*
eofeof

print "Ambiguous Case. ";
    &test("$nkf",$example{'amb'},$example{'amb.euc'});

# Input assumption

print "SJIS  Input assumption ";
    &test("$nkf -Sx",$example{'amb'},$example{'amb.sjis'});

# Broken JIS

print "Broken JIS ";
    $input = $example{'jis'};
    $input =~ s/\033//g;
    &test("$nkf -Be",$input,$example{'euc'});
print "Broken JIS is safe on Normal JIS? ";
    $input = $example{'jis'};
    &test("$nkf -Be",$input,$example{'euc'});

# X0201 $B2>L>(B
# X0201->X0208 conversion
# X0208 aphabet -> ASCII
# X0201 $BAj8_JQ49(B

print "\nX0201 test\n\n";

$example{'x0201.sjis'} = unpack('u',<<'eofeof');
MD5.*<(-*@TR#3H-0@U*#2X--@T^#48-3"I%3B7""8()A@F*"8X)D@F6"9H*!
M@H*"@X*$@H6"AH*'"I%3BTR-AH%)@9>!E(&0@9.!3X&5@9:!:8%J@7R!>X&!
M@6V!;H%O@7"!CPJ4O(IPMK>X/;FZMMZWWKC>N=ZZWH+&"I2\BG#*W\O?S-_-
MW\[?M]^QW@K*W\O?S`IH86YK86MU(,K?R]_,I`K*W\O?S-VA"I2\BG""S(SC
!"@!"
eofeof

$example{'x0201.euc'} = unpack('u',<<'eofeof');
MP;2ST:6KI:VEKZ6QI;.EK*6NI;"ELJ6T"L&TL=&CP:/"H\.CQ*/%H\:CQZ/A
MH^*CXZ/DH^6CYJ/G"L&TM:VYYJ&JH?>A]*'PH?.AL*'UH?:ARJ'+H=VAW*'A
MH<ZASZ'0H=&A[PK(OK/1CK:.MXZX/8ZYCKJ.MH[>CK>.WHZXCMZ.N8[>CKJ.
MWJ3("LB^L]&.RH[?CLN.WX[,CM^.S8[?CLZ.WXZWCM^.L8[>"H[*CM^.RX[?
MCLP*:&%N:V%K=2".RH[?CLN.WX[,CJ0*CLJ.WX[+CM^.S([=CJ$*R+ZST:3.
#N.4*
eofeof

$example{'x0201.utf'} = unpack('u',<<'eofeof');
MY86HZ*>2XX*KXX*MXX*OXX*QXX*SXX*LXX*NXX*PXX*RXX*T"N6%J.B+L>^\
MH>^\HN^\H^^\I.^\I>^\IN^\I^^]@>^]@N^]@^^]A.^]A>^]AN^]APKEA:CH
MJ)CEC[?OO('OO*#OO(/OO(3OO(7OO+[OO(;OO(KOO(COO(GBB)+OO(OOO)WO
MO+OOO+WOO9OOO9WOOZ4*Y8V*Z*>2[[VV[[VW[[VX/>^]N>^]NN^]MN^^GN^]
MM^^^GN^]N.^^GN^]N>^^GN^]NN^^GN.!J`KEC8KHIY+OOHKOOI_OOHOOOI_O
MOHSOOI_OOHWOOI_OOH[OOI_OO;?OOI_OO;'OOIX*[[Z*[[Z?[[Z+[[Z?[[Z,
M"FAA;FMA:W4@[[Z*[[Z?[[Z+[[Z?[[Z,[[VD"N^^BN^^G^^^B^^^G^^^C.^^
2G>^]H0KEC8KHIY+C@:[EOHP*
eofeof

$example{'x0201.jis'} = unpack('u',<<'eofeof');
M&R1"030S424K)2TE+R4Q)3,E+"4N)3`E,B4T&RA""ALD0D$T,5$C02-"(T,C
M1"-%(T8C1R-A(V(C8R-D(V4C9B-G&RA""ALD0D$T-2TY9B$J(7<A="%P(7,A
M,"%U(78A2B%+(5TA7"%A(4XA3R%0(5$A;QLH0@H;)$)(/C-1&RA)-C<X&RA"
M/1LH23DZ-EXW7CA>.5XZ7ALD0B1(&RA""ALD0D@^,U$;*$E*7TM?3%]-7TY?
M-U\Q7ALH0@H;*$E*7TM?3!LH0@IH86YK86MU(!LH24I?2U],)!LH0@H;*$E*
97TM?3%TA&RA""ALD0D@^,U$D3CAE&RA""@``
eofeof

$example{'x0201.sosi'} = unpack('u',<<'eofeof');
M&R1"030S424K)2TE+R4Q)3,E+"4N)3`E,B4T&RA*"ALD0D$T,5$C02-"(T,C
M1"-%(T8C1R-A(V(C8R-D(V4C9B-G&RA*"ALD0D$T-2TY9B$J(7<A="%P(7,A
M,"%U(78A2B%+(5TA7"%A(4XA3R%0(5$A;QLH2@H;)$)(/C-1&RA*#C8W.`\;
M*$H]#CDZ-EXW7CA>.5XZ7@\;)$(D2!LH2@H;)$)(/C-1&RA*#DI?2U],7TU?
M3E\W7S%>#PH.2E]+7TP/&RA*"FAA;FMA:W4@#DI?2U],)`\;*$H*#DI?2U],
672$/&RA*"ALD0D@^,U$D3CAE&RA""@``
eofeof

$example{'x0201.x0208'} = unpack('u',<<'eofeof');
M&R1"030S424K)2TE+R4Q)3,E+"4N)3`E,B4T&RA""ALD0D$T,5$;*$)!0D-$
M149'86)C9&5F9PH;)$)!-#4M.68;*$(A0",D)5XF*B@I+2L]6UU[?1LD0B%O
M&RA""ALD0D@^,U$E*R4M)2\;*$(]&R1")3$E,R4L)2XE,"4R)30D2!LH0@H;
M)$)(/C-1)5$E5"57)5HE724M(2PE(B$K&RA""ALD0B51)50E51LH0@IH86YK
M86MU(!LD0B51)50E52$B&RA""ALD0B51)50E525S(2,;*$(*&R1"2#XS421.
&.&4;*$(*
eofeof

# -X is necessary to allow X0201 in SJIS
# -Z convert X0208 alphabet to ASCII
print "X0201 conversion: SJIS ";
    &test("$nkf -XZ",$example{'x0201.sjis'},$example{'x0201.x0208'});
print "X0201 conversion: JIS  ";
    &test("$nkf -Z",$example{'x0201.jis'},$example{'x0201.x0208'});
print "X0201 conversion:SI/SO ";
    &test("$nkf -Z",$example{'x0201.sosi'},$example{'x0201.x0208'});
print "X0201 conversion: EUC  ";
    &test("$nkf -Z",$example{'x0201.euc'},$example{'x0201.x0208'});
print "X0201 conversion: UTF8 ";
    &test("$nkf -Z",$example{'x0201.utf'},$example{'x0201.x0208'});
# -x means X0201 output
print "X0201 output: SJIS     ";
    &test("$nkf -xs",$example{'x0201.euc'},$example{'x0201.sjis'});
print "X0201 output: JIS      ";
    &test("$nkf -xj",$example{'x0201.sjis'},$example{'x0201.jis'});
print "X0201 output: EUC      ";
    &test("$nkf -xe",$example{'x0201.jis'},$example{'x0201.euc'});
print "X0201 output: UTF8     ";
    &test("$nkf -xw",$example{'x0201.jis'},$example{'x0201.utf'});

# MIME decode

print "\nMIME test\n\n";

# MIME ISO-2022-JP

$example{'mime.iso2022'} = unpack('u',<<'eofeof');
M/3])4T\M,C`R,BU*4#]"/T=Y4D%.144W96E23TI566Q/4U9)1WEH2S\]"CT_
M:7-O+3(P,C(M2E`_0C]'>5)!3D5%-V5I4D]*55EL3U-624=Y:$L_/0H]/VES
M;RTR,#(R+4I0/U$_/3%")$(D1B11/3%"*$)?96YD/ST*&R1`)#TD)B0K)$H;
M*$H@/3])4T\M,C`R,BU*4#]"/T=Y4D%.144W96E23U!Y:S=D:'-O4V<]/3\]
M(&5N9"!O9B!L:6YE"CT_25-/+3(P,C(M2E`_0C]'>5)!3D5%-V5I4D]0>6LW
M9&AS;U-G/3T_/2`]/TE33RTR,#(R+4I0/T(_1WE204Y%13=E:5)/4'EK-V1H
M<V]39ST]/ST*0G)O:V5N(&-A<V4*/3])4T\M,C`R,BU*4#]"/T=Y4D%.144W
M96E23U!Y:S=D"FAS;U-G/3T_/2`]/TE33RTR,`HR,BU*4#]"/T=Y4D%.144W
M96E23U!Y:S=D:'-O4V<]/3\]"CT_25-/+3(P,C(M2E`_0C]'>5)!3D5%-V5I
44D]*55EL3QM;2U-624=Y:$L_/0H_
eofeof

$example{'mime.ans.strict'} = unpack('u',<<'eofeof');
M&R1"-$$[>B1.)48E.25(&RA""ALD0C1!.WHD3B5&)3DE2!LH0@H;)$(D1B11
M&RA"(&5N9`H;)$(D/20F)"LD2ALH0B`;)$(T03MZ)$X_*3MV&RA"96YD(&]F
M(&QI;F4*&R1"-$$[>B1./RD[=C1!.WHD3C\I.W8;*$(*0G)O:V5N(&-A<V4*
M/3])4T\M,C`R,BU*4#]"/T=Y4D%.144W96E23U!Y:S=D"FAS;U-G/3T_/2`]
M/TE33RTR,`HR,BU*4#]"/T=Y4D%.144W96E23U!Y:S=D:'-O4V<]/3\]"CT_
L25-/+3(P,C(M2E`_0C]'>5)!3D5%-V5I4D]*55EL3QM;2U-624=Y:$L_/0H_
eofeof

$example{'mime.unbuf.strict'} = unpack('u',<<'eofeof');
M&R1"-$$[>B1.)48E.25(&RA""ALD0C1!.WHD3B5&)3DE2!LH0@H;)$(D1B11
M&RA"(&5N9`H;)$(D/20F)"LD2ALH0B`;)$(T03MZ)$X_*3MV&RA"96YD(&]F
M(&QI;F4*&R1"-$$[>B1./RD[=C1!.WHD3C\I.W8;*$(*0G)O:V5N(&-A<V4*
M&R1"-$$[>B1./RD;*$)H<V]39ST]/ST@/3])4T\M,C`*,C(M2E`_0C]'>5)!
M3D5%-V5I4D]0>6LW9&AS;U-G/3T_/0H;)$(T03MZ)$XE1ALH0EM+4U9)1WEH
$2S\]"F5I
eofeof

$example{'mime.ans'} = unpack('u',<<'eofeof');
M&R1"-$$[>B1.)48E.25(&RA""ALD0C1!.WHD3B5&)3DE2!LH0@H;)$(D1B11
M&RA"(&5N9`H;)$(D/20F)"LD2ALH0B`;)$(T03MZ)$X_*3MV&RA"96YD(&]F
M(&QI;F4*&R1"-$$[>B1./RD[=C1!.WHD3C\I.W8;*$(*0G)O:V5N(&-A<V4*
M&R1"-$$[>B1./RD;*$)H<V]39ST]/ST@&R1"-$$[>B1./RD[=ALH0@H;)$(T
603MZ)$XE1ALH0EM+4U9)1WEH2S\]"@`*
eofeof

$example{'mime.unbuf'} = unpack('u',<<'eofeof');
M&R1"-$$[>B1.)48E.25(&RA""ALD0C1!.WHD3B5&)3DE2!LH0@H;)$(D1B11
M&RA"(&5N9`H;)$(D/20F)"LD2ALH0B`;)$(T03MZ)$X_*3MV&RA"96YD(&]F
M(&QI;F4*&R1"-$$[>B1./RD[=C1!.WHD3C\I.W8;*$(*0G)O:V5N(&-A<V4*
M&R1"-$$[>B1./RD;*$)H<V]39ST]/ST@&R1"-$$[>B1./RD[=ALH0@H;)$(T
603MZ)$XE1ALH0EM+4U9)1WEH2S\]"@`*
eofeof

$example{'mime.base64'} = unpack('u',<<'eofeof');
M9W-M5"])3&YG<FU#>$I+-&=Q=4,S24LS9W%Q0E%:3TUI-39,,S0Q-&=S5T)1
M43!+9VUA1%9O3T@*9S)+1%1O3'=K8C)1;$E+;V=Q2T-X24MG9W5M0W%*3EEG
<<T=#>$E+9V=U;4,X64Q&9W)70S592VMG<6U""F=Q
eofeof

$example{'mime.base64.ans'} = unpack('u',<<'eofeof');
M&R1")$M&?B1I)#LD1D0Z)"TD7B0Y)"PA(D5L-7XV83E9)$<A(ALH0@T*&R1"
M(T<E-R5G)4,E+R1R0C\_="0J)"0D1B0B)&LD*D4Y)$,D1B0B)&LD<R1')#<D
(9R0F)"L;*$(E
eofeof

# print "Next test is expected to Fail.\n";
print "MIME decode (strict)   ";
    $tmp = &test("$nkf -mS",$example{'mime.iso2022'},$example{'mime.ans.strict'});

$example{'mime.ans.alt'} = unpack('u',<<'eofeof');
M&R1"-$$[>B1.)48E.25(&RA""ALD0C1!.WHD3B5&)3DE2!LH0@H;)$(D1B11
M&RA"96YD"ALD0B0])"8D*R1*&RA"&R1"-$$[>B1./RD[=ALH0F5N9&]F;&EN
M90H;)$(T03MZ)$X_*3MV-$$[>B1./RD[=ALH0@I"<F]K96YC87-E"ALD0C1!
H.WHD3C\I.W8T03MZ)$X_*3MV&RA""ALD0C1!.WHD3B5&)3DE)!LH0@``
eofeof

$example{'mime.unbuf.alt'} = unpack('u',<<'eofeof');
M&R1"-$$[>B1.)48E.25(&RA""ALD0C1!.WHD3B5&)3DE2!LH0@H;)$(D1B11
M&RA"96YD"ALD0B0])"8D*R1*&RA"&R1"-$$[>B1./RD[=ALH0F5N9&]F;&EN
M90H;)$(T03MZ)$X_*3MV-$$[>B1./RD[=ALH0@I"<F]K96YC87-E"ALD0C1!
H.WHD3C\I.W8T03MZ)$X_*3MV&RA""ALD0C1!.WHD3B5&)3DE)!LH0@``
eofeof

print "MIME decode (nonstrict)";
    $tmp = &test("$nkf -mN",$example{'mime.iso2022'},$example{'mime.ans'},$example{'mime.ans.alt'});
    # open(OUT,">tmp1");print OUT pack('u',$tmp);close(OUT);
# unbuf mode implies more pessimistic decode
print "MIME decode (unbuf)    ";
    $tmp = &test("$nkf -mNu",$example{'mime.iso2022'},$example{'mime.unbuf'},$example{'mime.unbuf.alt'});
    # open(OUT,">tmp2");print OUT pack('u',$tmp);close(OUT);
print "MIME decode (base64)   ";
    &test("$nkf -mB",$example{'mime.base64'},$example{'mime.base64.ans'});

# MIME ISO-8859-1

$example{'mime.is8859'} = unpack('u',<<'eofeof');
M/3])4T\M.#@U.2TQ/U$_*CU#-V%V83\_/2`*4&5E<B!4]G)N9W)E;@I,87-S
M92!(:6QL97+X92!0971E<G-E;B`@7"`B36EN(&MA97!H97-T(&AA<B!F86%E
M="!E="!F;V5L(2(*06%R:'5S(%5N:79E<G-I='DL($1%3DU!4DL@(%P@(DUI
<;B!KYG!H97-T(&AA<B!FY65T(&5T(&;X;"$B"@!K
eofeof

$example{'mime.is8859.ans'} = unpack('u',<<'eofeof');
M*L=A=F$_(`I0965R(%3V<FYG<F5N"DQA<W-E($AI;&QE<OAE(%!E=&5R<V5N
M("!<(")-:6X@:V%E<&AE<W0@:&%R(&9A865T(&5T(&9O96PA(@I!87)H=7,@
M56YI=F5R<VET>2P@1$5.34%22R`@7"`B36EN(&OF<&AE<W0@:&%R(&;E970@
)970@9OAL(2(*
eofeof

# Without -l, ISO-8859-1 was handled as X0201.

print "MIME ISO-8859-1 (Q)    ";
    &test("$nkf -ml",$example{'mime.is8859'},$example{'mime.is8859.ans'});

# test for -f is not so simple.

print "\nBug Fixes\n\n";

# test_data/cr

$example{'test_data/cr'} = unpack('u',<<'eofeof');
1I,:DN:3(#71E<W0-=&5S=`T`
eofeof

$example{'test_data/cr.ans'} = unpack('u',<<'eofeof');
7&R1")$8D.21(&RA""G1E<W0*=&5S=`H`
eofeof

print "test_data/cr    ";
    &test("$nkf -d",$example{'test_data/cr'},$example{'test_data/cr.ans'});
# test_data/fixed-qencode

$example{'test_data/fixed-qencode'} = unpack('u',<<'eofeof');
M("`@("`@("`],4(D0CYE/STS1#TQ0BA""B`@("`@("`@/3%")$(^93TS1CTS
'1#TQ0BA""@``
eofeof

$example{'test_data/fixed-qencode.ans'} = unpack('u',<<'eofeof');
F("`@("`@("`;)$(^93\]&RA""B`@("`@("`@&R1"/F4_/1LH0@H`
eofeof

print "test_data/fixed-qencode    ";
    &test("$nkf -mQ",$example{'test_data/fixed-qencode'},$example{'test_data/fixed-qencode.ans'});
# test_data/long-fold-1

$example{'test_data/long-fold-1'} = unpack('u',<<'eofeof');
MI,JDK*2DI,JDK*2DI,JDK*'!I*2DKJ3GI*:DK*2BI.JDWJ2WI,:AHJ2SI.RD
M\J2]I,ZDWJ3>I**DQ*2KI*:DR*&BI,FDIJ3BI-^DT*2HI*RD[Z3KI*2DMZ&B
MI,BDP:3EI*:DQZ3!I.>D\Z2NI.RDZZ2KI.*DMZ3SI,JDI*&C"J2SI+.DS\.[
'I*2YU*&C"@``
eofeof

$example{'test_data/long-fold-1.ans'} = unpack('u',<<'eofeof');
M&R1")$HD+"0D)$HD+"0D)$HD+"%!)"0D+B1G)"8D+"0B)&HD7B0W)$8A(B0S
M)&PD<B0])$XD7B1>)"(D1"0K&RA""ALD0B0F)$@A(B1))"8D8B1?)%`D*"0L
M)&\D:R0D)#<A(B1()$$D920F)$<D021G)',D+B1L)&LD*R1B)#<D<QLH0@H;
A)$(D2B0D(2,;*$(*&R1")#,D,R1/0SLD)#E4(2,;*$(*
eofeof

print "test_data/long-fold-1    ";
    &test("$nkf -F60",$example{'test_data/long-fold-1'},$example{'test_data/long-fold-1.ans'});
# test_data/long-fold

$example{'test_data/long-fold'} = unpack('u',<<'eofeof');
MI,JDK*2DI,JDK*2DI,JDK*'!I*2DKJ3GI*:DK*2BI.JDWJ2WI,:AHJ2SI.RD
M\J2]I,ZDWJ3>I**DQ*2KI*:DR*&BI,FDIJ3BI-^DT*2HI*RD[Z3KI*2DMZ&B
MI,BDP:3EI*:DQZ3!I.>D\Z2NI.RDZZ2KI.*DMZ3SI,JDI*&C"J2SI+.DS\.[
'I*2YU*&C"@``
eofeof

$example{'test_data/long-fold.ans'} = unpack('u',<<'eofeof');
M&R1")$HD+"0D)$HD+"0D)$HD+"%!)"0D+B1G)"8D+"0B)&HD7B0W)$8A(B0S
M)&PD<B0])$XD7B1>)"(D1"0K&RA""ALD0B0F)$@A(B1))"8D8B1?)%`D*"0L
M)&\D:R0D)#<A(B1()$$D920F)$<D021G)',D+B1L)&LD*R1B)#<D<QLH0@H;
:)$(D2B0D(2,D,R0S)$]#.R0D.50A(QLH0@H`
eofeof

print "test_data/long-fold    ";
    &test("$nkf -f60",$example{'test_data/long-fold'},$example{'test_data/long-fold.ans'});
# test_data/mime_out

$example{'test_data/mime_out'} = unpack('u',<<'eofeof');
M"BTM+2T*4W5B:F5C=#H@86%A82!A86%A(&%A86$@86%A82!A86%A(&%A86$@
M86%A82!A86%A(&%A86$@86%A82!A86%A(&%A86$@86%A82!A86%A"BTM+2T*
M4W5B:F5C=#H@I**DI*2FI*BDJJ2KI*VDKZ2QI+.DM:2WI+FDNZ2]I+^DP:3$
MI,:DR*3*I,NDS*3-I,ZDSZ32I-6DV*3;I-ZDWZ3@I.&DXJ3DI*2DYJ2HI.@*
M+2TM+0I3=6)J96-T.B!A86%A(&%A86$@86%A82!A86%A(&%A86$@86%A82!A
I86%A(*2BI*2DIJ2HI*H@86%A82!A86%A(&%A86$@86%A80HM+2TM"@H`
eofeof

$example{'test_data/mime_out.ans'} = unpack('u',<<'eofeof');
M"BTM+2T*4W5B:F5C=#H@86%A82!A86%A(&%A86$@86%A82!A86%A(&%A86$@
M86%A82!A86%A(&%A86$*(&%A86$@86%A82!A86%A(&%A86$@86%A80HM+2TM
M"E-U8FIE8W0Z(#T_25-/+3(P,C(M2E`_0C]'>5)#2D-):TI#46U*0V=K2VE1
M<DI#,&M,>5%X2D1-:TY343-*1&MK3WAS;U%G/3T_/2`*(#T_25-/+3(P,C(M
M2E`_0C]'>5)#2D0P:U!Y4D)*15%K4FE224I%;VM3>5)-2D4P:U1I4E!*1DEK
M5E-264=Y:$,_/2`*(#T_25-/+3(P,C(M2E`_0C]'>5)#2D9S:UAI4F9*1T%K
M65-2:4I'46M*0U)M2D-G:V%"<V]19ST]/ST@"BTM+2T*4W5B:F5C=#H@86%A
M82!A86%A(&%A86$@86%A82!A86%A(&%A86$@86%A82`]/TE33RTR,#(R+4I0
M/T(_1WE20TI#26)+14D]/ST@"B`]/TE33RTR,#(R+4I0/T(_1WE20TI#46M*
J:5%O2D-O8DM%23T_/2`@86%A80H@86%A82!A86%A(&%A86$*+2TM+0H*
eofeof

print "test_data/mime_out    ";
    &test("$nkf -M",$example{'test_data/mime_out'},$example{'test_data/mime_out.ans'});
# test_data/multi-line

$example{'test_data/multi-line'} = unpack('u',<<'eofeof');
MI,JDK*2DI,JDK*2DI,JDK*'!I*2DKJ3GI*:DK*2BI.JDWJ2WI,:AH@"DLZ3L
MI/*DO:3.I-ZDWJ2BI,2DJZ2FI,BAHJ3)I*:DXJ3?I-"DJ*2LI.^DZZ2DI+>A
MHJ3(I,&DY:2FI,>DP:3GI/.DKJ3LI.NDJZ3BI+>D\Z3*I*2AHPJDLZ2SI,_#
8NZ2DN=2AHP`*I+.DLZ3/P[NDI+G4H:,*
eofeof

$example{'test_data/multi-line.ans'} = unpack('u',<<'eofeof');
MI,JDK*2DI,JDK*2DI,JDK*'!I*2DKJ3GI*:DK*2BI.JDWJ2WI,:AH@"DLZ3L
MI/*DO:3.I-ZDWJ2BI,2DJZ2FI,BAHJ3)I*:DXJ3?I-"DJ*2LI.^DZZ2DI+>A
MHJ3(I,&DY:2FI,>DP:3GI/.DKJ3LI.NDJZ3BI+>D\Z3*I*2AHPJDLZ2SI,_#
8NZ2DN=2AHP`*I+.DLZ3/P[NDI+G4H:,*
eofeof

print "test_data/multi-line    ";
    &test("$nkf -e",$example{'test_data/multi-line'},$example{'test_data/multi-line.ans'});
# test_data/nkf-19-bug-1

$example{'test_data/nkf-19-bug-1'} = unpack('u',<<'eofeof');
,I*:DJZ2D"KK8QJ,*
eofeof

$example{'test_data/nkf-19-bug-1.ans'} = unpack('u',<<'eofeof');
8&R1")"8D*R0D&RA""ALD0CI81B,;*$(*
eofeof

print "test_data/nkf-19-bug-1    ";
    &test("$nkf -Ej",$example{'test_data/nkf-19-bug-1'},$example{'test_data/nkf-19-bug-1.ans'});
# test_data/nkf-19-bug-2

$example{'test_data/nkf-19-bug-2'} = unpack('u',<<'eofeof');
%I-NDL@H`
eofeof

$example{'test_data/nkf-19-bug-2.ans'} = unpack('u',<<'eofeof');
%I-NDL@H`
eofeof

print "test_data/nkf-19-bug-2    ";
    &test("$nkf -Ee",$example{'test_data/nkf-19-bug-2'},$example{'test_data/nkf-19-bug-2.ans'});
# test_data/nkf-19-bug-3

$example{'test_data/nkf-19-bug-3'} = unpack('u',<<'eofeof');
8[;'Q\,&L"N6ZSN\*\NT)ON7.SL_+"0D*
eofeof

$example{'test_data/nkf-19-bug-3.ans'} = unpack('u',<<'eofeof');
8[;'Q\,&L"N6ZSN\*\NT)ON7.SL_+"0D*
eofeof

print "test_data/nkf-19-bug-3    ";
    &test("$nkf -e",$example{'test_data/nkf-19-bug-3'},$example{'test_data/nkf-19-bug-3.ans'});
# test_data/non-strict-mime

$example{'test_data/non-strict-mime'} = unpack('u',<<'eofeof');
M/3])4T\M,C`R,BU*4#]"/PIG<U-#;V]+.6=R-D-O;TQ%9W1Y0W0T1D-$46].
M0V\V16=S,D]N;T999S1Y1%=)3$IG=4-0:UD*2W!G<FU#>$E+:6=R,D-V;TMI
,9W-30V]O3&,*/ST*
eofeof

$example{'test_data/non-strict-mime.ans'} = unpack('u',<<'eofeof');
M&R1")$8D)"0_)$`D)"1&)%XD.2$C&RA"#0H-"ALD0CMD)$\[?B$Y)6PE.21+
<)&(]<20K)#LD1B0D)#\D0"0D)$8D)"1>&RA""@``
eofeof

print "test_data/non-strict-mime    ";
    &test("$nkf -mN",$example{'test_data/non-strict-mime'},$example{'test_data/non-strict-mime.ans'});
# test_data/q-encode-softrap

$example{'test_data/q-encode-softrap'} = unpack('u',<<'eofeof');
H/3%")$(T03MZ)3T*,R$\)4DD3CTQ0BA""CTQ0B1"2E$T.3TQ0BA""@``
eofeof

$example{'test_data/q-encode-softrap.ans'} = unpack('u',<<'eofeof');
>&R1"-$$[>B4S(3PE221.&RA""ALD0DI1-#D;*$(*
eofeof

print "test_data/q-encode-softrap    ";
    &test("$nkf -mQ",$example{'test_data/q-encode-softrap'},$example{'test_data/q-encode-softrap.ans'});
# test_data/rot13

$example{'test_data/rot13'} = unpack('u',<<'eofeof');
MI+.D\Z3+I,&DSZ&BS:W"]*3(I*2DI*3>I+FAHPH*;FMF('9E<BXQ+CDR(*3R
MS?C-T:2UI+NDQJ2DI+^DP*2DI,:DI*3>I+FDK*&B05-#24D@I,O"T*2WI,8@
M4D]4,3,@I*P*P+6DMZ2OQK"DI*3&I*2DRJ2DI.BDIJ3'H:*PRK*\I,ZDZ*2F
MI,O*T;2YI+6D[*3>I+ND\Z&C"@HE(&5C:&\@)VAO9V4G('P@;FMF("UR"FAO
#9V4*
eofeof

$example{'test_data/rot13.ans'} = unpack('u',<<'eofeof');
M&R1"4V)31%-Z4W!3?E!1?%QQ15-W4U-34U,O4VA04ALH0@H*87AS(&ER92XQ
M+CDR(!LD0E-#?$E\(E-D4VI3=5-34VY3;U-34W534U,O4VA36U!1&RA"3D90
M5E8@&R1"4WIQ(5-F4W4;*$(@14)',3,@&R1"4UL;*$(*&R1";V139E->=5]3
M4U-U4U-3>5-34SE355-V4%%?>6%K4WU3.5-54WIY(F-H4V13/5,O4VI31%!2
A&RA""@HE(')P=6(@)W5B='(G('P@87AS("UE"G5B='(*
eofeof

print "test_data/rot13    ";
    &test("$nkf -r",$example{'test_data/rot13'},$example{'test_data/rot13.ans'});
# test_data/slash

$example{'test_data/slash'} = unpack('u',<<'eofeof');
7("`]/U8\5"U5.5=%2RTK.U<U32LE+PH`
eofeof

$example{'test_data/slash.ans'} = unpack('u',<<'eofeof');
7("`]/U8\5"U5.5=%2RTK.U<U32LE+PH`
eofeof

print "test_data/slash    ";
    &test("$nkf  ",$example{'test_data/slash'},$example{'test_data/slash.ans'});
# test_data/z1space-0

$example{'test_data/z1space-0'} = unpack('u',<<'eofeof');
"H:$`
eofeof

$example{'test_data/z1space-0.ans'} = unpack('u',<<'eofeof');
"H:$`
eofeof

print "test_data/z1space-0    ";
    &test("$nkf -e -Z",$example{'test_data/z1space-0'},$example{'test_data/z1space-0.ans'});
# test_data/z1space-1

$example{'test_data/z1space-1'} = unpack('u',<<'eofeof');
"H:$`
eofeof

$example{'test_data/z1space-1.ans'} = unpack('u',<<'eofeof');
!(```
eofeof

print "test_data/z1space-1    ";
    &test("$nkf -e -Z1",$example{'test_data/z1space-1'},$example{'test_data/z1space-1.ans'});
# test_data/z1space-2

$example{'test_data/z1space-2'} = unpack('u',<<'eofeof');
"H:$`
eofeof

$example{'test_data/z1space-2.ans'} = unpack('u',<<'eofeof');
"("``
eofeof

print "test_data/z1space-2    ";
    &test("$nkf -e -Z2",$example{'test_data/z1space-2'},$example{'test_data/z1space-2.ans'});

# end