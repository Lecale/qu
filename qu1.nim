import terminal
import strutils, sequtils
import random
import algorithm

# this doesn't work very well visually
proc qwrite(instruction:string) =
    #ABXXYY
    #A : Colour
    #B : Number
    #XX : Coords
    let x: int = parseInt(instruction[2 .. 3])
    let y: int = parseInt(instruction[4 .. 5])
   
    setCursorPos(x,y)
    if instruction[0] == 'A' :
        stdout.styledWrite(fgRed, $instruction[1])
    if instruction[0] == 'B' :
        stdout.styledWrite(fgCyan, $instruction[1])
    if instruction[0] == 'C' :
        stdout.styledWrite(fgGreen, $instruction[1])
    if instruction[0] == 'D' :
        stdout.styledWrite(fgYellow, $instruction[1])
    if instruction[0] == 'E' :
        stdout.styledWrite(fgMagenta, $instruction[1])

proc piosh( bag: var seq[string],tuiles: int) : seq[string] =
    if tuiles > bag.len:
        echo "The bag is going to be emptied !"
    var myTiles: seq[string] = @[]
    for i in 1 .. tuiles:
        let r: int = rand(bag.len - 1)
        #echo "removing #" , $r
        myTiles.add(bag[r])
        bag.delete(r,r)
    return myTiles

# Test if the moves straddle multiple X Y planes
# check (test board) if there is a gap in the stones

proc lgPlane(moves: seq[string], board: var seq[string]) : bool =
    # in
    # notin
    var xMv: seq[int] = @[]
    var yMv: seq[int] = @[]
    for m in moves:
        let x: int = parseInt(m[2 .. 3])
        let y: int = parseInt(m[4 .. 5])
        if x notin xMv:
            xMv.add(x)
        if y notin yMv:
            yMv.add(y)
        if xMv.len > 1:
            if yMv.len > 1:
                echo "violation 1"
                return false

    # from max to min there must be tiles inbetween :: need test board
    if xMv.len > 1:
        xMv.sort()
        if xMv[1] - xMv[0] != 1:
            for mv in xMv[0] .. xMv[1]:
                echo "we can check it"
                # if board contains blank we return false
                # to move left we
                try:
                    if board[ (yMv[0]*11) + mv ] == "X":
                        echo "violation 2"
                        return false
                except: discard

    if yMv.len > 1:
        yMv.sort()
        if yMv[1] - yMv[0] != 1:
            for mv in yMv[0] .. yMv[1]:
                echo "we can check it"
                # if board contains blank we return false
                try:
                    if board[ (mv*11) + xMv[0] ] == "X":
                        echo "violation 3"
                        return false
                except: discard

    return true

# oops! this doesn't check for a duplicate in the row
proc check2(moves: seq[string], board: seq[string]) : bool =
    #play the moves
    #check 2 up for match < up + down == 4  && leftt + right = 4
    #check ....
    for m in moves:
        var colMatch:int = 0 #colour is 0*
        var shpMatch:int = 0 #shape is 1*
        let x: int = parseInt(m[2 .. 3])
        let y: int = parseInt(m[4 .. 5])
        let z = (11*y) + x
        try:
            if board[z+1]
        except: discard
    return true

proc joc(moves: seq[string], board: var seq[string], pScore: var int) : bool =
    echo "joc()"
    # Are moves either all in 1 row, or all in 1 col
    # For each move
        # Check 2 spaces up,down,left,right
    # Then caclculate the score
    return true


eraseScreen()
randomize()

qwrite("CC0506")

let ABCDE:string = "ABCDE"
var aScore:int = 0
var bScore:int = 0
var theBag: seq[string] = @[]
var theBoard: seq[string] = @[]
var aHand: seq[string] = @[]
var bHand: seq[string] = @[]
# concat exists for seq

for k in 0 .. 3:
    for i in 0 .. 4:
        for j in 0 .. 4:
            theBag.add($ABCDE[i] & $ABCDE[j] )
for i in 1 .. 121:
    theBoard.add("X")

aHand = piosh(theBag, 5)
bHand = piosh(theBag, 5)
echo "Player A" , aHand
echo "Player B" , bHand
echo "Tiles remaining " , $theBag.len
