#!/bin/bash
include=`dirname $0`
source $include/../conf/config

## Input: 
## Output $data/sub_min.order.csv
function cutSample(){

data=$DATA/final/
	cat $DATA/rec_log_test.txt | awk '$4> 1321891200{print}' > $data/rec_log_test.txt
	cat $data/rec_log_test.txt | awk '{print $1}' | sort -n | uniq > $data/rec_log_test.userid		
data=$DATA/leaderboard/
	cat $DATA/rec_log_test.txt | awk '$4<=1321891200{print}' > $data/rec_log_test.txt
	cat $data/rec_log_test.txt | awk '{print $1}' | sort -n | uniq > $data/rec_log_test.userid	
	leaderboard=`cat $data/rec_log_test.userid | wc -l`
	cat $DATA/sub_min.csv | awk -v l=$leaderboard  'NR<=l{print}' > $data/sub_min.csv
	awk 'BEGIN{i=1;j=1}ARGIND==1{id[i]=$1;i++}ARGIND==2{print id[j],$0;j++}' $data/rec_log_test.userid $data/sub_min.csv > $data/sub_min.order.csv
data=$DATA/final/ 
	cat $DATA/sub_min.csv | awk -v l=$leaderboard  'NR>l{print}' > $data/sub_min.csv
	awk 'BEGIN{i=1;j=1}ARGIND==1{id[i]=$1;i++}ARGIND==2{print id[j],$0;j++}' $data/rec_log_test.userid $data/sub_min.csv > $data/sub_min.order.csv

}


function statPopularity(){
	cat $TRAIN \
	| sort -nk2,2 | awk 'BEGIN{tot=0; id=-1;cnt=0;ok=0;}{
		if(id!=$2){
			if(cnt!=0) print id,cnt,ok
			id=$2; cnt=0; ok=0;
		}
		if($3==1) ok++;
		cnt++;
		tot++;
		if(tot%1000000==0){ print strftime("[%y-%m-%d %H:%M:%S]"),tot,"records loaded" > "/dev/stderr" }
	}END{if(cnt!=0) print id,cnt,ok}'  > $TRAIN.pop
	cat $TRAIN.pop | awk '{print $0,$3/$2}' | sort -nrk4,4 > $TRAIN.pop.ratio
}
## Input: $1=>data set
## Output sub.me
function culByPopularity(){
data=$DATA/$1
	#sort test file by user
	cat $data/rec_log_test.txt | sort -nk1,1 > $data/rec_log_test.txt.sorted
	#pick cul according to popularity
	awk 'BEGIN{
			r=0;
			now=-1;
			tot=0;
		}ARGIND==1&&$2>10{
			rank[$1]=r; r++;  
		}ARGIND==2{
			if($2 in rank){
				$3=rank[$1];
				print $0;
			}
			tot++; if(tot%1000000==0){ print strftime("[%y-%m-%d %H:%M:%S]"),tot,"records loaded" > "/dev/stderr" }
	}' $DATA/rec_log_train.txt.pop.ratio $data/rec_log_test.txt.sorted \
	| sort -n -k1,1 -k3,3 -r \
	| awk 'BEGIN{
		now=-1;
		cnt=0;
		}{
		if($1!=now){
			if(now!=-1) printf("\n");
				printf("%d ",$1);
				cnt=0;
				now=$1;
			}		
			if(cnt<3){
				printf("%s ",$2)
			}
			cnt++;	
		}' > $data/sub.poplarity
	awk 'ARGIND==1{
		id=$1; $1="";
		ans[id]=substr($0,2);
		}ARGIND==2{
			if(!($1 in ans)){
				id=$1; $1="";
        		ans[id]=substr($0,2);
			}
		}{
			tot++; if(tot%100000==0){ print strftime("[%y-%m-%d %H:%M:%S]"),tot,"records loaded" > "/dev/stderr" }
		}END{
			for(id in ans){
				print id,ans[id]
			}
	}' $data/sub.poplarity $data/sub_min.order.csv \
	| sort -nk1,1 | awk '{id=$1;$1="";printf("%d,%s\n",id,substr($0,2));}' > $data/sub.me
						
}


cutSample
culByPopularity leaderboard
culByPopularity final
echo "id,clicks" > $DATA/sub.me
cat $DATA/leaderboard/sub.me $DATA/final/sub.me >> $DATA/sub.me














