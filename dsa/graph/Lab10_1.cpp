// 66070503408 Khem Ingkapat
#include <iostream>
#include <vector>

using namespace std;

int main () {
    int n;
    cin >> n;

    vector<vector<int>> adj_mat(n,vector<int>(n,-1));

    for(int i = 0;i<n;i++){
        for(int j = 0;j<n;j++){
            cin >> adj_mat[i][j];
        }
    }

    for(int i = 0;i<n;i++){
        for(int j = 0;j<n;j++){
            for(int k =0;k<n;k++){
                int indirect = adj_mat[i][k] + adj_mat[k][j];
                if(adj_mat[i][j] > indirect){
                    adj_mat[i][j] = indirect;
                }
            }
        }
    }

    for(int i = 0;i<n;i++){
        for(int j = 0;j<n;j++){
            cout << adj_mat[i][j] << " ";
        }
        cout << endl;
    }

    
    return 0;
}
