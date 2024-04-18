// 66070503408 Khem Ingkapat
#include <iostream>
#include <map>
#include <queue>
#include <stack>
#include <vector>

using namespace std;

int main() {
    int edge;
    cin >> edge;

    vector<vector<int>> adjacency_list(10);
    map<int, bool> dfs_visited;
    map<int, bool> bfs_visited;

    for (int i = 0; i < edge; i++) {
        int from, to;
        cin >> from >> to;

        dfs_visited[from] = false;
        dfs_visited[to] = false;

        bfs_visited[from] = false;
        bfs_visited[to] = false;

        adjacency_list[from].push_back(to);
        adjacency_list[to].push_back(from);
    }
    int start;
    cin >> start;

    stack<int> s;
    s.push(start);
    dfs_visited[start] = true;
    cout << start << " ";

    while (!s.empty()) {
        int node = s.top();
        int i = 0;
        while (true) {
            if (!dfs_visited[adjacency_list[node][i]]) {
                dfs_visited[adjacency_list[node][i]] = true;
                node = adjacency_list[node][i];
                s.push(node);
                cout << node << " ";
                i = 0;
            } else {
                i++;
            }
            if (i >= adjacency_list[node].size()) {
                break;
            }
        }
        s.pop();
    }
    cout << endl;

    queue<int> q;
    q.push(start);
    bfs_visited[start] = true;
    while (!q.empty()) {
        int node = q.front();
        q.pop();
        cout << node << " ";
        for (int num : adjacency_list[node]) {
            if (!bfs_visited[num]) {
                q.push(num);
                bfs_visited[num] = true;
            }
        }
    }
    cout << endl;

    return 0;
}
