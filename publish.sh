#!/usr/bin/env bash
aws-vault exec jarden-prod -- aws s3 rm s3://docs.jarden.io --recursive
bundle exec middleman build --clean
aws-vault exec jarden-prod -- aws s3 sync build s3://docs.jarden.io --acl public-read --cache-control "public, max-age=86400"
