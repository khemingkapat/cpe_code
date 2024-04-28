// 66070503408 Khem Ingkapat
#include <iostream>
#include <map>
#include <vector>

using namespace std;

int main() {
    int n, e;

    cin >> n >> e;
    map<int, int> parents;
    vector<vector<int>> edges(e, vector<int>(3));

    for (int i = 0; i < e; i++) {
        int from, to, weight;
        cin >> from >> to >> weight;
        edges[i][0] = from;
        edges[i][1] = to;
        edges[i][2] = weight;

        parents[from] = from;
        parents[to] = to;
    }

    for (int i = 1; i < e; i++) {
        vector<int> temp = edges[i];
        int j = i - 1;
        while (j >= 0 && temp[2] < edges[j][2]) {
            edges[j + 1] = edges[j];
            j--;
        }
        edges[j + 1] = temp;
    }

    int mst = 0;
    for (int i = 0; i < e; i++) {

        int end_from = edges[i][0], end_to = edges[i][1];

        do {
            end_from = parents[end_from];
        } while (end_from != parents[end_from]);

        do {
            end_to = parents[end_to];
        } while (end_to != parents[end_to]);

        if (end_from != end_to) {
            mst += edges[i][2];

            int end = edges[i][0];
            while (end != parents[end]) {
                end = parents[end];
            }
            parents[end] = edges[i][1];
        }
    }

    cout << mst << endl;

    return 0;
}
