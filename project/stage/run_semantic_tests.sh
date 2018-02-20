# TODO ensure that Compiler.class exists in current dir
# TODO support "-a" and -r" flags to specify "accept" and "reject" tests
testType=$1

# sed removes the extra frontslash in path
tests=$(find semantic_tests/$testType -type f -name "*.ul" | sed 's/\/\//\//')

# TODO print seprator between accept and reject tests
for pathToTest in $tests
do
    echo "* Running $pathToTest"

    output=$(java Compiler $pathToTest)
    echo "$output"
    printf "\n\n"
done

numTests="$(echo $tests | wc -w)"
printf "\n"
echo "Ran $numTests tests:"
