# Using SFDX with Jenkins

The steps in this readme roughly follow the [Salesforce DX Developer guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ci_jenkins_config_env.htm) and attempt to fill in the gaps in order to set up CI on a new project. 

The sfdx project contains trivial metadata for the purpose of showing deployment examples using Jenkins and sfdx.

_You likely will not need the steps related to hosting Jenkins but they are included here for completeness._

## 1. Salesforce DevHub Org Setup

Jenkins will be using JWT to authenticate into the DevHub so there are a few initial tasks to do in the org.

1. Create a JWT-based connected app in the desired DevHub org. Check out [these steps](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_connected_app.htm) for the relevant connected app settings. During this process, create [private key and certificate](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_key_and_cert.htm) and upload the certificate to the connected app. Later we'll upload the private key into the Jenkins credentials interface.
    - In the connected app's Oauth Policies, set Permitted Users to `Admin approved users are pre-authorized`

2. Create an integration user in the DevHub. This will be the user Jenkins uses to perform build tasks. Make sure that the user has a profile that can access the connected app.

## 2. Getting a Jenkins Server Running (w/Digital Ocean)

_Skip this section if you already have a Jenkins server._

This section contains notes related to setting up a Jenkins using Digital Ocean (DO) as the hosting provider.  Note that many other hosting options exist (eg AWS, Bitnami, Cloudbees), but DO provided a fast path to getting Jenkins online (cost: 1 month free trial, then $5/month on lowest tier).

Notes from setup (this should only take a few minutes):

1. Create a DO account if you don't have one already
2. Create a droplet for Jenkins Distribution through the marketplace. Go to https://marketplace.digitalocean.com/apps/onjection-jenkins and select "Create Onjection Jenkins Droplet".
3. After the droplet is created, open the console for the next few steps (use the web-based console or SSH using the IP on the droplet page `ssh root@DROPLET_IP`)
    - In the console, you should see prompts to reset the default root password, and the jenkins user password.
    - Start the jenkins process using  
    `systemctl start jenkins`
    - Next, run these commands to install [Salesforce CLI](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_install_cli.htm) on the jenkins server:<br/>
        `wget https://developer.salesforce.com/media/salesforce-cli/sfdx-linux-amd64.tar.xz`<br/>
        `mkdir sfdx`  
        `tar xJf sfdx-linux-amd64.tar.xz -C sfdx --strip-components 1`  
        `./sfdx/install`  
    - Jenkins needs to checkout code from this repo, so create a Github user for Jenkins and setup an [SSH key](https://help.github.com/en/enterprise/2.15/user/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent) in the console:
        
        Run `ssh-keygen -t rsa -b 4096 -C "jenkins-user-email@example.com"` to generate the key
        (leave file name empty and don't set a password when prompted)  
        Run `cat .ssh/id_rsa.pub` to see the new key and add it to the Jenkins github user's SSH keys  
        Run `cat .ssh/id_rsa` to see the private key and copy/save it for later

## 3. Configure Jenkins Settings

Login to the Jenkin's UI (_which is now running on http://<PUBLIC-IP-OF-DROPLET>:8080 if you were following the previous steps_).

In **Manage Jenkins > Manage Plugins** update any old plugins and select restart when finished

In **Credentials > System > Global Credentials > Add Credentials**
- Create a **Secret File** credential, and select the private key from the connected app created earlier. Note/Copy the ID populated after you save.
- Also create a **SSH username and private key** credential, and upload the private key that was generated for the github account (should be found in .ssh/id_rsa). Also I named this `jenkinskey` but you can call it anything.

In **Manage Jenkins > Configure System > Global Properties** set the following Name/Value pairs:
- CONNECTED_APP_CONSUMER_KEY_DH: _Connected App Client Id_
- HUB_ORG_DH: _Your integration user's username from the DevHub org_
- JWT_CRED_ID_DH: _Credential Id created in previous step_
- SFDC_HOST_DH: _Instance URL of your devhub... eg https://login.salesforce.com_
- SFDX_AUTOUPDATE_DISABLE: true

In **Manage Jenkins > Global Tool Configuration** add a "Custom Tool" called `toolbelt` that references or installs the Salesforce CLI. This step allows us to reference `sfdx` from our CI scripts. 

The config should look like this:

![Alt text](docs/tool.png?raw=true "Tool config")

_The screenshot shows how you can ensure that the sfdx dependency is installed every time the job is run using the **Install Automatically** checkbox. If you don't install automatically you can reference the sfdx tool if you already installed in one of the previous steps._

## 4. Create a Jenkins Job

After bringing Jenkins online, the next step is to create a job that calls DX to perform our build tasks.

Create a new Jenkins Item and select `Pipeline` as the base project. Select Configure in the new job, then scroll down to the Pipeline section. 

Select `Pipeline script from SCM` and use your repository URL and select the credentials created earlier (jenkinskey). It should look something like this:

![Alt text](docs/pipelineconfig.png?raw=true "Pipeline config")

Set the **Script Path** to one of the Jenkinsfile filenames in this repo, here the job is pointed at `Jenkinsfile_unpackaged`.

The Jenkinsfile can be dropped directly into the Jenkins job in the Jenkins UI OR it can be checked out of a repo each time the job runs.  Here I've opted to commit the Jenkinsfile(s) to the repo and have Jenkins grab the latest version as a first step. This has the benefit of keeping the job configuration very simple and prevents Jenkins from "owning" your CI scripts.

## Jenkinsfile(s) Examples

There are multiple Jenkinsfiles included in this repo to showcase some of the different types of deployments made possible with sfdx. At a high-level, a Jenkinsfile contains a script that is executed to perform build automation tasks. In a Salesforce deployment context, this might include actions such as checking out your project from source control, creating a scratch org, deploying metadata, running unit tests, etc.

There are two main examples in this repo, unpackaged and packaged deployments (Unlocked/2nd Generation Packaging):

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
- Creates a Package Version
- Creates a Scratch Org
- Installs the Package into the Scratch Org
- Runs Apex tests
- Deletes the Scratch Org
- Logs current scratch org limits to the console

### Resources

- https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ci_jenkins_config_env.htm