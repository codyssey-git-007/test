# 02. GitHub Flow와 협업 기능

> **학습 목표:** `Issue → Branch → Commit → PR → Review → Merge`를 직접 수행하고, GitHub의 보호 규칙과 자동화 파일을 구분할 수 있다.
>
> **필요한 시점:** 팀 저장소를 만들고 협업 규칙을 정할 때.

## 1. GitHub Flow란?

**GitHub Flow**는 안정적인 기본 브랜치(`main`)에서 작업 브랜치를 분기하고, 변경을 Push해 Pull Request(PR)로 검토한 뒤 `main`에 병합하는 협업 방식이다.

```text
Issue 등록
   ↓
main에서 feature 브랜치 생성
   ↓
작업 → Commit → Push
   ↓
PR 생성 (base: main / compare: feature)
   ↓
Review → 수정·답글 → Approve
   ↓
Merge → Issue 종료 확인
```

왜 필요한가? 모든 팀원이 `main`을 직접 수정하면 미완성 작업이나 오류가 공동 작업 기준에 섞일 수 있다. 작업 브랜치는 **변경을 격리**하고, PR은 **병합 전 검증 지점**을 만든다.

**미션 규칙:** `main`은 팀 기준으로 정상 상태를 유지하고, 실제 작업은 `feature/*`에서 수행한다. 변경은 PR로만 병합한다.

## 2. Issue, PR, Review의 차이

| 항목 | 답하는 질문 | 남는 기록 |
|---|---|---|
| **Issue** | 무엇을, 왜 해야 하는가? | 요구사항·담당자·논의 |
| **PR** | 어떤 변경을 `main`에 포함할 것인가? | 커밋·변경 파일·검증 방법 |
| **Review** | 변경이 적절하고 안전한가? | 라인별 의견·승인·수정 요청 |

### 예시: Issue #12 — 팀원 소개 작성

1. GitHub의 **Issues → New issue**에서 작업을 등록한다.
2. `feature/12-profile` 브랜치를 만들고 커밋·Push한다.
3. **Pull requests → New pull request**로 PR을 만든다.
4. PR 본문에 다음을 적는다.

```md
## What
- team/my-profile.md 추가

## Why
- 팀 소개 결과물의 개인별 기여 기준 충족

## How
- README에서 파일 링크를 열어 확인

Closes #12
```

5. 다른 팀원이 **Files changed**에서 특정 파일·라인에 실질적인 코멘트를 남긴다.
6. 작성자가 답글이나 수정 커밋으로 대응한다. **Approve 1명 이상**을 받고 병합한다.

`Closes #12`는 PR이 **저장소의 기본 브랜치**를 대상으로 할 때 Issue 연동에 활용되고, PR이 병합되면 해당 Issue를 자동으로 닫을 수 있다. PR을 열기만 해서는 닫히지 않는다.

### Review 상태

- **Comment:** 의견 작성. 이것만으로 승인된 것은 아니다.
- **Approve:** 변경을 승인함.
- **Request changes:** 수정 요청. 병합을 제한할 수 있다.

**미션 기준:** 각 PR에 구체적인 리뷰 의견 1개 이상과 작성자·리뷰어의 상호작용이 있어야 한다. 팀원마다 *본인 외 PR 리뷰 2건*, *본인 PR 병합 2건*, *리뷰 반영 1회*를 충족한다.

## 3. Branch Protection Rule이란?

Git의 브랜치가 단순한 참조라면, **Branch Protection은 GitHub 서버에서 브랜치에 적용하는 변경 제한 정책**이다.

저장소의 **Settings → Branches → Add branch protection rule**에서 `main`을 대상으로 설정할 수 있다. 조직·UI에 따라 **Settings → Rules → Rulesets**로도 구성할 수 있다.

| 설정 | 미션 적용 |
|---|---|
| Require a pull request before merging | **필수:** `main` 변경을 PR 경유로 제한 |
| Required number of approvals: 1 | **필수:** 승인 1개 이상 필요 |
| Block force pushes / Allow force pushes 비활성화 | **권장:** 강제 Push 방지 |
| Require conversation resolution | **권장:** 미해결 리뷰 대화 확인 |
| Require review from Code Owners | **선택:** CODEOWNERS 기반 승인 강제 |

**주의:** 관리자·우회 권한이 보호 규칙을 우회할 수 있다. 전원에게 동일한 제한이 필요하면 bypass 설정도 확인한다. 또한 GitHub Free의 브랜치 보호는 공개 저장소에서 지원되며, 비공개 저장소의 지원 여부는 요금제에 따라 다르다.

## 4. `.github/` 폴더의 주요 파일

`.github/`는 GitHub가 특별한 의미로 해석하는 설정 파일을 보관하는 관례적 경로다. Git 자체의 필수 디렉터리가 아니다.

| 경로 | 역할 | 미션 |
|---|---|---|
| `.github/CODEOWNERS` | 변경된 파일의 담당 리뷰어 자동 요청 | 보너스 |
| `.github/PULL_REQUEST_TEMPLATE.md` | PR 생성 시 기본 본문 제공 | 편의 기능 |
| `.github/ISSUE_TEMPLATE/` | Issue 작성 양식 제공 | 편의 기능 |
| `.github/workflows/` | GitHub Actions 워크플로 정의 | 이번 범위 밖 |

### CODEOWNERS의 정확한 역할

```text
# .github/CODEOWNERS (GitHub 사용자명은 실제 계정으로 교체)
*        @alice
/docs/   @bob
*.py     @carol
```

- PR의 **대상(base) 브랜치**에 유효한 `CODEOWNERS`가 있으면 해당 변경에 대한 담당자의 리뷰가 자동 요청될 수 있다.
- 파일은 `.github/`, 저장소 루트, `docs/` 중 둘 수 있으며 GitHub는 그 순서로 하나를 선택한다.
- 패턴이 여러 번 일치하면 **마지막 일치 패턴**이 적용된다. 담당자는 저장소에 쓰기 권한이 있어야 한다.
- **리뷰어 자동 요청과 승인 필수는 다르다.** 승인 강제는 보호 규칙의 `Require review from Code Owners`로 별도 설정한다.

### PR Template 예시

```md
<!-- .github/PULL_REQUEST_TEMPLATE.md -->
## What
-

## Why
-

## How
-

## Related Issue
Closes #
```

미션에서 `What/Why/How`, `Closes #번호`를 빠뜨리지 않게 해 주므로 CODEOWNERS보다 먼저 도입해도 좋다.

## 5. 팀이 실제로 정해야 할 최소 규칙

`docs/CONTRIBUTING.md`에 다음을 짧게 합의하여 기록한다.

1. 브랜치: `feature/<issue-number>-<topic>`
2. 커밋: `docs: add profile`, `fix: correct link`처럼 변경 대상 명시
3. PR: `What / Why / How / Closes #번호` 필수
4. 리뷰: 구체적 근거를 든 코멘트 + 작성자의 답글·수정
5. 충돌: 작업 브랜치에서 해결한 뒤 `docs/conflict-resolution.md`에 기록

**확인 질문:** Issue와 PR의 차이는? Comment와 Approve의 차이는? CODEOWNERS만 만들면 승인이 강제되는가? (아니요)

## 참고 자료

- [GitHub Docs — GitHub Flow](https://docs.github.com/en/get-started/using-github/github-flow)
- [GitHub Docs — Linking a pull request to an issue](https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/linking-a-pull-request-to-an-issue)
- [GitHub Docs — About protected branches](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-protected-branches/about-protected-branches)
- [GitHub Docs — About code owners](https://docs.github.com/en/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)
