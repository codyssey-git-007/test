# 03. Git 충돌의 원리와 해결

> **학습 목표:** 3-way Merge와 충돌 마커를 이해하고, 충돌을 직접 재현·해결·기록할 수 있다.
>
> **필요한 시점:** 미션의 의도적 충돌 실습(팀 전체 2건, 그중 지정된 비자명 충돌 1건 이상).

## 1. Merge와 충돌의 의미

두 브랜치의 변경 내용을 합치는 것을 **Merge(병합)**라고 한다. Git은 가능한 경우 자동으로 변경을 결합한다. 하지만 서로 다른 변경을 안전하게 결합할 수 없으면 **Merge Conflict(병합 충돌)**를 보고한다.

**같은 파일을 수정했다는 사실만으로 반드시 충돌하지는 않는다.** 서로 떨어진 변경 영역은 자동 병합될 수 있다. 반대로 서로 같은 영역을 다르게 수정하면 충돌이 발생할 수 있다.

## 2. 3-way Merge의 핵심

```text
             B  (main: "Python")
            /
A (공통 조상: "미정")
            \
             C  (feature: "JavaScript")
```

Git은 보통 다음 세 가지를 비교한다.

1. **공통 조상 A:** 두 브랜치가 갈라지기 전 파일 내용
2. **현재 브랜치 B:** 공통 조상에서 무엇이 바뀌었는가?
3. **병합 대상 C:** 공통 조상에서 무엇이 바뀌었는가?

한쪽만 수정한 영역은 반영하기 쉽다. 동일 영역을 양쪽이 다르게 수정했다면 어느 변경이 의도에 맞는지 Git은 알 수 없으므로 사람이 결정해야 한다.

## 3. 충돌 마커 읽기

`feature/b`에서 `main`을 병합한다고 가정하면 충돌 파일에 다음과 같은 부분이 생길 수 있다.

```text
<<<<<<< HEAD
language: JavaScript
=======
language: Python
>>>>>>> main
```

- `<<<<<<< HEAD` 아래: **현재 체크아웃한 브랜치**의 내용
- `=======`: 두 내용을 구분하는 경계
- `>>>>>>> main` 위: **병합하려는 브랜치**의 내용

해결할 때는 둘 중 하나를 선택하거나, 양쪽을 조합하거나, 요구사항에 따라 새 문장을 작성한다. **마커 세 줄까지 모두 제거**해야 한다.

주의: 위 해석은 `git merge`의 일반적인 예시다. `rebase` 중에는 ours/theirs가 직관과 달라질 수 있으므로 현재 작업 맥락을 확인해야 한다.

## 4. 자명·비자명 충돌은 어떻게 구분하는가?

이 두 용어는 **Git이 공식적으로 제공하는 분류 이름이 아니다.** 이번 미션의 채점 기준을 우선 적용해야 한다.

| 상황 | Git에서 가능한 결과 | 미션 관점 |
|---|---|---|
| 서로 다른 파일 수정 | 대개 자동 병합 | 충돌 실습 아님 |
| 같은 파일의 충분히 떨어진 줄 수정 | 자동 병합 가능 | 충돌 실습이 아닐 수 있음 |
| **같은 hunk(동일·인접 변경 영역)를 서로 다르게 수정** | 충돌 가능 | **비자명 충돌 인정 조건 ①** |
| **한쪽은 파일 이동·이름 변경 또는 삭제, 다른 쪽은 내용 수정** | 충돌 또는 통합 문제 가능 | **비자명 충돌 인정 조건 ②** |
| 자동 병합은 됐지만 실행 결과가 잘못됨 | Git이 충돌로 표시하지 않을 수 있음 | 별도의 의미적 충돌 검토 필요 |

따라서 '어렵게 해결해야만 비자명 충돌'이라고 판단하면 안 된다. **미션의 명시적인 파일 변경 조건이 우선**이다.

