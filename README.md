# Jenkins + SFDX

This project contains trivial metadata for the purpose of showing examples of different options for deployments using Jenkins and sfdx.

There are multiple Jenkinsfiles included in this repo to showcase some of the different types of deployments made possible with sfdx.

#### What is a Jenkinsfile?

A Jenkinsfile contains a script that is executed to perform the CI "job". In a Salesforce deployment context, this might include actions such as checking out your project from source control, creating a scratch org, deploying metadata, running unit tests, etc.

The Jenkinsfile can be dropped directly into the Jenkins job in the Jenkins UI, or it can be checked out of a repo. In this case I opted to commit the Jenkinsfile(s) to this
repo and have Jenkins grab the latest version as a first step. This setup has the added benefit of keeping the job configuration very simple and prevents Jenkins from owning your CI scripts.

There are two main examples in this repo, unpackaged and packaged deployments using unlocked packaging (2nd Generation Packaging):

**Jenkinsfile_Unpackaged_Metadata**
Description of Steps

**Jenkinsfile_Packaged_Metadata**
Description of Steps

#### Jenkins Hosting

Jenkins needs to be hosted somewhere. For this example I chose Digital Ocean on the lowest pricing tier ($5/mo), but many hosting options exist (eg AWS, Bitnami, Cloudbees).  The steps used to get Jenkins running on DO are as follows:

1. 
