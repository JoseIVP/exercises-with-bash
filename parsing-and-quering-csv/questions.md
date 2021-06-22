# Using bash to get information from CSV files

The data used in this exercise was taken from
[Kaggle](https://www.kaggle.com/kaggle/us-baby-names). Inside
`NationalNames.csv.zip` comes a CSV file with data describing the number of
times a particular name was given to babies in a particular year in the US.


1. Unzip the NationalNames.csv file.

    ```
    unzip NationalNames.csv.zip
    ```

1. What are the columns in NationalNames.csv?

    ```bash
    head -3 NationalNames.csv
    ```
    ```
    Id,Name,Year,Gender,Count
    1,Mary,1880,F,7065
    2,Anna,1880,F,2604
    ```

1. How many entries are there in NationalNames.csv?

    ```bash
    tail -n +2 NationalNames.csv | wc -l
    ```
    ```
    1825433
    ```

1. What are the oldest and newest years for which there are records?

    ```bash
    tail -n +2 NationalNames.csv | {
    min=9999
    max=0
    while read line; do
        aux_IFS=$IFS
        IFS=,
        row=($line)
        IFS=$aux_IFS
        if((${row[2]}>max)); then
            max=${row[2]}
        fi
        if((${row[2]}<min)); then
            min=${row[2]}
        fi
    done
    echo "Oldest year: $min"
    echo "Newest year: $max"
    }
    ```
    ```
    Oldest year: 1880
    Newest year: 2014
    ```

    Other way of doing it:
    ```bash
    tail -n +2 NationalNames.csv |
    LC_ALL=C sort -n -t ',' -k '3,3' |
    tail -1 | {
        read line
        IFS=,
        row=($line)
        echo "Newest year: ${row[2]}"
    }
    tail -n +2 NationalNames.csv |
    LC_ALL=C sort -n -t ',' -k '3,3' |
    head -1 | {
        read line
        IFS=,
        row=($line)
        echo "Oldest year: ${row[2]}"
    }
    ```
    ```
    Newest year: 2014
    Oldest year: 1880
    ```

1. How many unique female names there are? How many unique male names? Are there
   any names that are for both male and female?

    ```bash
    (
        men=$(grep -E ',M,[[:digit:]]+$' NationalNames.csv |
            awk -F , '{print $2}'| sort | uniq | wc -l)
        women=$(grep -E ',F,[[:digit:]]+$' NationalNames.csv |
            awk -F , '{print $2}'| sort | uniq | wc -l)
        total=$(tail -n +2 NationalNames.csv |
            awk -F , '{print $2}' | sort | uniq | wc -l)
        echo "Number of male names: $men"
        echo "Number of female names: $women"
        echo "Number of unique names: $total"
        echo "Number of male and female names: $((men+women-total))"
    )
    ```
    ```
    Number of male names: 39199
    Number of female names: 64911
    Number of unique names: 93889
    Number of male and female names: 10221
    ```

    Other way of getting the number of male and female names:
    ```bash
    (
        echo 'Number of male and female names:'
        {
            grep ',M,' NationalNames.csv | awk -F , '{print $2}' |
                sort | uniq
            grep ',F,' NationalNames.csv | awk -F , '{print $2}' |
                sort | uniq
        } | sort | uniq -d | wc -l
    )
    ```
    ```
    Number of male and female names:
    10221
    ```

1. How many people were named Arie in 1893? How many over all the years?

    ```bash
    echo "Number of people named Arie in 1893: $(grep ',Arie,1893,' NationalNames.csv |
        awk -F ',' '{print $5}')"
    grep ',Arie,' NationalNames.csv | awk -F ','  '{print $5}' | {
        declare -i count=0
        while read number; do
        count+=number
        done
        echo  "Number of people named Arie over all the years: $count"
    }
    ```
    ```
    Number of people named Arie in 1893: 24
    Number of people named Arie over all the years: 4648
    ```

1. What was the most used name in 1917? Answer the question considering names
   that are used for both sexes as separate, and then consider them as being the
   same. Also, give the number of times the name was used.

    ```bash
    grep -E ',1917,(M|F),' NationalNames.csv | sort -t , -k 5 -n -r | head -1 |
        awk -F , '{print $2; print $5}' | {
            read name
            read count
            echo "The most used name in 1917 was $name with $count times"
        }
    ```
    ```
    The most used name in 1917 was Mary with 64280 times
    ```
    
    Now considering names used for both males and females:
    ```bash
    grep -E ',1917,(M|F),' NationalNames.csv | awk -F , '{print $2 " " $5}' | 
        sort -k 1,1 | {
            lastName=
            declare -i lastCount=0
            bestName=
            declare -i bestCount=0
            while read line; do
                arr=($line)
                if [ "$lastName" = "${arr[0]}" ]; then
                    lastCount+=${arr[1]}
                else
                    if ((lastCount>bestCount)); then
                        bestName=$lastName
                        bestCount=lastCount
                    fi
                    lastName=${arr[0]}
                    lastCount=${arr[1]}
                fi
            done
            if ((lastCount>bestCount)); then
                resultName=$lastName
                resultCount=$lastCount
            else
                resultName=$bestName
                resultCount=$bestCount
            fi
            echo "The most used name in 1917 was $resultName with $resultCount times"
        }
    ```
    ```
    The most used name in 1917 was Mary with 64439 times
    ```

1. What was the most used name in the 1980's?

    ```bash
    grep -E ',198[[:digit:]],[FM],' NationalNames.csv |
    awk -F , '{print $2 " " $5}' |
    sort -k 1,1 | {
        lastName=
        declare -i lastCount=0
        while read line; do
            arr=($line)
            name=${arr[0]}
            count=${arr[1]}
            if [ "$lastName" = "$name" ]; then
                lastCount+=count
            else
                echo $lastName $lastCount
                lastName=$name
                lastCount=count
            fi
        done
        echo $lastName $lastCount
    } |
    sort -k 2,2 -n |
    tail -1 | awk '{print "The most used name was " $1 " with " $2 " times"}'
    ```

    ```
    The most used name was Michael with 668724 times
    ```

1. What was the most used name across the whole range of years?

    ```bash
    tail -n +2 NationalNames.csv |
    awk -F , '{print $2 " " $5}' |
    sort -k 1,1 | {
        lastName=
        declare -i lastCount=0
        while read line; do
            arr=($line)
            name=${arr[0]}
            count=${arr[1]}
            if [ "$lastName" = "$name" ]; then
                lastCount+=count
            else
                echo $lastName $lastCount
                lastName=$name
                lastCount=count
            fi
        done
        echo $lastName $lastCount
    } |
    sort -k 2,2 -n |
    tail -1 | awk '{print "The most used name was " $1 " with " $2 " times"}'
    ```

    ```
    The most used name was James with 5129096 times
    ```