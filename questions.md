# Using bash to get information from CSV files 

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
    1825433
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

1. How many unique female names there are? How many unique male names?

1. How many people were named Arie in 1893? How many over all the years?

1. Are there any names that have male and female genders at the same time?
