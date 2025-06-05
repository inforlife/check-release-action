# Check Release
GitHub Action to check if all the conditions defined in the software quality plan for a milestone to be released are met.

The action can be used as follows:

```
- name: Run checks
  id: run-checks
  uses: inforlife/check-release-action@1.0.0
  env:
    GITHUB_REPOSITORY: ${{ github.repository }}
    GITHUB_MILESTONE: ${{ github.event.client_payload.milestone }}
    GITHUB_ACCESS_TOKEN: ${{ secrets.ACCESS_TOKEN }}
```

The `GITHUB_ACCESS_TOKEN` must be the `repo` scope.
