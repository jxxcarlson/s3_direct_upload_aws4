# S3DirectUpload

## Intro

This is a start on adapting Andrew Kappen's S3DirectUpload to
Amazon's *AWS Signature Version 4* signing scheme.

Kappen's package is a Pre-signed S3 upload helper for client-side multipart POSTs in Elixir,
with code at https://github.com/akappen/s3_direct_upload

   - See: [Browser Uploads to S3 using HTML POST Forms](https://aws.amazon.com/articles/1434/)


## The task

The first task is to implement the signing of a policy document.  The requirements
are outlined in Amazon's documentation:

*(1)*   http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-authentication-HTTPPOST.html

*(2)*   http://docs.aws.amazon.com/AmazonS3/latest/API/sigv4-post-example.html

We use CargoSense's code for signing policies.  In (2), an example is given so that
that the signing method can be tested.  This test is implemented in `test/auth_test.exs`
At the moment it is not working, as you will see when you runtime
`mix test`.  *This needs to be fixed.*


## The plan

Make sure the authentication process works, then integration this into a fork of
Kappen's S3DirectUpload to produces a version that works with *AWS Signature Version 4*
