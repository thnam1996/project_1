#!/bin/bash
# Project1 – Movies Data Analyze

# Download Data Set
curl -o movies.csv https://raw.githubusercontent.com/yinghaoz1/tmdb-movie-dataset-analysis/master/tmdb-movies.csv

echo "Q1:Sắp xếp các bộ phim theo ngày phát hành giảm dần rồi lưu ra một file mới"
# remove newline in  quotes

gawk -v RS='"' -v ORS='' '
NR % 2 == 0 { gsub(/\r?\n/, " ") }
{ printf "%s", $0; if (RT) printf "%s", RT }
' movies.csv > movies_nolf.csv

#sorting by release_date

{
head -n 1 movies.csv
tail -n +2 movies.csv \
| awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' 'BEGIN{OFS=","}{
split($16,d,"/"); y=$19+0
printf "%04d-%02d-%02d,%s\n", y, d[1]+0, d[2]+0, $0
}' \
| sort -t',' -k1,1r \
| cut -d',' -f2-
} > movies_sorted.csv

echo "Done created movie_sorted.csv" 

echo "Q2: Lọc ra các bộ phim có đánh giá trung bình trên 7.5 rồi lưu ra một file mới"

{
head -n 1 movies_nolf.csv
tail -n +2 movies_nolf.csv \
| awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '($18+0) > 7.5' \
| sort -t',' -k18,18r
} > movies_rating_7.5.csv

echo "Done created movies_rating_7.5.csv"

echo "Q3. Tìm ra phim nào có doanh thu cao nhất và doanh thu thấp nhất"

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 && $5+0==0 { print "lowest revenue movie:", $6, ", revenue:", $5 }
' movies_nolf.csv

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 { print $5, $6 }
' movies_nolf.csv \
| sort -k1,1nr \
| head -n 1 \
| awk '{print "highest revenue film:", $2, ", revenue", $1}'

echo "Q4: Tính tổng doanh thu tất cả các bộ phim"

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 { x+=$5 } END{ print "Total revenue", x }
' movies_nolf.csv

echo "Q5: Top 10 bộ phim đem về lợi nhuận cao nhất"

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 {
profit = $5 - $4
printf "%015d,%s,%d,%d\n", profit, $6, $4, $5
}
' movies_nolf.csv \
| sort -t',' -k1,1nr \
| head -n 10 \
| awk -F',' '{printf "Movie: %s | Profit: %d |\n", $2, $1, $3, $4}'


echo "Q6: Đạo diễn nào có nhiều bộ phim nhất và diễn viên nào đóng nhiều phim nhất"

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 && $9!="" { count[$9]++ }
END { for (d in count) printf "%s,%d\n", d, count[d] }
' movies_nolf.csv \
| sort -t',' -k2,2nr \
| head -n 1 \
| awk -F',' '{printf "Director with the most movies: %s with %d movies\n", $1, $2}'

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 && $7 != "" {
  n = split($7, actors, "|")
  for (i=1; i<=n; i++) {
    count[actors[i]]++
  }
}
END {
  for (actor in count) {
    printf "%s,%d\n", actor, count[actor]
  }
}
' movies_nolf.csv \
| sort -t',' -k2,2nr \
| head -n 1 \
| awk -F',' '{printf "Actor  with the most movies: %s with %d movies\n", $1, $2}'

echo "Q7: Thống kê số lượng phim theo các thể loại"

awk -vFPAT='\"([^\"]|\"\")*\"|[^,]*' '
NR>1 && $14 != "" {
  n = split($14, actors, "|")
  for (i=1; i<=n; i++) {
    count[actors[i]]++
  }
}
END {
  for (actor in count) {
    printf "%s,%d\n", actor, count[actor]
  }
}
' movies_nolf.csv \
| sort -t',' -k2,2nr \
| awk -F',' '{printf "Genre %s: %d movies\n", $1, $2}'

