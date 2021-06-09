# Usage:
# ./filler.sh [name=value] ... template-file

declare -a expressions # Will store sed expressions
# Get each positional parameter, except for the last one (file name)
# and construct its corresponding sed expression
for(( i=1 ; i<$# ; i++ )); do
    assignment=${!i}
    aux_IFS=$IFS
    IFS='='
    parts=($assignment)
    IFS=$aux_IFS
    sed_expr="s/([^\])\{${parts[0]}\}/\1${parts[1]}/g"
    expressions+=(-e "$sed_expr") # add -e flag and the expression
done
# Execute the sed command, giving the file name as last parameter
sed -E "${expressions[@]}" "${!#}"
