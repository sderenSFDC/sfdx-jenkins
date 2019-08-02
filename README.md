# Jenkins + SFDX

This project contains trivial metadata for the purpose of showing deployment examples using Jenkins and sfdx.

#### Jenkins Hosting

This section contains notes related to setting up a Jenkins server.  For this example I chose Digital Ocean (DO) to host Jenkins. Many hosting options exist (eg AWS, Bitnami, Cloudbees) but I wanted something with minimal server-side setup.  DO provided a fast path to getting Jenkins online in just a few minutes (cost: 1 month free trial, then $5/month on lowest tier).

Notes from Digital Ocean setup:

1. Create a DO account

#### Using a Jenkinsfile

After bringing Jenkins online, the next step is to create a job. In contrast with ANT There are multiple Jenkinsfiles included in this repo to showcase some of the different types of deployments made possible with sfdx.

At a high-level, a Jenkinsfile contains a script that is executed to perform build automation tasks. In a Salesforce deployment context, this might include actions such as checking out your project from source control, creating a scratch org, deploying metadata, running unit tests, etc.

The Jenkinsfile can be dropped directly into the Jenkins job in the Jenkins UI, or it can be checked out of a repo each time the job runs.  In this case I opted to commit the Jenkinsfile(s) to the
repo and have Jenkins grab the latest version as a first step. This configuration has the added benefit of keeping the job configuration very simple and prevents Jenkins from owning your CI scripts.

There are two main examples in this repo, unpackaged and packaged deployments using unlocked packaging (2nd Generation Packaging):

**Jenkinsfile_unpackaged**
This script performs the following steps:
- Ensures that the sfdx tool is avaialble
- Cleans the workspace to start from a clean slate
- Performs Git checkout of this repo
- Logs into the DevHub using JWT authentication
- Creates a Scratch Org
- Pushes all metadata from force-app to the Scratch Org
- Runs Apex tests
- Deletes the Scratch Org
- Logs current scratch org limits to the console

**Jenkinsfile_packaged**
This script performs the following steps:
- Ensures that the sfdx tool is avaialble
- Cleans the workspace to start from a clean slate
- Performs Git checkout of this repo
- Logs into the DevHub using JWT authentication
- Creates a Scratch Org
- Pushes all metadata from force-app to the Scratch Org
- Runs Apex tests
- Deletes the Scratch Org
- Logs current scratch org limits to the console

