# TODO ensure that Compiler.class exists in current dir
# TODO support "-a" and -r" flags to specify "accept" and "reject" tests
testType=$1

# sed removes the extra frontslash in path
tests=$(find tests/$testType -type f -name "*.ul" | sed 's/\/\//\//')

# TODO print seprator between accept and reject tests
for pathToTest in $tests
do
    echo "* Running $pathToTest"

    # parse out name of file from its path
    testFileName=$(echo $pathToTest | egrep -o "[a-zA-Z_0-9]*\.ul")

    output=$(java Compiler $pathToTest)

    # when running the accept tests exclusively,
    # store the pretty print output and compare with previous output
    if [ -n "$testType" ] && [ "$testType" == "accept" ]
    then
        echo "$output" > "results/$testFileName.out"
        diff "results/$testFileName.out" "expected/$testFileName.out"
    fi
    printf "\n\n"
done

numTests="$(echo $tests | wc -w)"
printf "\n"
echo "Ran $numTests tests:"
