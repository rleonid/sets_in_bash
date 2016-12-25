# http://www.catonmat.net/blog/set-operations-in-unix-shell/

# TODO:
# 1. how to (or if) deal with numerical values (environment variable)
#     by passing '-n' to sort where appropriate

set_mem_q() {
  grep -xq $1 $2
}

set_mem() {
  set_mem_q $1 $2 && echo true || echo false
}

set_equal_q() {
  diff -q <(sort -u $1) <(sort -u $2) >/dev/null
}

set_equal() {
  set_equal_q $1 $2 && echo true || echo false
}

set_size() {
  echo $(wc -l < $1 | tr -d [:space:])
}

set_subset_q() {
  [[ -z $(comm -23 <(sort -u $1) <(sort -u $2)) ]]
}

set_subset() {
  set_subset_q $1 $2 && echo true || echo false
}

set_union() {
  sort -u $1 $2 
}

set_inter() {
  comm -12 <(sort $1) <(sort $2)
  # grep -xF -f $1 $2           ... but if |$1| >>> |$2|?
  # sort set1 set2 | uniq -d    ... but discards cardinality of duplicates.
  # join <(sort $1) <(sort $2)  ... faster?
}

set_comp() {
  comm -23 <(sort $1) <(sort $2)
  # grep -vxF -f $2 $1           ... but if |$1| >>> |$2|?
}

set_sym_diff() {
  comm -3 <(sort $1) <(sort $2) | tr -d '\t'
}

set_cart_prod() {
  while read a; do while read b; do printf "$a\t$b\n"; done < $2; done < $1
}

set_min() {
  head -1 <(sort $1)
}

set_max() {
  tail -1 <(sort $1)
}

if [ -z "$TEST_SET" ] ; then
  return
fi

cat > Atest <<EO
1
2
3
EO

printf "set_mem\t\tshould be true\t%s\n" $(set_mem 1 Atest)
printf "set_mem\t\tshould be false\t%s\n" $(set_mem 5 Atest)

cat > Asub << EO
1
2
EO

printf "set_equal\tshould be true\t%s\n" $(set_equal Atest Atest)
printf "set_equal\tshould be false\t%s\n" $(set_equal Asub Atest)
printf "set_equal\tshould be false\t%s\n" $(set_equal Atest Asub)

printf "set_size\tshould be 3\t%s\n" $(set_size Atest)
printf "set_size\tshould be 2\t%s\n" $(set_size Asub)

printf "set_subset\tshould be true\t%s\n" $(set_subset Asub Atest)
printf "set_subset\tshould be false\t%s\n" $(set_subset Atest Asub)

printf "set_union\tshould be true\t%s\n" $(set_equal <(set_union Atest Asub) Atest)
printf "set_union\tshould be false\t%s\n" $(set_equal <(set_union Asub Asub) Atest)

printf "set_inter\tshould be true\t%s\n" $(set_equal <(set_inter Atest Asub) Asub)
printf "set_inter\tshould be false\t%s\n" $(set_equal <(set_inter Asub Asub) Atest)

rm Atest
rm Asub
