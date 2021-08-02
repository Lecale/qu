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

# we can pass in the points score here
proc check2(moves: seq[string], board: seq[string], pointsScore: var int =0) : bool =
    #play the moves
    #check 2 up for match < up + down == 4  && leftt + right = 4
    #check .... DUPLICATE
    var thePoints: seq[seq[string]]  = @[]

    #there is a problem in calculating the points score
    #we don't want to re-add a move in the same line

    #therefore thePoints has to be a list of lists

    for m in moves:
        var colMatch:int = 0 #colour is 0*
        var shpMatch:int = 0 #shape is 1*
        var noDuplicates: seq[string] = @[]
        noDuplicates.add(m)
        var noDuplicates2: seq[string] = @[]
        noDuplicates2.add(m)
        let x: int = parseInt(m[2 .. 3])
        let y: int = parseInt(m[4 .. 5])
        let z = (11*y) + x
        var continueLocalSearch: bool = true
        # look to the right
        try:            
            for i in (x+1) .. 9:
                if continueLocalSearch:
                    if board[ (y*11) + i ] == "X":
                        continueLocalSearch = false
                    else:
                        if board[ (y*11) + i ][0] == board[z][0]:
                            inc colMatch
                        if board[ (y*11) + i ][1] == board[z][1]:
                            inc shpMatch
                        if noDuplicates.contains(board[z][0..1]):
                            noDuplicates.add(board[z][0..1])
                        else:
                            echo "violation c2 #1"
                            return false
        except: discard
        # look to the left
        continueLocalSearch = true
        try:
            for i in countdown((x-1),0):
                if continueLocalSearch:
                    if board[ (y*11) + i ] == "X":
                        continueLocalSearch = false
                    else:
                        if board[ (y*11) + i ][0] == board[z][0]:
                            inc colMatch
                        if board[ (y*11) + i ][1] == board[z][1]:
                            inc shpMatch
                        if noDuplicates.contains(board[z][0..1]):
                            noDuplicates.add(board[z][0..1])
                        else:
                            echo "violation c2 #2"
                            return false
        except: discard
        # now colour of shape must match the noDuplicates length
        if((noDuplicates.len==shpMatch) or (noDuplicates.len == colMatch)):
            noDuplicates.sort()
        else:
            echo "violation c2 #3"
            return false

        #look up
        try:            
            for i in (y+1) .. 9:
                if continueLocalSearch:
                    if board[ (i*11) + x ] == "X":
                        continueLocalSearch = false
                    else:
                        if board[ (i*11) + x ][0] == board[z][0]:
                            inc colMatch
                        if board[ (i*11) + x ][1] == board[z][1]:
                            inc shpMatch
                        if noDuplicates.contains(board[z][0..1]):
                            noDuplicates.add(board[z][0..1])
                        else:
                            echo "violation c2 #1"
                            return false
        except: discard
        #look down
        continueLocalSearch = true
        try:
            for i in countdown((y-1),0):
                if continueLocalSearch:
                    if board[ (i*11) + y ] == "X":
                        continueLocalSearch = false
                    else:
                        if board[ (i*11) + y ][0] == board[z][0]:
                            inc colMatch
                        if board[ (i*11) + y ][1] == board[z][1]:
                            inc shpMatch
                        if noDuplicates.contains(board[z][0..1]):
                            noDuplicates.add(board[z][0..1])
                        else:
                            echo "violation c2 #2"
                            return false
        except: discard
        # again 
        if((noDuplicates2.len==shpMatch) or (noDuplicates2.len == colMatch)):
            noDuplicates2.sort()
        else:
            echo "violation c2 #3"
            return false
        
        if thePoints.contains(noDuplicates) == false:
            thePoints.add(noDuplicates)
        if thePoints.contains(noDuplicates2) == false:
            thePoints.add(noDuplicates2)

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
