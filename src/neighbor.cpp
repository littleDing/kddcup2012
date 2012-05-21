#include <iostream>
#include <fstream>
#include <vector>
#include <map>
#include "STLExtends.hpp"
#include "Vector.h"
#include <algorithm>
using namespace std;
struct RelationShip {
    bool followed;
    short at;
    short retweet;
    short comment;
};
ostream& operator << (ostream& out,const RelationShip& r){
    
    return out;
}

struct User{
	map<int,RelationShip> sns;
	Vector scores;
};
ostream& operator << (ostream& out,const User u){
	//out<<"{";
	//out<<"sns=";
	out<<u.sns<<" ";
	//out<<"scores="
	out<<u.scores;
	//out<<"}";
	return out;
}

void logRecordLoaded(int& cnt){
    cnt++;
    if(cnt%1000000==0){
        LOG()<<cnt<<" record loaded"<<endl;
    }
}

class Solver {
    vector<int> userReced;
    vector<User> users;
    vector<int> ids;
    int tranID(const int& origin){
        return lower_bound(ids.begin(),ids.end(),origin)-ids.begin();
    }
    void BFSOnce(){
        for(int i=0;i<users.size();i++){
            User& u=users[i];
            for(map<int,RelationShip>::iterator it=u.sns.begin();it!=u.sns.end();++it){
                u.scores+=users[it->first].scores;
            }
        }
    }
public:
    void BFS(){
        for(int i=0;i<userReced.size();i++){
            int u=userReced[i];
            users[u].scores[u]=1;
        }
        for(int i=0;i<3;i++){
            BFSOnce();
        }
    }
    void loadIDs(const string& file="../data/track1/user_id.txt"){
		LOG()<<__FUNCTION__<<" begins"<<endl;
        int cnt=0,id,n=2000000;
		ifstream fin;	fin.open(file.c_str());
        //fin>>n;
        ids.resize(n);
		while(fin>>id){
			ids.push_back(id);
            logRecordLoaded(cnt);
        }
        users.resize(ids.size());
		LOG()<<__FUNCTION__<<" ends"<<endl;
    }
    void loadSNS(const string& file="../data/track1/user_sns.txt"){
		LOG()<<__FUNCTION__<<" begins"<<endl;
        int cnt=0;
		ifstream fin;	fin.open(file.c_str());
		int a,b;
		while(fin>>a>>b){
            a=tranID(a); b=tranID(b);
			users[a].sns[b].followed=true;
            cnt++;
            logRecordLoaded(cnt);
        }
		LOG()<<__FUNCTION__<<" ends"<<endl;
	}
    void loadAction(const string& file="../data/track1/user_action.txt"){
		LOG()<<__FUNCTION__<<" begins"<<endl;
		ifstream fin;	fin.open(file.c_str());
		int a,b,cnt=0;
		while(fin>>a>>b){
            a=tranID(a); b=tranID(b);
            fin>>users[a].sns[b].at;
            fin>>users[a].sns[b].retweet;
            fin>>users[a].sns[b].comment;
            logRecordLoaded(cnt);
		}
		LOG()<<__FUNCTION__<<" ends"<<endl;
	}
	void loadRecomemdedUsers(const string& file="../data/track1/final/users.reced"){
        LOG()<<__FUNCTION__<<" begins"<<endl;
		ifstream fin;	fin.open(file.c_str());
        int a;
		while(fin>>a){
            a=tranID(a);
            userReced.push_back(a);
		}
		LOG()<<__FUNCTION__<<" ends"<<endl;
    }
    void loadAll(const string basic="../data/track1/leaderboard/"){
        loadIDs();
        loadSNS(basic+"/user_sns.txt");
        loadRecomemdedUsers(basic+"/users.reced");
        //loadAction();
    }
}solver;


int main(int argc,char **argv){
	LOG()<<__FUNCTION__<<" begins"<<endl;
    const char opts[]="d:";
    char ch;
    char dir[1024]; dir[0]=0;
    while ((ch=getopt(argc,argv,"d:")) !=-1) {
        switch (ch) {
            case 'd':
                strcpy(dir,optarg);
                break;
            default:
                break;
        }
    }

    solver.loadAll();
    
	LOG()<<__FUNCTION__<<" ends"<<endl;
	return 0;
}
