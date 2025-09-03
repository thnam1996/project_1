#!/bin/bas

# Q1:Sắp xếp các bộ phim theo ngày phát hành giảm dần rồi lưu ra một file mới
#remove newline in ""
gawk -v RS='"' -v ORS='' '
NR % 2 == 0 { gsub(/\r?\n/, " ") }
{ printf "%s", $0; if (RT) printf "%s", RT }
' movies.csv > movies_nolf.csv

#sorting by release_date
{
head -n 1 movies.csv
tail -n +2 movies.csv \
| awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' 'BEGIN{OFS=","} {
split($16, d, "/");          
y = $19 + 0;                 
printf "%04d-%02d-%02d,%s\n", y, d[1]+0, d[2]+0, $0
}' \
| sort -t',' -k1,1r

| cut -d',' -f2-  

} > movies_sorted.csv

#Q2: Lọc ra các bộ phim có đánh giá trung bình trên 7.5 rồi lưu ra một file mới

{
head -n 1 movies_nolf.csv
tail -n +2 movies_nolf.csv \
| awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '($18+0) > 7.5' \
| sort -t',' -k18,18r
} > movies_rating_7.5.csv

#Q3:  Tìm ra phim nào có doanh thu cao nhất và doanh thu thấp nhất

#min revenue

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 && $5+0==0 { print "movie:", $6, ", revenue:", $5 }
' movies_nolf.csv

#max revenue

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 { print $5, $6 }
' movies_nolf.csv \
| sort -k1,1nr \
| head -n 1 \
| awk '{print "highest revenue film:", $2, ", revenue", $1}

#Q4: Tính tổng doanh thu tất cả các bộ phim

awk -vFPAT='\"([^\"]|\"\")\"|[^,]' 'NR>1 { x+=$5 } END{ print "Total", x }' movies_nolf.csv

#Q5: Top 10 bộ phim đem về lợi nhuận cao nhất

 awk -vFPAT='\"([^\"]|\"\")\"|[^,]' '
NR>1 {
profit = $5 - $4
printf "%015d,%s,%d,%d\n", profit, $6, $4, $5
}
' movies_nolf.csv \
| sort -t',' -k1,1nr \
| head -n 10 \
| awk -F',' '{printf "Movie: %s | Profit: %d |\n", $2, $1, $3, $4}'
