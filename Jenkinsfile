pipeline {
    agent {
        label 'master'
    }
    parameters {
        choice (name: 'AwsCredentialId', choices: ['AWS-D1', 'AWS-DR-Deploy', 'AWS-PROD-Deploy'], description: 'Choose AWS ENV Where you Creating this AMI')
    }
    stages {
        stage('Prepare Environment') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '*/master']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'tools']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'e12b4da2-d040-482c-bfeb-6d770514be03', url: 'http://gerrit.div1-vnext.systems/automation/jenkins/tools']]])
                sh label: 'Prepare Environment Variables', script: '''#!/bin/bash
                    case $AwsCredentialId in
                        AWS-DEV-*)
                            cat - > aws.env <<EOF
export S3URL=s3://mail-maps/ami/${BUILD_TAG}/fs.tgz
export S3REGION=ap-northeast-1
export BUILDAMI_SECURITYGROUPS='sg-0db129a90e91155ae'
export BUILDAMI_SUBNET='subnet-08ae7d69afad57367'
export BUILDAMI_PROFILE='DEV-D1'
EOF
                            ;;
                        AWS-DR-*)
                            cat - > aws.env <<EOF
export S3URL=s3://porters-repository-dr/ami/${BUILD_TAG}/fs.tgz
export S3REGION=ap-northeast-1
export BUILDAMI_SECURITYGROUPS='sg-02bff8e739125897b'
export BUILDAMI_SUBNET='subnet-0622ae1df1b3d0b56'
export BUILDAMI_PROFILE='DR-Deploy'
EOF
                            ;;
                        AWS-PROD-*)
                        cat - > aws.env <<EOF
export S3URL=s3://porters-repository/ami/${BUILD_TAG}/fs.tgz
export S3REGION=ap-northeast-1
export BUILDAMI_SECURITYGROUPS='sg-e9b9f58c'
export BUILDAMI_SUBNET='subnet-b4fd03dc'
export BUILDAMI_PROFILE='porters-default-role'
EOF
                            ;;
                    esac
'''
                stash includes: 'tools/build/build-ami.sh,tools/build/compile-create-ami-userdata.sh', name: 'tools'
                stash includes: 'aws.env', name: 'aws-env'
            }
        }

        stage('Prepare AMI') {
            steps {
                checkout([$class: 'GitSCM', branches: [[name: '${Branch}']], doGenerateSubmoduleConfigurations: false, extensions: [[$class: 'RelativeTargetDirectory', relativeTargetDir: 'src']], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'GerritHRBC', name:'origin', refspec:'+refs/heads/*:refs/remotes/origin/* +refs/tags/*:refs/tags/* ${Refspec}', url: 'http://gerrit.ps.porters.local/hrbc/ami/base']]])

                unstash name: 'tools'
                unstash name: 'aws-env'

                sh label:'prepare script', script: '''#!/bin/bash
                    source aws.env
                    env -uS3URL bash tools/build/compile-create-ami-userdata.sh src/ out
                    cp src/ami.env out
                '''

                stash includes: 'out/**', name: 'ami'
            }
        }
        stage('Build AMI') {
            steps {
                withCredentials([[$class: 'AmazonWebServicesCredentialsBinding', accessKeyVariable: 'AWS_ACCESS_KEY_ID', credentialsId: params.AwsCredentialId, secretKeyVariable: 'AWS_SECRET_ACCESS_KEY']]) {
                    unstash 'name': 'tools'
                    unstash 'name': 'aws-env'
                    unstash 'name': 'ami'
                    sh label: 'Init AWS Client', script: '''#!/bin/bash
                        mkdir -p ~/.aws
                        cat - > ~/.aws/config <<EOF
[default]
region = ap-northeast-1
EOF
                    '''
                    sh label: 'Create AMI', script: '''#!/bin/bash
                        source out/ami.env
                        source out/vars.env
                        source aws.env

                        if [ -f out/fs.tgz ]; then
                            export BUILDAMI_FSTGZ=out/fs.tgz
                            export BUILDAMI_S3URL=$FSS3URL
                            export BUILDAMI_S3REGION=$S3REGION
                        fi

                        env BUILDAMI_TYPE='t2.nano' \
                            BUILDAMI_TIMEOUT_INSTANCE=600 \
                            BUILDAMI_OUTPUT=ami.env \
                            BUILDAMI_BASEAMI=$BASE \
                            bash tools/build/build-ami.sh out/userdata.gz $NAME $VERSION
'''
                }
                archiveArtifacts 'out/ami.env'
            }
        }
    }
}
