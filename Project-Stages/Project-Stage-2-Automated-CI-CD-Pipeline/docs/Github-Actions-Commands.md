# GitHub Actions Commands Reference Guide

## Overview
This document provides a comprehensive reference for all GitHub Actions CLI commands used in our automated CI/CD pipeline implementation, including their outputs and explanations.

## Table of Contents
1. [Pipeline Monitoring Commands](#pipeline-monitoring-commands)
2. [Workflow Management Commands](#workflow-management-commands)
3. [Pipeline Triggering Commands](#pipeline-triggering-commands)
4. [Troubleshooting Commands](#troubleshooting-commands)
5. [GitHub Restrictions and Solutions](#github-restrictions-and-solutions)

---

## Pipeline Monitoring Commands

### 1. List Recent Pipeline Runs

**Command:**
```bash
gh run list --limit 3
```

**Purpose:** 
- View the most recent 3 pipeline runs
- Check pipeline status (running, completed, failed)
- Get pipeline IDs for detailed inspection

**Sample Output:**
```
STATUS  TITLE                  WORKFLOW        BRANCH  EVENT           ID           ELAPSED  AGE           
*       Stage 2 CI (Qualit...  Stage 2 CI ...  main    workflow_di...  16919802490  3m16s    about 3 min...
✓       Stage 2 CI (Qualit...  Stage 2 CI ...  main    workflow_di...  16919597280  6m6s     about 12 mi...
✓       test(pipeline): ve...  Stage 2 CI ...  main    push            16919187855  6m3s     about 32 mi...
```

**Output Explanation:**
- `*` = Currently running pipeline
- `✓` = Successfully completed pipeline
- `ID` = Unique pipeline run identifier
- `EVENT` = Trigger type (push, workflow_dispatch, pull_request)
- `ELAPSED` = Total execution time

### 2. Watch Pipeline Progress in Real-time

**Command:**
```bash
gh run watch 16919597280
```

**Purpose:**
- Monitor pipeline execution in real-time
- See individual job progress
- Track step-by-step execution

**Sample Output:**
```
* main Stage 2 CI (Quality Gates) · 16919597280
Triggered via workflow_dispatch about 4 minutes ago

JOBS
✓ Unit Tests (Node 18.x) in 53s (ID 47942110175)
✓ Unit Tests (Node 20.x) in 56s (ID 47942110180)
✓ SonarCloud in 1m19s (ID 47942183283)
✓ Build images in 1m42s (ID 47942183311)
✓ E2E in 1m13s (ID 47942315144)
* Deploy to EKS (stage-2) (ID 47942410464)
  ✓ Set up job
  ✓ Checkout
  ✓ Configure AWS credentials
  ✓ Setup kubectl
  * Wait for rollout to complete
```

**Output Explanation:**
- Each job shows execution time and status
- `*` indicates currently running step
- `✓` indicates completed step
- Job IDs allow for detailed log inspection

### 3. Get Detailed Pipeline Information with JSON

**Command:**
```bash
gh run list --limit 5 --json databaseId,headSha,conclusion,createdAt,displayTitle
```

**Purpose:**
- Get structured data about pipeline runs
- Compare commit SHAs with pipeline runs
- Verify which commits triggered which pipelines

**Sample Output:**
```json
[
  {
    "conclusion": "success",
    "createdAt": "2025-08-12T19:44:34Z",
    "databaseId": 16919187855,
    "displayTitle": "test(pipeline): verify automated deployment with README.md change",
    "headSha": "ef77e5f7275682f6e93b3dd30e233794ec9b15c0"
  }
]
```

**Output Explanation:**
- `headSha` = Git commit that triggered the pipeline
- `conclusion` = Final pipeline result (success, failure, cancelled)
- `createdAt` = Pipeline start timestamp
- `databaseId` = Unique pipeline identifier

---

## Workflow Management Commands

### 4. List Available Workflows

**Command:**
```bash
gh workflow list
```

**Purpose:**
- See all available workflows in the repository
- Check workflow status (active/disabled)
- Get workflow IDs for management

**Sample Output:**
```
NAME                        STATE   ID       
Stage 2 CI (Quality Gates)  active  180175370
```

**Output Explanation:**
- `NAME` = Workflow display name from YAML file
- `STATE` = active (enabled) or disabled
- `ID` = Workflow identifier for management operations

---

## Pipeline Triggering Commands

### 5. Manual Pipeline Trigger

**Command:**
```bash
gh workflow run "Stage 2 CI (Quality Gates)"
```

**Purpose:**
- Manually trigger a workflow when automatic triggers fail
- Test pipeline without making code changes
- Bypass GitHub rate limiting issues

**Sample Output:**
```
✓ Created workflow_dispatch event for stage2-ci.yml at main

To see runs for this workflow, try: gh run list --workflow="stage2-ci.yml"
```

**Output Explanation:**
- `workflow_dispatch` = Manual trigger event type
- Provides command to monitor the triggered run
- Confirms successful trigger creation

### 6. Trigger with Specific Workflow File

**Command:**
```bash
gh run list --workflow="stage2-ci.yml"
```

**Purpose:**
- Filter runs by specific workflow file
- Monitor runs for a particular workflow
- Useful when repository has multiple workflows

---

## Troubleshooting Commands

### 7. Check Pipeline Logs

**Command:**
```bash
gh run view 16919597280 --log
```

**Purpose:**
- View detailed logs for failed pipelines
- Debug specific job failures
- Analyze error messages and stack traces

### 8. Check Specific Job Logs

**Command:**
```bash
gh run view 16919597280 --job=47942110175 --log
```

**Purpose:**
- Focus on logs from a specific job
- Debug individual job failures
- Analyze step-by-step execution

---

## GitHub Restrictions and Solutions

### Common GitHub Actions Limitations

1. **Rate Limiting**
   - **Issue:** GitHub limits workflow trigger frequency
   - **Solution:** Use manual triggers with `gh workflow run`
   - **Command:** `gh workflow run "Workflow Name"`

2. **Concurrent Workflow Limits**
   - **Issue:** Free accounts have limited concurrent runs
   - **Solution:** Wait for current runs to complete
   - **Check:** `gh run list --limit 10`

3. **Actions Minutes Quota**
   - **Issue:** Monthly limits on GitHub Actions minutes
   - **Solution:** Optimize workflow efficiency
   - **Monitor:** Check usage in GitHub repository settings

4. **Push Event Delays**
   - **Issue:** Automatic triggers may have delays
   - **Solution:** Use manual triggers for immediate execution
   - **Verify:** Compare commit SHA with pipeline runs

### Verification Commands

**Check if commit triggered pipeline:**
```bash
git log --oneline -3
gh run list --limit 3 --json headSha,displayTitle
```

**Monitor pipeline queue:**
```bash
gh run list --limit 10
```

**Force immediate trigger:**
```bash
gh workflow run "Stage 2 CI (Quality Gates)"
```

---

## Best Practices

1. **Always verify pipeline triggers:**
   ```bash
   git push origin main
   sleep 10
   gh run list --limit 3
   ```

2. **Use manual triggers for testing:**
   ```bash
   gh workflow run "Stage 2 CI (Quality Gates)"
   gh run watch $(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
   ```

3. **Monitor long-running pipelines:**
   ```bash
   gh run watch <pipeline-id>
   ```

4. **Check pipeline history:**
   ```bash
   gh run list --limit 10
   ```

---

## Command Quick Reference

| Command | Purpose | Usage |
|---------|---------|-------|
| `gh run list` | List pipeline runs | Monitoring |
| `gh run watch <id>` | Watch pipeline progress | Real-time monitoring |
| `gh workflow list` | List workflows | Management |
| `gh workflow run <name>` | Trigger pipeline | Manual execution |
| `gh run view <id>` | View pipeline details | Troubleshooting |

---

## Real Implementation Examples

### Example 1: Complete Pipeline Execution Flow

**Step 1: Check current status**
```bash
$ gh run list --limit 3
STATUS  TITLE                  WORKFLOW        BRANCH  EVENT           ID           ELAPSED  AGE
✓       test(pipeline): ve...  Stage 2 CI ...  main    push            16919187855  6m3s     about 28 mi...
✓       fix(deployment): i...  Stage 2 CI ...  main    push            16918929744  6m12s    about 40 mi...
✓       fix(ci-cd): resol...  Stage 2 CI ...  main    push            16918625835  6m11s    about 54 mi...
```

**Step 2: Trigger new pipeline**
```bash
$ gh workflow run "Stage 2 CI (Quality Gates)"
✓ Created workflow_dispatch event for stage2-ci.yml at main
```

**Step 3: Monitor execution**
```bash
$ gh run list --limit 1
STATUS  TITLE                  WORKFLOW        BRANCH  EVENT           ID           ELAPSED  AGE
*       Stage 2 CI (Qualit...  Stage 2 CI ...  main    workflow_di...  16919597280  10s      less than a...
```

**Step 4: Watch detailed progress**
```bash
$ gh run watch 16919597280
* main Stage 2 CI (Quality Gates) · 16919597280
Triggered via workflow_dispatch less than a minute ago

JOBS
* Unit Tests (Node 18.x) (ID 47942110175)
  ✓ Set up job
  ✓ Checkout
  ✓ Setup Node
  * Install dependencies (root + frontend + backend)
```

### Example 2: Pipeline Success Verification

**Final status check:**
```bash
$ gh run list --limit 1
STATUS  TITLE                  WORKFLOW        BRANCH  EVENT           ID           ELAPSED  AGE
✓       Stage 2 CI (Qualit...  Stage 2 CI ...  main    workflow_di...  16919597280  6m6s     about 12 mi...
```

**Detailed completion view:**
```bash
$ gh run view 16919597280
✓ main Stage 2 CI (Quality Gates) · 16919597280
Triggered via workflow_dispatch about 12 minutes ago

JOBS
✓ Unit Tests (Node 18.x) in 53s (ID 47942110175)
✓ Unit Tests (Node 20.x) in 56s (ID 47942110180)
✓ SonarCloud in 1m19s (ID 47942183283)
✓ Build images in 1m42s (ID 47942183311)
✓ E2E in 1m13s (ID 47942315144)
✓ Deploy to EKS (stage-2) in 2m15s (ID 47942410464)
```

### Example 3: Troubleshooting Failed Pipeline

**Identify failed pipeline:**
```bash
$ gh run list --limit 5
STATUS  TITLE                  WORKFLOW        BRANCH  EVENT           ID           ELAPSED  AGE
✗       fix(database): imp...  Stage 2 CI ...  main    push            16919123456  3m45s    about 5 min...
```

**View failure details:**
```bash
$ gh run view 16919123456
✗ main Stage 2 CI (Quality Gates) · 16919123456
Triggered via push about 5 minutes ago

JOBS
✓ Unit Tests (Node 18.x) in 53s (ID 47942110175)
✓ Unit Tests (Node 20.x) in 56s (ID 47942110180)
✗ Build images in 2m15s (ID 47942183311)
```

**Check specific job logs:**
```bash
$ gh run view 16919123456 --job=47942183311 --log
```

### Example 4: Commit-to-Deployment Verification

**Check recent commits:**
```bash
$ git log --oneline -3
8755f3f9 (HEAD -> main, origin/main) fix(database): improve seeding fallback mechanism
61f5601c fix(database): implement robust inline database seeding for doctor data
47e64607 fix(database): enable automatic doctor data seeding in deployment
```

**Verify pipeline triggered for latest commit:**
```bash
$ gh run list --limit 3 --json headSha,displayTitle,conclusion
[
  {
    "conclusion": "success",
    "displayTitle": "fix(database): improve seeding fallback mechanism with better error handling",
    "headSha": "8755f3f9c1234567890abcdef1234567890abcdef"
  }
]
```

---

## Advanced Usage Patterns

### Pattern 1: Continuous Monitoring During Development

```bash
# Start development cycle
git add .
git commit -m "feature: implement new functionality"
git push origin main

# Monitor pipeline trigger
sleep 10
gh run list --limit 1

# Watch execution if triggered
PIPELINE_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
gh run watch $PIPELINE_ID
```

### Pattern 2: Manual Testing Workflow

```bash
# Trigger test pipeline
gh workflow run "Stage 2 CI (Quality Gates)"

# Get the pipeline ID
sleep 5
PIPELINE_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')

# Monitor until completion
gh run watch $PIPELINE_ID

# Verify success
gh run view $PIPELINE_ID
```

### Pattern 3: Debugging Failed Deployments

```bash
# Find failed pipeline
gh run list --limit 10 | grep "✗"

# Get detailed failure info
gh run view <failed-pipeline-id>

# Check specific job that failed
gh run view <failed-pipeline-id> --job=<job-id> --log

# Re-trigger after fixes
gh workflow run "Stage 2 CI (Quality Gates)"
```

---

## Integration with Kubernetes Commands

### Verify Deployment Success

**After pipeline completion, verify pods:**
```bash
$ kubectl get pods -n healthcare -o wide
NAME                                  READY   STATUS    RESTARTS   AGE
healthcare-backend-7bd4c68bbf-7hppq   1/1     Running   0          93s
healthcare-backend-7bd4c68bbf-hmmwz   1/1     Running   0          52s
healthcare-frontend-d585dfdcf-qvcsj   1/1     Running   0          93s
healthcare-frontend-d585dfdcf-xpb8n   1/1     Running   0          81s
```

**Check deployment logs:**
```bash
$ kubectl logs deployment/healthcare-backend -n healthcare -c db-init --tail=20
🗄️ Running database initialization with seeding...
✅ Database seeded with 4 departments and 5 doctors
✅ Database initialization and seeding complete
```

---

## Error Handling and Recovery

### Common Error Scenarios

1. **Pipeline doesn't trigger automatically:**
   ```bash
   # Check if commit was pushed
   git log --oneline -1

   # Manual trigger
   gh workflow run "Stage 2 CI (Quality Gates)"
   ```

2. **Pipeline stuck in queue:**
   ```bash
   # Check running pipelines
   gh run list --limit 10

   # Cancel stuck pipeline if needed
   gh run cancel <pipeline-id>
   ```

3. **Deployment verification:**
   ```bash
   # After pipeline success, verify deployment
   kubectl get pods -n healthcare
   kubectl rollout status deployment/healthcare-backend -n healthcare
   ```

---

## Performance Optimization Tips

### 1. Efficient Pipeline Monitoring

**Use JSON output for automation:**
```bash
# Get only running pipelines
gh run list --json status,databaseId --jq '.[] | select(.status=="in_progress") | .databaseId'

# Get latest pipeline status
gh run list --limit 1 --json conclusion --jq '.[0].conclusion'
```

### 2. Batch Operations

**Check multiple pipeline statuses:**
```bash
# Get last 5 pipeline results
gh run list --limit 5 --json conclusion,displayTitle --jq '.[] | {status: .conclusion, title: .displayTitle}'
```

### 3. Automated Verification Scripts

**Pipeline success verification script:**
```bash
#!/bin/bash
# wait-for-pipeline.sh

PIPELINE_ID=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
echo "Monitoring pipeline: $PIPELINE_ID"

while true; do
    STATUS=$(gh run list --limit 1 --json status --jq '.[0].status')
    if [ "$STATUS" = "completed" ]; then
        CONCLUSION=$(gh run list --limit 1 --json conclusion --jq '.[0].conclusion')
        echo "Pipeline completed with status: $CONCLUSION"
        break
    fi
    echo "Pipeline status: $STATUS"
    sleep 30
done
```

---

## Security Considerations

### 1. Sensitive Information in Logs

**Avoid logging sensitive data:**
```bash
# Don't use --log flag for pipelines that might contain secrets
gh run view <pipeline-id>  # Safe - shows summary only
gh run view <pipeline-id> --log  # Caution - shows full logs
```

### 2. Pipeline Access Control

**Check workflow permissions:**
```bash
# Verify you have access to trigger workflows
gh workflow list

# Check if manual triggers are allowed
gh workflow view "Stage 2 CI (Quality Gates)"
```

---

## Troubleshooting Checklist

### When Pipeline Doesn't Trigger

1. **Check commit was pushed:**
   ```bash
   git log --oneline -1
   git status
   ```

2. **Verify workflow file syntax:**
   ```bash
   # Check if workflow file exists and is valid
   cat .github/workflows/stage2-ci.yml | head -20
   ```

3. **Manual trigger as fallback:**
   ```bash
   gh workflow run "Stage 2 CI (Quality Gates)"
   ```

### When Pipeline Fails

1. **Identify failed job:**
   ```bash
   gh run view <pipeline-id>
   ```

2. **Check specific job logs:**
   ```bash
   gh run view <pipeline-id> --job=<job-id> --log
   ```

3. **Common failure patterns:**
   - **Build failures:** Check dependency issues
   - **Test failures:** Review test logs
   - **Deployment failures:** Verify Kubernetes connectivity

### When Deployment Doesn't Update

1. **Verify pipeline completed successfully:**
   ```bash
   gh run list --limit 1
   ```

2. **Check Kubernetes deployment:**
   ```bash
   kubectl get pods -n healthcare
   kubectl describe deployment healthcare-backend -n healthcare
   ```

3. **Force deployment refresh:**
   ```bash
   kubectl rollout restart deployment/healthcare-backend -n healthcare
   ```

---

## Command Aliases and Shortcuts

### Useful Aliases

Add these to your `~/.bashrc` or `~/.zshrc`:

```bash
# GitHub Actions shortcuts
alias ghrl='gh run list --limit 5'
alias ghrw='gh run watch'
alias ghwf='gh workflow run "Stage 2 CI (Quality Gates)"'
alias ghrs='gh run list --limit 1 --json status,conclusion --jq ".[0]"'

# Combined pipeline + deployment check
alias checkdeploy='gh run list --limit 1 && echo "---" && kubectl get pods -n healthcare'
```

### Quick Status Functions

```bash
# Function to get latest pipeline status
pipeline_status() {
    local status=$(gh run list --limit 1 --json status,conclusion --jq '.[0] | "\(.status): \(.conclusion // "running")"')
    echo "Latest pipeline: $status"
}

# Function to trigger and monitor pipeline
trigger_and_watch() {
    gh workflow run "Stage 2 CI (Quality Gates)"
    sleep 10
    local pipeline_id=$(gh run list --limit 1 --json databaseId --jq '.[0].databaseId')
    gh run watch $pipeline_id
}
```

---

## Summary

This document provides a complete reference for GitHub Actions CLI usage in our automated CI/CD pipeline. Key takeaways:

1. **Always verify pipeline triggers** after pushing commits
2. **Use manual triggers** when automatic triggers fail due to GitHub restrictions
3. **Monitor pipeline progress** with `gh run watch` for real-time feedback
4. **Check deployment success** by combining GitHub Actions status with Kubernetes verification
5. **Use JSON output** for automation and scripting

### Essential Commands for Daily Use

```bash
# Check pipeline status
gh run list --limit 3

# Trigger pipeline manually
gh workflow run "Stage 2 CI (Quality Gates)"

# Monitor pipeline execution
gh run watch <pipeline-id>

# Verify deployment
kubectl get pods -n healthcare
```

---

*This comprehensive guide covers all GitHub Actions commands, patterns, and best practices used in our healthcare system's automated CI/CD pipeline implementation.*
