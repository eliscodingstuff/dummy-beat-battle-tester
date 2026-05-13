def UserPrefs():
    return {
        "name": "BBAC2",
        "version": "1.0",
        "description": "A solution to a competitive programming problem.",
        "author": "ChatGPT",
        "license": "MIT"
    }

def main():
    n = int(input())
    a = list(map(int, input().split()))
    b = list(map(int, input().split()))
    a.sort()
    b.sort()
    ans = 0
    for i in range(n):
        ans += abs(a[i] - b[i])
    print(ans)