## 5. 로컬에서 재현하는 최소 실습

이 실습은 팀 저장소를 변경하지 않는 **별도 임시 저장소**에서 한다. 로컬 Git 사용자 정보가 없으면 먼저 `git config user.name`, `git config user.email`을 설정해야 커밋이 가능하다.

```bash
mkdir git-conflict-lab && cd git-conflict-lab
git init -b main

printf 'language: undecided\n' > config.txt
git add config.txt
git commit -m "docs: add initial config"

# 브랜치 A에서 한 줄 수정
git switch -c feature/a
printf 'language: Python\n' > config.txt
git add config.txt
git commit -m "docs: select Python"

# 공통 조상으로 돌아와 브랜치 B에서 같은 줄 수정
git switch main
git switch -c feature/b
printf 'language: JavaScript\n' > config.txt
git add config.txt
git commit -m "docs: select JavaScript"

# 같은 영역을 서로 다르게 수정했으므로 충돌 발생 예상
git merge feature/a
```

충돌 시 다음으로 확인한다.

```bash
git status
git diff -- config.txt
cat config.txt
```

양쪽 변경을 반영하기로 합의했다는 가정하에 파일을 해결한다.

```bash
printf 'language: Python and JavaScript\n' > config.txt
git add config.txt
git commit -m "merge: reconcile language choices"

git status
git log --oneline --graph --all
```

**검증:** `git status`에 병합 중 표시나 unmerged path가 없어야 하고, 결과 파일이 팀의 합의와 일치해야 한다. 해결 대신 병합을 취소하고 싶다면 `git merge --abort`를 고려한다.

## 6. 실제 팀 PR에서 발생하는 충돌 흐름

```text
A와 B가 둘 다 오래된 main에서 분기
         ↓
각자 같은 파일의 같은 영역 수정
         ↓
A의 PR이 먼저 main에 병합
         ↓
B는 자신의 feature 브랜치에서 최신 main을 병합
         ↓
충돌 해결 → 확인·커밋 → Push → B의 PR 병합
```

B의 브랜치에서 사용하는 대표 명령:

```bash
git switch feature/b
git fetch origin
git merge origin/main   # 충돌 시 이 브랜치에서 해결
git status
# 파일 수정 후
git add <충돌-파일>
git commit
git push
```

> 위 명령의 `<충돌-파일>`은 실제 파일 경로로 바꾼다. 해결할 파일이 여러 개라면 모두 처리한다. 이미 진행 중인 병합이 아니라면 `git commit`을 실행하기 전에 `git status`로 상태를 확인한다.

두 번째 충돌은 별도 파일을 대상으로 **수정/삭제(modify/delete)** 상황 등을 만들어 재현하면 좋다. 다른 브랜치가 파일을 삭제한 동안 현재 브랜치는 그 내용을 수정하도록 설정한다.

## 7. 기록은 무엇을 남겨야 하는가?

`docs/conflict-resolution.md`에 **팀 전체 최소 2건**을 아래 구조로 기록한다.

```md
### 충돌 사례 #1
- 참여자 / 브랜치 / 관련 Issue·PR:
- 충돌 유형: 동일 hunk 수정 또는 수정/삭제 등
- 공통 조상과 양측 변경 내용:
- 재현 명령 및 `git status` 결과:
- 충돌 마커 또는 Git의 충돌 메시지:
- 해결 원칙 / 실행 명령:
- 검증 결과 / 해결 커밋 링크:
- 주의점:
```

**확인 질문:** 같은 파일을 수정해도 충돌이 없는 이유는? 3-way Merge에서 공통 조상이 중요한 이유는? '비자명' 판단 기준은 Git의 공식 명령인가? (아니요)

## 참고 자료

- [Git Reference — git-merge](https://git-scm.com/docs/git-merge)
- [Git Reference — merge strategies](https://git-scm.com/docs/merge-strategies)
