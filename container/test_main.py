import os

import aws_cdk as cdk
import pytest
from aws_cdk import assertions
from main import AthenaStack


@pytest.fixture
def template():
    unittest_app = cdk.App(context={"env": "tst"})
    unittest_stack = AthenaStack(unittest_app, "unit_test_stack")

    unittest_template = assertions.Template.from_stack(unittest_stack)
    return unittest_template


def test_s3_bucket(template):
    template.resource_count_is("AWS::S3::Bucket", 1)


def test_glue_database(template):
    template.resource_count_is("AWS::Glue::Database", 1)


def test_glue_crawler(template):
    template.resource_count_is("AWS::Glue::Crawler", 1)


def test_iam_role(template):
    template.resource_count_is("AWS::IAM::Role", 1)


def test_iam_policy(template):
    template.resource_count_is("AWS::IAM::Policy", 1)


def test_iam_managed_policy(template):
    template.resource_count_is("AWS::IAM::ManagedPolicy", 1)


def test_glue_database(template):
    template.resource_count_is("AWS::Glue::Database", 1)


def test_glue_crawler(template):
    template.resource_count_is("AWS::Glue::Crawler", 1)
