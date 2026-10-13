# 01. Git의 기본 구조와 동작 원리

> **학습 목표:** Git이 변경 사항을 어디에 보관하는지, Commit·Branch·HEAD가 어떤 관계인지 설명하고 브랜치를 직접 생성·확인할 수 있다.
>
> **필요한 시점:** 미션 시작 전. 뒤의 GitHub Flow, 충돌, `reset` 실습을 이해하기 위한 선행 개념이다.

## 1. Git은 무엇을 관리하는가?

Git은 파일의 **상태를 커밋(Commit)이라는 단위로 기록**하고, 커밋 사이의 부모 관계를 관리하는 분산 버전 관리 시스템이다. 단순히 파일마다 수정 내역을 일렬로 보관하는 방식이 아니다.

각 커밋은 대표적으로 다음 정보를 가진다.

- 특정 시점의 프로젝트 파일 상태를 가리키는 정보(트리)
- 부모 커밋의 식별자
- 작성자·커밋터·시간·메시지 등의 메타데이터

Git 객체는 내용 기반의 해시로 식별된다. 따라서 기존 커밋의 내용이나 메타데이터를 수정하는 것은 같은 커밋을 덮어쓰는 일이 아니라 **새 커밋을 생성하는 일**이다.

## 2. 작업 내용이 커밋이 되는 과정

```text
Working Tree          Index (Staging Area)      Local Repository
실제 편집 중인 파일  ──git add──────────────▶  다음 커밋 후보
                                                   │
                                                   └─git commit──▶ 저장된 커밋
```

- **Working Tree:** 에디터에서 편집하는 실제 파일. 아직 저장소 이력으로 기록되지 않은 수정이 있을 수 있다.
- **Index(스테이징 영역):** 다음 커밋에 포함할 파일 내용을 미리 선정한 상태. 단순 파일 목록이 아니라 선택된 내용의 상태를 보관한다.
- **Local Repository:** `.git` 내부의 객체와 참조로 관리되는 로컬 이력.

```bash
printf '첫 번째 내용\n' > note.md
git status              # Working Tree의 변경 확인
git add note.md         # Index에 등록
git diff --cached       # 커밋 예정 내용 확인
git commit -m "docs: add note"
git log --oneline -3
```

`git status`는 Working Tree와 Index의 상태를 함께 보여주므로 실습 중 가장 먼저 확인할 명령이다.

## 3. Commit, Branch, HEAD

```text
A ── B ── C   ← main
       \
        D ── E ← feature/profile
               ↑
             현재 HEAD가 가리키는 브랜치의 끝
```

- **Commit:** 프로젝트의 기록 단위. A~E는 각기 다른 커밋이다.
- **Branch:** 특정 커밋을 가리키는 *이동 가능한 참조*. 파일의 별도 사본 자체가 아니다.
- **HEAD:** 현재 체크아웃한 위치를 가리키는 특수 참조. 보통 브랜치 이름을 가리키며, 브랜치는 최신 커밋을 가리킨다.

`feature/profile`에서 새 커밋 F를 만들면 브랜치 참조만 E에서 F로 이동한다. `main`은 계속 C를 가리킨다.

```bash
git switch main
git switch -c feature/profile  # 현재 커밋에서 브랜치 생성 + 이동
git branch --show-current    # 현재 브랜치
git log --oneline --graph --all --decorate
```

**상대 커밋 참조:**

| 표현 | 의미 |
|---|---|
| `HEAD` | 현재 체크아웃한 커밋 |
| `HEAD~1` 또는 `HEAD^` | HEAD 커밋의 첫 번째 부모 |
| `HEAD~2` | 첫 번째 부모를 두 번 따라간 커밋 |

주의: `HEAD~1`은 단순히 시각적으로 '바로 이전에 만든 커밋'이 아니라 **부모 관계**를 따라간다. Merge Commit은 부모가 둘 이상일 수 있다.

## 4. 로컬 브랜치와 원격 브랜치

GitHub의 저장소는 로컬 저장소와 별개다.

```text
내 컴퓨터:  feature/profile ──git push──▶ GitHub: feature/profile
내 컴퓨터:  origin/main     ◀──git fetch─ GitHub: main
```

`origin`은 일반적으로 GitHub 원격 저장소의 이름이고, `origin/main`은 마지막으로 확인한 원격 `main`의 상태를 나타내는 **원격 추적 참조**다.

- `git fetch origin`: 원격 이력과 원격 추적 참조를 갱신한다. 현재 작업 브랜치를 자동 병합하지 않는다.
- `git pull`: 일반적으로 `fetch` 후 통합(merge 또는 rebase)을 수행한다. 설정에 따라 방식이 달라진다.
- `git push -u origin feature/profile`: 해당 로컬 브랜치를 원격에 게시하고 upstream 연결을 설정한다.

## 5. 미션에서의 최소 실습

> 기존 팀 저장소의 `main`이 아닌 **개인 feature 브랜치**에서 실습한다.

```bash
git switch main
git pull --ff-only origin main
git switch -c feature/12-profile

mkdir -p team
printf '# 팀원 소개\n' > team/my-profile.md
git add team/my-profile.md
git commit -m "docs: add team profile"

git log --oneline --graph --all --decorate
git push -u origin feature/12-profile
```

**확인 질문**

1. `git add` 전과 후에 `git status`는 어떻게 달라지는가?
2. 새 커밋을 만들 때 이동하는 것은 `main`인가, 현재 `feature` 브랜치인가?
3. `git fetch`만 실행하면 현재 파일이 GitHub의 최신 상태로 즉시 바뀌는가? (아니요)

## 참고 자료

- [Pro Git — Git Basics](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository)
- [Git Reference — git-commit](https://git-scm.com/docs/git-commit)
- [Git Reference — gitrevisions](https://git-scm.com/docs/gitrevisions)
