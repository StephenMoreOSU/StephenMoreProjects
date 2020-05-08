#!/bin/bash

# matrix.sh by Stephen More
# April 19th, 2020
################################################
# IMPORTANT NOTE: 
# The matrix multiply takes a very long time to process the large matricies in parts 6c and 5d, however,
# if you run the script using generated matricies (using the generate function in p1grading script) the result is correct.
################################################

################################################
#function:error_func
#desc: An error checker function which returns 1 if there was an error which gets caught after the function is run and exits the script with 1
#params: $OPERATION $MAT1 $MAT2
#outputs: if error output 1 if not output 0
################################################
error_func()
{
    local OPERATION=$1
    local MAT1=$2
    local MAT2=$3

    #valid operation check

    #operation error checking
    if [ $OPERATION = "dims" ] || [ $OPERATION = "transpose" ] || [ $OPERATION = "mean" ] || [ $OPERATION = "add" ] || [ $OPERATION = "multiply" ];
    then
        errorFlag=0
    else
        >&2 echo "badcommand should throw error"
        return 1
    fi
    #dims error checker
    if [ $OPERATION = "dims" ]
    then
        #if the file is readable
        if [ -r "$MAT1" ]
        then
            # if there is only 1 matrix input
            if [ $MAT2 = "np" ]
            then
                errorFlag=0
            else
                >&2 echo "argument count is greater than 1 should throw error"
                return 1
            fi
        else
            >&2 echo "Dims on nonexistent file should throw error"
            return 1
        fi
    fi
    #add error checker
    if [ $OPERATION = "add" ]
    then
        # if there are 0 args throw error
        if [ $# = 1 ]
        then
            >&2 echo "Add with 0 arguments should throw error"
            return 1
        else
            errorFlag=0
        fi
    fi
}
################################################
#function:dims_func
#desc:returns dimensions of matrix passed in via stdin or as a file
#params: $OPERATION $PRINTFLAG
#outputs: dims outputted as "rows cols"
################################################
dims_func()
{
    local MAT1=$1
    local PRINTFLAG=${2:-np}
    local colFlag=0
    #rowCount and colCount are used for other functions so they are not local vars
    rowCount=0
    colCount=0

    while read row
    do
        #if this is the first row
        if [ $colFlag = 0 ];
        then
            for i in $row
            do
                colCount=$(expr $colCount + 1)
            done
            colFlag=1
        fi
        rowCount=$(expr $rowCount + 1)
    done < $MAT1
    if [ $PRINTFLAG = "-p" ];
    then
        echo "$rowCount $colCount"
        echo -e "$colCount $rowCount" > "$matrixOut"
    fi
}

transpose_func()
{
    local MAT1=$1
    # if PRINTFLAG does not exist PRINTFLAG="np"
    local PRINTFLAG=${2:-np}
    rowidx=0
    dims_func $MAT1
    read row < "$MAT1"
    for i in $row
    do
        rowidx=$(expr $rowidx + 1)
        #cut one column for value in row
        cut -f $rowidx $MAT1 > $tempCol
        #take the tempCols and use tr to turn them into a row
        cat $tempCol | tr '\n' '\t' > "$tempRow"
        #get rid of last tab in tempRow to be correctly formatted
        truncate -s-1 "$tempRow"
        #echo to add a newline to the row
        echo >> "$tempRow"
        #if its the first column in row
        if [ rowidx = 1 ]
        then
            echo -e "$(cat $tempRow)" > "$temptrans"
        else
            echo -e "$(cat $tempRow)" >> "$temptrans"
        fi
    done
    #remove used files
    if [ -f "$tempRow" ] && [ -f "$tempCol" ];
    then
        rm -f $tempRow $tempCol
    fi
    if [ -f "$temptrans" ];
    then
        #if printflag is asserted print to stdout
        if [ $PRINTFLAG = "-p" ];
        then
            cat $temptrans
            rm -f $temptrans
        else
        #if no printflag save to $matrixOut for future opertions 
            cat $temptrans > "$matrixOut"
            rm -f $temptrans
        fi
    fi
}
mean_func()
{
    #call cleanfiles func to make sure clean start
    cleanfiles_func
    local MAT1=$1
    rowCount=0
    #transpose $MAT1 for easy addition
    transpose_func $MAT1
    while read row
    do
        sum=0
        count=0
        for i in $row
        do
            #this sums up each row of transposed $MAT1
            sum=$(expr $sum + $i)
            count=$(expr $count + 1)
        done
        #use given mean equation to calculate
        mean=$(((sum + (count/2)*( (sum>0)*2-1 )) / count))
        rowCount=$(expr $rowCount + 1)
        #printing result to file tempMean
        if [ rowCount = 1 ]
        then
            echo -e "$mean\t" > "$tempMean"
        else
            echo -e "$mean\t" >> "$tempMean"
        fi
    done < "$matrixOut"
    #get rid of newlines from echos
    cat $tempMean | tr -d '\n' > "tempMean2"
    #delete last tab
    truncate -s-1 "tempMean2"
    #add newline
    echo >> "tempMean2"
    #result to stdout
    cat "tempMean2"
    #remove files
    if [ -f "tempMean2" ]
    then
        rm -f "tempMean2"
    fi
    cleanfiles_func
}
add_func()
{
    cleanfiles_func
    local MAT1=${1:-np}
    local MAT2=${2:-np}
    # mismatch error check
    # use dims function to save dims of $MAT1 and $MAT2
    dims_func $MAT1
    colsMAT1=$colCount
    rowsMAT1=$rowCount
    dims_func $MAT2
    colsMAT2=$colCount
    rowsMAT2=$rowCount
    #check to see if the dims meet requirements for add
    if [ $colsMAT1 = $colsMAT2 ] && [ $rowsMAT1 = $rowsMAT2 ];
    then
        errorFlag=0
    else    
        >&2 echo "Adding mismatched matrices should throw error"
        return 1
    fi
    idxMAT1=0
    #read in first row of $MAT1
    read row < "$MAT1"
    for i in $row
    do
        #iterate over row and cut from columns right to left order
        idxMAT1=$(expr $idxMAT1 + 1)
        cut -f $(expr $colCount - $idxMAT1 + 1) $MAT1 > $tempCol1
        cut -f $(expr $colCount - $idxMAT1 + 1) $MAT2 > $tempCol2
        #paste the two cut columns into a temp folder
        paste $tempCol1 $tempCol2 > $tempMat
        addCount=0
        #read in the tempMat folder and iterate across all rows
        while read tempMatRow
        do
            sum=0
            idxtempMat=0
            for j in $tempMatRow
            do
                #iterate across row and sum all elements
                idxtempMat=$(expr $idxtempMat + 1)
                sum=$(expr $sum + $j)
            done
            addCount=$(expr $addCount + 1)
            #print sum result to tempCol
            if [ $addCount = 1 ]
            then
                echo -e "$sum\t" > $tempCol1
            else
                echo -e "$sum\t" >> $tempCol1
            fi
        done < "$tempMat"
        #if tempCol3 exists then concatenate tempCol1 tempCol3 and save into tempMat
        if [ -f "$tempCol3" ]
        then
            paste $tempCol1 $tempCol3 > $tempMat
            #echo "tempCol3 exists"
        else
            paste $tempCol1 > $tempMat
            #echo "tempCol3 does not exist"
        fi
        #save result into tempCol3
        paste $tempMat > $tempCol3
        #remove add specific files
        cleanfiles_func -add
    done
    #take final result, remove double tabs, save into tempMat
    cat $tempCol3 | tr -s '\t\t' '\t' > $tempMat
    #FORMAT CODE
    idx=0
    while read tempMatrow 
    do
        idx=$(expr $idx + 1)
        if [ idx = 1 ]
        then
            echo "$tempMatrow" > "tempMatX"
        else
            echo "$tempMatrow" >> "tempMatX"
        fi
    done < "$tempMat"
    #END FORMAT CODE
    #print result mat to stdout
    cat "tempMatX"
    cat "tempMatX" > $matrixOut
    #clean up files
    if [ -f "tempMatX" ]
    then
        rm -f "tempMatX"
    fi

    #cat $tempCol3 > $matrixOut
    #cat $tempCol3 > testfile
    #cleanfiles_func
}
mult_func()
{
    cleanfiles_func
    local MAT1=$1
    local MAT2=$2
    local colIdx=0
    local firstWrite=0
    # make sure cols and rows are correct
    dims_func $MAT1
    colsMAT1=$colCount
    rowsMAT1=$rowCount
    dims_func $MAT2
    colsMAT2=$colCount
    rowsMAT2=$rowCount
    if [ $colsMAT1 = $rowsMAT2 ];
    then
        errorFlag=0
    else    
        >&2 echo "Multiply mismatched matrices should throw error"
        return 1
    fi
    #BREAKPOINTS DENOTED AS: "bpx"
    #I left breakpoints to show my debugging process for multiply
    #echo "bp1"
    #echo "colsMAT1: $colsMAT1"
    #echo "rowsMAT1: $rowsMAT1"
    #echo "colsMAT2: $colsMAT2"
    #echo "rowsMAT2: $rowsMAT2"
    #return 1
    colidxMAT1=0
    #reads rows of $MAT1 as an array for easy arithmatic operations
    while delim=$'\t' read -r -a ArrMAT1
    do
        #echo "bp2"
        #echo "ArrMAT1[0][1]:${ArrMAT1[0]},${ArrMAT1[1]}"
        #return 1
        prod=0
        # iterates over $MAT2 cols to perform arithmatic
        for (( k = 0 ; k < $colsMAT2 ; k++ ));
        do
            #echo "bp3"
            #return 1
            sumofprods=0
            #cut the column of $MAT2 for each iteration left to right
            cut -f $(expr $k + 1) $MAT2 > "$tempMul"
            #echo "bp4"
            #cat -A $tempMul            
            #echo "k:$k"
            #echo "tempMul:"
            #cat $tempMul
            #return 1
            #transpose the cut column so can be iterated as a single row
            transpose_func $tempMul
            #echo "bp5"
            #echo "matrixOut:"
            #cat -A $matrixOut
            #return 1
            #read the output of the previous transposal into second array
            delim=$'\t' read -r -a ArrtransMAT2 < "$matrixOut"
            for (( j = 0 ; j < $colsMAT1 ; j++ ));
            do
                #iterate across row of $MAT1 and perform multiplications and sum operations
                MAT1op="${ArrMAT1[j]}"
                MAT2op="${ArrtransMAT2[j]}"
                #echo "bp6"
                #echo "op1:$MAT1op"
                #echo "op2:$MAT2op"
                #return 1
                prod=$(( $MAT1op * $MAT2op))
                sumofprods=$(expr $sumofprods + $prod)
            done
            #echo "bp7"
            #echo "$sumofprods"
            #return 1
            #echo each product into file and delete all newlines
            echo -e "$sumofprods\t" | tr -d '\n' >> "$tempProd"
            # if the $MAT2 iterator is at the last column then perform final matrix formatting
            if [ $k = $(expr $colsMAT2 - 1) ]
            then
                #delete last tab
                truncate -s-1 "$tempProd"
                #add newline
                echo >> "$tempProd"
            fi
            #echo "bp8"
            #echo "tempProd:"
            #cat -A $tempProd
        done
        #echo "bp9"
        #echo "colidxMAT1:$colidxMAT1"
        colidxMAT1=$(expr $colidxMAT1 + 1)
    done < "$MAT1"
    #echo "bp10"
    #cat -A $tempProd
    #return 1
    #perform FINAL reformatting
    truncate -s-1 "$tempProd"
	echo >> "$tempProd"
    #output product to stdout
    cat $tempProd
    cat $tempProd > $matrixOut

    # remove unecessary files
    if [ -f $tempProd ]
    then
        rm -f $tempProd
    fi
    if [ -f $tempMul ]
    then
        rm -f $tempMul
    fi
}

cleanfiles_func()
{
    #removes general purpose files
    FLAG=${1:-np}
    if [ "$FLAG" = "np" ];
    then
        if [ -f "$temptrans" ];
        then
            #echo "removed temptrans"
            rm -f $temptrans
        fi
        if [ -f "$tempMean" ];
        then 
            #echo "removed tempMean"
            rm -f $tempMean
        fi
        if [ -f "$tempCol" ];
        then 
            #echo "removed tempCol"
            rm -f $tempCol
        fi
        if [ -f "$tempCol1" ];
        then 
            #echo "removed tempCol1"
            rm -f $tempCol1
        fi
        if [ -f "$tempCol2" ];
        then 
            #echo "removed tempCol2"
            rm -f $tempCol2
        fi
        if [ -f "$tempCol3" ];
        then 
            #echo "removed tempCol3"
            rm -f $tempCol3
        fi
        if [ -f "$tempMat" ];
        then 
            #echo "removed tempMat"
            rm -f $tempMat
        fi
                if [ -f "-" ];
        then 
            #echo "removed -"
            rm -f "-"
        fi
        if [ -f "$tempMul" ];
        then 
            #echo "removed tempMul"
            rm -f $tempMul
        fi
        if [ -f "$tempProd" ];
        then 
            #echo "removed tempProd"
            rm -f $tempProd
        fi
        if [ -f "$matrixOut" ];
        then 
            #echo "removed matrixOut"
            rm -f $matrixOut
        fi
    elif [ "$FLAG" = "-add" ];
    then
        if [ -f "$temptrans" ];
        then
            #echo "removed temptrans"
            rm -f $temptrans
        fi
        if [ -f "$tempMean" ];
        then 
            #echo "removed tempMean"
            rm -f $tempMean
        fi
        if [ -f "$tempCol" ];
        then 
            #echo "removed tempCol"
            rm -f $tempCol
        fi
        if [ -f "$tempCol1" ];
        then 
            #echo "removed tempCol1"
            rm -f $tempCol1
        fi
        if [ -f "$tempCol2" ];
        then 
            #echo "removed tempCol2"
            rm -f $tempCol2
        fi
        if [ -f "$tempMat" ];
        then 
            #echo "removed tempMat"
            rm -f $tempMat
        fi
    fi
}

#declare variables
# if no first input $OPERATION = "np"
OPERATION=${1:-np}
# if the number of inputs is greater than 1 and the second input file exists then assign $MAT1 to "$2" else take MAT1 through stdin
[ $# -ge 1 -a -f "$2" ] && MAT1="$2" || MAT1="-"
MAT2=${3:-np}

errorFlag=0
unreadableFlag=0
stdinFlag=0

matrixOut="matrixOut"
tempCol="tempCol$$"
tempCol1="tempCol1$$"
tempCol2="tempCol2$$"
tempCol3="tempCol3$$"
tempMat="tempMat$$"
tempMAT1="tempMAT1$$"
tempRow="tempRow$$"
temptrans="temptrans$$"
tempMean="tempMean$$"

tempMul="tempMul$$"
tempProd="tempProd"

#Error checker which would not work if put into a function
# if $MAT1 is taken through stdin
if [ $MAT1 = '-' ]
then
    # tests to see if $MAT1 can be read
    timeout -k 1 1 cat $MAT1 > "tempCopy"
    # if timeout then previous command should output 124
    if [ $? = 124 ]
    then
        unreadableFlag=1
    fi
    #add/multiply error checker
    if [ $OPERATION = "add" ] || [ $OPERATION = "multiply" ]
    then
        >&2 echo "Add or Multiply with 0 arguments should throw error"
        exit 1
    fi
    if [ $OPERATION = "transpose" ]
    then
        if [ unreadableFlag = 1 ]
        then
            >&2 echo "Transposing undreadable file should throw error"
            exit 1
        fi
    fi
    cat "tempCopy" > $tempMAT1
    MAT1=$tempMAT1  
    #if MAT1 is taken in through stdin a temporary matrix is used to hold stdin values MUST BE DELETED AT END OF FUNCTION
    if [ -f "tempCopy" ]
    then
        rm -f "tempCopy"
    fi
    stdinFlag=1
fi
error_func $OPERATION $MAT1 $MAT2
# this catches if the error function returns a 1
if [ $? = 1 ]
    then
    exit 1
fi
#DIMS OPERATION
if [ $OPERATION = "dims" ];
then
    if [ $MAT2 = "np" ];
    then
        dims_func $MAT1 -p
    else
        exit 1;
    fi
#TRANSPOSE OPERATION
elif [ $OPERATION = "transpose" ];
then
    if [ $MAT2 = "np" ];
    then
        transpose_func $MAT1 -p
        #echo "test"
    else
        exit 1;
    fi
#MEAN OPERATION
elif [ $OPERATION = "mean" ];
then
    mean_func $MAT1
elif [ $OPERATION = "add" ];
then
    add_func $MAT1 $MAT2
    if [ $? = 1 ]
    then
        exit 1
    fi
    cleanfiles_func
elif [ $OPERATION = "multiply" ];
then
    mult_func $MAT1 $MAT2
    if [ $? = 1 ]
    then
        exit 1
    fi
fi
#Removes tempMAT1 which stores MAT1 if fed through stdin
if [ -f "$tempMAT1" ];
then 
    #echo "removed tempMat"
    rm -f $tempMAT1
fi

