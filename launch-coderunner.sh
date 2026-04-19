# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# launch-coderunner.sh - Script to launch the Java main class with the VSCode
# Code Runner extension. The main class and classpath are stored in files.
# If files do not exist, it will search for the main class in 'src/main/java'
# and build the classpath using Maven.
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# file with main class, e.g. 'com.example.Main'
mcfile=".vscode/main-class"

# file with classpath, e.g. 'target/classes:lib/dependency1.jar:lib/dependency2.jar'
cpfile="target/classpath"

# file with command line arguments for the main class, e.g. '--option value'
argsfile=".vscode/args"


# create file '.vscode/main-class' with main class, e.g. 'com.example.Main'
# if a main()-method is found in 'src/main/java'
function find_mainclass() {
    echo "searching for main()-method in 'src/main/java'..."
    find src/main/java -name "*.java" \
        -exec grep -Hn 'static[[:space:]]*void[[:space:]]*main' {} \; |
            head -n 1 | cut -d: -f1 |
            sed 's/src\/main\/java\///;s/\.java$//;s/\//./g' > $mcfile &&
        [ -f "$mcfile" -a -s "$mcfile" ] &&
        echo "found main class: '$(cat $mcfile)', stored in file '$mcfile'" ||
        echo "Error: no main()-method found, file '$mcfile' is empty"
}

# create file with classpath in 'target/classpath' containing, e.g.
# 'target/classes:lib/dependency1.jar:lib/dependency2.jar'
function build_classpath() {
    # check for cygwin or msys (GitBash) and set classpath separator
    [ "$(uname | grep 'CYGWIN\|MINGW\|MSYS')" ] && local sep=";" || local sep=":"
    # 
    echo "building $cpfile..."
    local cp="target/classes${sep}$(mvn dependency:build-classpath | grep '\.jar')" &&
    echo $cp | tee $cpfile
}

# if file with main class does not exist or is empty, search for main() and create file
[ ! -f "$mcfile" -o ! -s "$mcfile" ] && find_mainclass

# if directory 'target/classes' does not exist, compile code with 'mvn compile'
[ ! -d "target/classes" ] &&
    echo "compiling code from 'src/main/java' to 'target/classes'..." &&
    mvn compile -q

# if file with classpath does not exist, build classpath and create file
[ ! -f "$cpfile" ] && build_classpath

# if file with classpath exists, launch with 'java'
[ -f "$cpfile" ] &&
    java -cp "$(cat $cpfile)" "$(cat $mcfile)" $([ -f "$argsfile" ] && cat $argsfile) ||
    echo "Error: no file '$cpfile'"
