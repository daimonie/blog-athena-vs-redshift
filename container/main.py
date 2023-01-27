#!/usr/bin/env python3
import json
import os

import aws_cdk as cdk
from aws_cdk import aws_athena as athena
from aws_cdk import aws_batch_alpha as batch
from aws_cdk import aws_ec2 as ec2
from aws_cdk import aws_ecr as ecr
from aws_cdk import aws_ecs as ecs
from aws_cdk import aws_events as events
from aws_cdk import aws_events_targets as targets
from aws_cdk import aws_glue as glue
from aws_cdk import aws_iam as iam
from aws_cdk import aws_s3 as s3
from aws_cdk import aws_ssm as ssm


class AthenaStack(cdk.Stack):
    def __init__(self, scope, construct_id: str, **kwargs) -> None:
        super().__init__(
            scope,
            construct_id,
            description="Stack containing related resources for setting up Athena.",
            tags={"application": "woco-nettoets"},
            **kwargs,
        )
        aws_account_id = os.environ["AWS_DEFAULT_ACCOUNT"]
        self.prefix = "athena-vs-redshift"
        self.setup_resources()

    def setup_resources(self):
        self.setup_glue_policy()
        self.setup_glue_role()
        self.setup_glue_crawler()

    def setup_glue_policy(self, env):
        policy_name = f"{self.prefix}-glue-policy"
        self.s3_managed_policy = iam.ManagedPolicy(
            self,
            policy_name,
            managed_policy_name=policy_name,
            statements=[
                iam.PolicyStatement(
                    actions=["s3:*", "s3-object-lambda:*", "lambda:*", "iam:PassRole"],
                    resources=["*"],
                    conditions={
                        "StringEquals": {"aws:RequestedRegion": "eu-central-1"},
                    },
                )
            ],
        )

    def _setup_role_for_glue(self, env):
        role_name = f"{self.prefix}-glue-role"
        self.glue_role = iam.Role(
            self,
            role_name,
            description="Role for Athena can connect with the"
            "AWS environment including S3",
            assumed_by=iam.CompositePrincipal(
                iam.ServicePrincipal("athena.amazonaws.com"),
                iam.ServicePrincipal("glue.amazonaws.com"),
            ),
            managed_policies=[
                iam.ManagedPolicy.from_aws_managed_policy_name(
                    "service-role/AWSGlueServiceRole"
                ),
                self.s3_managed_policy,
            ],
            role_name=role_name,
        )

    def _setup_glue_tables(self, env):

        database_name = f"{self.prefix}-glue-db"
        crawler_name = f"{self.prefix}-glue-crawler"
        bucket_name = f"{self.prefix}-query-results"

        # I made this bucket by hand and uploaded the data directory
        s3_url = "s3://athena-vs-redshift/output/"

        glue_database = glue.CfnDatabase(
            self,
            database_name,
            catalog_id=self.aws_account_id,
            database_input=glue.CfnDatabase.DatabaseInputProperty(
                name=database_name,
            ),
        )

        cancel_duration = cdk.Duration.days(3)
        transition_duration = cdk.Duration.days(30)
        expiry_duration = cdk.Duration.days(90)

        athena_bucket = s3.Bucket(
            self,
            bucket_name,
            bucket_name=bucket_name,
            block_public_access=s3.BlockPublicAccess.BLOCK_ALL,
            encryption=s3.BucketEncryption.S3_MANAGED,
            versioned=True,
            removal_policy=cdk.RemovalPolicy.DESTROY,
            lifecycle_rules=[
                s3.LifecycleRule(
                    abort_incomplete_multipart_upload_after=cancel_duration,
                    expiration=expiry_duration,
                    transitions=[
                        s3.Transition(
                            storage_class=s3.StorageClass.INFREQUENT_ACCESS,
                            transition_after=transition_duration,
                        )
                    ],
                )
            ],
        )

        crawler = glue.CfnCrawler(
            self,
            crawler_name,
            role=self.glue_role.role_arn,
            database_name=database_name,
            name=crawler_name,
            configuration=json.dumps(
                {
                    "Version": 1.0,
                    "Grouping": {"TableGroupingPolicy": "CombineCompatibleSchemas"},
                }
            ),
            description=f"Automatically crawls {s3_url} and adds outputs to a glue table.",
            table_prefix="crawler_",
            targets={"s3Targets": [{"path": s3_url, "exclusions": [".*input.*"]}]},
            # classifiers=["parquet"],
            schema_change_policy=glue.CfnCrawler.SchemaChangePolicyProperty(
                delete_behavior="DEPRECATE_IN_DATABASE",
                update_behavior="UPDATE_IN_DATABASE",
            ),
            # Every sunday at 0:00
            schedule=glue.CfnCrawler.ScheduleProperty(
                schedule_expression="cron(0 0 * * ? *)"
            ),
        )


if __name__ == "__main__":
    app = cdk.App()
    AthenaStack(app, "redshift-vs-athena-stack")

    app.synth()
