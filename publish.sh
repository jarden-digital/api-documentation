#!/usr/bin/env bash
aws-vault jar-prod -- aws s3 rm s3://developer.jarden.io --recursive
bundle exec middleman build --clean
aws-vault jar-prod -- aws s3 sync build s3://developer.jarden.io --acl public-read --cache-control "public, max-age=86400"
